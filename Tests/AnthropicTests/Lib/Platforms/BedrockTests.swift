import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_bedrock.py.

private func bedrockClient(_ recorder: RequestRecorder, apiKey: String? = nil, env: [String: String] = [:]) throws -> AnthropicBedrock {
    let client = apiKey == nil
        ? try AnthropicBedrock(awsSecretKey: "example-secret-key", awsAccessKey: "example-access-key", awsRegion: "us-east-1",
                               transport: recorder.transport, environment: isolatedEnv(env))
        : try AnthropicBedrock(awsRegion: "us-east-1", apiKey: apiKey, transport: recorder.transport, environment: isolatedEnv(env))
    client.sleeper = { _ in }
    return client
}

private func send(_ client: AnthropicBedrock, model: ModelParam = "anthropic.claude-3-5-sonnet-20241022-v2:0", extraBody: Body? = nil,
                  userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil) async throws
{
    _ = try await client.messages.create(maxTokens: 1024, messages: userMessages("Say hello there!"), model: model, userProfileID: userProfileID,
                                         workspaceID: workspaceID, extraHeaders: extraHeaders, extraBody: extraBody)
}

/// One `chunk` event in AWS event-stream framing (`_eventstream_chunk_frame`).
func eventStreamChunkFrame(_ payload: JSONValue) -> Data {
    let inner = try! JSONValue.serialize(payload)
    let body = try! JSONValue.serialize(["bytes": .string(inner.base64EncodedString())])
    return AWSEventStreamMessage(headers: [":message-type": .string("event"), ":event-type": .string("chunk"),
                                           ":content-type": .string("application/json")], payload: body).encoded()
}

/// A frame built byte by byte, independently of `AWSEventStreamMessage.encoded()` (`_eventstream_frame`).
func eventStreamFrame(_ headerValues: [(String, String)], _ body: Data) -> Data {
    var headers = Data()
    for (name, value) in headerValues {
        headers.append(UInt8(name.utf8.count))
        headers.append(contentsOf: Array(name.utf8))
        headers.append(7)
        headers.append(contentsOf: [UInt8(value.utf8.count >> 8), UInt8(value.utf8.count & 0xff)])
        headers.append(contentsOf: Array(value.utf8))
    }
    func be32(_ v: Int) -> [UInt8] { [UInt8((v >> 24) & 0xff), UInt8((v >> 16) & 0xff), UInt8((v >> 8) & 0xff), UInt8(v & 0xff)] }
    var prelude = Data(be32(12 + headers.count + body.count + 4) + be32(headers.count))
    prelude.append(contentsOf: be32(Int(CRC32.checksum(prelude))))
    var message = prelude + headers + body
    message.append(contentsOf: be32(Int(CRC32.checksum(message))))
    return message
}

private let invocationMetrics: JSONValue = ["inputTokenCount": 5, "outputTokenCount": 3, "invocationLatency": 500, "firstByteLatency": 100]
private let typelessChunkStream: [JSONValue] = [
    ["type": "message_start", "message": ["id": "msg_1", "type": "message", "role": "assistant", "content": [], "model": "claude",
                                          "stop_reason": nil, "stop_sequence": nil, "usage": ["input_tokens": 5, "output_tokens": 1]]],
    // no `type` and no `completion`: there is no event name to route this by
    ["amazon-bedrock-invocationMetrics": invocationMetrics],
    ["type": "message_stop", "amazon-bedrock-invocationMetrics": invocationMetrics],
]

private func eventStreamResponse(_ data: Data) -> @Sendable (HTTPRequest) -> HTTPResponse {
    { req in HTTPResponse(statusCode: 200, headers: ["content-type": "application/vnd.amazon.eventstream"], stream: chunked(data, size: 13), request: req) }
}

@Suite struct BedrockTests {
    @Test func messagesRetries() async throws {
        let recorder = RequestRecorder(sequence: [
            platformJSON(#"{"error": "server error"}"#, status: 500, headers: ["retry-after-ms": "10"]), platformMessageResponse,
        ])
        try await send(try bedrockClient(recorder))
        #expect(recorder.urls == Array(repeating: "https://bedrock-runtime.us-east-1.amazonaws.com/model/anthropic.claude-3-5-sonnet-20241022-v2:0/invoke", count: 2))
    }

    @Test func applicationInferenceProfile() async throws {
        let recorder = RequestRecorder(sequence: [
            platformJSON(#"{"error": "server error"}"#, status: 500, headers: ["retry-after-ms": "10"]), platformMessageResponse,
        ])
        try await send(try bedrockClient(recorder), model: "arn:aws:bedrock:us-east-1:123456789012:application-inference-profile/jf2sje1c0jnb")
        #expect(recorder.urls == Array(repeating:
            "https://bedrock-runtime.us-east-1.amazonaws.com/model/arn:aws:bedrock:us-east-1:123456789012:application-inference-profile%2Fjf2sje1c0jnb/invoke",
            count: 2))
    }

