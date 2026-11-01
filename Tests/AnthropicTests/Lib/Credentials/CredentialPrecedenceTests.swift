import Foundation
import Testing
@testable import Anthropic

// Port of `TestAsyncAnthropicCredentials`, the client-level tests of `TestAsyncAccessTokenProvider`,
// `TestCredentialPrecedence`, `TestTypedCredentialErrors`, `TestDanglingActiveConfig`,
// `TestAccessTokenReprMasking` and `TestEmptySecretFieldFalsiness` from
// `tests/lib/test_credentials.py`. The `client_cls` parametrizations (`Anthropic` /
// `AsyncAnthropic`) collapse to the one Swift client.

let CREDENTIAL_ARGUMENTS = ["api_key", "auth_token", "credentials", "config", "profile"]

/// A provider class, so tests can check identity and closing.
final class TrackedProvider: AccessTokenProvider, @unchecked Sendable {
    private let lock = NSLock()
    private var _closed = 0
    var closed: Int { lock.withLock { _closed } }
    func callAsFunction(forceRefresh: Bool) async throws -> AccessToken { AccessToken(token: "t") }
    func close() async { lock.withLock { _closed += 1 } }
}

@Suite struct AsyncAnthropicCredentialsTests {
    let tmp: TempDir
    let router = MockRouter()
    var env: [String: String] { cleanEnv(tmp) }
    init() throws { tmp = try TempDir() }

    @Test func authorizedUserRefreshFlow() async throws {
        let dir = tmp.defaultConfigDir
        try writeProfile(dir, "default", ["type": "authorized_user", "client_id": "cid"],
                         ["access_token": "old", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "rt"])
        router.post(CREDS_TOKEN_URL, json: ["access_token": "refreshed", "expires_in": 3600])
        router.mockMessages()
        let file = try CredentialsFile(transport: router, environment: CredentialEnvironment(env))
        try await sendMessage(try credsClient(router, env, credentials: file))
        #expect(router.messageCalls.first?.headers["Authorization"] == "Bearer refreshed")
    }

