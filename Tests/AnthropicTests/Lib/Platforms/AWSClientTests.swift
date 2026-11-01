import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_aws.py. Each test passes an isolated environment (the `monkeypatch`
// setenv / delenv calls become entries of that dictionary).

private let ambientFirstParty = ["ANTHROPIC_API_KEY": "ambient-key", "ANTHROPIC_AUTH_TOKEN": "ambient-token"]

private func awsClient(_ recorder: RequestRecorder? = nil, apiKey: String? = nil, access: String? = nil, secret: String? = nil,
                       region: String? = nil, profile: String? = nil, token: String? = nil, workspace: String? = nil,
                       skipAuth: Bool = false, baseURL: String? = nil, headers: Headers? = nil,
                       env: [String: String] = [:]) throws -> AnthropicAWS
{
    try AnthropicAWS(apiKey: apiKey, awsAccessKey: access, awsSecretKey: secret, awsRegion: region, awsProfile: profile,
                     awsSessionToken: token, workspaceID: workspace, skipAuth: skipAuth, baseURL: baseURL, defaultHeaders: headers,
                     transport: (recorder ?? RequestRecorder()).transport, environment: isolatedEnv(env))
}

private func sigv4Client(_ recorder: RequestRecorder? = nil, region: String = "us-east-1", headers: Headers? = nil,
                         env: [String: String] = [:]) throws -> AnthropicAWS
{
    try awsClient(recorder, access: "AKID", secret: "secret", region: region, workspace: "ws-123", headers: headers, env: env)
}

private func send(_ client: Anthropic, workspaceID: String? = nil, userProfileID: String? = nil) async throws {
    _ = try await client.messages.create(maxTokens: 1024, messages: userMessages("Hello"), model: "claude-sonnet-4-20250514",
                                         userProfileID: userProfileID, workspaceID: workspaceID)
}

@Suite struct AWSInitTests {
    @Test func apiKeyMode() throws {
        let client = try awsClient(apiKey: "test-key", region: "us-east-1", workspace: "ws-123")
        #expect(client.apiKey == "test-key")
        #expect(client.useSigV4 == false)
    }

    @Test func sigv4ExplicitCreds() throws {
        let client = try awsClient(access: "AKID", secret: "secret", region: "us-west-2", workspace: "ws-123")
        #expect(client.useSigV4)
        #expect(client.apiKey == nil)
        #expect(client.awsAccessKey == "AKID")
        #expect(client.awsSecretKey == "secret")
    }

    @Test func sigv4Profile() throws {
        let client = try awsClient(region: "eu-west-1", profile: "my-profile", workspace: "ws-123")
        #expect(client.useSigV4)
        #expect(client.awsProfile == "my-profile")
    }

    @Test func sigv4DefaultCredentialChain() throws {
        let client = try awsClient(region: "us-east-1", workspace: "ws-123")
        #expect(client.useSigV4)
        #expect(client.apiKey == nil)
    }

    @Test func requiresRegionForSigV4() async {
        await expectThrows(AnthropicError.self, matching: "No AWS region was provided") {
            _ = try awsClient(access: "AKID", secret: "secret", workspace: "ws-123")
        }
    }

    @Test func requiresWorkspaceID() async {
        await expectThrows(AnthropicError.self, matching: "No workspace ID found") { _ = try awsClient(apiKey: "test-key", region: "us-east-1") }
    }

    @Test func workspaceIDFromEnv() throws {
        let client = try awsClient(apiKey: "test-key", region: "us-east-1", env: ["ANTHROPIC_AWS_WORKSPACE_ID": "env-workspace"])
        #expect(client.workspaceID == "env-workspace")
    }

    @Test func partialCredsAccessKeyOnly() async {
        await expectThrows(ValueError.self, matching: "aws_access_key.*without.*aws_secret_key") {
            _ = try awsClient(access: "AKID", region: "us-east-1", workspace: "ws-123")
        }
    }

    @Test func partialCredsSecretKeyOnly() async {
        await expectThrows(ValueError.self, matching: "aws_secret_key.*without.*aws_access_key") {
            _ = try awsClient(secret: "secret", region: "us-east-1", workspace: "ws-123")
        }
    }
}

@Suite struct AWSSkipAuthTests {
    @Test func noWorkspaceRequired() throws {
        let client = try awsClient(skipAuth: true, baseURL: "https://custom.example.com")
        #expect(client.skipAuth)
        #expect(client.useSigV4 == false)
        #expect(client.workspaceID == nil)
    }

    @Test func requiresRegionOrBaseURL() async {
        await expectThrows(AnthropicError.self, matching: "No AWS region was provided and no base_url") {
            _ = try awsClient(skipAuth: true, env: ["ANTHROPIC_BASE_URL": "https://first-party.example.com"])
        }
    }

    @Test func baseURLFromRegionArg() throws {
        let client = try awsClient(region: "eu-west-1", skipAuth: true)
        #expect(client.awsRegion == "eu-west-1")
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.eu-west-1.api.aws/")
    }

    @Test func baseURLFromRegionEnv() throws {
        let client = try awsClient(skipAuth: true, env: ["AWS_REGION": "ap-southeast-1"])
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.ap-southeast-1.api.aws/")
    }

    @Test func baseURLEnvOverridesRegion() throws {
        let client = try awsClient(region: "eu-west-1", skipAuth: true, env: ["ANTHROPIC_AWS_BASE_URL": "https://custom-gateway.example.com"])
        #expect(client.baseURL.absoluteString == "https://custom-gateway.example.com/")
    }

    @Test func explicitBaseURLWins() throws {
        let client = try awsClient(region: "eu-west-1", skipAuth: true, baseURL: "https://custom.example.com",
                                   env: ["ANTHROPIC_AWS_BASE_URL": "https://custom-gateway.example.com"])
        #expect(client.baseURL.absoluteString == "https://custom.example.com/")
    }

    @Test func noAuthHeaders() async throws {
        let recorder = RequestRecorder()
        try await send(try awsClient(recorder, skipAuth: true, baseURL: "https://custom.example.com", env: ambientFirstParty))
        #expect(recorder.count == 1)
        let h = recorder.requests[0].headers
        #expect(h["X-Api-Key"] == nil)
        #expect(h["Authorization"] == nil)
        #expect(h["X-Amz-Date"] == nil)
        #expect(h["anthropic-workspace-id"] == nil)
    }

    @Test func regionRequestURL() async throws {
        let recorder = RequestRecorder()
        var env = ambientFirstParty
        env["ANTHROPIC_BASE_URL"] = "https://first-party.example.com"
        try await send(try awsClient(recorder, region: "eu-west-1", workspace: "ws-123", skipAuth: true, env: env))
        #expect(recorder.urls == ["https://aws-external-anthropic.eu-west-1.api.aws/v1/messages"])
        let h = recorder.requests[0].headers
        #expect(h["anthropic-workspace-id"] == "ws-123")
        #expect(h["X-Api-Key"] == nil)
        #expect(h["Authorization"] == nil)
    }

    @Test(arguments: ["copy", "scoped_helper"])
    func explicitAuthTokenOnCopyIsSent(via: String) async throws {
        let recorder = RequestRecorder()
        let client = try awsClient(recorder, region: "eu-west-1", workspace: "ws-123", skipAuth: true, env: ambientFirstParty)
        let scoped: Anthropic = via == "copy"
            ? try client.copy(authToken: "scoped-token")
            : try ScopedClient.copyWithBearerAuth(client, authToken: "scoped-token", helper: .environmentsWorker)
        try await send(scoped)
        #expect(recorder.count == 1)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer scoped-token")
        #expect(recorder.requests[0].headers["X-Api-Key"] == nil)
    }
}

@Suite struct AWSEnvironmentTests {
    @Test func envAPIKey() throws {
        let client = try awsClient(workspace: "ws-123", baseURL: "https://example.com", env: ["ANTHROPIC_AWS_API_KEY": "env-key"])
        #expect(client.apiKey == "env-key")
        #expect(client.useSigV4 == false)
    }

    @Test func envRegion() throws {
        #expect(try awsClient(apiKey: "test-key", workspace: "ws-123", env: ["AWS_REGION": "ap-southeast-1"]).awsRegion == "ap-southeast-1")
    }

    @Test func envBaseURL() throws {
        let client = try awsClient(apiKey: "test-key", workspace: "ws-123", env: ["ANTHROPIC_AWS_BASE_URL": "https://custom-gateway.example.com"])
        #expect(client.baseURL.absoluteString == "https://custom-gateway.example.com/")
    }

    @Test func apiKeyArgTakesPrecedenceOverEnv() throws {
        let client = try awsClient(apiKey: "arg-key", region: "us-east-1", workspace: "ws-123", env: ["ANTHROPIC_AWS_API_KEY": "env-key"])
        #expect(client.apiKey == "arg-key")
        #expect(client.useSigV4 == false)
    }

    @Test func explicitAWSCredsSuppressEnvAPIKey() throws {
        let client = try awsClient(access: "AKID", secret: "secret", region: "us-east-1", workspace: "ws-123",
                                   env: ["ANTHROPIC_AWS_API_KEY": "env-key"])
        #expect(client.useSigV4)
        #expect(client.apiKey == nil)
    }

    @Test func awsProfileSuppressesEnvAPIKey() throws {
        let client = try awsClient(region: "us-east-1", profile: "my-profile", workspace: "ws-123", env: ["ANTHROPIC_AWS_API_KEY": "env-key"])
        #expect(client.useSigV4)
        #expect(client.apiKey == nil)
    }

    @Test func regionFromConstructor() throws {
        let client = try awsClient(apiKey: "test-key", region: "eu-central-1", workspace: "ws-123")
        #expect(client.awsRegion == "eu-central-1")
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.eu-central-1.api.aws/")
    }

    @Test func regionConstructorOverridesEnv() throws {
        let client = try awsClient(apiKey: "test-key", region: "eu-west-1", workspace: "ws-123", env: ["AWS_REGION": "us-west-2"])
        #expect(client.awsRegion == "eu-west-1")
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.eu-west-1.api.aws/")
    }

    @Test func baseURLOverride() throws {
        let client = try awsClient(apiKey: "test-key", region: "us-east-1", workspace: "ws-123", baseURL: "https://custom.example.com")
        #expect(client.baseURL.absoluteString == "https://custom.example.com/")
    }

    @Test func apiKeyModeNoRegionWithBaseURL() throws {
        let client = try awsClient(apiKey: "test-key", workspace: "ws-123", baseURL: "https://custom.example.com")
        #expect(client.awsRegion == nil)
        #expect(client.useSigV4 == false)
    }

    @Test func apiKeyModeNoRegionNoBaseURLErrors() async {
        await expectThrows(AnthropicError.self, matching: "No AWS region was provided and no base_url") {
            _ = try awsClient(apiKey: "test-key", workspace: "ws-123")
        }
    }

    @Test func hasAllResources() throws {
        let client = try awsClient(apiKey: "test-key", region: "us-east-1", workspace: "ws-123")
        _ = client.messages
        _ = client.beta
        _ = client.models
    }
}

@Suite struct AWSRequestTests {
    @Test func apiKeyRequest() async throws {
        let recorder = RequestRecorder()
        try await send(try awsClient(recorder, apiKey: "test-key", region: "us-east-1", workspace: "ws-123"))
        #expect(recorder.urls == ["https://aws-external-anthropic.us-east-1.api.aws/v1/messages"])
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer test-key")
        #expect(recorder.requests[0].headers["X-Api-Key"] == nil)
    }

    @Test(arguments: [(nil, "ws-client"), ("ws-request", "ws-request")] as [(String?, String)])
    func workspaceIDHeader(requestWorkspaceID: String?, expected: String) async throws {
        let recorder = RequestRecorder()
        try await send(try awsClient(recorder, apiKey: "test-key", region: "us-east-1", workspace: "ws-client"), workspaceID: requestWorkspaceID)
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == expected)
    }

    @Test func retries() async throws {
        let recorder = RequestRecorder(sequence: [
            platformJSON(#"{"error": "server error"}"#, status: 500, headers: ["retry-after-ms": "10"]), platformMessageResponse,
        ])
        let client = try awsClient(recorder, apiKey: "test-key", region: "us-east-1", workspace: "ws-123")
        client.sleeper = { _ in }
        try await send(client)
        #expect(recorder.count == 2)
    }

    @Test func sigv4BinaryFileUpload() async throws {
        let recorder = RequestRecorder { req, _ in
            platformJSON(#"{"id": "file_123", "type": "file", "created_at": "2026-01-01T00:00:00Z", "filename": "x.png", "mime_type": "image/png", "size_bytes": 11}"#)(req)
        }
        let png = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0xFF, 0xFE])
        _ = try await sigv4Client(recorder).files.upload(file: FileUpload(data: png, filename: "x.png", contentType: "image/png"))
        #expect(recorder.urls == ["https://aws-external-anthropic.us-east-1.api.aws/v1/files"])
        let body = try #require(recorder.requests[0].body)
        #expect(body.range(of: png) != nil)
        #expect(recorder.requests[0].headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
        // The signature covers the exact multipart body that is sent.
        let auth = recorder.requests[0].headers["Authorization"]!
        var unsigned = recorder.requests[0]
        unsigned.headers.remove("Authorization")
        let resigned = awsAuthHeaders(method: unsigned.method, url: unsigned.url, headers: unsigned.headers, body: unsigned.body,
                                      credentials: AWSCredentials(accessKeyID: "AKID", secretAccessKey: "secret"), region: "us-east-1",
                                      serviceName: "aws-external-anthropic",
                                      date: SigV4TestDates.parse(unsigned.headers["X-Amz-Date"]!))
        #expect(resigned.first(where: { $0.0 == "Authorization" })?.1 == auth)
    }

    @Test func sigv4UserProfilesRequests() async throws {
        let recorder = RequestRecorder { req, _ in
            if req.method == "DELETE" { return platformJSON(#"{"id": "uprof_test", "type": "user_profile_deleted"}"#)(req) }
            if req.method == "GET" && req.url.path.hasSuffix("/user_profiles") { return platformJSON(#"{"data": [], "next_page": null}"#)(req) }
            return platformJSON(#"{"id": "uprof_test", "type": "user_profile"}"#)(req)
        }
        let client = try sigv4Client(recorder)
        _ = try await client.userProfiles.withRawResponse.create()
        _ = try await client.userProfiles.withRawResponse.retrieve("uprof_test")
        _ = try await client.userProfiles.withRawResponse.update("uprof_test")
        _ = try await client.userProfiles.withRawResponse.list()
        _ = try await client.userProfiles.withRawResponse.delete("uprof_test")
        let url = "https://aws-external-anthropic.us-east-1.api.aws/v1/user_profiles"
        #expect(recorder.requests.map { "\($0.method) \($0.url.absoluteString)" } == [
            "POST \(url)", "GET \(url)/uprof_test", "POST \(url)/uprof_test", "GET \(url)", "DELETE \(url)/uprof_test",
        ])
        for request in recorder.requests {
            #expect(request.headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
            #expect(request.headers["anthropic-workspace-id"] == "ws-123")
        }
    }

    @Test func sigv4UserProfileIDHeader() async throws {
        let recorder = RequestRecorder()
        let client = try sigv4Client(recorder, headers: ["anthropic-user-profile-id": "uprof_client"])
        try await send(client, userProfileID: "uprof_test")
        try await send(client)
        #expect(recorder.requests.map { $0.headers["anthropic-user-profile-id"] } == ["uprof_test", "uprof_client"])
        for request in recorder.requests { #expect(request.headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true) }
    }

    @Test func userProfileActionURLsAreRejected() async throws {
        let recorder = RequestRecorder()
        let client = try awsClient(recorder, apiKey: "test-key", region: "us-east-1", workspace: "ws-123")
        let action: UserProfileEnrollEndUserActionParam = try JSONValue.object(["type": "enroll_end_user"]).decode()
        await expectThrows(AnthropicError.self, matching: "action URLs are not supported in the AWS client") {
            _ = try await client.userProfiles.actionURLs.create("uprof_test", action: action)
        }
        await expectThrows(AnthropicError.self, matching: "action URLs are not supported in the AWS client") {
            _ = try await client.userProfiles.actionURLs.withRawResponse.create("uprof_test", action: action)
        }
        let betaAction: BetaUserProfileEnrollEndUserActionParam = try JSONValue.object(["type": "enroll_end_user"]).decode()
        await expectThrows(AnthropicError.self, matching: "action URLs are not supported in the AWS client") {
            _ = try await client.beta.userProfiles.actionURLs.create("uprof_test", action: betaAction)
        }
        #expect(recorder.count == 0)
    }

    @Test func sigv4WithOptionsIgnoresAmbientFirstPartyCredentials() async throws {
        let recorder = RequestRecorder()
        let client = try sigv4Client(recorder, region: "eu-west-1", env: ambientFirstParty)
        #expect(client.apiKey == nil)
        #expect(client.authToken == nil)
        try await send(try client.withOptions(awsRegion: "us-west-2"))
        #expect(recorder.urls == ["https://aws-external-anthropic.us-west-2.api.aws/v1/messages"])
        let authorization = recorder.requests[0].headers["Authorization"]!
        #expect(authorization.hasPrefix("AWS4-HMAC-SHA256 "))
        #expect(authorization.contains("/us-west-2/"))
        #expect(recorder.requests[0].headers["X-Api-Key"] == nil)
    }

    @Test func sigv4SignsWithSessionTokenFromProfile() async throws {
        let credentials = writeTempFile("[dev]\naws_access_key_id = AKDEV\naws_secret_access_key = devsecret\naws_session_token = devtoken\n")
        let recorder = RequestRecorder()
        let client = try awsClient(recorder, region: "us-east-1", profile: "dev", workspace: "ws-123",
                                   env: ["AWS_SHARED_CREDENTIALS_FILE": credentials])
        try await send(client)
        let h = recorder.requests[0].headers
        #expect(h["Authorization"]?.contains("Credential=AKDEV/") == true)
        #expect(h["X-Amz-Security-Token"] == "devtoken")
    }
}

@Suite struct AWSCopyTests {
    @Test func copyPreservesAWSOptions() throws {
        let client = try awsClient(access: "AKID", secret: "secret", region: "us-east-1", profile: "my-profile", token: "token", workspace: "ws-123")
        let copied: AnthropicAWS = try client.copy()
        #expect(copied.awsAccessKey == "AKID")
        #expect(copied.awsSecretKey == "secret")
        #expect(copied.awsRegion == "us-east-1")
        #expect(copied.awsProfile == "my-profile")
        #expect(copied.awsSessionToken == "token")
        #expect(copied.useSigV4)
        #expect(try client.copy() is AnthropicAWS)
    }

    @Test func copyOverridesAWSOptions() throws {
        let client = try sigv4Client()
        let copied = try client.copy(awsAccessKey: "AKID2", awsSecretKey: "secret2", workspaceID: "ws-456")
        #expect(copied.awsAccessKey == "AKID2")
        #expect(copied.awsSecretKey == "secret2")
        #expect(copied.workspaceID == "ws-456")
        #expect(copied.awsRegion == "us-east-1")
        #expect(copied.baseURL.absoluteString == "https://aws-external-anthropic.us-east-1.api.aws/")
    }

    @Test func copyWithAuthTokenKeepsTheAPIKey() throws {
        let client = try awsClient(apiKey: "test-key", region: "us-east-1", workspace: "ws-123")
        let copied = try client.copy(authToken: "token") as! AnthropicAWS
        #expect(copied.useSigV4 == false)
        #expect(copied.authHeaders == ["Authorization": "Bearer test-key"])
    }

    @Test func copyRegionChangeRederivesBaseURL() throws {
        let client = try sigv4Client(region: "eu-west-1", env: ambientFirstParty)
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.eu-west-1.api.aws/")
        let copied = try client.withOptions(awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://aws-external-anthropic.us-west-2.api.aws/")
        #expect(copied.apiKey == nil && copied.authToken == nil)
        #expect(client.awsRegion == "eu-west-1")
        #expect(client.baseURL.absoluteString == "https://aws-external-anthropic.eu-west-1.api.aws/")
        let chained = try copied.withOptions(awsRegion: "ap-northeast-1")
        #expect(chained.baseURL.absoluteString == "https://aws-external-anthropic.ap-northeast-1.api.aws/")
    }

    @Test func copyRegionChangeRederivesBaseURLAPIKeyMode() throws {
        let client = try awsClient(apiKey: "test-key", region: "eu-west-1", workspace: "ws-123")
        #expect(try client.withOptions(awsRegion: "us-west-2").baseURL.absoluteString == "https://aws-external-anthropic.us-west-2.api.aws/")
    }

    @Test func copyRegionChangeRederivesBaseURLSkipAuth() throws {
        var env = ambientFirstParty
        env["ANTHROPIC_BASE_URL"] = "https://first-party.example.com"
        let client = try awsClient(region: "eu-west-1", skipAuth: true, env: env)
        let copied = try client.withOptions(awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://aws-external-anthropic.us-west-2.api.aws/")
        #expect(copied.apiKey == nil && copied.authToken == nil)
    }

    @Test func copyRegionChangeExplicitBaseURLWins() throws {
        let client = try sigv4Client(region: "eu-west-1")
        let copied = try client.withOptions(baseURL: "https://custom.example.com", awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://custom.example.com/")
        let chained = try copied.withOptions(awsRegion: "ap-northeast-1")
        #expect(chained.awsRegion == "ap-northeast-1")
        #expect(chained.baseURL.absoluteString == "https://custom.example.com/")
    }

    @Test func copyRegionChangeKeepsCustomBaseURL() throws {
        let client = try awsClient(access: "AKID", secret: "secret", region: "eu-west-1", workspace: "ws-123", baseURL: "https://custom.example.com")
        let copied = try client.withOptions(awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://custom.example.com/")
        #expect(try client.withOptions(workspaceID: "ws-456").baseURL.absoluteString == "https://custom.example.com/")
    }

    @Test func copyRegionChangeKeepsEnvBaseURL() throws {
        let client = try sigv4Client(region: "eu-west-1", env: ["ANTHROPIC_AWS_BASE_URL": "https://custom-gateway.example.com"])
        let copied = try client.withOptions(awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://custom-gateway.example.com/")
    }

    @Test func copyRegionChangeKeepsBaseURLAssignedAfterConstruction() throws {
        let client = try sigv4Client(region: "eu-west-1")
        client.baseURL = URL(string: "https://gateway.example.com")!
        let copied = try client.withOptions(awsRegion: "us-west-2")
        #expect(copied.awsRegion == "us-west-2")
        #expect(copied.baseURL.absoluteString == "https://gateway.example.com/")
    }

    @Test func scopedBearerClientHelperOnAWS() throws {
        let client = try sigv4Client()
        let scoped = try ScopedClient.copyWithBearerAuth(client, authToken: "unused-under-sigv4", helper: .environmentsWorkPoller)
        #expect(scoped.useSigV4)
        #expect(scoped.workspaceID == "ws-123")
    }
}

enum SigV4TestDates {
    static func parse(_ amzDate: String) -> Date {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(identifier: "UTC")
        f.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return f.date(from: amzDate)!
    }
}
