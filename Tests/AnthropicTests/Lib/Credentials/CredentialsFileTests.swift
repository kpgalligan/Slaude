import Foundation
import Testing
@testable import Anthropic

// Port of the basic-provider and `TestCredentialsFile` sections of `tests/lib/test_credentials.py`.

@Suite struct AccessTokenTests {
    @Test func defaults() {
        let tok = AccessToken(token: "abc")
        #expect(tok.token == "abc")
        #expect(tok.expiresAt == nil)
    }

    @Test func withExpiry() {
        #expect(AccessToken(token: "abc", expiresAt: 123).expiresAt == 123)
    }
}

@Suite struct BaseURLBoundProviderTests {
    @Test func deploymentBoundProvidersImplementIt() throws {
        let tmp = try TempDir()
        let env = CredentialEnvironment(cleanEnv(tmp))
        #expect(workloadCredentials() as Any is any BaseURLBoundProvider)
        #expect(try CredentialsFile(profile: "default", environment: env) as Any is any BaseURLBoundProvider)
        let _: CredentialsFile.Type = InMemoryConfig.self  // issubclass(InMemoryConfig, CredentialsFile), checked by the compiler
    }

    @Test func otherProvidersDoNot() {
        #expect(!(StaticToken("tok") as Any is any BaseURLBoundProvider))
        #expect(!(EnvToken() as Any is any BaseURLBoundProvider))
    }
}

@Suite struct StaticTokenTests {
    @Test func returnsToken() async throws {
        let p = StaticToken("sk-ant-oat01-static")
        #expect(try await p() == AccessToken(token: "sk-ant-oat01-static", expiresAt: nil))
        #expect(try await p().expiresAt == nil)
    }
}

@Suite struct EnvTokenTests {
    @Test func readsEnv() async throws {
        #expect(try await EnvToken(environment: ["ANTHROPIC_AUTH_TOKEN": "env-token"])().token == "env-token")
    }

    @Test func raisesWhenMissing() async {
        await expectThrows(AnthropicError.self, "ANTHROPIC_AUTH_TOKEN") { _ = try await EnvToken(environment: [:])() }
    }
}

@Suite struct IdentityTokenFileTests {
    @Test func rereadsOnEachCall() async throws {
        let tmp = try TempDir()
        let f = tmp.child("token")
        try writeText(f, "jwt-one\n")
        let provider = try IdentityTokenFile(f.path, environment: [:])
        #expect(try await provider() == "jwt-one")
        try writeText(f, "jwt-two\n")
        #expect(try await provider() == "jwt-two")
    }

    @Test func readsEnvVarPath() async throws {
        let tmp = try TempDir()
        let f = tmp.child("token")
        try writeText(f, "from-env")
        #expect(try await IdentityTokenFile(environment: ["ANTHROPIC_IDENTITY_TOKEN_FILE": f.path])() == "from-env")
    }

    @Test func raisesWhenNoPath() async {
        await expectThrows(AnthropicError.self, "ANTHROPIC_IDENTITY_TOKEN_FILE") { _ = try IdentityTokenFile(environment: [:]) }
    }

    @Test func raisesWhenFileMissing() async throws {
        let tmp = try TempDir()
        let path = tmp.child("nope")
        let err = await expectThrows(IdentityTokenFileError.self, "not found") { _ = try await IdentityTokenFile(url: path)() }
        // Subclasses CredentialsError / AnthropicError so existing handlers keep matching.
        #expect((err as Any) is CredentialsError)
        #expect((err as Any) is AnthropicError)
        #expect(err?.path == path)
    }
}

/// All tests use `ANTHROPIC_CONFIG_DIR` pointing at a temp directory laid out as
/// `configs/<profile>.json` + `credentials/<profile>.json`.
@Suite struct CredentialsFileTests {
    let tmp: TempDir
    let router = MockRouter()
    var env: CredentialEnvironment { CredentialEnvironment(configDirEnv(tmp)) }

    init() throws { tmp = try TempDir() }