    /// Concurrent requests sharing a cache cause at most one provider call.
    @Test func concurrentRequestsSingleFlight() async throws {
        router.mockMessages()
        let calls = Counter()
        let client = try credsClient(router, env, credentials: provider { _ in
            let n = calls.next() + 1
            try await Task.sleep(nanoseconds: 50_000_000)  // widen the window for racing requests
            return AccessToken(token: "tok-\(n)")
        })
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<8 { group.addTask { try await sendMessage(client) } }
            try await group.waitForAll()
        }
        #expect(calls.count == 1)
    }

    @Test func status401InvalidatesAndRetriesOnce() async throws {
        router.post("\(CREDS_BASE_URL)/v1/messages", status: 401, json: ["error": "unauthorized"])
        let calls = Counter()
        let client = try credsClient(router, env, credentials: provider { _ in AccessToken(token: "tok-\(calls.next() + 1)") }, maxRetries: 2)
        await expectThrows(AuthenticationError.self) { try await sendMessage(client) }
        #expect(calls.count == 2)
    }

    @Test func closeCascadesToCredentials() async throws {
        let tracked = TrackedProvider()
        let client = try credsClient(router, env, credentials: tracked)
        await client.close()
        #expect(tracked.closed == 1)
    }

    /// Closing a client whose provider created its own transport closes that transport; a
    /// provider built by the client borrows the client's transport and leaves it to the client.
    @Test func closeReleasesProviderOwnedTransportOnly() async throws {
        let creds = workloadCredentials()  // owns a transport it creates lazily
        let client = try credsClient(router, env, credentials: creds)
        await client.close()
        #expect(router.isClosed)

        let jwt = tmp.child("jwt")
        try writeText(jwt, "j")
        let other = MockRouter()
        let configured = try credsClient(other, env, config: [
            "organization_id": "o", "authentication": ["type": "oidc_federation", "federation_rule_id": "f", "identity_token": ["source": "file", "path": .string(jwt.path)]],
        ])
        let provider = try #require(configured.credentials as? InMemoryConfig)
        #expect(provider.transport.get() as AnyObject === other)
        await configured.close()
        #expect(other.isClosed)  // closed once, by the client
    }

    @Test func maxRetriesZeroHonoredOn401() async throws {
        router.post("\(CREDS_BASE_URL)/v1/messages", status: 401, json: ["error": "unauthorized"])
        let client = try credsClient(router, env, credentials: StaticToken("t"), maxRetries: 0)
        await expectThrows(AuthenticationError.self) { try await sendMessage(client) }
        #expect(router.calls.count == 1)
    }

    // -- from TestAsyncAccessTokenProvider

    @Test func providerIsCalledOnceAndCached() async throws {
        router.mockMessages()
        let calls = Counter()
        let client = try credsClient(router, env, credentials: provider { _ in
            _ = calls.next()
            return AccessToken(token: "tok", expiresAt: Int(Date().timeIntervalSince1970) + 3600)
        })
        try await sendMessage(client)
        try await sendMessage(client)
        #expect(calls.count == 1)
        #expect(router.bearerTokens() == ["tok", "tok"])
    }

    @Test func status401InvalidatesAndRetriesWithNewToken() async throws {
        router.post("\(CREDS_BASE_URL)/v1/messages", sequence: [(401, ["error": "unauthorized"]), (200, messageResponseJSON)])
        let calls = Counter()
        try await sendMessage(try credsClient(router, env, credentials: provider { _ in AccessToken(token: "tok-\(calls.next() + 1)") }))
        #expect(router.bearerTokens() == ["tok-1", "tok-2"])
    }

    @Test func status401RetryPassesForceRefresh() async throws {
        router.post("\(CREDS_BASE_URL)/v1/messages", sequence: [(401, ["error": "unauthorized"]), (200, messageResponseJSON), (200, messageResponseJSON)])
        let forces = Box<[Bool]>([])
        let client = try credsClient(router, env, credentials: provider { force in
            var n = 0
            forces.mutate {
                $0.append(force)
                n = $0.count
            }
            return AccessToken(token: "tok-\(n)")
        })
        try await sendMessage(client)
        try await sendMessage(client)
        #expect(forces.value == [false, true])
        #expect(router.bearerTokens() == ["tok-1", "tok-2", "tok-2"])
    }

    /// Requests don't queue behind each other for a token that can't be shared.
    @Test func zeroExpiryTokensAreFetchedConcurrently() async throws {
        router.mockMessages()
        let calls = Counter()
        let arrived = Counter()
        let client = try credsClient(router, env, credentials: provider { _ in
            let n = calls.next() + 1
            if n > 1 {
                _ = arrived.next()
                guard await eventually({ arrived.count >= 3 }) else { throw AnthropicError("requests queued behind each other") }
            }
            return AccessToken(token: "tok-\(n)", expiresAt: 0)
        })
        try await sendMessage(client)
        try await withDeadline {
            try await withThrowingTaskGroup(of: Void.self) { group in
                for _ in 0..<3 { group.addTask { try await sendMessage(client) } }
                try await group.waitForAll()
            }
        }
        #expect(router.bearerTokens().sorted() == ["tok-1", "tok-2", "tok-3", "tok-4"])
    }

    @Test func closeAwaitsAnAsyncClose() async throws {
        let closed = Box<[String]>([])
        let p = AccessTokenProviderFunction(onClose: { closed.mutate { $0.append("close") } }) { _ in AccessToken(token: "t") }
        await (try credsClient(router, env, credentials: p)).close()
        #expect(closed.value == ["close"])
    }
}

@Suite struct CredentialPrecedenceTests {
    let tmp: TempDir
    let router = MockRouter()
    var dir: URL { tmp.defaultConfigDir }

    init() throws {
        tmp = try TempDir()
        try writeProfile(dir, "dev", ["type": "external"], ["access_token": "from-profile"])
        try writeProfile(dir, "in-memory", ["type": "external"], ["access_token": "from-config"])
    }

    func env(_ extra: [String: String] = [:]) -> [String: String] { cleanEnv(tmp, extra) }

