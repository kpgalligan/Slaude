import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/streaming/test_messages.py (async variants; sync-only tests run async).

let invalidToolJSONPattern =
    #"^Unable to parse tool parameter JSON from model\. Please retry your request or adjust your prompt\. Error: .+\. JSON: \{"location": "Paris", "unit": celsius\}$"#

let followUpMessage: JSONValue = [
    "id": "msg_01FollowUp", "type": "message", "role": "assistant", "model": "claude-sonnet-4-5",
    "content": [["type": "text", "text": "It is sunny in Paris."]], "stop_reason": "end_turn", "stop_sequence": nil,
    "usage": ["input_tokens": 400, "output_tokens": 10],
]

let expectedToolUseParam: JSONValue = [
    "type": "tool_use", "id": "toolu_01NRLabsLyVHZPKxbKvkfSMn", "name": "get_weather", "input": ["location": "Paris"],
    "caller": ["type": "direct"],
]

func assertBasicResponse(_ events: [ParsedMessageStreamEvent], _ message: Message) throws {
    #expect(message.id == "msg_4QpJur2dWWDjF6C758FbBw5vm12BaVipnK")
    #expect(message.model.rawValue == "claude-3-opus-latest")
    #expect(message.role == "assistant")
    #expect(message.stopReason?.rawValue == "end_turn")
    #expect(message.stopSequence == nil)
    #expect(message.type == "message")
    #expect(message.content.count == 1)
    guard case .text(let content) = message.content.first else {
        Issue.record("expected a text block")
        return
    }
    #expect(content.text == "Hello there!")
    // accumulated blocks must serialize like a non-streaming response: keys the API didn't send stay unset
    #expect(try JSONValue.from(message.content[0]) == ["type": "text", "text": "Hello there!"])
    #expect(events.map(\.type) == [
        "message_start", "content_block_start", "content_block_delta", "text", "content_block_delta", "text",
        "content_block_delta", "text", "content_block_stop", "message_delta",
    ])
}

func assertUnknownEventsResponse(_ events: [ParsedMessageStreamEvent], _ message: Message) throws {
    #expect(events.map(\.type) == [
        "future_event", "content_block_stop", "message_start", "content_block_start", "content_block_delta", "text",
        "content_block_delta", "text", "content_block_delta", "text", "content_block_stop", "future_event", "message_delta",
        "message_stop", "future_event",
    ])
    #expect(try JSONValue.from(events[0]) == ["type": "future_event", "usage": ["input_tokens": 99, "output_tokens": 99]])
    #expect(try JSONValue.from(message)["content"] == [["type": "text", "text": "Hello there!"]])
    #expect(message.stopReason?.rawValue == "end_turn")
    #expect(try JSONValue.from(message.usage) == ["input_tokens": 11, "output_tokens": 6])
}

func assertToolUseResponse(_ events: [ParsedMessageStreamEvent], _ message: Message) throws {
    #expect(message.id == "msg_019Q1hrJbZG26Fb9BQhrkHEr")
    #expect(message.model.rawValue == "claude-sonnet-4-20250514")
    #expect(message.stopReason?.rawValue == "tool_use")
    #expect(message.stopSequence == nil)
    #expect(message.content.count == 2)
    guard case .text(let text) = message.content[0], case .toolUse(let toolUse) = message.content[1] else {
        Issue.record("unexpected content \(message.content)")
        return
    }
    #expect(text.text == "I'll check the current weather in Paris for you.")
    #expect(toolUse.id == "toolu_01NRLabsLyVHZPKxbKvkfSMn")
    #expect(toolUse.name == "get_weather")
    #expect(toolUse.input == ["location": "Paris"])
    #expect(message.usage.inputTokens == 377)
    #expect(message.usage.outputTokens == 65)
    #expect(message.usage.cacheCreationInputTokens == 0)
    #expect(message.usage.cacheReadInputTokens == 0)
    #expect(message.usage.serviceTier?.rawValue == "standard")
    #expect(message.usage.serverToolUse == nil)
    #expect(events.map(\.type) == [
        "message_start", "content_block_start", "content_block_delta", "text", "content_block_delta", "text", "content_block_stop",
        "content_block_start", "content_block_delta", "input_json", "content_block_delta", "input_json", "content_block_delta",
        "input_json", "content_block_delta", "input_json", "content_block_delta", "input_json", "content_block_stop", "message_delta",
    ])
}

