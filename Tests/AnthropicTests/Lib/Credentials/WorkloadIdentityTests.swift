import Foundation
import Testing
@testable import Anthropic

// Port of `TestWorkloadIdentityCredentials`, `TestProfileEnvFill` and `TestIdentityTokenValidation`
// from `tests/lib/test_credentials.py`.

@Suite struct WorkloadIdentityCredentialsTests {
    let router = MockRouter()

    func creds(_ jwt: @escaping @Sendable () async throws -> String = { "j" }, rule: String = "f", org: String = "o",
               serviceAccountID: String? = nil, workspaceID: String? = nil, scope: String? = nil) -> WorkloadIdentityCredentials
    {
        WorkloadIdentityCredentials(identityTokenProvider: jwt, federationRuleID: rule, organizationID: org,
                                    serviceAccountID: serviceAccountID, workspaceID: workspaceID, scope: scope, transport: router)
    }

    @Test func exchange() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "sk-ant-oat01-test", "token_type": "Bearer", "expires_in": 600])
        let c = creds({ "ext.jwt.value" }, rule: "fdrl_01abc", org: "00000000-0000-0000-0000-000000000000")
        let before = Int(Date().timeIntervalSince1970)
        let token = try await c()
        let after = Int(Date().timeIntervalSince1970)
        #expect(token.token == "sk-ant-oat01-test")
        let expiresAt = try #require(token.expiresAt)
        #expect(before + 600 - 2 <= expiresAt && expiresAt <= after + 600 + 2)

        #expect(router.calls.count == 1)
        let req = try #require(router.calls.first)
        let flags = Set((req.headers["anthropic-beta"] ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        #expect(flags.contains(OAUTH_API_BETA_HEADER))
        #expect(flags.contains(FEDERATION_BETA_HEADER))
        #expect(req.headers["User-Agent"] == "anthropic-swift/\(ANTHROPIC_SDK_VERSION)")
        let body = try #require(req.jsonBody)
        #expect(body["grant_type"] == .string(GRANT_TYPE_JWT_BEARER))
        #expect(body["assertion"] == "ext.jwt.value")
        #expect(body["federation_rule_id"] == "fdrl_01abc")
        #expect(body["organization_id"] == "00000000-0000-0000-0000-000000000000")
        #expect(body["service_account_id"] == nil)
        #expect(body["workspace_id"] == nil)
        #expect(body["scope"] == nil)
    }

    @Test func serviceAccountIncluded() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        _ = try await creds(rule: "fdrl_01abc", org: "org", serviceAccountID: "svac_01xyz")()
        let body = try #require(router.calls.first?.jsonBody)
        #expect(body["service_account_id"] == "svac_01xyz")
        #expect(body["scope"] == nil)
    }

    @Test func workspaceIDIncluded() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        _ = try await creds(rule: "fdrl_01abc", org: "org", workspaceID: "wrkspc_01abc")()
        #expect(router.calls.first?.jsonBody?["workspace_id"] == "wrkspc_01abc")
    }

    @Test func workspaceIDDefaultSentinel() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        _ = try await creds(rule: "fdrl_01abc", org: "org", workspaceID: "default")()
        #expect(router.calls.first?.jsonBody?["workspace_id"] == "default")
    }

    @Test func scopeIsDisplayOnly() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        let c = creds(rule: "fdrl_x", org: "org", scope: "api:read api:write")
        _ = try await c()
        #expect(c.scope == "api:read api:write")
        #expect(router.calls.first?.jsonBody?["scope"] == nil)
    }

    @Test func exchangeFederationAssertionHelper() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "sk-ant-oat01-one", "expires_in": 600])
        let token = try await exchangeFederationAssertion(assertion: "ext.jwt.value", federationRuleID: "fdrl_x", organizationID: "org_x",
                                                          workspaceID: "wrkspc_x", transport: router)
        #expect(token.token == "sk-ant-oat01-one")
        let body = try #require(router.calls.first?.jsonBody)
        #expect(body["assertion"] == "ext.jwt.value")
        #expect(body["federation_rule_id"] == "fdrl_x")
        #expect(body["workspace_id"] == "wrkspc_x")
    }

    @Test func bindBaseURL() async throws {
        let bound = "https://bound.example"
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        _ = try await creds(rule: "fdrl_x", org: "org")()
        #expect(router.calls.last?.url.absoluteString == CREDS_TOKEN_URL)

        router.post("\(bound)\(TOKEN_ENDPOINT)", json: ["access_token": "t", "expires_in": 60])
        let c = creds(rule: "fdrl_x", org: "org")
        try c.bindBaseURL(bound)
        _ = try await c()
        #expect(router.calls.last?.url.absoluteString == "\(bound)\(TOKEN_ENDPOINT)")
    }

    @Test func bindBaseURLHTTPRejected() async {
        await expectThrows(AnthropicError.self, "must use https") { try creds(rule: "fdrl_x", org: "org").bindBaseURL("http://evil.example") }
    }

    @Test func forBaseURL() async throws {
        router.mockTokenExchange(CREDS_BASE_URL, "tok-primary")
        router.mockTokenExchange(OTHER_BASE_URL, "tok-other")
        let c = workloadCredentials(router)
        #expect(try c.forBaseURL("\(CREDS_BASE_URL)/") as AnyObject === c)
        #expect(try c.forBaseURL(CREDS_BASE_URL) as AnyObject === c)
        let other = try c.forBaseURL(OTHER_BASE_URL)
        #expect(other as AnyObject !== c)

        #expect(try await other().token == "tok-other")
        #expect(try await c().token == "tok-primary")
        // The per-host provider borrows the original's transport, so closing it must not take the
        // original down with it.
        await other.close()
        #expect(!router.isClosed)
        #expect(try await c().token == "tok-primary")
        #expect(router.requests(to: CREDS_BASE_URL).map { $0.url.absoluteString } == [CREDS_TOKEN_URL, CREDS_TOKEN_URL])
    }

    @Test func forBaseURLHTTPRejected() async throws {
        let c = workloadCredentials(router)
        _ = try c.forBaseURL(CREDS_BASE_URL)
        await expectThrows(AnthropicError.self, "must use https") { _ = try c.forBaseURL("http://evil.example") }
    }

    @Test func exchangeFederationAssertionHTTPRejected() async {
        await expectThrows(AnthropicError.self, "must use https") {
            _ = try await exchangeFederationAssertion(assertion: "j", federationRuleID: "fdrl_x", organizationID: "org_x",
                                                      baseURL: "http://example.com", transport: router)
        }
    }

    @Test func reinvokesIdentityProvider() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        let counter = Counter()
        let c = creds({ "jwt-\(counter.next() + 1)" })
        _ = try await c()
        _ = try await c()
        #expect(counter.count == 2)
        let bodies = router.calls.map { $0.jsonBody }
        #expect(bodies[0]?["assertion"] == "jwt-1")
        #expect(bodies[1]?["assertion"] == "jwt-2")
    }

    @Test func status403Raises() async {
        router.post(CREDS_TOKEN_URL, status: 403, json: ["error": "assertion rejected"])
        let err = await expectThrows(WorkloadIdentityError.self) { _ = try await creds()() }
        #expect(err?.statusCode == 403)
        #expect(err.map { String(describing: $0) }?.contains("assertion rejected") == true)
    }

    @Test func status503Raises() async {
        router.post(CREDS_TOKEN_URL) { HTTPResponse.text("overloaded", status: 503, for: $0) }
        let err = await expectThrows(WorkloadIdentityError.self) { _ = try await creds()() }
        #expect(err?.statusCode == 503)
    }

    @Test func requestIDSurfacedOnError() async {
        router.post(CREDS_TOKEN_URL, status: 400, json: ["error": "invalid_grant"], headers: ["Request-Id": "req_abc123"])
        let err = await expectThrows(WorkloadIdentityError.self) { _ = try await creds()() }
        #expect(err?.requestID == "req_abc123")
        #expect(err.map { String(describing: $0) }?.contains("[request_id=req_abc123]") == true)
    }

    @Test func status401WithoutWorkspaceIDIncludesHint() async {
        router.post(CREDS_TOKEN_URL, status: 401, json: ["error": "unauthorized"])
        let message = await expectThrows(WorkloadIdentityError.self) { _ = try await creds()() }.map { String(describing: $0) } ?? ""
        #expect(message.contains("Ensure your federation rule matches your identity token"))
        #expect(message.contains("ANTHROPIC_WORKSPACE_ID"))
        #expect(message.contains("scoped to multiple workspaces"))
        #expect(message.contains("workspace_id"))
        #expect(message.contains("View your authentication events"))
    }

    @Test func status401WithWorkspaceIDSetOmitsWorkspaceHint() async {
        router.post(CREDS_TOKEN_URL, status: 401, json: ["error": "unauthorized"])
        let message = await expectThrows(WorkloadIdentityError.self) { _ = try await creds(workspaceID: "wrkspc_x")() }
            .map { String(describing: $0) } ?? ""
        #expect(message.contains("Ensure your federation rule matches your identity token"))
        #expect(message.contains("View your authentication events"))
        #expect(!message.contains("ANTHROPIC_WORKSPACE_ID"))
        #expect(!message.contains("scoped to multiple workspaces"))
    }

    @Test func non401OmitsHint() async {
        router.post(CREDS_TOKEN_URL, status: 500, json: ["error": "server_error"])
        let message = await expectThrows(WorkloadIdentityError.self) { _ = try await creds()() }.map { String(describing: $0) } ?? ""
        #expect(!message.contains("Ensure your federation rule"))
        #expect(!message.contains("ANTHROPIC_WORKSPACE_ID"))
        #expect(!message.contains("View your authentication events"))
    }

    @Test func oversizedAssertionRejected() async {
        let big = String(repeating: "x", count: 16 * 1024 + 1)
        await expectThrows(WorkloadIdentityError.self, "exceeds the 16384-byte limit") { _ = try await creds({ big })() }
    }

    @Test func nonBearerTokenTypeRejected() async {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60, "token_type": "MAC"])
        await expectThrows(WorkloadIdentityError.self, "unsupported token_type 'MAC'") { _ = try await creds()() }
    }

    @Test func bearerTokenTypeCaseInsensitive() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60, "token_type": "bearer"])
        #expect(try await creds()().token == "t")
    }

    @Test func oversizedResponseBodyRejected() async {
        router.post(CREDS_TOKEN_URL) { HTTPResponse(statusCode: 200, body: Data(repeating: UInt8(ascii: "x"), count: (1 << 20) + 1), request: $0) }
        await expectThrows(WorkloadIdentityError.self, "response body exceeds") { _ = try await creds()() }
    }
}

