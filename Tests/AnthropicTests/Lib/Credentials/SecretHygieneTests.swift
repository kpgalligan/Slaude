import Foundation
import Testing
@testable import Anthropic

// Port of `TestNoSecretsInTracebackFrameLocals` from `tests/lib/test_credentials.py`.
//
// Python checks that no traceback frame local holds credential material, because crash reporters
// render frame locals. Swift errors carry no frames; what a crash reporter or log line sees is the
// error itself, so these tests check that the thrown error — its description, debug description
// and reflection dump (which walks every stored property, including `body`) — holds none of the
// secrets.

let SECRET_ASSERTION = "eyJ-SECRET-ASSERTION-MATERIAL-eyJ"
let SECRET_MINTED = "sk-ant-oat01-MINTED-SECRET"

/// `_assert_not_in_sdk_frame_locals`, for the error value.
func expectNoSecrets(_ error: Error?, _ secrets: String..., sourceLocation: SourceLocation = #_sourceLocation) {
    guard let error else {
        Issue.record("expected an error", sourceLocation: sourceLocation)
        return
    }
    var dumped = ""
    dump(error, to: &dumped)
    let renderings = [String(describing: error), String(reflecting: error), dumped, error.localizedDescription]
    for secret in secrets {
        for r in renderings {
            #expect(!r.contains(secret), "secret retained in \(r)", sourceLocation: sourceLocation)
        }
    }
}

@Suite struct SecretHygieneTests {
    let tmp: TempDir
    let router = MockRouter()
    init() throws { tmp = try TempDir() }

    func workloadProvider(_ handler: @escaping MockRouter.Responder) throws -> WorkloadIdentityCredentials {
        router.post(CREDS_TOKEN_URL, handler)
        let creds = WorkloadIdentityCredentials(identityTokenProvider: { SECRET_ASSERTION }, federationRuleID: "fdrl_01abc",
                                                organizationID: "org-uuid", transport: router)
        try creds.bindBaseURL(CREDS_BASE_URL)
        return creds
    }

    @Test func http4xxDoesNotRetainAssertion() async throws {
        let p = try workloadProvider { HTTPResponse.json(["error": "invalid_grant"], status: 401, for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, SECRET_ASSERTION)
    }

    @Test(arguments: ["\"NaN\"", "1e400"])
    func invalidExpiresInDoesNotRetainMintedToken(expiresIn: String) async throws {
        let p = try workloadProvider { HTTPResponse.text("{\"access_token\": \"\(SECRET_MINTED)\", \"expires_in\": \(expiresIn)}", for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, SECRET_ASSERTION, SECRET_MINTED)
    }

    @Test func tokenTypeMismatchDoesNotRetainMintedToken() async throws {
        let p = try workloadProvider {
            HTTPResponse.json(["access_token": .string(SECRET_MINTED), "expires_in": 600, "token_type": "MAC"], for: $0)
        }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, SECRET_ASSERTION, SECRET_MINTED)
    }

    @Test func nonJSONResponseDoesNotRetainAssertion() async throws {
        let p = try workloadProvider { HTTPResponse.text("<html>gateway error</html>", for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, SECRET_ASSERTION)
    }

    /// A 200 whose body is a JSON *string* echoing the assertion is rejected without echoing it.
    @Test func jsonStringEchoResponseDoesNotRetainAssertion() async throws {
        let p = try workloadProvider { HTTPResponse.json(.string(SECRET_ASSERTION), for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self, "expected an object") { _ = try await p() }, SECRET_ASSERTION)
    }

    @Test func transportErrorDoesNotRetainAssertion() async throws {
        let p = try workloadProvider { _ in throw URLError(.cannotConnectToHost) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, SECRET_ASSERTION)
    }

    @Test func oversizedAssertionNotRetained() async {
        let big = String(repeating: "A", count: 17 * 1024)
        let p = WorkloadIdentityCredentials(identityTokenProvider: { big }, federationRuleID: "fdrl_01abc", organizationID: "org-uuid",
                                            transport: router)
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await p() }, big)
    }