    func client(_ name: String? = nil, env extra: [String: String] = [:], baseURL: String? = nil,
                defaultHeaders: Headers? = nil, profile: String? = nil, config: [String: JSONValue]? = nil) throws -> Anthropic
    {
        let a = argument(name)
        return try credsClient(router, env(extra), apiKey: a.apiKey, authToken: a.authToken, credentials: a.credentials,
                               config: a.config ?? config, profile: a.profile ?? profile, baseURL: baseURL, defaultHeaders: defaultHeaders)
    }

    struct Argument {
        var apiKey: String?
        var authToken: String?
        var credentials: (any AccessTokenProvider)?
        var config: [String: JSONValue]?
        var profile: String?
    }

    /// A value for each credential argument (the `credential_arguments` fixture). The one named `x`
    /// sends `Bearer from-x`.
    func argument(_ name: String?) -> Argument {
        switch name {
        case "api_key": return Argument(apiKey: "from-api_key")
        case "auth_token": return Argument(authToken: "from-auth_token")
        case "credentials": return Argument(credentials: StaticToken("from-credentials"))
        case "config":
            return Argument(config: [
                "authentication": ["type": "user_oauth", "credentials_path": .string(dir.appendingPathComponent("credentials").appendingPathComponent("in-memory.json").path)],
            ])
        case "profile": return Argument(profile: "dev")
        default: return Argument()
        }
    }

    func copy(_ c: Anthropic, _ name: String, baseURL: String? = nil) throws -> Anthropic {
        let a = argument(name)
        return try c.copy(apiKey: a.apiKey, authToken: a.authToken, credentials: a.credentials.map { .some($0) },
                          config: a.config, profile: a.profile, baseURL: baseURL)
    }

    /// Sends a message and returns its `Authorization` values (`_sent_authorization`).
    func sentAuthorization(_ c: Anthropic) async throws -> [String] {
        router.mockMessages()
        try await sendMessage(c)
        let request = try #require(router.calls.last)
        #expect(request.headers["X-Api-Key"] == nil)
        return request.headers.values("Authorization")
    }

    /// Builds a request and runs the auth hook on it (`_walk_sync_auth`).
    func walkAuth(_ c: Anthropic) async throws -> HTTPRequest {
        var request = try c.buildRequest(FinalRequestOptions(method: "get", url: "/foo"))
        try await c.authenticate(&request)
        return request
    }

    // -- step 1 beats step 2: explicit credentials beat env static

    @Test func explicitCredentialsBeatsEnvAPIKey() async throws {
        try await withCapturedLogs { logs in
            let c = try credsClient(router, env(["ANTHROPIC_API_KEY": "sk-from-env"]), credentials: StaticToken("bearer-from-creds"))
            #expect(c.apiKey == nil)
            #expect(c.authToken == nil)
            #expect(c.credentials != nil)
            let req = try await walkAuth(c)
            #expect(req.headers["X-Api-Key"] == nil)
            #expect(req.headers["Authorization"] == "Bearer bearer-from-creds")
            #expect(!logs.text.contains("takes precedence"))
        }
    }

    @Test func explicitCredentialsBeatsEnvAuthToken() async throws {
        try await withCapturedLogs { logs in
            let c = try credsClient(router, env(["ANTHROPIC_AUTH_TOKEN": "env-auth-token"]), credentials: StaticToken("bearer-from-creds"))
            #expect(c.authToken == nil)
            #expect(c.credentials != nil)
            #expect(try await walkAuth(c).headers["Authorization"] == "Bearer bearer-from-creds")
            #expect(!logs.text.contains("takes precedence"))
        }
    }

    @Test func explicitConfigBeatsEnvAPIKey() throws {
        let jwt = tmp.child("jwt")
        try writeText(jwt, "ext-jwt.ext-jwt.ext-jwt")
        let c = try client(env: ["ANTHROPIC_API_KEY": "sk-from-env"], config: [
            "organization_id": "org_x",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x", "identity_token": ["source": "file", "path": .string(jwt.path)]],
        ])
        #expect(c.apiKey == nil)
        #expect(c.credentials is InMemoryConfig)
    }