/// Profile fields left empty are filled from `ANTHROPIC_*` variables (the file wins, the
/// environment fills gaps).
@Suite struct ProfileEnvFillTests {
    let tmp: TempDir
    init() throws { tmp = try TempDir() }

    func provider(_ extra: [String: String]) throws -> CredentialsFile {
        try CredentialsFile(transport: MockRouter(), environment: CredentialEnvironment(configDirEnv(tmp, extra)))
    }

    @Test func envFillsMissingOrganizationID() throws {
        try writeText(tmp.child("tok"), "jwt")
        try writeProfile(tmp.url, "default", ["authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_01abc"]])
        let p = try provider(["ANTHROPIC_ORGANIZATION_ID": "org_from_env", "ANTHROPIC_IDENTITY_TOKEN_FILE": tmp.child("tok").path])
        let delegate = try p.buildWorkloadDelegate(try p.authBlock())
        #expect(delegate.organizationID == "org_from_env")
    }

    @Test func profileValueWinsOverEnv() throws {
        try writeText(tmp.child("tok"), "jwt")
        try writeProfile(tmp.url, "default", [
            "organization_id": "org_from_file", "workspace_id": "wrkspc_file",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_01abc"],
        ])
        let p = try provider(["ANTHROPIC_ORGANIZATION_ID": "org_from_env", "ANTHROPIC_WORKSPACE_ID": "wrkspc_env",
                              "ANTHROPIC_IDENTITY_TOKEN_FILE": tmp.child("tok").path])
        let delegate = try p.buildWorkloadDelegate(try p.authBlock())
        #expect(delegate.organizationID == "org_from_file")
        #expect(delegate.workspaceID == "wrkspc_file")
    }

    @Test func envFillsMissingWorkspaceID() throws {
        try writeText(tmp.child("tok"), "jwt")
        try writeProfile(tmp.url, "default", ["authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_01abc"]])
        let p = try provider(["ANTHROPIC_ORGANIZATION_ID": "org_x", "ANTHROPIC_WORKSPACE_ID": "wrkspc_from_env",
                              "ANTHROPIC_IDENTITY_TOKEN_FILE": tmp.child("tok").path])
        let delegate = try p.buildWorkloadDelegate(try p.authBlock())
        #expect(delegate.workspaceID == "wrkspc_from_env")
    }

    @Test func envWorkspaceIDFillsUserOAuth() throws {
        let credsPath = tmp.child("creds.json")
        try writeJSON(credsPath, ["type": "oauth_token", "access_token": "tok", "expires_at": nil])
        try writeProfile(tmp.url, "default", [
            "authentication": ["type": "user_oauth", "client_id": "cid", "credentials_path": .string(credsPath.path)],
        ])
        #expect(try provider(["ANTHROPIC_WORKSPACE_ID": "wrkspc_env"]).extraHeaders() == ["anthropic-workspace-id": "wrkspc_env"])
    }
}

/// `identity_token.source` "file" with an empty path is a config bug, not an env-var fallback signal.
@Suite struct IdentityTokenValidationTests {
    @Test func emptyPathRaises() async throws {
        let tmp = try TempDir()
        try writeProfile(tmp.url, "default", [
            "organization_id": "org",
            "authentication": ["type": "oidc_federation", "federation_rule_id": "fdrl_01abc", "identity_token": ["source": "file", "path": ""]],
        ])
        let p = try CredentialsFile(transport: MockRouter(), environment: CredentialEnvironment(configDirEnv(tmp)))
        await expectThrows(AnthropicError.self, "non-empty path") { _ = try p.buildWorkloadDelegate(try p.authBlock()) }
    }
}
