import Foundation
import Testing
@testable import Anthropic

// Port of `TestDefaultCredentials` and `TestDanglingActiveConfig` from
// `tests/lib/test_credentials.py`.
//
// Python patches `_config_dir` to point the default config directory somewhere; here `HOME`
// points at a temp directory, so `dir` (`<HOME>/.config/anthropic`) is the default config dir.

@Suite struct DefaultCredentialsTests {
    let tmp: TempDir
    let router = MockRouter()
    var dir: URL { tmp.defaultConfigDir }

    init() throws { tmp = try TempDir() }

    func resolve(_ extra: [String: String] = [:]) throws -> CredentialResult? {
        try defaultCredentials(environment: CredentialEnvironment(cleanEnv(tmp, extra)), transport: router)
    }

    let federationTrio = [
        "ANTHROPIC_IDENTITY_TOKEN": "literal-jwt", "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc",
        "ANTHROPIC_ORGANIZATION_ID": "00000000-0000-0000-0000-000000000000",
    ]

    @Test func apiKeyReturnsNil() throws {
        #expect(try resolve(["ANTHROPIC_API_KEY": "sk-ant-api-key"]) == nil)
    }

    @Test func authTokenReturnsStatic() async throws {
        let result = try #require(try resolve(["ANTHROPIC_AUTH_TOKEN": "bearer-tok"]))
        #expect(result.provider is StaticToken)
        #expect(try await result.provider().token == "bearer-tok")
    }