    func writeRefreshProfile(_ extra: [String: JSONValue] = [:]) throws {
        var creds: [String: JSONValue] = [
            "access_token": "old-access-SECRET", "expires_at": .int(Int(Date().timeIntervalSince1970) - 1), "refresh_token": "rt-SECRET",
        ]
        creds.merge(extra) { $1 }
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"], creds)
    }

    func file() throws -> CredentialsFile {
        try CredentialsFile(transport: router, environment: CredentialEnvironment(cleanEnv(tmp)))
    }

    var credsPath: URL { tmp.defaultConfigDir.appendingPathComponent("credentials").appendingPathComponent("default.json") }

    @Test func refreshFailureDoesNotRetainRefreshToken() async throws {
        try writeRefreshProfile()
        router.post(CREDS_TOKEN_URL, status: 400, json: ["error": "invalid_grant"])
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await file()() }, "rt-SECRET", "old-access-SECRET")
    }

    @Test(arguments: ["\"NaN\"", "1e400"])
    func refreshInvalidExpiresDoesNotRetainNewToken(expiresIn: String) async throws {
        try writeRefreshProfile()
        router.post(CREDS_TOKEN_URL) { HTTPResponse.text("{\"access_token\": \"\(SECRET_MINTED)\", \"expires_in\": \(expiresIn)}", for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) { _ = try await file()() }, "rt-SECRET", "old-access-SECRET", SECRET_MINTED)
    }

    @Test func refreshNonJSONResponseRaisesRedactedError() async throws {
        try writeRefreshProfile()
        router.post(CREDS_TOKEN_URL) { HTTPResponse.text("<html>gateway error</html>", for: $0) }
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self, "non-JSON") { _ = try await file()() }, "rt-SECRET", "old-access-SECRET")
    }

    @Test func refreshJSONArrayResponseRaisesRedactedError() async throws {
        try writeRefreshProfile()
        router.post(CREDS_TOKEN_URL, json: ["rt-SECRET"])
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self, "expected an object") { _ = try await file()() }, "rt-SECRET", "old-access-SECRET")
    }

    @Test func scalarCredentialsFileDoesNotRetainToken() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"])
        try writeText(credsPath, "\"rt-SECRET\"", mode: 0o600)
        expectNoSecrets(await expectThrows(AnthropicError.self, "must contain a JSON object, not str") { _ = try await file()() }, "rt-SECRET")
    }

    /// The redaction is a rendering concern only: the refresh POST body and the persisted file carry
    /// the raw values, including unknown string fields.
    @Test func refreshSuccessWritesRawTokensToDiskAndWire() async throws {
        try writeRefreshProfile(["id_token": "idt-SECRET"])
        router.post(CREDS_TOKEN_URL, json: ["access_token": "new-access", "expires_in": 3600, "refresh_token": "rt-NEW"])
        #expect(try await file()().token == "new-access")
        #expect(router.calls.last?.jsonBody == ["grant_type": "refresh_token", "refresh_token": "rt-SECRET", "client_id": "cid"])
        let onDisk = try readJSON(credsPath)
        #expect(onDisk["access_token"] == "new-access")
        #expect(onDisk["refresh_token"] == "rt-NEW")
        #expect(onDisk["id_token"] == "idt-SECRET")
    }

    @Test func missingAccessTokenDoesNotRetainRefreshToken() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"], ["refresh_token": "rt-SECRET"])
        expectNoSecrets(await expectThrows(AnthropicError.self, "missing 'access_token'") { _ = try await file()() }, "rt-SECRET")
    }

    @Test func invalidJSONCredentialsDoesNotRetainRawText() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"])
        try writeText(credsPath, "{\"refresh_token\": \"rt-SECRET\", ", mode: 0o600)
        expectNoSecrets(await expectThrows(AnthropicError.self, "not valid JSON") { _ = try await file()() }, "rt-SECRET")
    }

    @Test func credentialsTypeMismatchDoesNotRetainTokens() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"],
                         ["type": "wrong_type", "access_token": "at-SECRET", "refresh_token": "rt-SECRET"])
        expectNoSecrets(await expectThrows(AnthropicError.self, "has type") { _ = try await file()() }, "at-SECRET", "rt-SECRET")
    }

    @Test func corruptExpiresAtDoesNotRetainTokens() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "authorized_user", "client_id": "cid"],
                         ["access_token": "at-SECRET", "expires_at": "tomorrow", "refresh_token": "rt-SECRET", "id_token": "idt-SECRET"])
        expectNoSecrets(await expectThrows(AnthropicError.self, "invalid 'expires_at'") { _ = try await file()() }, "at-SECRET", "rt-SECRET", "idt-SECRET")
    }

    @Test func corruptExpiresAtExternalProfileDoesNotRetainToken() async throws {
        try writeProfile(tmp.defaultConfigDir, "default", ["type": "external"], ["access_token": "at-SECRET", "expires_at": "tomorrow"])
        expectNoSecrets(await expectThrows(AnthropicError.self, "invalid 'expires_at'") { _ = try await file()() }, "at-SECRET")
    }

    /// A refresh that succeeds but fails to persist throws (the refresh token may have rotated
    /// server-side), without the tokens in the error. Python makes `mkstemp` fail; here the
    /// credentials directory is made read-only, which root ignores.
    @Test(.disabled(if: runningAsRoot, "root bypasses POSIX mode bits"))
    func failedWritebackAfterRefreshDoesNotRetainTokens() async throws {
        try writeRefreshProfile()
        router.post(CREDS_TOKEN_URL, json: ["access_token": .string(SECRET_MINTED), "expires_in": 3600, "refresh_token": "rt-NEW-SECRET"])
        let dir = credsPath.deletingLastPathComponent()
        try chmod(dir, 0o500)
        defer { try? chmod(dir, 0o700) }
        expectNoSecrets(await expectThrows(CredentialsError.self, "could not be written") { _ = try await file()() },
                        "rt-SECRET", "old-access-SECRET", SECRET_MINTED, "rt-NEW-SECRET")
    }

    @Test func oneshotExchangeFailureDoesNotRetainAssertion() async {
        router.post(CREDS_TOKEN_URL, status: 401, json: ["error": "invalid_grant"])
        expectNoSecrets(await expectThrows(WorkloadIdentityError.self) {
            _ = try await exchangeFederationAssertion(assertion: SECRET_ASSERTION, federationRuleID: "fdrl_01abc", organizationID: "org-uuid",
                                                      baseURL: CREDS_BASE_URL, transport: router)
        }, SECRET_ASSERTION)
    }

    /// Parsed credential payloads render every non-plumbing string masked — unknown fields too —
    /// while reading back (and serializing) the raw values (`_wrap_secret_fields`).
    @Test func secretPayloadRendersRedacted() throws {
        let payload = try SecretPayload.parse(Data(#"{"access_token": "at-SECRET", "id_token": "idt-SECRET", "type": "oauth_token", "expires_at": 5}"#.utf8))
        var dumped = ""
        dump(payload, to: &dumped)
        for r in [String(describing: payload), String(reflecting: payload), dumped] {
            #expect(!r.contains("at-SECRET"))
            #expect(!r.contains("idt-SECRET"))
            #expect(r.contains("oauth_token"))
        }
        #expect(payload["access_token"] == "at-SECRET")
        #expect(try JSONValue.parse(try payload.serialized())["id_token"] == "idt-SECRET")
        #expect(throws: NonObjectPayloadError.self) { _ = try SecretPayload.parse(Data(#""rt-SECRET""#.utf8)) }
    }
}