    @Test func extraBodyAnthropicVersionWins() async throws {
        let recorder = RequestRecorder()
        try await send(try bedrockClient(recorder), extraBody: ["anthropic_version": "2000-01-01"])
        #expect(recorder.requests[0].json["anthropic_version"] == "2000-01-01")
    }

    @Test func bodyRewrite() async throws {
        let recorder = RequestRecorder()
        try await send(try bedrockClient(recorder))
        let body = recorder.requests[0].json
        #expect(body["model"] == nil && body["stream"] == nil)
        #expect(body["anthropic_version"] == .string(ANTHROPIC_API_VERSION))
        #expect(recorder.requests[0].headers["anthropic-version"] == nil)
        #expect(recorder.requests[0].headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
        #expect(recorder.requests[0].headers["Authorization"]?.contains("/us-east-1/bedrock/aws4_request") == true)
        #expect(recorder.requests[0].headers["x-amz-date"] != nil)
    }

    @Test func apiKeyAuth() async throws {
        let recorder = RequestRecorder()
        try await send(try bedrockClient(recorder, apiKey: "test-api-key"))
        #expect(recorder.count == 1)
        #expect(recorder.requests[0].headers["Authorization"] == "Bearer test-api-key")
    }

    @Test func apiKeyFromEnv() throws {
        let client = try AnthropicBedrock(awsRegion: "us-east-1", environment: isolatedEnv(["AWS_BEARER_TOKEN_BEDROCK": "env-api-key"]))
        #expect(client.apiKey == "env-api-key")
    }

    @Test func apiKeyMutualExclusion() async {
        await expectThrows(ValueError.self, matching: "Cannot specify both") {
            _ = try AnthropicBedrock(awsAccessKey: "example-access-key", awsRegion: "us-east-1", apiKey: "test-api-key", environment: isolatedEnv())
        }
        await expectThrows(ValueError.self, matching: "Cannot specify both") {
            _ = try AnthropicBedrock(awsSecretKey: "example-secret-key", awsRegion: "us-east-1", apiKey: "test-api-key", environment: isolatedEnv())
        }
    }

    @Test func apiKeyEnvMutualExclusion() async {
        await expectThrows(ValueError.self, matching: "Cannot specify both") {
            _ = try AnthropicBedrock(awsAccessKey: "example-access-key", awsRegion: "us-east-1",
                                     environment: isolatedEnv(["AWS_BEARER_TOKEN_BEDROCK": "env-api-key"]))
        }
    }

    /// `profile_to_ini` + the `mock_aws_config` fixture.
    func awsConfig(_ profiles: [(String, String)]) -> String {
        writeTempFile(profiles.map { name, region in "[\(name == "default" ? "default" : "profile \(name)")]\nregion = \(region)\n" }.joined())
    }

    @Test func regionInferFromProfile() throws {
        let client = try AnthropicBedrock(environment: isolatedEnv(["AWS_CONFIG_FILE": awsConfig([("default", "us-east-2")])]))
        #expect(client.awsRegion == "us-east-2")
    }

    @Test(arguments: [([("default", "us-east-2")], "default"), ([("default", "us-east-2"), ("custom", "us-west-1")], "custom")])
    func regionInferFromSpecifiedProfile(profiles: [(String, String)], awsProfile: String) throws {
        let env = isolatedEnv(["AWS_CONFIG_FILE": awsConfig(profiles), "AWS_PROFILE": awsProfile])
        #expect(try AnthropicBedrock(environment: env).awsRegion == profiles.first(where: { $0.0 == awsProfile })!.1)
    }

    @Test func regionInferFromAWSProfileArgument() throws {
        let env = isolatedEnv(["AWS_CONFIG_FILE": awsConfig([("default", "us-east-2"), ("custom", "us-west-1")])])
        #expect(try AnthropicBedrock(awsProfile: "custom", environment: env).awsRegion == "us-west-1")
    }

