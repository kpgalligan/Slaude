import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_bedrock_mantle.py.

private let mantleMessagesURL = "https://bedrock-mantle.us-east-1.api.aws/anthropic/v1/messages"
private let model: ModelParam = "anthropic.claude-sonnet-4-5"

private func mantle(_ recorder: RequestRecorder? = nil, apiKey: String? = nil, access: String? = nil, secret: String? = nil,
                    region: String? = nil, skipAuth: Bool = false, baseURL: String? = nil, headers: Headers? = nil,
                    env: [String: String] = [:]) throws -> AnthropicBedrockMantle
{
    try AnthropicBedrockMantle(awsAccessKey: access, awsSecretKey: secret, awsRegion: region, apiKey: apiKey, skipAuth: skipAuth,
                               baseURL: baseURL, defaultHeaders: headers, transport: (recorder ?? RequestRecorder()).transport,
                               environment: isolatedEnv(env))
}

/// `respond_with_message`.
private func respondWithMessage() -> RequestRecorder {
    RequestRecorder { req, _ in
        if req.url.path.hasSuffix("/count_tokens") { return platformJSON(#"{"input_tokens": 1}"#)(req) }
        if req.json["stream"] == true {
            let sse = "event: message_start\ndata: {\"type\": \"message_start\", \"message\": \(platformMessageJSON)}\n\nevent: message_stop\ndata: {\"type\": \"message_stop\"}\n\n"
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(sse.utf8)), request: req)
        }
        return platformMessageResponse(req)
    }
}

private let batchJSON = #"{"id": "msgbatch_1", "type": "message_batch", "processing_status": "in_progress", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-02T00:00:00Z", "archived_at": null, "cancel_initiated_at": null, "ended_at": null, "results_url": null, "request_counts": {"canceled": 0, "errored": 0, "expired": 0, "processing": 0, "succeeded": 0}}"#

/// The ways of sending a message (`send_message`): create, stream (the `MessageStream` helper and
/// the raw `createStreaming`), beta create / stream / parse / tool runner, count tokens.
enum MantleSend: String, CaseIterable, Sendable {
    case create, stream, createStreaming, betaCreate, betaStream, betaCreateStreaming, betaParse, betaToolRunner, countTokens,
         betaCountTokens

    func callAsFunction(_ client: AnthropicBedrockMantle, _ userProfileID: String?, _ extraBody: Body?) async throws {
        switch self {
        case .create:
            _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hi"), model: model, userProfileID: userProfileID, extraBody: extraBody)
        case .stream:
            try await client.messages.stream(maxTokens: 16, messages: userMessages("Hi"), model: model, userProfileID: userProfileID,
                                             extraBody: extraBody).untilDone()
        case .createStreaming:
            for try await _ in try await client.messages.createStreaming(maxTokens: 16, messages: userMessages("Hi"), model: model,
                                                                          userProfileID: userProfileID, extraBody: extraBody) {}
        case .betaCreate:
            _ = try await client.beta.messages.create(maxTokens: 16, messages: betaUserMessages("Hi"), model: model, userProfileID: userProfileID,
                                                      extraBody: extraBody)
        case .betaStream:
            try await client.beta.messages.stream(maxTokens: 16, messages: betaUserMessages("Hi"), model: model, userProfileID: userProfileID,
                                                  extraBody: extraBody).untilDone()
        case .betaCreateStreaming:
            for try await _ in try await client.beta.messages.createStreaming(maxTokens: 16, messages: betaUserMessages("Hi"), model: model,
                                                                               userProfileID: userProfileID, extraBody: extraBody) {}
        case .betaParse:
            _ = try await client.beta.messages.parse(maxTokens: 16, messages: betaUserMessages("Hi"), model: model, userProfileID: userProfileID,
                                                     extraBody: extraBody)
        case .betaToolRunner:
            _ = try await client.beta.messages.toolRunner(maxTokens: 16, messages: betaUserMessages("Hi"), model: model, tools: [],
                                                          userProfileID: userProfileID, extraBody: extraBody).untilDone()
        case .countTokens:
            _ = try await client.messages.countTokens(messages: userMessages("Hi"), model: model, userProfileID: userProfileID, extraBody: extraBody)
        case .betaCountTokens:
            _ = try await client.beta.messages.countTokens(messages: betaUserMessages("Hi"), model: model, userProfileID: userProfileID,
                                                           extraBody: extraBody)
        }
    }
}