    @Test(arguments: CREDENTIAL_ARGUMENTS)
    func passedCredentialIgnoresTheEnvironment(name: String) async throws {
        try await withCapturedLogs { logs in
            let c = try client(name, env: ["ANTHROPIC_API_KEY": "env-key", "ANTHROPIC_AUTH_TOKEN": "env-token", "ANTHROPIC_PROFILE": "missing-profile"])
            #expect(try await sentAuthorization(c) == ["Bearer from-\(name)"])
            #expect(logs.warnings == [])
        }
    }

    // -- step 1 ∩ step 1: two explicit credential arguments

    static let pairs: [(String, String)] = {
        var out: [(String, String)] = []
        for (i, a) in CREDENTIAL_ARGUMENTS.enumerated() { for b in CREDENTIAL_ARGUMENTS[(i + 1)...] { out.append((a, b)) } }
        return out
    }()

    @Test(arguments: pairs.map { "\($0.0)+\($0.1)" })
    func twoPassedCredentialsRaise(names: String) async throws {
        let parts = names.split(separator: "+").map(String.init)
        var a = argument(parts[0])
        let b = argument(parts[1])
        a.apiKey = a.apiKey ?? b.apiKey
        a.authToken = a.authToken ?? b.authToken
        a.credentials = a.credentials ?? b.credentials
        a.config = a.config ?? b.config
        a.profile = a.profile ?? b.profile
        let message = "Pass at most one of `api_key=`, `auth_token=`, `credentials=`, `config=`, or `profile=`. Received `\(parts[0])=`, `\(parts[1])=`."

        let constructed = await expectThrows(ValueError.self) {
            _ = try credsClient(router, env(), apiKey: a.apiKey, authToken: a.authToken, credentials: a.credentials, config: a.config, profile: a.profile)
        }
        #expect(constructed?.message == message)

        let parent = try credsClient(router, env(), apiKey: "parent-key")
        let copied = await expectThrows(ValueError.self) {
            _ = try parent.copy(apiKey: a.apiKey, authToken: a.authToken, credentials: a.credentials.map { .some($0) }, config: a.config, profile: a.profile)
        }
        #expect(copied?.message == message)
    }

    // -- step 2 shadows steps 3-5: env static shadows auto-discovery

    @Test func envAPIKeyShadowsEnvFederationTrioWithWarning() async throws {
        let jwt = tmp.child("jwt")
        try writeText(jwt, "ext-jwt.ext-jwt.ext-jwt")
        try await withCapturedLogs { logs in
            let c = try client(env: [
                "ANTHROPIC_API_KEY": "sk-from-env", "ANTHROPIC_IDENTITY_TOKEN_FILE": jwt.path, "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc",
                "ANTHROPIC_ORGANIZATION_ID": "00000000-0000-0000-0000-000000000000",
            ])
            #expect(c.apiKey == "sk-from-env")
            #expect(c.credentials == nil)
            #expect(logs.warnings.contains { $0.contains("ANTHROPIC_API_KEY") && $0.contains("profile / federation") })
        }
    }

    @Test func envAPIKeyShadowsEnvProfileWithWarning() async throws {
        try await withCapturedLogs { logs in
            let c = try client(env: ["ANTHROPIC_API_KEY": "sk-from-env", "ANTHROPIC_PROFILE": "dev"])
            #expect(c.apiKey == "sk-from-env")
            #expect(c.credentials == nil)
            #expect(logs.warnings.contains { $0.contains("ANTHROPIC_API_KEY") && $0.contains("profile / federation") })
        }
    }

    @Test func envAPIKeyAloneDoesNotWarn() async throws {
        try await withCapturedLogs { logs in
            let c = try client(env: ["ANTHROPIC_API_KEY": "sk-from-env"])
            #expect(c.apiKey == "sk-from-env")
            #expect(!logs.text.contains("takes precedence"))
        }
    }

    // -- step 2: both static env vars are set