    @Test func regionIsRequired() async throws {
        let env = isolatedEnv(["AWS_CONFIG_FILE": awsConfig([])])
        await expectThrows(ValueError.self, matching: "No AWS region was provided") { _ = try AnthropicBedrock(environment: env) }
        await expectThrows(ValueError.self, matching: "No AWS region was provided") { _ = try AnthropicBedrock(apiKey: "test-api-key", environment: env) }
        // an explicit region always wins and skips inference entirely
        #expect(try AnthropicBedrock(awsRegion: "eu-west-1", environment: env).awsRegion == "eu-west-1")
    }

    @Test func chunkBytesToSSETypedEvent() throws {
        let raw = #"{"type":"message_start","message":{"id":"msg_123","type":"message","role":"assistant","content":[],"model":"claude-x","stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":1,"output_tokens":1}}}"#
        let sse = try #require(AWSEventStreamDecoder.chunkBytesToSSE(Data(raw.utf8)))
        #expect(sse.event == "message_start")
        #expect(sse.data == raw)
    }

    @Test func chunkBytesToSSELegacyCompletion() {
        #expect(AWSEventStreamDecoder.chunkBytesToSSE(Data(#"{"completion":" Hello","stop_reason":null,"model":"claude-2"}"#.utf8))?.event == "completion")
    }

    @Test func chunkBytesToSSELegacyCompletionWithMetrics() {
        let raw = #"{"completion":" Hello","stop_reason":"stop_sequence","model":"claude-2","amazon-bedrock-invocationMetrics":{"inputTokenCount":1,"outputTokenCount":1}}"#
        #expect(AWSEventStreamDecoder.chunkBytesToSSE(Data(raw.utf8))?.event == "completion")
    }

    @Test func chunkBytesToSSEDropsChunkWithoutTypeOrCompletion() {
        #expect(AWSEventStreamDecoder.chunkBytesToSSE(Data(#"{"amazon-bedrock-invocationMetrics":{"inputTokenCount":1,"outputTokenCount":1}}"#.utf8)) == nil)
    }

    @Test func chunkBytesToSSENonJSON() {
        #expect(AWSEventStreamDecoder.chunkBytesToSSE(Data("plain text".utf8)) == ServerSentEvent(event: "completion", data: "plain text"))
    }