enum MantleBatch: String, CaseIterable, Sendable {
    case createBatch, betaCreateBatch

    func callAsFunction(_ client: AnthropicBedrockMantle, _ userProfileID: String?, extraHeaders: Headers? = nil) async throws {
        switch self {
        case .createBatch:
            _ = try await client.messages.batches.withRawResponse.create(requests: [], userProfileID: userProfileID, extraHeaders: extraHeaders)
        case .betaCreateBatch:
            _ = try await client.beta.messages.batches.withRawResponse.create(requests: [], userProfileID: userProfileID, extraHeaders: extraHeaders)
        }
    }
}

@Suite struct BedrockMantleTests {
    // MARK: TestBaseURL

    @Test func derivesBaseURLFromRegion() throws {
        #expect(try mantle(apiKey: "k", region: "us-east-1").baseURL.absoluteString == "https://bedrock-mantle.us-east-1.api.aws/anthropic/")
    }

    @Test func differentRegion() throws {
        #expect(try mantle(apiKey: "k", region: "eu-west-1").baseURL.absoluteString == "https://bedrock-mantle.eu-west-1.api.aws/anthropic/")
    }

    @Test func usesBaseURLEnvVar() throws {
        let client = try mantle(apiKey: "k", region: "us-east-1", env: ["ANTHROPIC_BEDROCK_MANTLE_BASE_URL": "https://custom-mantle.example.com"])
        #expect(client.baseURL.absoluteString == "https://custom-mantle.example.com/")
    }

    @Test func baseURLArgTakesPrecedenceOverEnv() throws {
        let client = try mantle(apiKey: "k", baseURL: "https://arg.example.com", env: ["ANTHROPIC_BEDROCK_MANTLE_BASE_URL": "https://env.example.com"])
        #expect(client.baseURL.absoluteString == "https://arg.example.com/")
    }

    @Test func raisesWithoutRegionOrBaseURL() async {
        await expectThrows(AnthropicError.self, matching: "No AWS region or base URL found") { _ = try mantle(apiKey: "k") }
    }

    // MARK: TestSigV4ServiceName

    @Test func usesBedrockMantleServiceName() async throws {
        let recorder = respondWithMessage()
        try await MantleSend.create(try mantle(recorder, access: "AKID", secret: "secret", region: "us-east-1"), nil, nil)
        let auth = try #require(recorder.requests[0].headers["Authorization"])
        #expect(auth.hasPrefix("AWS4-HMAC-SHA256 "))
        #expect(auth.contains("/us-east-1/bedrock-mantle/aws4_request"))
    }

    // MARK: TestEnvironmentVariables