    @Test func envAPIKeyAndAuthTokenWarnOncePerProcess() async throws {
        try await withCapturedLogs { logs in
            let both = ["ANTHROPIC_API_KEY": "env-key", "ANTHROPIC_AUTH_TOKEN": "env-token"]
            let c = try client(env: both)
            #expect(logs.records.filter { $0.1 == BOTH_STATIC_ENV_VARS_WARNING }.map(\.0) == [.warning])
            #expect(try await sentAuthorization(c) == ["Bearer env-key"])
            _ = try client(env: both)
            _ = try client(env: both)
            #expect(logs.records.filter { $0.1 == BOTH_STATIC_ENV_VARS_WARNING }.count == 1)
        }
    }

    @Test(arguments: [
        ["ANTHROPIC_API_KEY": "env-key"], ["ANTHROPIC_AUTH_TOKEN": "env-token"],
        ["ANTHROPIC_API_KEY": "env-key", "ANTHROPIC_AUTH_TOKEN": ""], ["ANTHROPIC_API_KEY": "", "ANTHROPIC_AUTH_TOKEN": "env-token"],
    ])
    func oneStaticEnvVarDoesNotWarn(extra: [String: String]) async throws {
        try await withCapturedLogs { logs in
            _ = try client(env: extra)
            #expect(logs.warnings == [])
        }
    }

    // -- steps 2-5: the first environment source that is set is the only one used