    @Test func configDirEnvTriggersTier1() async throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "from-file"])
        let result = try #require(try resolve(["ANTHROPIC_CONFIG_DIR": dir.path]))
        #expect(result.provider is CredentialsFile)
        #expect(try await result.provider().token == "from-file")
    }

    @Test func profileEnvTriggersTier1() async throws {
        try writeProfile(dir, "work", ["type": "external"], ["access_token": "from-work"])
        let result = try #require(try resolve(["ANTHROPIC_PROFILE": "work"]))
        #expect(result.provider is CredentialsFile)
        #expect(try await result.provider().token == "from-work")
    }

    @Test func defaultDirWithConfigsTriggersTier1() throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "from-default"])
        let result = try #require(try resolve())
        #expect(result.provider is CredentialsFile)
    }

    @Test func workloadIdentityTier() throws {
        let f = tmp.child("jwt")
        try writeText(f, "ext-jwt")
        let result = try #require(try resolve([
            "ANTHROPIC_IDENTITY_TOKEN_FILE": f.path, "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc", "ANTHROPIC_ORGANIZATION_ID": "org-uuid",
        ]))
        #expect(result.provider is WorkloadIdentityCredentials)
    }

    @Test func workloadIdentityLiteralToken() throws {
        let result = try #require(try resolve(federationTrio))
        #expect(result.provider is WorkloadIdentityCredentials)
    }

    @Test func workloadIdentityScopeEnv() throws {
        let result = try #require(try resolve(federationTrio.merging(["ANTHROPIC_SCOPE": "api:read api:write"]) { $1 }))
        let p = try #require(result.provider as? WorkloadIdentityCredentials)
        #expect(p.scope == "api:read api:write")
    }

    @Test func workloadIdentityWorkspaceIDEnv() throws {
        let result = try #require(try resolve(federationTrio.merging(["ANTHROPIC_WORKSPACE_ID": "wrkspc_01abc"]) { $1 }))
        let p = try #require(result.provider as? WorkloadIdentityCredentials)
        #expect(p.workspaceID == "wrkspc_01abc")
    }

    /// `ANTHROPIC_WORKSPACE_ID=""` is treated as unset — never `"workspace_id": ""` on the wire.
    @Test func workloadIdentityWorkspaceIDEnvEmptyTreatedUnset() async throws {
        router.post(CREDS_TOKEN_URL, json: ["access_token": "t", "expires_in": 60])
        let result = try #require(try resolve(federationTrio.merging(["ANTHROPIC_WORKSPACE_ID": ""]) { $1 }))
        let p = try #require(result.provider as? WorkloadIdentityCredentials)
        #expect(p.workspaceID == nil)
        _ = try await p()
        #expect(router.calls.first?.jsonBody?["workspace_id"] == nil)
    }

    /// `ANTHROPIC_IDENTITY_TOKEN` is re-read on every provider invocation.
    @Test func workloadIdentityLiteralTokenReadsFresh() async throws {
        let env = MutableEnvironment(cleanEnv(tmp, federationTrio.merging(["ANTHROPIC_IDENTITY_TOKEN": "jwt-v1"]) { $1 }))
        let result = try #require(try defaultCredentials(environment: env.environment, transport: router))
        let p = try #require(result.provider as? WorkloadIdentityCredentials)
        #expect(try await p.identityTokenProvider() == "jwt-v1")
        env["ANTHROPIC_IDENTITY_TOKEN"] = "jwt-v2"
        #expect(try await p.identityTokenProvider() == "jwt-v2")
    }

    @Test func workloadIdentityRequiresAllThree() throws {
        #expect(try resolve(["ANTHROPIC_IDENTITY_TOKEN": "literal-jwt", "ANTHROPIC_FEDERATION_RULE_ID": "fdrl_01abc"]) == nil)
    }

    @Test func envFederationBeatsFallbackOnDiskProfile() throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "from-on-disk-profile"])
        #expect(try resolve(federationTrio)?.provider is WorkloadIdentityCredentials)
    }

    @Test func envFederationBeatsActiveConfigPointer() throws {
        try writeText(dir.appendingPathComponent("active_config"), "prod")
        try writeProfile(dir, "prod", ["type": "external"], ["access_token": "from-prod"])
        #expect(try resolve(federationTrio)?.provider is WorkloadIdentityCredentials)
    }

    @Test func emptyIdentityTokenDoesNotBeatActiveProfile() throws {
        try writeText(dir.appendingPathComponent("active_config"), "prod")
        try writeProfile(dir, "prod", ["type": "external"], ["access_token": "from-prod"])
        #expect(try resolve(federationTrio.merging(["ANTHROPIC_IDENTITY_TOKEN": ""]) { $1 })?.provider is CredentialsFile)
    }

    /// `ANTHROPIC_CONFIG_DIR` says where profiles are looked up. It selects none.
    @Test func envFederationBeatsProfileInConfigDirEnv() throws {
        try writeProfile(dir, "default", ["type": "external"], ["access_token": "from-on-disk-profile"])
        #expect(try resolve(federationTrio.merging(["ANTHROPIC_CONFIG_DIR": dir.path]) { $1 })?.provider is WorkloadIdentityCredentials)
    }

    @Test func envFederationDoesNotReadBrokenProfileInConfigDirEnv() throws {
        try writeText(dir.appendingPathComponent("configs").appendingPathComponent("default.json"), "this is not JSON")
        #expect(try resolve(federationTrio.merging(["ANTHROPIC_CONFIG_DIR": dir.path]) { $1 })?.provider is WorkloadIdentityCredentials)
    }

    @Test func configDirEnvPropagatesError() async throws {
        try writeText(dir.appendingPathComponent("configs").appendingPathComponent("default.json"), "this is not JSON", mode: 0o644)
        await expectThrows(AnthropicError.self, "not valid JSON") { _ = try resolve(["ANTHROPIC_CONFIG_DIR": dir.path]) }
    }

    @Test func autoDiscoveredProfileErrorIsSilentFallthrough() throws {
        try writeText(dir.appendingPathComponent("configs").appendingPathComponent("default.json"), "this is not JSON", mode: 0o644)
        #expect(try resolve() == nil)
    }

    /// Step 3 (`ANTHROPIC_PROFILE`) sits above step 4 (env federation).
    @Test func explicitProfileBeatsEnvFederation() async throws {
        try writeProfile(dir, "dev", ["type": "external"], ["access_token": "from-dev-profile"])
        let result = try #require(try resolve(federationTrio.merging(["ANTHROPIC_PROFILE": "dev"]) { $1 }))
        #expect(result.provider is CredentialsFile)
        #expect(try await result.provider().token == "from-dev-profile")
    }

    @Test func nothingSetReturnsNil() throws {
        #expect(try resolve() == nil)
    }
}