    @Test func eventStreamFramesMatchTheReferenceEncoding() throws {
        let headers = [(":message-type", "event"), (":event-type", "chunk")]
        let body = Data(#"{"bytes": "e30="}"#.utf8)
        let frame = eventStreamFrame(headers, body)
        var buffer = AWSEventStreamBuffer()
        buffer.add(frame.prefix(10))
        #expect(try buffer.next() == nil)
        buffer.add(frame.dropFirst(10))
        let message = try #require(try buffer.next())
        #expect(message.payload == body)
        #expect(message.headers[":event-type"] == .string("chunk"))
        #expect(try buffer.next() == nil)
        #expect(message.encoded().count == frame.count)
        var corrupt = frame
        corrupt[corrupt.count - 6] ^= 0xff
        var bad = AWSEventStreamBuffer()
        bad.add(corrupt)
        #expect(throws: AWSEventStreamError.self) { _ = try bad.next() }
    }

    @Test func streamSkipsTypelessChunk() async throws {
        let data = typelessChunkStream.map(eventStreamChunkFrame).reduce(Data(), +)
        let recorder = RequestRecorder { req, _ in eventStreamResponse(data)(req) }
        let stream = try await bedrockClient(recorder).messages.createStreaming(maxTokens: 8, messages: userMessages("hi"), model: "anthropic.claude-x")
        var events: [RawMessageStreamEvent] = []
        for try await e in stream { events.append(e) }
        let types = try events.map { try JSONValue.from($0)["type"]?.stringValue }
        #expect(types == ["message_start", "message_stop"])
        #expect(try JSONValue.from(events[0])["message"]?["id"] == "msg_1")
        #expect(recorder.urls == ["https://bedrock-runtime.us-east-1.amazonaws.com/model/anthropic.claude-x/invoke-with-response-stream"])
    }

    /// `test_beta_messages_helpers_are_bound`, plus the routing checks of
    /// `test_beta_messages_helpers_are_bound`: `create`, `parse` and `stream` (beta and stable) go through `/invoke`
    /// (`/invoke-with-response-stream`), SigV4-signed, with the body rewritten. `tool_runner` is checked by
    /// `betaToolRunnerRoutesThroughInvoke`.
    @Test func messagesHelpersRouteThroughInvoke() async throws {
        let frames = platformCityStreamEvents.map(eventStreamChunkFrame).reduce(Data(), +)
        let recorder = RequestRecorder { req, _ in
            req.url.path.hasSuffix("/invoke-with-response-stream") ? eventStreamResponse(frames)(req) : platformJSON(platformCityMessageJSON)(req)
        }
        let client = try bedrockClient(recorder)
        let model: ModelParam = "anthropic.claude-haiku-4-5-20251001-v1:0"
        let city = PlatformHelpersCity(city: "Paris")

        _ = try await client.beta.messages.create(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model)
        let betaParsed = try await client.beta.messages.parse(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model,
                                                              outputFormat: PlatformHelpersCity.self)
        let betaStream = try await client.beta.messages.stream(maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: model,
                                                               outputFormat: PlatformHelpersCity.self)
        let betaStreamed = try await betaStream.getFinalMessage()
        let parsed = try await client.messages.parse(maxTokens: 256, messages: userMessages("weather in Paris?"), model: model,
                                                     outputFormat: PlatformHelpersCity.self)
        let stream = try await client.messages.stream(maxTokens: 256, messages: userMessages("weather in Paris?"), model: model,
                                                      outputFormat: PlatformHelpersCity.self)
        let streamed = try await stream.getFinalMessage()

        #expect(betaParsed.parsedOutput == city)
        #expect(betaStreamed.parsedOutput == city)
        #expect(betaStreamed.stopReason == .endTurn)
        #expect(parsed.parsedOutput == city)
        #expect(streamed.parsedOutput == city)
        let invoke = "/model/anthropic.claude-haiku-4-5-20251001-v1:0/invoke"
        #expect(recorder.requests.map(\.url.path) == [invoke, invoke, invoke + "-with-response-stream", invoke, invoke + "-with-response-stream"])
        for req in recorder.requests {
            #expect(req.headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
            #expect(req.headers["x-amz-date"] != nil)
            #expect(req.headers["anthropic-version"] == nil)
            let body = req.json
            #expect(body["model"] == nil && body["stream"] == nil && body["output_format"] == nil)
            #expect(body["anthropic_version"] == .string(ANTHROPIC_API_VERSION))
        }
        for i in 1...4 { #expect(recorder.requests[i].json["output_config"]?["format"]?["type"] == "json_schema") }
    }

    /// `test_beta_tool_runner_routes_through_invoke` (the sync and async tests are one Swift test).
    @Test func betaToolRunnerRoutesThroughInvoke() async throws {
        let recorder = RequestRecorder(sequence: platformToolRunnerReplies())
        let final = try await bedrockClient(recorder).beta.messages.toolRunner(
            maxTokens: 256, messages: betaUserMessages("weather in Paris?"), model: "anthropic.claude-haiku-4-5-20251001-v1:0",
            tools: [platformToolRunnerWeatherTool()]).untilDone()

        #expect(final.stopReason == .endTurn)
        platformToolRunnerCheckSecondRequest(recorder)
        for req in recorder.requests {
            #expect(req.url.path == "/model/anthropic.claude-haiku-4-5-20251001-v1:0/invoke")
            #expect(req.headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
            #expect(req.headers["x-amz-date"] != nil)
            #expect(req.headers["anthropic-version"] == nil)
            let body = req.json
            #expect(body["model"] == nil && body["stream"] == nil && body["output_format"] == nil)
            #expect(body["anthropic_version"] == .string(ANTHROPIC_API_VERSION))
        }
    }

    static let throttlingMessage = "Too many requests, please wait before trying again."

    @Test(arguments: [
        (eventStreamFrame([(":message-type", "exception"), (":exception-type", "throttlingException"), (":content-type", "application/json")],
                          Data(#"{"message": "Too many requests, please wait before trying again."}"#.utf8)),
         ["type": "throttlingException", "message": .string(BedrockTests.throttlingMessage)] as JSONValue),
        (eventStreamFrame([(":message-type", "error"), (":error-code", "InternalFailure"), (":error-message", "Something went wrong.")], Data()),
         ["type": "InternalFailure", "message": "Something went wrong."] as JSONValue),
    ])
    func streamRaisesAPIErrorForErrorFrame(frame: Data, error: JSONValue) async throws {
        let data = eventStreamChunkFrame(typelessChunkStream[0]) + frame
        let recorder = RequestRecorder { req, _ in eventStreamResponse(data)(req) }
        let stream = try await bedrockClient(recorder).messages.createStreaming(maxTokens: 8, messages: userMessages("hi"), model: "anthropic.claude-x")
        var received: [String] = []
        do {
            for try await event in stream { received.append(try JSONValue.from(event)["type"]?.stringValue ?? "") }
            Issue.record("expected an APIStatusError")
        } catch let e as APIStatusError {
            #expect(type(of: e) == APIStatusError.self)
            #expect(e.body == ["type": "error", "error": error])
        }
        #expect(received == ["message_start"])
    }

    @Test func sigv4SignsBinaryBody() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON("{}")(req) }
        let client = try bedrockClient(recorder)
        let content = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0xFF, 0xFE])
        _ = try await client.requestBinaryResponse(FinalRequestOptions(method: "post", url: "/foo", content: content)).parse()
        #expect(recorder.urls == ["https://bedrock-runtime.us-east-1.amazonaws.com/foo"])
        #expect(recorder.requests[0].body == content)
        #expect(recorder.requests[0].headers["Authorization"]?.hasPrefix("AWS4-HMAC-SHA256 ") == true)
    }