    /// With the sources before `first` unset and every later one set, `first` is sent.
    @Test(arguments: 0..<5)
    func environmentOrder(first: Int) async throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "from-active-profile"])
        router.mockTokenExchange(CREDS_BASE_URL, "from-federation")
        let sources: [([String: String], String)] = [
            (["ANTHROPIC_API_KEY": "from-api-key"], "from-api-key"),
            (["ANTHROPIC_AUTH_TOKEN": "from-auth-token"], "from-auth-token"),
            (["ANTHROPIC_PROFILE": "dev"], "from-profile"),
            (["ANTHROPIC_IDENTITY_TOKEN": "ext-jwt", "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc", "ANTHROPIC_ORGANIZATION_ID": "org-uuid"], "from-federation"),
            ([:], "from-active-profile"),
        ]
        var extra: [String: String] = [:]
        for (e, _) in sources[first...] { extra.merge(e) { $1 } }
        let c = try client(env: extra)
        #expect(try await sentAuthorization(c) == ["Bearer \(sources[first].1)"])
        let held: [Any?] = [c.apiKey, c.authToken, c.credentials]
        #expect(held.compactMap { $0 }.count == 1)
    }

    // -- copy(): a passed credential replaces the parent's, none inherits it

    static let permutations: [String] = CREDENTIAL_ARGUMENTS.flatMap { a in CREDENTIAL_ARGUMENTS.filter { $0 != a }.map { "\(a)>\($0)" } }

    @Test(arguments: permutations)
    func copyCredentialReplacesTheParents(pair: String) async throws {
        let parts = pair.split(separator: ">").map(String.init)
        let copied = try copy(try client(parts[0]), parts[1])
        #expect(try await sentAuthorization(copied) == ["Bearer from-\(parts[1])"])
    }

    @Test(arguments: CREDENTIAL_ARGUMENTS)
    func copyInheritsTheParentsCredential(parent: String) async throws {
        let copied = try client(parent).copy()
        #expect(try await sentAuthorization(copied) == ["Bearer from-\(parent)"])
    }

    @Test func copyOfAClientResolvedFromBothEnvVars() async throws {
        let copied = try client(env: ["ANTHROPIC_API_KEY": "env-key", "ANTHROPIC_AUTH_TOKEN": "env-token"]).copy()
        #expect(try await sentAuthorization(copied) == ["Bearer env-key"])
    }

    final class SubclassedAnthropic: Anthropic, @unchecked Sendable {}

    @Test func copyCredentialsReplacesASubclassAPIKey() async throws {
        let parent = try SubclassedAnthropic(apiKey: "parent-key", transport: router, environment: env())
        let copied = try parent.copy(credentials: StaticToken("from-credentials"))
        #expect(try await sentAuthorization(copied) == ["Bearer from-credentials"])
    }

    // -- copy(): the host and headers a credential brings go where it goes

    /// Arguments for a credential that brings the host `parent.example` and the workspace
    /// `wrkspc_parent` (the `parent_arguments` fixture). The profile `other` brings `other.example`
    /// and `wrkspc_other`.
    func parentClient(_ kind: String, baseURL: String? = nil, env extra: [String: String] = [:], defaultHeaders: Headers? = nil) throws -> Anthropic {
        for name in ["parent", "other"] {
            try writeProfile(dir, name, ["type": "external", "base_url": .string("https://\(name).example"), "workspace_id": .string("wrkspc_\(name)")],
                             ["access_token": .string("from-\(name)")])
        }
        switch kind {
        case "config":
            return try client(env: extra, baseURL: baseURL, defaultHeaders: defaultHeaders, config: [
                "base_url": "https://parent.example", "workspace_id": "wrkspc_parent",
                "authentication": ["type": "user_oauth", "credentials_path": .string(dir.appendingPathComponent("credentials").appendingPathComponent("parent.json").path)],
            ])
        case "profile":
            return try client(env: extra, baseURL: baseURL, defaultHeaders: defaultHeaders, profile: "parent")
        default:
            return try client(env: extra.merging(["ANTHROPIC_PROFILE": "parent"]) { $1 }, baseURL: baseURL, defaultHeaders: defaultHeaders)
        }
    }

    /// Sends a message and returns the host and workspace header it went with (`_sent_host_and_workspace`).
    func sentHostAndWorkspace(_ c: Anthropic) async throws -> [String?] {
        router.postAnyHost("/v1/messages", json: messageResponseJSON)
        try await sendMessage(c)
        let request = try #require(router.calls.last)
        return [request.url.host, request.headers["anthropic-workspace-id"]]
    }

    static let parentKinds = ["config", "profile", "environment"]

    @Test(arguments: parentKinds)
    func copyCredentialDropsTheParentsHostAndHeaders(kind: String) async throws {
        let c = try parentClient(kind)
        for copied in [try c.copy(apiKey: "new-key"), try c.copy().copy(apiKey: "new-key")] {
            #expect(try await sentHostAndWorkspace(copied) == ["api.anthropic.com", nil])
        }
    }

    @Test(arguments: parentKinds)
    func copyCredentialBringsItsOwnHostAndHeaders(kind: String) async throws {
        for c in [try parentClient(kind), try client("api_key")] {
            #expect(try await sentHostAndWorkspace(try c.copy(profile: "other")) == ["other.example", "wrkspc_other"])
        }
    }

    @Test(arguments: parentKinds)
    func copyInheritsTheParentsHostAndHeaders(kind: String) async throws {
        let c = try parentClient(kind)
        for inheritor in [c, try c.copy(), try c.copy(setDefaultHeaders: [:])] {
            #expect(try await sentHostAndWorkspace(inheritor) == ["parent.example", "wrkspc_parent"])
        }
    }

    @Test(arguments: parentKinds.flatMap { k in ["constructor", "environment", "copy"].map { "\(k):\($0)" } })
    func copyCredentialKeepsAPassedBaseURL(combo: String) async throws {
        let parts = combo.split(separator: ":").map(String.init)
        let passedTo = parts[1]
        let c = try parentClient(parts[0], baseURL: passedTo == "constructor" ? "https://passed.example" : nil,
                                 env: passedTo == "environment" ? ["ANTHROPIC_BASE_URL": "https://passed.example"] : [:])
        let copied = try c.copy(apiKey: "new-key", baseURL: passedTo == "copy" ? "https://passed.example" : nil)
        #expect(try await sentHostAndWorkspace(copied) == ["passed.example", nil])
    }

    @Test(arguments: parentKinds)
    func copyCredentialKeepsPassedDefaultHeaders(kind: String) async throws {
        let c = try parentClient(kind, defaultHeaders: ["anthropic-workspace-id": "wrkspc_passed"])
        #expect(try await sentHostAndWorkspace(c) == ["parent.example", "wrkspc_passed"])
        #expect(try await sentHostAndWorkspace(try c.copy(apiKey: "new-key")) == ["api.anthropic.com", "wrkspc_passed"])
    }

    // -- step 2: empty env values are unset, not empty credentials

    @Test func emptyEnvAuthTokenIsUnset() throws {
        let c = try client(env: ["ANTHROPIC_API_KEY": "sk-from-env", "ANTHROPIC_AUTH_TOKEN": ""])
        let request = try c.buildRequest(FinalRequestOptions(method: "get", url: "/foo"))
        #expect(request.headers["Authorization"] == "Bearer sk-from-env")
        #expect(request.headers["X-Api-Key"] == nil)
        #expect(c.authToken == nil)
    }

    @Test func emptyEnvCredentialsFallThroughToNoAuth() async throws {
        let c = try client(env: ["ANTHROPIC_API_KEY": "", "ANTHROPIC_AUTH_TOKEN": ""])
        await expectThrows(ArgumentTypeError.self, "Could not resolve authentication method") {
            _ = try c.buildRequest(FinalRequestOptions(method: "get", url: "/foo"))
        }
        #expect(c.apiKey == nil)
        #expect(c.authToken == nil)
    }

    // -- step 1 alone

    @Test func credentialsOnlyStillWorks() async throws {
        try await withCapturedLogs { logs in
            let req = try await walkAuth(try client("credentials"))
            #expect(req.headers["X-Api-Key"] == nil)
            #expect(req.headers["Authorization"] == "Bearer from-credentials")
            #expect(!logs.text.contains("takes precedence"))
        }
    }

    // -- one-shot warning

    @Test func shadowWarningIsOneShotPerProcess() async throws {
        try await withCapturedLogs { logs in
            for _ in 0..<3 { _ = try client(env: ["ANTHROPIC_API_KEY": "sk-from-env", "ANTHROPIC_PROFILE": "dev"]) }
            #expect(logs.records.filter { $0.1.contains("takes precedence") }.count == 1)
        }
    }
}