let expectedServerToolUseEventTypes: [String] =
    ["message_start", "content_block_start"] + Array(repeating: ["content_block_delta", "input_json"], count: 6).flatMap { $0 } + [
        "content_block_stop", "content_block_start", "content_block_stop", "content_block_start", "content_block_delta", "citation",
        "content_block_delta", "text", "content_block_delta", "text", "content_block_stop", "message_delta",
    ]

let expectedServerToolPartials = ["", #"{"query": ""#, "anthropic cl", "aude re", "lease notes", #""}"#]

func assertServerToolUseResponse(_ events: [ParsedMessageStreamEvent], _ message: Message) {
    #expect(events.map(\.type) == expectedServerToolUseEventTypes)
    guard case .serverToolUse(let block) = message.content[0] else {
        Issue.record("expected server_tool_use")
        return
    }
    #expect(block.input == ["query": "anthropic claude release notes"])
    // input_json events must fire for server_tool_use blocks, not just client tool_use
    let inputs = events.compactMap { e -> InputJsonEvent? in if case .inputJson(let i) = e { return i } else { return nil } }
    #expect(inputs.map(\.partialJSON) == expectedServerToolPartials)
    #expect(inputs.last?.snapshot == ["query": "anthropic claude release notes"])
}

func toolUseResponseWithoutCaller() -> String {
    getResponse("tool_use_response.txt").replacingOccurrences(of: #""caller":{"type":"direct"},"#, with: "")
}

func assertRefusalResponse(stopReason: String?, category: String?, explanation: String?, type: String?) {
    #expect(stopReason == "refusal")
    #expect(type == "refusal")
    #expect(category == "cyber")
    #expect(explanation == "This request was refused due to policy.")
}

@Suite struct MessageStreamTests {
    func open(_ server: MockServer, model: String = "claude-3-opus-latest", speed: MessageCreateParamsBase.Speed?? = nil) async throws
        -> MessageStream<Never>
    {
        try await server.client().messages.stream(maxTokens: 1024, messages: [userMessage("Say hello there!")], model: ModelParam(rawValue: model),
                                                  speed: speed)
    }

    @Test func basicResponse() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"))])
        let stream = try await open(server)
        let events = try await collect(stream)
        try assertBasicResponse(events, try await stream.getFinalMessage().message)
        // the stream helper telemetry headers are sent
        #expect(server.requests[0].headers["x-stainless-helper-method"] == "stream")
        #expect(server.requests[0].headers["x-stainless-stream-helper"] == "messages")
        #expect(server.bodies[0]["stream"] == true)
    }

    @Test func unknownEventsArePassedThrough() async throws {
        let server = MockServer([.sse(getResponse("unknown_events_response.txt"))])
        let stream = try await open(server)
        try assertUnknownEventsResponse(try await collect(stream), try await stream.getFinalMessage().message)
    }

    @Test func contextManager() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"), headers: ["request-id": "my-req-id", "anthropic-workspace-id": "wrkspc_123"])])
        let stream = try await open(server)
        #expect(!stream.response.isClosed)
        #expect(stream.requestID == "my-req-id")
        #expect(stream.workspaceID == "wrkspc_123")
        // response should be closed even if the body isn't read
        stream.close()
        #expect(stream.response.isClosed)
    }

    @Test func deprecatedModelWarningStream() async throws {
        for model in DEPRECATED_MODELS.keys.sorted() {
            let server = MockServer([.sse(getResponse("basic_response.txt"))])
            let warnings = try await recordingWarnings {
                _ = try await open(server, model: model).getFinalMessage()
            }
            #expect(warnings.contains { $0.contains("The model '\(model)' is deprecated") })
        }
    }

    @Test func toolUse() async throws {
        let server = MockServer([.sse(getResponse("tool_use_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        try assertToolUseResponse(try await collect(stream), try await stream.getFinalMessage().message)
    }

    @Test func serverToolUse() async throws {
        let server = MockServer([.sse(getResponse("server_tool_use_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        assertServerToolUseResponse(try await collect(stream), try await stream.getFinalMessage().message)
    }

    @Test func toolUseInvalidJSON() async throws {
        let server = MockServer([.sse(getResponse("tool_use_invalid_json_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        do {
            try await stream.untilDone()
            Issue.record("expected an error")
        } catch let e as ValueError {
            #expect(e.message.range(of: invalidToolJSONPattern, options: .regularExpression) != nil, "\(e.message)")
        }
    }

    @Test func toolUseCallerOmitted() async throws {
        let server = MockServer([.sse(toolUseResponseWithoutCaller())])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        guard case .toolUse(let toolUse) = message.content[1] else {
            Issue.record("expected tool_use")
            return
        }
        #expect(toolUse.input == ["location": "Paris"])
        #expect(toolUse.caller == nil)
        // an omitted `caller` must stay unset so it doesn't round-trip as `"caller": null`
        #expect(try JSONValue.from(toolUse)["caller"] == nil)
    }

    @Test func toolUseRoundTrip() async throws {
        let server = MockServer([.sse(getResponse("tool_use_response.txt")), .json(followUpMessage)])
        let client = try server.client()
        let message = try await client.messages.stream(maxTokens: 1024, messages: [userMessage("What is the weather in Paris?")],
                                                       model: "claude-sonnet-5-5").getFinalMessage()
        // accumulated blocks must be reusable as request params without leaking accumulator state
        let assistant = try JSONValue.object(["role": "assistant", "content": JSONValue.from(message.content)]).decode(as: MessageParam.self)
        _ = try await client.messages.create(
            maxTokens: 1024,
            messages: [
                userMessage("What is the weather in Paris?"), assistant,
                userMessage([["type": "tool_result", "tool_use_id": "toolu_01NRLabsLyVHZPKxbKvkfSMn", "content": "Sunny"]]),
            ],
            model: "claude-sonnet-5-5")
        #expect(server.bodies.last?["messages"]?[1]?["content"]?[1] == expectedToolUseParam)
    }

    @Test func refusalStopDetailsPropagated() async throws {
        let server = MockServer([.sse(getResponse("refusal_response.txt"))])
        let message = try await open(server, model: "claude-opus-4-7").getFinalMessage()
        let d = message.stopDetails
        assertRefusalResponse(stopReason: message.stopReason?.rawValue, category: d?.category?.rawValue, explanation: d?.explanation, type: d?.type)
    }

    @Test func messageDeltaFieldsPropagated() async throws {
        let server = MockServer([.sse(getResponse("message_delta_fields_response.txt"))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        // every field the final `message_delta` carried must land on the accumulated message
        #expect(message.container?.id == "container_01AbCdEfGh")
        #expect(message.usage.outputTokens == 8)
        #expect(message.usage.inputTokens == 40)
        #expect(message.usage.cacheCreationInputTokens == 12)
        #expect(message.usage.cacheReadInputTokens == 7)
        #expect(message.usage.outputTokensDetails?.thinkingTokens == 3)
        #expect(message.usage.serverToolUse?.webSearchRequests == 1)
        // never re-sent on `message_delta`, so these must survive from `message_start`
        #expect(message.usage.serviceTier?.rawValue == "standard")
        #expect(message.usage.cacheCreation?.ephemeral5mInputTokens == 10)
    }

    @Test func messageDeltaOmittedUsageKeepsMessageStart() async throws {
        let server = MockServer([.sse(getResponse("message_delta_omitted_usage_response.txt"))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        #expect(message.usage.outputTokens == 8)
        #expect(message.usage.inputTokens == 25)
        #expect(message.usage.cacheCreationInputTokens == 10)
        #expect(message.usage.cacheReadInputTokens == 5)
        #expect(message.usage.serviceTier?.rawValue == "priority")
        #expect(message.usage.cacheCreation?.ephemeral5mInputTokens == 10)
        #expect(message.container == nil)
    }

    @Test func messageStopEventSerialization() async throws {
        // trailing blank line terminates the final `message_stop` SSE so it is dispatched
        let server = MockServer([.sse(getResponse("basic_response.txt") + "\n")])
        let events = try await collect(try await open(server, model: "claude-opus-4-7"))
        guard case .messageStop(let stop)? = events.last else {
            Issue.record("expected message_stop last, got \(events.last.map(\.type) ?? "nothing")")
            return
        }
        guard case .text = stop.message.content[0] else {
            Issue.record("expected a text block")
            return
        }
        let json = try JSONValue.from(ParsedMessageStreamEvent.messageStop(stop))
        #expect(json["type"] == "message_stop")
        #expect(json["message"]?["content"]?[0]?["type"] == "text")
    }

    @Test func speedIsForwarded() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"))])
        try await open(server, model: "claude-opus-4-7", speed: .fast).untilDone()
        #expect(server.bodies.last?["speed"] == "fast")
    }

    @Test func getFinalTextAndTextStream() async throws {
        let server = MockServer([.sse(getResponse("tool_use_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        var texts: [String] = []
        for try await t in stream.textStream { texts.append(t) }
        #expect(texts.joined() == "I'll check the current weather in Paris for you.")
        #expect(try await stream.getFinalText() == "I'll check the current weather in Paris for you.")
    }
}

/// `test_message_delta_fields_are_all_accumulated`: a tripwire listing the fields of the
/// `message_delta` types; handle a new field in `accumulateEvent`, then list it here.
@Test func messageDeltaFieldsAreAllAccumulated() {
    #expect(fieldNames(RawMessageDeltaEvent(delta: .init(), usage: MessageDeltaUsage(outputTokens: 0))) == ["delta", "type", "usage"])
    #expect(fieldNames(RawMessageDeltaEvent.Delta()) == ["container", "stopDetails", "stopReason", "stopSequence"])
    #expect(fieldNames(MessageDeltaUsage(outputTokens: 0)) == [
        "cacheCreationInputTokens", "cacheReadInputTokens", "inputTokens", "outputTokens", "outputTokensDetails", "serverToolUse",
    ])
}

/// `test_tracks_tool_input_type_alias_is_up_to_date`: every content block with an `input` property
/// is accumulated from `input_json_delta`.
@Test func tracksToolInputIsUpToDate() throws {
    let samples: [JSONValue] = [
        ["type": "tool_use", "id": "a", "name": "n", "input": [:]],
        ["type": "server_tool_use", "id": "a", "name": "web_search", "input": [:]],
    ]
    for sample in samples {
        let block = try sample.decode(as: ContentBlock.self)
        let message = Message(id: "m", content: [], model: "m", usage: Usage(inputTokens: 0, outputTokens: 0))
        var bufs: [Int: String] = [:]
        var snapshot = try accumulateEvent(.contentBlockStart(RawContentBlockStartEvent(contentBlock: try sample.decode(), index: 0)),
                                           snapshot: message, jsonBufs: &bufs)
        #expect(snapshot.content == [block])
        snapshot = try accumulateEvent(.contentBlockDelta(RawContentBlockDeltaEvent(delta: .inputJsonDelta(InputJSONDelta(partialJson: #"{"k": 1}"#)), index: 0)),
                                       snapshot: snapshot, jsonBufs: &bufs)
        #expect(try JSONValue.from(snapshot.content[0])["input"] == ["k": 1])
    }
}