    @Test func copyXStainlessHelperHeaderAppends() throws {
        let client = try bedrockClient(RequestRecorder()).withOptions(defaultHeaders: ["x-stainless-helper": "parent"])
        let copied = try client.withOptions(defaultHeaders: ["x-stainless-helper": "child"])
        #expect(buildHeaderLayers([copied.defaultHeaders]).0["x-stainless-helper"] == "parent, child")
    }

    @Test func prepareOptionsLiftsAnthropicBetaHeaderCaseInsensitively() throws {
        let options = try AnthropicBedrock.prepareBedrockOptions(FinalRequestOptions(
            method: "post", url: "/v1/messages", headers: ["Anthropic-Beta": "context-1m-2025-08-07,other-beta"],
            jsonData: ["model": "anthropic.claude-sonnet-4-5"]))
        #expect(options.jsonData?["anthropic_beta"] == ["context-1m-2025-08-07", "other-beta"])
    }

    @Test func unsupportedEndpoints() async throws {
        let recorder = RequestRecorder()
        let client = try bedrockClient(recorder, apiKey: "k")
        await expectThrows(AnthropicError.self, matching: "Token counting is not supported in Bedrock yet") {
            _ = try await client.messages.countTokens(messages: userMessages("hi"), model: "claude")
        }
        await expectThrows(AnthropicError.self, matching: "The Batch API is not supported in Bedrock yet") {
            _ = try await client.messages.batches.withRawResponse.list()
        }
        #expect(recorder.count == 0)
    }

    @Test func textCompletionsPathIsNotRewritten() async throws {
        let recorder = RequestRecorder { req, _ in platformJSON("{}")(req) }
        let _: JSONValue = try await bedrockClient(recorder).post("/v1/complete", body: ["model": "anthropic.claude-v2"])
        #expect(recorder.urls == ["https://bedrock-runtime.us-east-1.amazonaws.com/v1/complete"])
    }

    @Test func betasParamAndExtraHeadersCaseVariant() async throws {
        let recorder = RequestRecorder()
        _ = try await bedrockClient(recorder, apiKey: "test-api-key").beta.messages.create(
            maxTokens: 1024, messages: betaUserMessages("Say hello there!"), model: "anthropic.claude-3-5-sonnet-20241022-v2:0",
            betas: ["from-betas-param"], extraHeaders: ["Anthropic-Beta": "from-extra-headers"])
        #expect(recorder.count == 1)
        #expect(recorder.requests[0].headers.values("anthropic-beta") == ["from-extra-headers"])
        #expect(recorder.requests[0].json["anthropic_beta"] == ["from-extra-headers"])
    }

    @Test func userProfileIDIsSentInTheHeader() async throws {
        let recorder = RequestRecorder()
        let client = try bedrockClient(recorder, apiKey: "test-api-key")
        try await send(client, userProfileID: "uprof_test")
        _ = try await client.beta.messages.create(maxTokens: 1024, messages: betaUserMessages("Say hello there!"),
                                                  model: "anthropic.claude-3-5-sonnet-20241022-v2:0", userProfileID: "uprof_test")
        try await send(client, extraHeaders: ["Anthropic-User-Profile-Id": "uprof_test"])
        #expect(recorder.count == 3)
        for request in recorder.requests {
            #expect(request.headers["anthropic-user-profile-id"] == "uprof_test")
            #expect(request.json["user_profile_id"] == nil)
        }
    }

