import Foundation
import Testing
@testable import Anthropic

// Port of `TestAnthropicCredentials` and `TestInMemoryConfig` from `tests/lib/test_credentials.py`.
// The Python suite runs these against the sync `Anthropic`; Swift has the one (async) client.

/// A client on the mock router that doesn't wait between retries.
func credsClient(_ router: MockRouter, _ env: [String: String], apiKey: String? = nil, authToken: String? = nil,
                 credentials: (any AccessTokenProvider)? = nil, config: [String: JSONValue]? = nil, profile: String? = nil,
                 baseURL: String? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES, defaultHeaders: Headers? = nil) throws -> Anthropic
{
    let client = try Anthropic(apiKey: apiKey, authToken: authToken, credentials: credentials, config: config, profile: profile,
                               baseURL: baseURL, maxRetries: maxRetries, defaultHeaders: defaultHeaders, transport: router, environment: env)
    client.sleeper = { _ in }
    return client
}

extension MockRouter {
    var messageCalls: [HTTPRequest] { calls.filter { $0.url.absoluteString.hasSuffix("/v1/messages") } }
    var tokenCalls: [HTTPRequest] { calls.filter { $0.url.absoluteString.contains(TOKEN_ENDPOINT) } }
}

func betaFlags(_ request: HTTPRequest?) -> [String] {
    (request?.headers["anthropic-beta"] ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
}

@Suite struct AnthropicCredentialsTests {
    let tmp: TempDir
    let router = MockRouter()
    var env: [String: String] { cleanEnv(tmp) }
    var dir: URL { tmp.defaultConfigDir }

    init() throws { tmp = try TempDir() }

    func client(apiKey: String? = nil, credentials: (any AccessTokenProvider)? = nil, config: [String: JSONValue]? = nil,
                profile: String? = nil, baseURL: String? = nil, maxRetries: Int = DEFAULT_MAX_RETRIES,
                env extra: [String: String] = [:]) throws -> Anthropic
    {
        try credsClient(router, env.merging(extra) { $1 }, apiKey: apiKey, credentials: credentials, config: config, profile: profile,
                        baseURL: baseURL, maxRetries: maxRetries)
    }

    @Test func messagesRequestHasBearerAndBeta() async throws {
        router.mockTokenEndpoint()
        router.mockMessages()
        try await sendMessage(try client(credentials: workloadCredentials(router)))
        #expect(router.messageCalls.count == 1)
        let req = router.messageCalls.first
        #expect(req?.headers["Authorization"] == "Bearer sk-ant-oat01-test")
        // API requests carry the OAuth API beta — not the federation beta, which is only for
        // jwt-bearer exchanges.
        #expect(betaFlags(req).contains(OAUTH_API_BETA_HEADER))
        #expect(!betaFlags(req).contains(FEDERATION_BETA_HEADER))
        #expect(req?.headers["X-Api-Key"] == nil)
    }

    @Test func workloadIdentityInheritsClientBaseURL() async throws {
        let custom = "https://api-staging.example"
        router.post("\(custom)\(TOKEN_ENDPOINT)", json: ["access_token": "tok-staging", "expires_in": 600])
        router.mockMessages(custom)
        try await sendMessage(try client(credentials: workloadCredentials(router), baseURL: custom))
        #expect(router.tokenCalls.map { $0.url.absoluteString } == ["\(custom)\(TOKEN_ENDPOINT)"])
        #expect(router.messageCalls.first?.headers["Authorization"] == "Bearer tok-staging")
    }

    @Test func tokenEndpointCalledOnceAcrossRequests() async throws {
        router.mockTokenEndpoint()
        router.mockMessages()
        let c = try client(credentials: workloadCredentials(router))
        try await sendMessage(c)
        try await sendMessage(c)
        #expect(router.tokenCalls.count == 1)
        #expect(router.messageCalls.count == 2)
    }

    @Test func staticTokenCredentials() async throws {
        router.mockMessages()
        try await sendMessage(try client(credentials: StaticToken("static-bearer")))
        let req = router.calls.first
        #expect(req?.headers["Authorization"] == "Bearer static-bearer")
        #expect(req?.headers["anthropic-beta"]?.contains(OAUTH_API_BETA_HEADER) == true)
    }

    @Test func betaHeaderNotDuplicated() async throws {
        router.mockMessages()
        let c = try client(credentials: StaticToken("static-bearer"))
        _ = try await c.post("/v1/messages", body: ["max_tokens": 1, "model": "claude-opus-4-5", "messages": [["role": "user", "content": "hi"]]],
                             as: JSONValue.self, options: RequestOptions(extraHeaders: ["anthropic-beta": .value(OAUTH_API_BETA_HEADER)]))
        #expect(router.calls.first?.headers["anthropic-beta"] == OAUTH_API_BETA_HEADER)
    }

    /// The dedupe matches whole comma-separated flags, not substrings.
    @Test func betaHeaderDedupeIsTokenBased() async throws {
        router.mockTokenEndpoint()
        router.mockMessages()
        let c = try client(credentials: workloadCredentials(router))
        _ = try await c.post("/v1/messages", body: ["max_tokens": 1, "model": "claude-opus-4-5", "messages": [["role": "user", "content": "hi"]]],
                             as: JSONValue.self,
                             options: RequestOptions(extraHeaders: ["anthropic-beta": .value("\(OAUTH_API_BETA_HEADER)-future-variant")]))
        let req = router.messageCalls.first
        #expect(betaFlags(req).contains(OAUTH_API_BETA_HEADER))
        #expect(betaFlags(req).contains("\(OAUTH_API_BETA_HEADER)-future-variant"))
        #expect(req?.headers["anthropic-beta"] == "\(OAUTH_API_BETA_HEADER)-future-variant,\(OAUTH_API_BETA_HEADER)")
    }

    @Test func zeroConfigWorkloadIdentityFromEnv() async throws {
        let f = tmp.child("jwt")
        try writeText(f, "env-jwt")
        router.mockTokenEndpoint()
        router.mockMessages()
        let c = try client(env: [
            "ANTHROPIC_IDENTITY_TOKEN_FILE": f.path, "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc", "ANTHROPIC_ORGANIZATION_ID": "org-uuid",
        ])
        #expect(c.credentials is WorkloadIdentityCredentials)
        try await sendMessage(c)
        #expect(router.tokenCalls.count == 1)
        #expect(router.tokenCalls.first?.jsonBody?["assertion"] == "env-jwt")
        #expect(router.messageCalls.first?.headers["Authorization"] == "Bearer sk-ant-oat01-test")
    }

    @Test func zeroConfigWorkloadIdentityBeatsActiveProfile() async throws {
        try writeText(dir.appendingPathComponent("active_config"), "prod")
        try writeProfile(dir, "prod", ["type": "external"], ["access_token": "sk-ant-oat01-file"])
        router.mockTokenEndpoint()
        router.mockMessages()
        let extra = [
            "ANTHROPIC_CONFIG_DIR": dir.path, "ANTHROPIC_IDENTITY_TOKEN": "env-jwt", "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc",
            "ANTHROPIC_ORGANIZATION_ID": "org-uuid",
        ]
        let c = try client(env: extra)
        #expect(c.credentials is WorkloadIdentityCredentials)
        try await sendMessage(c)
        #expect(router.calls.map { $0.url.absoluteString } == [CREDS_TOKEN_URL, "\(CREDS_BASE_URL)/v1/messages"])
        #expect(router.calls.first?.jsonBody?["assertion"] == "env-jwt")
        #expect(router.calls.last?.headers["Authorization"] == "Bearer sk-ant-oat01-test")
    }

    @Test func zeroConfigCredentialsFileFromEnv() async throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "sk-ant-oat01-file"])
        router.mockMessages()
        let c = try client(env: ["ANTHROPIC_CONFIG_DIR": dir.path])
        #expect(c.credentials is CredentialsFile)
        try await sendMessage(c)
        #expect(router.calls.first?.headers["Authorization"] == "Bearer sk-ant-oat01-file")
    }

    /// A zero-argument client adopts the active profile's base URL when neither `baseURL:` nor
    /// `ANTHROPIC_BASE_URL` is given. Precedence: argument > env > profile > default.
    @Test func profileBaseURLAdoptedByClient() throws {
        try writeProfile(dir, "default", ["type": "external", "base_url": "https://staging.example"], ["access_token": "sk-ant-oat01-x"])
        let extra = ["ANTHROPIC_CONFIG_DIR": dir.path]
        #expect(try client(env: extra).baseURL.absoluteString == "https://staging.example/")
        #expect(try client(env: extra.merging(["ANTHROPIC_BASE_URL": "https://env.example"]) { $1 }).baseURL.absoluteString == "https://env.example/")
        #expect(try client(baseURL: "https://kwarg.example", env: extra).baseURL.absoluteString == "https://kwarg.example/")

        try writeProfile(dir, "default", ["type": "external"], ["access_token": "sk-ant-oat01-x"])
        #expect(try client(env: extra).baseURL.absoluteString == "https://api.anthropic.com/")
    }

    @Test func configDictBaseURLAdoptedByClient() throws {
        let credsPath = tmp.child("creds.json")
        try writeJSON(credsPath, ["type": "oauth_token", "access_token": "sk-ant-oat01-x"], mode: 0o600)
        let cfg: [String: JSONValue] = [
            "base_url": "https://staging.example",
            "authentication": ["type": "user_oauth", "credentials_path": .string(credsPath.path)],
        ]
        #expect(try client(config: cfg).baseURL.absoluteString == "https://staging.example/")
        #expect(try client(config: cfg, baseURL: "https://kwarg.example").baseURL.absoluteString == "https://kwarg.example/")
    }

    @Test func workspaceIDHeaderFromConfig() async throws {
        try writeProfile(dir, "default", ["type": "external", "workspace_id": "wrkspc_01abc"], ["access_token": "sk-ant-oat01-file"])
        router.mockMessages()
        let c = try client(env: ["ANTHROPIC_CONFIG_DIR": dir.path])
        try await sendMessage(c)
        _ = try await c.post("/v1/messages", body: ["max_tokens": 1, "model": "claude-opus-4-5", "messages": [["role": "user", "content": "hi"]]],
                             as: JSONValue.self, options: RequestOptions(extraHeaders: ["anthropic-workspace-id": "wrkspc_req"]))
        #expect(router.calls[0].headers["anthropic-workspace-id"] == "wrkspc_01abc")
        #expect(router.calls[1].headers["anthropic-workspace-id"] == "wrkspc_req")
    }

    /// On a 401 the cache is invalidated and the request retried once with a fresh token.
    @Test func status401InvalidatesCacheAndRetriesOnce() async throws {
        let calls = Counter()
        router.post("\(CREDS_BASE_URL)/v1/messages", sequence: [(401, ["error": "unauthorized"]), (200, messageResponseJSON)])
        let c = try client(credentials: provider { _ in AccessToken(token: "tok-\(calls.next() + 1)") }, maxRetries: 2)
        try await sendMessage(c)
        #expect(calls.count == 2)
        #expect(router.calls[0].headers["Authorization"] == "Bearer tok-1")
        #expect(router.calls[1].headers["Authorization"] == "Bearer tok-2")
    }

    /// Two consecutive 401s → exactly one retry, then the error surfaces.
    @Test func status401RetryIsSingleShot() async throws {
        router.post("\(CREDS_BASE_URL)/v1/messages", status: 401, json: ["error": "unauthorized"])
        let calls = Counter()
        let c = try client(credentials: provider { _ in AccessToken(token: "tok-\(calls.next() + 1)") }, maxRetries: 3)
        await expectThrows(AuthenticationError.self) { try await sendMessage(c) }
        #expect(calls.count == 2)
        #expect(router.calls.count == 2)
    }

    @Test func apiKeyPrecedencePreserved() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "should-not-be-used"])
        router.mockMessages()
        let c = try client(env: ["ANTHROPIC_API_KEY": "sk-ant-api-key", "ANTHROPIC_CONFIG_DIR": tmp.path])
        #expect(c.credentials == nil)
        #expect(c.tokenCache == nil)
        try await sendMessage(c)
        #expect(router.calls.first?.headers["Authorization"] == "Bearer sk-ant-api-key")
        #expect(router.calls.first?.headers["X-Api-Key"] == nil)
    }

    @Test func copyPropagatesCredentials() throws {
        let creds = CountingProvider([AccessToken(token: "a")])
        let c = try client(credentials: creds)
        let copied = try c.copy()
        #expect(copied.credentials as AnyObject === creds)
        // The cache is shared so a copy doesn't trigger an independent token exchange.
        #expect(copied.tokenCache === c.tokenCache)

        let other = CountingProvider([AccessToken(token: "b")])
        let copied2 = try c.copy(credentials: other)
        #expect(copied2.credentials as AnyObject === other)
        #expect(copied2.tokenCache !== c.tokenCache)

        let cleared = try c.copy(apiKey: "x", credentials: .some(nil))
        #expect(cleared.credentials == nil)
        #expect(cleared.tokenCache == nil)
    }

    @Test func withOptionsAlias() throws {
        let c = try client(credentials: CountingProvider([AccessToken(token: "a")]))
        let copied = try c.withOptions(maxRetries: 7)
        #expect(copied.maxRetries == 7)
        #expect(copied.credentials as AnyObject === c.credentials as AnyObject)
    }

    /// `copy(baseURL:)` must not move the parent's token exchange.
    @Test func copyWithDifferentBaseURLExchangesPerClient() async throws {
        router.mockDeployment(CREDS_BASE_URL, "tok-primary")
        router.mockDeployment(OTHER_BASE_URL, "tok-other")
        let parent = try client(credentials: workloadCredentials(router))
        let child = try parent.copy(baseURL: OTHER_BASE_URL)
        try await sendMessage(child)
        try await sendMessage(parent)
        router.expectExchangedAndCalledOwnDeployment(OTHER_BASE_URL, "tok-other")
        router.expectExchangedAndCalledOwnDeployment(CREDS_BASE_URL, "tok-primary")
    }

    @Test func sharedProviderBindsPerClient() async throws {
        router.mockDeployment(CREDS_BASE_URL, "tok-primary")
        router.mockDeployment(OTHER_BASE_URL, "tok-other")
        let creds = workloadCredentials(router)
        let primary = try client(credentials: creds)
        let other = try client(credentials: creds, baseURL: OTHER_BASE_URL)
        #expect(primary.credentials as AnyObject === creds)
        try await sendMessage(other)
        try await sendMessage(primary)
        router.expectExchangedAndCalledOwnDeployment(OTHER_BASE_URL, "tok-other")
        router.expectExchangedAndCalledOwnDeployment(CREDS_BASE_URL, "tok-primary")
    }

    @Test func copyWithSameBaseURLSharesTokenExchange() async throws {
        router.mockDeployment(CREDS_BASE_URL, "tok-primary")
        let parent = try client(credentials: workloadCredentials(router))
        let child = try parent.copy(baseURL: CREDS_BASE_URL)
        #expect(child.credentials as AnyObject === parent.credentials as AnyObject)
        try await sendMessage(child)
        try await sendMessage(parent)
        let reqs = router.requests(to: CREDS_BASE_URL)
        #expect(reqs.map { $0.url.absoluteString } == [CREDS_TOKEN_URL, "\(CREDS_BASE_URL)/v1/messages", "\(CREDS_BASE_URL)/v1/messages"])
        #expect(reqs.dropFirst().allSatisfy { $0.headers["Authorization"] == "Bearer tok-primary" })
    }

    @Test func copyOfFederationProfileClientExchangesPerClient() async throws {
        let jwt = dir.appendingPathComponent("jwt")
        try writeText(jwt, "ext-jwt")
        try writeProfile(dir, "fed", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwt.path)],
            "federation_rule_id": "fdrl_01abc", "organization_id": "org-uuid",
        ])
        router.mockDeployment(CREDS_BASE_URL, "tok-primary")
        router.mockDeployment(OTHER_BASE_URL, "tok-other")
        let parent = try client(profile: "fed")
        let child = try parent.copy(baseURL: OTHER_BASE_URL)
        try await sendMessage(child)
        try await sendMessage(parent)
        router.expectExchangedAndCalledOwnDeployment(OTHER_BASE_URL, "tok-other")
        router.expectExchangedAndCalledOwnDeployment(CREDS_BASE_URL, "tok-primary")
        #expect(try readJSON(dir.appendingPathComponent("credentials").appendingPathComponent("fed.json"))["access_token"] == "tok-primary")
    }

    /// A `user_oauth` refresh token belongs to the deployment that issued it.
    @Test func copyOfUserOAuthProfileClientKeepsRefreshEndpoint() async throws {
        try writeProfile(dir, "oauth", ["type": "authorized_user", "client_id": "cid"],
                         ["access_token": "stale", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "rt"])
        router.mockTokenExchange(CREDS_BASE_URL, "tok-refreshed")
        router.mockMessages(OTHER_BASE_URL)
        let parent = try client(profile: "oauth")
        let child = try parent.copy(baseURL: OTHER_BASE_URL)
        #expect(child.credentials as AnyObject === parent.credentials as AnyObject)
        try await sendMessage(child)
        #expect(router.requests(to: CREDS_BASE_URL).map { $0.url.absoluteString } == [CREDS_TOKEN_URL])
        let others = router.requests(to: OTHER_BASE_URL)
        #expect(others.map { $0.url.absoluteString } == ["\(OTHER_BASE_URL)/v1/messages"])
        #expect(others.first?.headers["Authorization"] == "Bearer tok-refreshed")
    }

    @Test func configParamBuildsInMemoryFederation() async throws {
        let jwt = tmp.child("jwt")
        try writeText(jwt, "ext-jwt-value")
        router.mockTokenEndpoint()
        router.mockMessages()
        let c = try client(config: [
            "organization_id": "org_x", "workspace_id": "wrkspc_x",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x", "identity_token": ["source": "file", "path": .string(jwt.path)]],
        ])
        #expect(c.credentials is InMemoryConfig)
        try await sendMessage(c)
        let msg = router.calls.last
        #expect(msg?.headers["Authorization"] == "Bearer sk-ant-oat01-test")
        // Federation profiles send workspace_id in the exchange body, not as a header.
        #expect(msg?.headers["anthropic-workspace-id"] == nil)
        #expect(router.calls.first?.jsonBody?["workspace_id"] == "wrkspc_x")
    }

    @Test func explicitConfigBeatsEnvAPIKey() throws {
        let jwt = tmp.child("jwt")
        try writeText(jwt, "ext-jwt.ext-jwt.ext-jwt")
        let c = try client(config: [
            "organization_id": "org_x",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x", "identity_token": ["source": "file", "path": .string(jwt.path)]],
        ], env: ["ANTHROPIC_API_KEY": "sk-from-env"])
        #expect(c.apiKey == nil)
        #expect(c.credentials is InMemoryConfig)
    }

    @Test func profileParamLoadsNamedProfile() throws {
        try writeProfile(dir, "staging", ["type": "external", "base_url": "https://staging.example"], ["access_token": "sk-ant-oat01-staging"])
        let c = try client(profile: "staging")
        #expect((c.credentials as? CredentialsFile)?.profile == "staging")
        #expect(c.baseURL.absoluteString == "https://staging.example/")
    }

    @Test func explicitProfileBeatsEnvAPIKey() throws {
        try writeProfile(dir, "dev", ["type": "external"], ["access_token": "sk-ant-oat01-dev"])
        let c = try client(profile: "dev", env: ["ANTHROPIC_API_KEY": "sk-from-env"])
        #expect(c.apiKey == nil)
        #expect((c.credentials as? CredentialsFile)?.profile == "dev")
    }

    /// A `WorkloadIdentityError` from the provider surfaces as-is (not wrapped in
    /// `APIConnectionError`) and is not retried.
    @Test func workloadIdentityErrorPropagatesThroughRequestFlow() async throws {
        let calls = Counter()
        let c = try client(credentials: provider { _ in
            _ = calls.next()
            throw WorkloadIdentityError("simulated 403", statusCode: 403,
                                        body: ["error": ["type": "permission_error", "message": "Permission denied"]])
        }, maxRetries: 3)
        let err = await expectThrows(WorkloadIdentityError.self) { try await sendMessage(c) }
        #expect(err?.statusCode == 403)
        #expect(err?.body?["error"]?["type"] == "permission_error")
        #expect(calls.count == 1)
    }
}