    @Test func usesMantleAPIKeyEnvVar() throws {
        let client = try mantle(region: "us-east-1", env: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key"])
        #expect(client.apiKey == "mantle-key")
        #expect(client.useSigV4 == false)
    }

    @Test func fallsBackToAWSAPIKeyEnvVar() throws {
        #expect(try mantle(region: "us-east-1", env: ["ANTHROPIC_AWS_API_KEY": "aws-key"]).apiKey == "aws-key")
    }

    @Test func mantleAPIKeyTakesPrecedenceOverAWS() throws {
        let client = try mantle(region: "us-east-1", env: ["AWS_BEARER_TOKEN_BEDROCK": "mantle-key", "ANTHROPIC_AWS_API_KEY": "aws-key"])
        #expect(client.apiKey == "mantle-key")
    }

    @Test func regionFromAWSRegionEnvVar() throws {
        let client = try mantle(apiKey: "k", env: ["AWS_REGION": "ap-southeast-1"])
        #expect(client.awsRegion == "ap-southeast-1")
        #expect(client.baseURL.absoluteString == "https://bedrock-mantle.ap-southeast-1.api.aws/anthropic/")
    }

    @Test func regionFromAWSDefaultRegionEnvVar() throws {
        #expect(try mantle(apiKey: "k", env: ["AWS_DEFAULT_REGION": "eu-central-1"]).awsRegion == "eu-central-1")
    }

    // MARK: TestAuthPrecedence

    @Test func apiKeyArgUsesAPIKeyMode() throws {
        let client = try mantle(apiKey: "my-key", region: "us-east-1")
        #expect(client.useSigV4 == false)
        #expect(client.apiKey == "my-key")
    }

    @Test func awsCredsUseSigV4Mode() throws {
        let client = try mantle(access: "AKID", secret: "secret", region: "us-east-1")
        #expect(client.useSigV4)
        #expect(client.apiKey == nil)
    }

    @Test func apiKeyModeReturnsBearerAuthHeader() throws {
        #expect(try mantle(apiKey: "my-key", region: "us-east-1").authHeaders == ["Authorization": "Bearer my-key"])
    }

    @Test func sigv4ModeReturnsEmptyAuthHeaders() throws {
        #expect(try mantle(access: "AKID", secret: "secret", region: "us-east-1").authHeaders.isEmpty)
    }

    @Test func skipAuthReturnsEmptyAuthHeaders() throws {
        #expect(try mantle(skipAuth: true, baseURL: "https://example.com").authHeaders.isEmpty)
    }

    // MARK: TestVersionHeader

    @Test func versionHeaderMatchesTheFirstPartyClient() throws {
        let expected = try Anthropic(apiKey: "test-key", environment: [:]).defaultHeaders["anthropic-version"]
        #expect(try mantle(apiKey: "test-key", region: "us-east-1").defaultHeaders["anthropic-version"] == expected)
    }

    // MARK: TestSkipAuth

    @Test func skipAuthDoesNotSignRequest() async throws {
        let recorder = respondWithMessage()
        try await MantleSend.create(try mantle(recorder, skipAuth: true, baseURL: "https://example.com"), nil, nil)
        #expect(recorder.requests[0].headers["Authorization"] == nil)
        #expect(recorder.requests[0].headers["X-Amz-Date"] == nil)
    }

    // MARK: TestPartialCredentials

    @Test func accessKeyOnlyRaises() async {
        await expectThrows(ValueError.self, matching: "aws_access_key.*without.*aws_secret_key") { _ = try mantle(access: "AKID", region: "us-east-1") }
    }

    @Test func secretKeyOnlyRaises() async {
        await expectThrows(ValueError.self, matching: "aws_secret_key.*without.*aws_access_key") { _ = try mantle(secret: "secret", region: "us-east-1") }
    }

    // MARK: TestCopy

    @Test func copyPreservesConfig() throws {
        let client = try mantle(apiKey: "test-key", region: "us-east-1")
        let copied = try client.copy()
        #expect(copied.baseURL == client.baseURL)
        #expect(copied.awsRegion == client.awsRegion)
    }

    @Test func copyOverridesRegion() throws {
        #expect(try mantle(apiKey: "test-key", region: "us-east-1").copy(awsRegion: "us-west-2").awsRegion == "us-west-2")
    }

    @Test func copyXStainlessHelperHeaderAppends() throws {
        let client = try mantle(apiKey: "test-key", region: "us-east-1", headers: ["x-stainless-helper": "parent"])
        let copied = try client.copy(defaultHeaders: ["x-stainless-helper": "child"])
        #expect(copied.defaultHeaders["x-stainless-helper"] == "parent, child")
    }

    // MARK: TestUserProfileID

    @Test(arguments: MantleSend.allCases)
    func sentInBodyInsteadOfHeader(send: MantleSend) async throws {
        let recorder = respondWithMessage()
        try await send(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), "uprof_test", nil)
        #expect(recorder.count == 1)
        #expect(recorder.urls[0].hasPrefix(mantleMessagesURL))
        #expect(recorder.requests[0].json["user_profile_id"] == "uprof_test")
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test(arguments: ["uprof_first,uprof_second", "uprof_first, uprof_second", ""])
    func valueIsSentAsGiven(userProfileID: String) async throws {
        let recorder = respondWithMessage()
        try await MantleSend.create(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), userProfileID, nil)
        #expect(recorder.requests[0].json["user_profile_id"] == .string(userProfileID))
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test func absentFromBodyWhenNotGiven() async throws {
        let recorder = respondWithMessage()
        try await MantleSend.create(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), nil, nil)
        #expect(recorder.requests[0].json["user_profile_id"] == nil)
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test func extraBodyValueWins() async throws {
        let recorder = respondWithMessage()
        try await MantleSend.create(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), "uprof_argument",
                                    ["user_profile_id": "uprof_extra_body"])
        #expect(recorder.requests[0].json["user_profile_id"] == "uprof_extra_body")
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test func extraHeadersValueIsSentInBody() async throws {
        let recorder = respondWithMessage()
        _ = try await mantle(recorder, apiKey: "test-key", region: "us-east-1").messages.create(
            maxTokens: 16, messages: userMessages("Hi"), model: model, userProfileID: "uprof_argument",
            extraHeaders: ["Anthropic-User-Profile-Id": "uprof_extra_headers"])
        #expect(recorder.requests[0].json["user_profile_id"] == "uprof_extra_headers")
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test(arguments: [(nil, "uprof_default"), ("uprof_argument", "uprof_argument")] as [(String?, String)])
    func clientDefaultHeaderIsSentInBodyUnlessTheRequestNamesOne(userProfileID: String?, sent: String) async throws {
        let recorder = respondWithMessage()
        let client = try mantle(recorder, apiKey: "test-key", region: "us-east-1").withOptions(defaultHeaders: ["Anthropic-User-Profile-Id": "uprof_default"])
        try await MantleSend.create(client, userProfileID, nil)
        #expect(recorder.requests[0].json["user_profile_id"] == .string(sent))
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test(arguments: MantleBatch.allCases)
    func batchesKeepTheHeader(send: MantleBatch) async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(batchJSON)(req) }
        try await send(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), "uprof_test")
        #expect(recorder.urls[0].hasPrefix(mantleMessagesURL))
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == "uprof_test")
        #expect(recorder.requests[0].json["user_profile_id"] == nil)
    }

    @Test(arguments: MantleBatch.allCases)
    func batchesSendNoHeaderWhenNoProfileIsSet(send: MantleBatch) async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(batchJSON)(req) }
        try await send(try mantle(recorder, apiKey: "test-key", region: "us-east-1"), nil)
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
        #expect(recorder.requests[0].json["user_profile_id"] == nil)
    }

    @Test(arguments: MantleBatch.allCases, [(nil, "uprof_default"), ("uprof_argument", "uprof_argument")] as [(String?, String)])
    func batchesSendTheClientDefaultHeaderUnlessTheRequestNamesOne(send: MantleBatch, profile: (String?, String)) async throws {
        let recorder = RequestRecorder { req, _ in platformJSON(batchJSON)(req) }
        let client = try mantle(recorder, apiKey: "test-key", region: "us-east-1").withOptions(defaultHeaders: ["Anthropic-User-Profile-Id": "uprof_default"])
        try await send(client, profile.0)
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == profile.1)
        #expect(recorder.requests[0].json["user_profile_id"] == nil)
    }

    @Test func clientWorkspaceIDIsKept() async throws {
        let recorder = RequestRecorder { req, i in i == 2 ? platformJSON(batchJSON)(req) : platformMessageResponse(req) }
        let client = try mantle(recorder, apiKey: "test-key", region: "us-east-1").withOptions(defaultHeaders: ["Anthropic-Workspace-Id": "wrkspc_default"])
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hi"), model: model)
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hi"), model: model, workspaceID: "wrkspc_argument")
        _ = try await client.messages.batches.withRawResponse.create(requests: [])
        #expect(recorder.requests.map { $0.headers["anthropic-workspace-id"] } == ["wrkspc_default", "wrkspc_argument", "wrkspc_default"])
    }

    @Test func perRequestOmitKeepsTheClientDefault() async throws {
        let recorder = RequestRecorder { req, i in i == 1 ? platformJSON(batchJSON)(req) : platformMessageResponse(req) }
        let client = try mantle(recorder, apiKey: "test-key", region: "us-east-1").withOptions(defaultHeaders: ["Anthropic-User-Profile-Id": "uprof_default"])
        _ = try await client.messages.create(maxTokens: 16, messages: userMessages("Hi"), model: model, extraHeaders: ["Anthropic-User-Profile-Id": .omit])
        try await MantleBatch.createBatch(client, nil, extraHeaders: ["Anthropic-User-Profile-Id": .omit])
        #expect(recorder.requests[0].json["user_profile_id"] == "uprof_default")
        #expect(recorder.requests[1].headers["anthropic-user-profile-id"] == "uprof_default")
    }
}