/// Every exit point in the credentials subsystem throws an `AnthropicError` (or subclass).
@Suite struct TypedCredentialErrorsTests {
    let tmp: TempDir
    init() throws { tmp = try TempDir() }

    @Test func invalidProfileNameRaisesAnthropicError() async {
        await expectThrows(AnthropicError.self, "ANTHROPIC_PROFILE") {
            _ = try Anthropic(transport: MockRouter(), environment: cleanEnv(tmp, ["ANTHROPIC_PROFILE": "work/dev"]))
        }
    }

    @Test func profileNameWithDotPrefixRaisesAnthropicError() async {
        await expectThrows(AnthropicError.self, "start with a dot") {
            _ = try Anthropic(transport: MockRouter(), environment: cleanEnv(tmp, ["ANTHROPIC_PROFILE": ".hidden"]))
        }
    }

    @Test func httpBaseURLOnWorkloadProviderRaisesAnthropicError() async {
        let creds = WorkloadIdentityCredentials(identityTokenProvider: { "jwt" }, federationRuleID: "fdrl_x", organizationID: "org_x")
        await expectThrows(AnthropicError.self, "https") { try creds.bindBaseURL("http://evil.example/") }
    }

    @Test func httpBaseURLInConfigFileRaisesAnthropicError() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["base_url": "http://api.example/", "authentication": ["type": "user_oauth"]], ["access_token": "tok"])
        await expectThrows(AnthropicError.self, "https") {
            _ = try await CredentialsFile(profile: "default", transport: MockRouter(), environment: CredentialEnvironment(cleanEnv(tmp)))()
        }
    }

    @Test(.disabled(if: runningAsRoot, "root bypasses POSIX mode bits"))
    func identityTokenFilePermissionErrorRaisesAnthropicError() async throws {
        let f = tmp.child("token")
        try writeText(f, "jwt", mode: 0o000)
        defer { try? chmod(f, 0o600) }
        let err = await expectThrows(IdentityTokenFileError.self, "not readable") { _ = try await IdentityTokenFile(url: f)() }
        #expect(err?.path == f)
    }

    @Test func identityTokenFileDirectoryRaisesAnthropicError() async {
        let err = await expectThrows(IdentityTokenFileError.self, "is a directory") { _ = try await IdentityTokenFile(url: tmp.url)() }
        #expect(err?.path == tmp.url)
    }

    @Test func identityTokenFileBinaryContentRaisesAnthropicError() async throws {
        let f = tmp.child("token")
        try Data([0xFF, 0xFE, 0xFD, 0x00] + Array("not-utf8".utf8)).write(to: f)
        let err = await expectThrows(IdentityTokenFileError.self) { _ = try await IdentityTokenFile(url: f)() }
        #expect(err?.path == f)
    }

    @Test func identityTokenFileEmptyRaisesAnthropicError() async throws {
        let f = tmp.child("token")
        try writeText(f, "")
        let err = await expectThrows(IdentityTokenFileError.self, "empty") { _ = try await IdentityTokenFile(url: f)() }
        #expect(err?.path == f)
    }

    @Test func userOAuthMalformedExpiresAtRaisesAnthropicError() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["authentication": ["type": "user_oauth"]],
                         ["access_token": "tok", "expires_at": "2030-01-01T00:00:00Z"])
        await expectThrows(AnthropicError.self, "expires_at") {
            _ = try await CredentialsFile(profile: "default", environment: CredentialEnvironment(cleanEnv(tmp)))()
        }
    }
}