@Suite struct InMemoryConfigTests {
    let tmp: TempDir
    let router = MockRouter()
    init() throws { tmp = try TempDir() }

    @Test func oidcFederation() async throws {
        let jwt = tmp.child("jwt")
        try writeText(jwt, "ext-jwt")
        router.post(CREDS_TOKEN_URL, json: ["access_token": "tok", "expires_in": 600])
        let p = try InMemoryConfig([
            "organization_id": "org_x", "workspace_id": "wrkspc_x",
            "authentication": [
                "type": "oidc_federation", "federation_rule_id": "fdrl_x", "service_account_id": "svac_x",
                "identity_token": ["source": "file", "path": .string(jwt.path)],
            ],
        ], transport: router, environment: [:])
        #expect(try await p().token == "tok")
        #expect(try p.extraHeaders() == [:])
        let body = try #require(router.calls.first?.jsonBody)
        #expect(body["federation_rule_id"] == "fdrl_x")
        #expect(body["organization_id"] == "org_x")
        #expect(body["service_account_id"] == "svac_x")
        #expect(body["workspace_id"] == "wrkspc_x")
    }

    @Test func identityTokenProviderOverride() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "tok", "expires_in": 600])
        let p = try InMemoryConfig([
            "organization_id": "org_x", "workspace_id": "wrkspc_x",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x"],
        ], identityTokenProvider: { "programmatic-jwt" }, transport: router, environment: [:])
        _ = try await p()
        let body = try #require(router.calls.first?.jsonBody)
        #expect(body["assertion"] == "programmatic-jwt")
        #expect(body["workspace_id"] == "wrkspc_x")
    }

    @Test func oidcFederationNoCredentialsPathNoDiskCache() async throws {
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "tok", "expires_in": 600])
        let p = try InMemoryConfig(["organization_id": "org_x", "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x"]],
                                   identityTokenProvider: { "jwt" }, transport: router, environment: CredentialEnvironment(cleanEnv(tmp)))
        _ = try await p()
        _ = try await p()
        #expect(route.callCount == 2)
        let files = FileManager.default.enumerator(atPath: tmp.path)?.compactMap { $0 as? String }.filter { $0.hasSuffix(".json") } ?? []
        #expect(files.isEmpty)
    }

    @Test func oidcFederationWithCredentialsPathDiskCache() async throws {
        let credsPath = tmp.child("cache.json")
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "cached-tok", "expires_in": 600])
        let p = try InMemoryConfig([
            "organization_id": "org_x",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x", "credentials_path": .string(credsPath.path)],
        ], identityTokenProvider: { "jwt" }, transport: router, environment: [:])
        #expect(try await p().token == "cached-tok")
        #expect(route.callCount == 1)
        let onDisk = try readJSON(credsPath)
        #expect(onDisk["access_token"] == "cached-tok")
        #expect(onDisk["type"] == "oauth_token")
        #expect(permissionBits(try fileStatus(credsPath.path)) == 0o600)
        #expect(try await p().token == "cached-tok")
        #expect(route.callCount == 1)
    }

    @Test func userOAuthRequiresCredentialsPath() async {
        await expectThrows(AnthropicError.self, "requires 'authentication.credentials_path'") {
            _ = try InMemoryConfig(["authentication": ["type": "user_oauth", "client_id": "cid"]], environment: [:])
        }
    }

    @Test func userOAuthRefreshAndWriteback() async throws {
        let credsPath = tmp.child("creds.json")
        try writeJSON(credsPath, [
            "type": "oauth_token", "access_token": "old-tok", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "refresh-old",
        ], mode: 0o600)
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "new-tok", "expires_in": 3600, "refresh_token": "refresh-new"])
        let p = try InMemoryConfig([
            "workspace_id": "wrkspc_x",
            "authentication": ["type": "user_oauth", "client_id": "cid", "credentials_path": .string(credsPath.path)],
        ], transport: router, environment: [:])
        #expect(try await p().token == "new-tok")
        #expect(route.callCount == 1)
        let rewritten = try readJSON(credsPath)
        #expect(rewritten["access_token"] == "new-tok")
        #expect(rewritten["refresh_token"] == "refresh-new")
        // The workspace header IS set for user_oauth (federation suppresses it).
        #expect(try p.extraHeaders() == ["anthropic-workspace-id": "wrkspc_x"])
    }

    @Test func unknownTypeRejected() async {
        await expectThrows(AnthropicError.self, "Unknown authentication.type") {
            _ = try InMemoryConfig(["authentication": ["type": "something_else"]], environment: [:])
        }
    }

    @Test func missingAuthentication() async {
        await expectThrows(AnthropicError.self, "missing the 'authentication' object") {
            _ = try InMemoryConfig(["organization_id": "org_x"], environment: [:])
        }
    }

    @Test func missingRequiredFields() async throws {
        let p = try InMemoryConfig(["authentication": ["type": "oidc_federation"]], identityTokenProvider: { "j" }, environment: [:])
        await expectThrows(WorkloadIdentityError.self, "federation_rule_id") { _ = try await p() }
    }

    @Test func httpBaseURLRejected() async {
        await expectThrows(AnthropicError.self, "must use https") {
            _ = try InMemoryConfig([
                "organization_id": "org_x", "base_url": "http://example.com",
                "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_x"],
            ], identityTokenProvider: { "j" }, environment: [:])
        }
    }
}