    @Test func clientUserProfileIDIsKept() async throws {
        let recorder = RequestRecorder()
        let client = try bedrockClient(recorder, apiKey: "test-api-key").withOptions(defaultHeaders: ["anthropic-user-profile-id": "uprof_client"])
        try await send(client)
        try await send(client, userProfileID: "uprof_request")
        #expect(recorder.requests.map { $0.headers["anthropic-user-profile-id"] } == ["uprof_client", "uprof_request"])
    }

    @Test func clientWorkspaceIDIsKept() async throws {
        let recorder = RequestRecorder()
        let client = try bedrockClient(recorder, apiKey: "test-api-key").withOptions(defaultHeaders: ["anthropic-workspace-id": "wrkspc_client"])
        try await send(client)
        try await send(client, workspaceID: "wrkspc_request")
        #expect(recorder.requests.map { $0.headers["anthropic-workspace-id"] } == ["wrkspc_client", "wrkspc_request"])
    }

    @Test func clientLevelHeaderSurvivesPerRequestOmit() async throws {
        let recorder = RequestRecorder()
        let client = try bedrockClient(recorder, apiKey: "test-api-key").withOptions(defaultHeaders: ["anthropic-workspace-id": "wrkspc_client"])
        try await send(client, extraHeaders: ["Anthropic-Workspace-Id": .omit])
        #expect(recorder.requests[0].headers["anthropic-workspace-id"] == "wrkspc_client")
    }

    @Test func noHeaderWithoutAUserProfileID() async throws {
        let recorder = RequestRecorder()
        try await send(try bedrockClient(recorder, apiKey: "test-api-key"))
        #expect(recorder.requests[0].headers["anthropic-user-profile-id"] == nil)
    }

    @Test func statusErrorMapping() async throws {
        for (status, type) in [(400, "BadRequestError"), (503, "ServiceUnavailableError"), (529, "InternalServerError"), (413, "APIStatusError")] {
            let recorder = RequestRecorder { req, _ in platformJSON(#"{"message": "x"}"#, status: status)(req) }
            let client = try AnthropicBedrock(awsRegion: "us-east-1", apiKey: "k", maxRetries: 0, transport: recorder.transport,
                                              environment: isolatedEnv())
            do {
                try await send(client)
                Issue.record("expected an error")
            } catch let e as APIStatusError {
                #expect(String(describing: Swift.type(of: e)) == type)
            }
        }
    }
}

/// The replies of the platform tool-runner tests (`_tool_runner_responses`): a `get_weather` call, then the answer.
func platformToolRunnerReplies() -> [@Sendable (HTTPRequest) -> HTTPResponse] {
    [
        messageResponse(id: "msg_01", content: [["type": "tool_use", "id": "toolu_01", "name": "get_weather", "input": ["city": "Paris"]]],
                        stopReason: "tool_use"),
        messageResponse(id: "msg_02", content: [["type": "text", "text": "It is sunny in Paris."]], stopReason: "end_turn"),
    ].map { body in platformJSON(String(decoding: try! JSONValue.serialize(body), as: UTF8.self)) }
}

private struct PlatformToolRunnerCity: Decodable, Sendable { var city: String }

/// `get_weather(city)`, which answers `sunny in <city>`.
func platformToolRunnerWeatherTool() -> BetaFunctionTool {
    BetaFunctionTool(name: "get_weather", description: "Get the weather.",
                     inputSchema: ["type": "object", "properties": ["city": ["type": "string", "description": "city name"]],
                                   "required": ["city"]]) { (input: PlatformToolRunnerCity) in
        .string("sunny in \(input.city)")
    }
}

/// `_assert_tool_runner_calls`, the part every platform shares: two requests, the second sending the whole history
/// (a platform client has no message threads) with the tool result.
func platformToolRunnerCheckSecondRequest(_ recorder: RequestRecorder, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(recorder.count == 2, sourceLocation: sourceLocation)
    guard recorder.count == 2 else { return }
    for req in recorder.requests { #expect(req.json["thread"] == nil, sourceLocation: sourceLocation) }
    let messages = recorder.requests[1].json["messages"]?.arrayValue ?? []
    #expect(messages.map { $0["role"] } == ["user", "assistant", "user"], sourceLocation: sourceLocation)
    #expect(messages.count == 3 && messages[1]["content"]?[0]?["type"] == "tool_use", sourceLocation: sourceLocation)
    #expect(messages.count == 3 && messages[2]["content"]?[0] == [
        "type": "tool_result", "tool_use_id": "toolu_01", "content": "sunny in Paris",
    ], sourceLocation: sourceLocation)
}