/// An `active_config` pointer naming a profile with no config surfaces a clear error rather than
/// silently falling through to "no auth configured".
@Suite struct DanglingActiveConfigTests {
    let tmp: TempDir
    var env: [String: String] { cleanEnv(tmp) }
    init() throws { tmp = try TempDir() }

    var pointer: URL { tmp.defaultConfigDir.appendingPathComponent("active_config") }

    @Test func pointerAtMissingProfileRaises() async throws {
        try writeText(pointer, "prod")
        await expectThrows(AnthropicError.self, "prod") { _ = try defaultCredentials(environment: CredentialEnvironment(env)) }
    }

    @Test func pointerAtMissingProfileRaisesViaClient() async throws {
        try writeText(pointer, "prod")
        await expectThrows(AnthropicError.self, "prod") { _ = try Anthropic(transport: MockRouter(), environment: env) }
    }

    @Test func emptyPointerFileIsSilentFallthrough() throws {
        try writeText(pointer, "")
        #expect(try defaultCredentials(environment: CredentialEnvironment(env)) == nil)
    }

    @Test func pointerAtPresentProfileLoadsNormally() async throws {
        try writeText(pointer, "prod")
        try writeProfile(tmp.defaultConfigDir, "prod", ["type": "external"], ["access_token": "from-prod"])
        let result = try #require(try defaultCredentials(environment: CredentialEnvironment(env)))
        #expect(result.provider is CredentialsFile)
        #expect(try await result.provider().token == "from-prod")
    }
}

@Suite struct AccessTokenReprMaskingTests {
    @Test func longTokenMaskedToLastFour() {
        let tok = AccessToken(token: "sk-ant-oat01-SECRETMATERIAL", expiresAt: 123)
        #expect(String(reflecting: tok) == "AccessToken(token='...RIAL', expires_at=123)")
        #expect(String(describing: tok) == String(reflecting: tok))
        // Reflection (`dump`, crash reporters) is masked too.
        var dumped = ""
        dump(tok, to: &dumped)
        #expect(!dumped.contains("SECRETMATERIAL"))
    }

    @Test func shortTokenFullyMasked() {
        #expect(String(describing: AccessToken(token: "hunter2")) == "AccessToken(token='**********', expires_at=None)")
    }
}

/// The missing-token guards treat empty strings as missing.
@Suite struct EmptySecretFieldFalsinessTests {
    let tmp: TempDir
    init() throws { tmp = try TempDir() }

    func file() throws -> CredentialsFile { try CredentialsFile(transport: MockRouter(), environment: CredentialEnvironment(cleanEnv(tmp))) }

    @Test func emptyAccessTokenTreatedAsMissing() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"], ["access_token": "", "refresh_token": "rt"])
        await expectThrows(AnthropicError.self, "missing 'access_token'") { _ = try await file()() }
    }

    @Test func emptyRefreshTokenTreatedAsMissing() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"], ["access_token": "at", "refresh_token": ""])
        await expectThrows(WorkloadIdentityError.self, "must include 'refresh_token'") { _ = try await file()() }
    }
}