    func file(_ profile: String? = nil, env: CredentialEnvironment? = nil) throws -> CredentialsFile {
        try CredentialsFile(profile: profile, transport: router, environment: env ?? self.env)
    }

    var jwtPath: URL { tmp.child("jwt") }

    // -- "type": "external"

    @Test func external() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "sk-ant-oat01-x", "expires_at": 1775000000])
        let tok = try await file()()
        #expect(tok.token == "sk-ant-oat01-x")
        #expect(tok.expiresAt == 1775000000)
    }

    @Test func externalNoExpiry() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "sk-ant-oat01-x"])
        #expect(try await file()().expiresAt == nil)
    }

    @Test func externalRereadsCredentialsOnEachCall() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "first"])
        let provider = try file()
        #expect(try await provider().token == "first")
        try writeJSON(tmp.child("credentials", "default.json"), ["access_token": "second"])
        #expect(try await provider().token == "second")
    }

    @Test func externalMissingCredentialsFile() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"])
        let err = await expectThrows(CredentialsError.self, "Credentials file not found") { _ = try await file()() }
        #expect((err as Any) is AnthropicError)
    }

    @Test func credentialsFileWrongTypeRaises() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["type": "something_else", "access_token": "x"])
        await expectThrows(AnthropicError.self,
                           "credentials file has type 'something_else'; expected 'oauth_token' for authentication.type 'user_oauth'") {
            _ = try await file()()
        }
    }

    @Test func credentialsFileAbsentTypeIsLenient() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"])
        try writeJSON(tmp.child("credentials", "default.json"), ["access_token": "no-type-field"], mode: 0o600)
        #expect(try await file()().token == "no-type-field")
    }

    @Test func unrecognizedTopLevelKeysIgnored() async throws {
        try writeProfile(tmp.url, "default",
                         ["type": "external", "_note": "test comment", "future_field": 123, "nested_future": ["a": [1, 2]]],
                         ["access_token": "tolerant", "expires_at": 1775000000, "_note": "creds comment", "future_field": 123])
        let tok = try await file()()
        #expect(tok.token == "tolerant")
        #expect(tok.expiresAt == 1775000000)
    }

    // -- "type": "workload_identity"

    @Test func workloadIdentityDispatch() async throws {
        try writeText(jwtPath, "ext-jwt-from-file")
        // workload_identity needs no credentials file — config is sufficient.
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
            "federation_rule_id": "fdrl_file", "organization_id": "org-from-file", "service_account_id": "svac_file",
        ])
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "exch_tok", "expires_in": 3600])

        let provider = try file()
        let tok = try await provider()
        #expect(tok.token == "exch_tok")
        #expect((tok.expiresAt ?? 0) > Int(Date().timeIntervalSince1970))
        #expect(route.callCount == 1)
        let body = try #require(route.calls.first?.jsonBody)
        #expect(body["grant_type"] == .string(GRANT_TYPE_JWT_BEARER))
        #expect(body["assertion"] == "ext-jwt-from-file")
        #expect(body["federation_rule_id"] == "fdrl_file")
        #expect(body["organization_id"] == "org-from-file")
        #expect(body["service_account_id"] == "svac_file")
        #expect(body["workspace_id"] == nil)
        #expect(body["scope"] == nil)

        // Disk cache: the second call returns the cached token without hitting the network.
        _ = try await provider()
        #expect(route.callCount == 1)
        #expect(provider.workloadDelegate != nil)
        let cached = try readJSON(tmp.child("credentials", "default.json"))
        #expect(cached["version"] == "1.0")
        #expect(cached["type"] == "oauth_token")
        #expect(cached["access_token"] == "exch_tok")
        #expect(cached["expires_at"]?.intValue != nil)
        if case .int? = cached["expires_at"] {} else { Issue.record("expires_at is not an int") }
    }

    @Test func bindBaseURLPrecedence() async throws {
        try writeText(jwtPath, "j")
        let bound = "https://bound.example"
        func write(_ profile: String, withBaseURL: String?) throws {
            var cfg: [String: JSONValue] = [
                "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
                "federation_rule_id": "fdrl_x", "organization_id": "org",
            ]
            if let withBaseURL { cfg["base_url"] = .string(withBaseURL) }
            try writeProfile(tmp.url, profile, cfg)
        }
        let ok: JSONValue = ["access_token": "t", "expires_in": 60]

        // config omits base_url, no bind → default
        try write("p0", withBaseURL: nil)
        router.post(CREDS_TOKEN_URL, json: ok)
        _ = try await file("p0")()
        #expect(router.calls.last?.url.absoluteString == CREDS_TOKEN_URL)

        // config omits base_url + bound → bound
        try write("p1", withBaseURL: nil)
        router.post("\(bound)\(TOKEN_ENDPOINT)", json: ok)
        var creds = try file("p1")
        try creds.bindBaseURL(bound)
        _ = try await creds()
        #expect(router.calls.last?.url.absoluteString == "\(bound)\(TOKEN_ENDPOINT)")

        // config has base_url + bound → config wins
        try write("p2", withBaseURL: "https://from-config.example")
        router.post("https://from-config.example\(TOKEN_ENDPOINT)", json: ok)
        creds = try file("p2")
        try creds.bindBaseURL(bound)
        _ = try await creds()
        #expect(router.calls.last?.url.absoluteString == "https://from-config.example\(TOKEN_ENDPOINT)")

        // re-entrancy: binding after the config loaded re-resolves in place; the last bind wins.
        try write("p3", withBaseURL: nil)
        creds = try file("p3")
        _ = try creds.extraHeaders()
        try creds.bindBaseURL("https://first.example")
        try creds.bindBaseURL("https://second.example")
        #expect(creds.resolvedExchangeBaseURL == "https://second.example")
        // eager scheme validation — http:// rejected at bind time, before load
        await expectThrows(AnthropicError.self, "https") { try file("p3").bindBaseURL("http://evil.example") }
    }

    @Test func forBaseURLFederationProfile() async throws {
        try writeText(jwtPath, "ext-jwt")
        try writeProfile(tmp.url, "fed", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
            "federation_rule_id": "fdrl_01abc", "organization_id": "org-uuid",
        ])
        router.mockTokenExchange(CREDS_BASE_URL, "tok-primary")
        router.mockTokenExchange(OTHER_BASE_URL, "tok-other")
        let creds = try file("fed")
        #expect(try creds.forBaseURL(CREDS_BASE_URL) as AnyObject === creds)
        #expect(try creds.forBaseURL("\(CREDS_BASE_URL)/") as AnyObject === creds)
        let other = try creds.forBaseURL(OTHER_BASE_URL)
        #expect(other as AnyObject !== creds)

        #expect(try await other().token == "tok-other")
        #expect(!fileExistsAt(tmp.child("credentials", "fed.json")))
        #expect(try await creds().token == "tok-primary")
        #expect(try readJSON(tmp.child("credentials", "fed.json"))["access_token"] == "tok-primary")
        // The other host's provider never consults the file the original wrote.
        #expect(try await other().token == "tok-other")
        #expect(router.requests(to: OTHER_BASE_URL).map { $0.url.absoluteString } == [OTHER_TOKEN_URL, OTHER_TOKEN_URL])
        #expect(router.requests(to: CREDS_BASE_URL).map { $0.url.absoluteString } == [CREDS_TOKEN_URL])
    }

    @Test func forBaseURLReturnsSelfWhenBindIsMoot() throws {
        try writeProfile(tmp.url, "pinned", ["type": "workload_identity", "federation_rule_id": "fdrl_x", "base_url": "https://pinned.example"])
        let pinned = try file("pinned")
        #expect(try pinned.forBaseURL(CREDS_BASE_URL) as AnyObject === pinned)
        #expect(try pinned.forBaseURL(OTHER_BASE_URL) as AnyObject === pinned)

        try writeProfile(tmp.url, "oauth", ["type": "authorized_user", "client_id": "cid"])
        let oauth = try file("oauth")
        #expect(try oauth.forBaseURL(CREDS_BASE_URL) as AnyObject === oauth)
        #expect(try oauth.forBaseURL(OTHER_BASE_URL) as AnyObject === oauth)
    }

    @Test func workloadIdentityDiskCacheStaleReexchange() async throws {
        try writeText(jwtPath, "ext-jwt")
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
            "federation_rule_id": "fdrl_x", "organization_id": "org_x",
        ], ["access_token": "stale-tok", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1)])
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "fresh-tok", "expires_in": 600])
        #expect(try await file()().token == "fresh-tok")
        #expect(route.callCount == 1)
        #expect(try readJSON(tmp.child("credentials", "default.json"))["access_token"] == "fresh-tok")
    }

    @Test func workloadIdentityDiskCacheCorruptExpiresAtReexchange() async throws {
        try writeText(jwtPath, "ext-jwt")
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
            "federation_rule_id": "fdrl_x", "organization_id": "org_x",
        ], ["access_token": "stale-tok", "expires_at": "not-a-number"])
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "fresh-tok", "expires_in": 600])
        #expect(try await file()().token == "fresh-tok")
        #expect(route.callCount == 1)
    }

    @Test func workloadIdentityMissingRequiredFields() async throws {
        try writeProfile(tmp.url, "default", ["type": "workload_identity", "federation_rule_id": "fdrl_x"])
        await expectThrows(WorkloadIdentityError.self, "'authentication.federation_rule_id' and top-level 'organization_id'") {
            _ = try await file()()
        }
    }

    @Test func workloadDelegateBorrowsParentTransport() async throws {
        try writeText(jwtPath, "ext-jwt")
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "identity_token": ["source": "file", "path": .string(jwtPath.path)],
            "federation_rule_id": "fdrl_x", "organization_id": "00000000-0000-0000-0000-000000000000",
        ])
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        // A provider that creates its own transport hands that same one to its delegate.
        let provider = try CredentialsFile(environment: env)
        let shared = provider.transport.get()
        let delegate = try provider.buildWorkloadDelegate(try provider.authBlock())
        #expect(delegate.transport.get() as AnyObject === shared as AnyObject)
        await provider.close()
        await delegate.close()
    }

    @Test func workloadIdentityUnknownSourceRaises() async throws {
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "federation_rule_id": "f", "organization_id": "o",
            "identity_token": ["source": "url", "url": "https://example.com/token"],
        ])
        await expectThrows(AnthropicError.self, "identity_token source 'url' is not supported") { _ = try await file()() }
    }

    @Test func workloadIdentityTokenOmittedUsesEnv() async throws {
        try writeText(jwtPath, "via-env-chain")
        try writeProfile(tmp.url, "default", ["type": "workload_identity", "federation_rule_id": "f", "organization_id": "o"])
        let provider = try file(env: CredentialEnvironment(configDirEnv(tmp, ["ANTHROPIC_IDENTITY_TOKEN_FILE": jwtPath.path])))
        let delegate = try provider.buildWorkloadDelegate(try provider.authBlock())
        #expect(try await delegate.identityTokenProvider() == "via-env-chain")
    }

    // -- "type": "authorized_user"

    @Test func authorizedUserRefreshAndWriteback() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user", "client_id": "cid", "scope": "x:y"], [
            "access_token": "old-tok", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "refresh-old",
        ])
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "new-tok", "expires_in": 3600, "refresh_token": "refresh-new"])

        let tok = try await file()()
        #expect(tok.token == "new-tok")
        #expect((tok.expiresAt ?? 0) > Int(Date().timeIntervalSince1970))
        #expect(route.callCount == 1)
        #expect(route.calls.first?.jsonBody == ["grant_type": "refresh_token", "refresh_token": "refresh-old", "client_id": "cid"])

        let credsFile = tmp.child("credentials", "default.json")
        let rewritten = try readJSON(credsFile)
        #expect(rewritten["version"] == "1.0")
        #expect(rewritten["type"] == "oauth_token")
        #expect(rewritten["access_token"] == "new-tok")
        #expect(rewritten["refresh_token"] == "refresh-new")
        #expect((rewritten["expires_at"]?.intValue ?? 0) > Int(Date().timeIntervalSince1970))
        #expect(!fileExistsAt(tmp.child("credentials", "default.json.tmp")))
        let leftovers = try FileManager.default.contentsOfDirectory(atPath: tmp.child("credentials").path)
        #expect(leftovers == ["default.json"])
        // The config file was not touched.
        #expect(try readJSON(tmp.child("configs", "default.json")) == ["authentication": ["type": "user_oauth", "client_id": "cid", "scope": "x:y"]])
    }

    @Test func authorizedUserFreshTokenNoRefresh() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user"], [
            "access_token": "still-good", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600), "refresh_token": "refresh-old",
        ])
        #expect(try await file()().token == "still-good")
    }

    @Test func authorizedUserRefreshFailure() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user", "client_id": "cid"], [
            "access_token": "old", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "rt",
        ])
        router.post(CREDS_TOKEN_URL, status: 400, json: ["error": "invalid_grant"])
        await expectThrows(WorkloadIdentityError.self, "refresh failed") { _ = try await file()() }
    }

    @Test func userOAuthWithoutClientIDIsStatic() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user"], [
            "access_token": "daemon-minted", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600),
        ])
        #expect(try await file()().token == "daemon-minted")
    }

    @Test func authorizedUserRefreshBetaHeaders() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user", "client_id": "cid"], [
            "access_token": "old", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "refresh-old",
        ])
        let route = router.post(CREDS_TOKEN_URL, json: ["access_token": "new-tok", "expires_in": 3600])
        _ = try await file()()
        let req = try #require(route.calls.first)
        let flags = Set((req.headers["anthropic-beta"] ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        #expect(flags.contains(OAUTH_API_BETA_HEADER))
        #expect(!flags.contains(FEDERATION_BETA_HEADER))
        #expect(req.headers["User-Agent"] == "anthropic-swift/\(ANTHROPIC_SDK_VERSION)")
    }

    @Test func userOAuthWithClientIDMissingRefreshToken() async throws {
        try writeProfile(tmp.url, "default", ["type": "authorized_user", "client_id": "cid"], [
            "access_token": "x", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1),
        ])
        await expectThrows(WorkloadIdentityError.self, "'refresh_token'") { _ = try await file()() }
    }

    // -- common error paths

    @Test func unknownType() async throws {
        try writeProfile(tmp.url, "default", ["type": "mystery"])
        await expectThrows(AnthropicError.self, "Unknown authentication.type") { _ = try await file()() }
    }

    @Test func missingConfigFile() async throws {
        try FileManager.default.createDirectory(at: tmp.child("configs"), withIntermediateDirectories: true)
        await expectThrows(AnthropicError.self, "Config file not found") { _ = try await file("nonexistent")() }
    }

    @Test func defaultCredentialsExplicitEnvPropagatesError() async throws {
        try writeText(tmp.child("configs", "broken.json"), "this is not JSON", mode: 0o644)
        let env = CredentialEnvironment(configDirEnv(tmp, ["ANTHROPIC_PROFILE": "broken"]))
        await expectThrows(AnthropicError.self, "not valid JSON") { _ = try defaultCredentials(environment: env, transport: router) }
    }

    // -- security: HTTPS enforcement

    @Test func configBaseURLHTTPRejected() async throws {
        try writeProfile(tmp.url, "default", ["type": "external", "base_url": "http://evil.example.com"], ["access_token": "x"])
        await expectThrows(AnthropicError.self, "must use https") { _ = try await file()() }
    }

    @Test func configBaseURLLocalhostHTTPAllowed() async throws {
        try writeProfile(tmp.url, "default", ["type": "external", "base_url": "http://localhost:8080"],
                         ["access_token": "x", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600)])
        #expect(try await file()().token == "x")
    }

    @Test func workloadIdentityHTTPRejected() async {
        let creds = WorkloadIdentityCredentials(identityTokenProvider: { "j" }, federationRuleID: "fdrl_x",
                                                organizationID: "00000000-0000-0000-0000-000000000000")
        await expectThrows(AnthropicError.self, "must use https") { try creds.bindBaseURL("http://evil.example.com") }
    }

    // -- security: profile-name validation

    @Test func profileNamePathTraversalRejected() async {
        await expectThrows(AnthropicError.self, "path separators") { _ = try await file("evil/shadow")() }
    }

    @Test func profileNameLeadingDotRejected() async {
        await expectThrows(AnthropicError.self, "must not start with a dot") { _ = try await file(".hidden")() }
    }

    @Test func profileNameEmptyRejected() async {
        await expectThrows(AnthropicError.self, "must not be empty") { _ = try await file("")() }
    }

    // -- security: credentials file permissions

    @Test(arguments: [0o644, 0o640, 0o604, 0o660, 0o620, 0o602])
    func credentialsFileGroupOrOtherAccessRejected(mode: Int) async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x"])
        try chmod(tmp.child("credentials", "default.json"), mode)
        await expectThrows(AnthropicError.self, "accessible by group or others (mode \(octalMode(mode)))") { _ = try await file()() }
    }

    @Test func credentialsFileOwnerOnlyAccepted() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600)])
        try chmod(tmp.child("credentials", "default.json"), 0o600)
        #expect(try await file()().token == "x")
    }

    @Test func credentialsFileSymlinkRejected() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x"])
        let real = tmp.child("credentials", "default.json")
        let target = tmp.child("real-secret.json")
        try FileManager.default.moveItem(at: real, to: target)
        try chmod(target, 0o600)
        try FileManager.default.createSymbolicLink(at: real, withDestinationURL: target)
        await expectThrows(AnthropicError.self, "symlink") { _ = try await file()() }
    }

    // -- security: config file permissions

    @Test(arguments: [0o664, 0o646, 0o666, 0o620, 0o602])
    func configFileGroupOrOtherWritableRejected(mode: Int) async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x"])
        try chmod(tmp.child("configs", "default.json"), mode)
        await expectThrows(AnthropicError.self, "writable by group or others (mode \(octalMode(mode)))") { _ = try await file()() }
    }

    @Test(arguments: [0o644, 0o640, 0o600])
    func configFileNotWritableByOthersAccepted(mode: Int) async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600)])
        try chmod(tmp.child("configs", "default.json"), mode)
        #expect(try await file()().token == "x")
    }

    @Test func configFileSymlinkChecksTargetMode() async throws {
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "x", "expires_at": .int(Int(Date().timeIntervalSince1970) + 3600)])
        // Like a Kubernetes ConfigMap volume, where each file is a symlink into `..data/`.
        let link = tmp.child("configs", "default.json")
        let target = tmp.child("configs", "..data", "default.json")
        try FileManager.default.createDirectory(at: target.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.moveItem(at: link, to: target)
        try FileManager.default.createSymbolicLink(atPath: link.path, withDestinationPath: "..data/default.json")
        try chmod(target, 0o644)
        #expect(try await file()().token == "x")

        try chmod(target, 0o666)
        await expectThrows(AnthropicError.self, "writable by group or others") { _ = try await file()() }
    }

    @Test func configFileSymlinkOutsideConfigDirRejected() async throws {
        let configDir = tmp.child("config-dir")
        let env = CredentialEnvironment(cleanEnv(tmp, ["ANTHROPIC_CONFIG_DIR": configDir.path]))
        try writeProfile(configDir, "default", ["type": "external"], ["access_token": "x"])
        let link = configDir.appendingPathComponent("configs").appendingPathComponent("default.json")
        let target = tmp.child("elsewhere.json")
        try FileManager.default.moveItem(at: link, to: target)
        try FileManager.default.createSymbolicLink(at: link, withDestinationURL: target)
        await expectThrows(AnthropicError.self, "escapes config directory") { _ = try await file(env: env)() }
    }

    // -- security: redacted error bodies

    @Test func workloadIdentityErrorBodyRedacted() {
        let long = String(repeating: "sensitive_", count: 100)
        let result = redactBody(.string(long))?.stringValue
        #expect((result?.count ?? .max) < long.count)
        #expect(result?.contains("... <") == true)

        let dirty: JSONValue = [
            "error": "invalid_grant", "error_description": "token expired",
            "assertion": "eyJleHAmple.jwt.sensitive", "refresh_token": "rt_sensitive",
        ]
        #expect(redactBody(dirty) == ["error": "invalid_grant", "error_description": "token expired"])
    }

    @Test func badConfigJSON() async throws {
        try writeText(tmp.child("configs", "default.json"), "{not json", mode: 0o644)
        await expectThrows(AnthropicError.self, "not valid JSON") { _ = try await file()() }
    }

    // -- profiles & paths

    @Test func explicitProfile() async throws {
        try writeProfile(tmp.url, "work", ["type": "external"], ["access_token": "work-tok"])
        try writeProfile(tmp.url, "default", ["type": "external"], ["access_token": "default-tok"])
        #expect(try await file("work")().token == "work-tok")
        #expect(try await file()().token == "default-tok")
    }

    @Test func profileFromEnv() async throws {
        try writeProfile(tmp.url, "from-env", ["type": "external"], ["access_token": "env-tok"])
        #expect(try await file(env: CredentialEnvironment(configDirEnv(tmp, ["ANTHROPIC_PROFILE": "from-env"])))().token == "env-tok")
    }

    @Test func profileFromActiveConfig() async throws {
        try writeProfile(tmp.url, "pointed-at", ["type": "external"], ["access_token": "active-tok"])
        try writeText(tmp.child("active_config"), "pointed-at\n")
        #expect(try await file()().token == "active-tok")
    }

    @Test func envOverridesActiveConfig() async throws {
        try writeProfile(tmp.url, "from-env", ["type": "external"], ["access_token": "env-tok"])
        try writeProfile(tmp.url, "from-file", ["type": "external"], ["access_token": "file-tok"])
        try writeText(tmp.child("active_config"), "from-file")
        #expect(try await file(env: CredentialEnvironment(configDirEnv(tmp, ["ANTHROPIC_PROFILE": "from-env"])))().token == "env-tok")
    }

    @Test func credentialsPathOverride() async throws {
        let custom = tmp.child("elsewhere", "secrets.json")
        try writeJSON(custom, ["access_token": "redirected"], mode: 0o600)
        try writeProfile(tmp.url, "default", ["type": "external", "credentials_path": .string(custom.path)])
        #expect(try await file()().token == "redirected")
    }

    @Test func baseURLFromConfig() async throws {
        try writeText(jwtPath, "x")
        try writeProfile(tmp.url, "default", [
            "type": "workload_identity", "base_url": "https://from-config.example.com",
            "identity_token": ["source": "file", "path": .string(jwtPath.path)], "federation_rule_id": "f", "organization_id": "o",
        ])
        let route = router.post("https://from-config.example.com/v1/oauth/token", json: ["access_token": "tok", "expires_in": 3600])
        _ = try await file()()
        #expect(route.calls.first?.url.absoluteString.hasPrefix("https://from-config.example.com/") == true)
    }

    // -- review fixes

    @Test func chainAndClassAgreeOnProfile() throws {
        try writeProfile(tmp.url, "agreed", ["type": "external"], ["access_token": "x"])
        let env = CredentialEnvironment(configDirEnv(tmp, ["ANTHROPIC_PROFILE": "agreed"]))
        let result = try #require(try defaultCredentials(environment: env, transport: router))
        let chain = try #require(result.provider as? CredentialsFile)
        let direct = try file(env: env)
        #expect(chain.profile == direct.profile)
        #expect(chain.profile == "agreed")
        #expect(chain.configPath == direct.configPath)
    }
}
