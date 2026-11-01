import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/streaming/test_beta_messages.py (async variants; sync-only tests run async).

let expectedBetaBasicMessage: JSONValue = [
    "id": "msg_4QpJur2dWWDjF6C758FbBw5vm12BaVipnK", "model": "claude-3-opus-latest", "role": "assistant", "stop_reason": "end_turn",
    "type": "message", "content": [["type": "text", "text": "Hello there!"]], "usage": ["input_tokens": 11, "output_tokens": 6],
]

let expectedBetaBasicEventTypes = [
    "message_start", "content_block_start", "content_block_delta", "text", "content_block_delta", "text", "content_block_delta", "text",
    "content_block_stop", "message_delta",
]

let expectedBetaToolUseMessage: JSONValue = [
    "id": "msg_019Q1hrJbZG26Fb9BQhrkHEr", "model": "claude-sonnet-4-20250514", "role": "assistant", "stop_reason": "tool_use",
    "type": "message",
    "content": [
        ["type": "text", "text": "I'll check the current weather in Paris for you."],
        ["type": "tool_use", "caller": ["type": "direct"], "id": "toolu_01NRLabsLyVHZPKxbKvkfSMn", "name": "get_weather",
         "input": ["location": "Paris"]],
    ],
    "usage": ["input_tokens": 377, "output_tokens": 65, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "service_tier": "standard"],
]

let expectedBetaToolUseEventTypes = [
    "message_start", "content_block_start", "content_block_delta", "text", "content_block_delta", "text", "content_block_stop",
    "content_block_start", "content_block_delta", "input_json", "content_block_delta", "input_json", "content_block_delta", "input_json",
    "content_block_delta", "input_json", "content_block_delta", "input_json", "content_block_stop", "message_delta",
]

let expectedIncompleteMessage: JSONValue = [
    "id": "msg_01UdjYBBipA9omjYhicnevgq", "model": "claude-3-7-sonnet-20250219", "role": "assistant", "stop_reason": "max_tokens",
    "type": "message",
    "content": [
        ["type": "text",
         "text": "I'll create a comprehensive tax guide for someone with multiple W2s and save it in a file called taxes.txt. Let me do that for you now."],
        ["type": "tool_use", "id": "toolu_01EKqbqmZrGRXy18eN7m9kvY", "name": "make_file",
         "input": ["filename": "taxes.txt",
                   "lines_of_text": ["# COMPREHENSIVE TAX GUIDE FOR INDIVIDUALS WITH MULTIPLE W-2s", "", "## INTRODUCTION", ""]]],
    ],
    "usage": ["input_tokens": 450, "output_tokens": 124, "cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "service_tier": "standard"],
]

let expectedIncompleteEventTypes = [
    "message_start", "content_block_start", "content_block_delta", "text", "content_block_delta", "text", "content_block_delta", "text",
    "content_block_delta", "text", "content_block_delta", "text", "content_block_stop", "content_block_start", "content_block_delta",
    "input_json", "content_block_delta", "input_json", "content_block_delta", "input_json", "content_block_delta", "input_json", "message_delta",
]

let expectedCompactionMessage: JSONValue = [
    "id": "msg_01CompactionEncryptedContent01", "model": "claude-opus-4-7", "role": "assistant", "stop_reason": "end_turn", "type": "message",
    "content": [
        ["type": "compaction", "content": "Earlier conversation summarized.", "encrypted_content": "EpwBCioIDxgCEAEYASJALd_opaque_compaction_payload"],
        ["type": "text", "text": "Hello there!"],
    ],
    "usage": ["input_tokens": 30, "output_tokens": 8],
]

let expectedCompactionEventTypes = [
    "message_start", "content_block_start", "content_block_delta", "compaction", "content_block_stop", "content_block_start",
    "content_block_delta", "text", "content_block_stop", "message_delta",
]

let expectedFallbackEventTypes = [
    "message_start", "content_block_start", "content_block_stop", "content_block_start", "content_block_delta", "text", "content_block_stop",
    "message_delta",
]

let inputTransformationsCases: [(String, JSONValue)] = [
    ("input_transformations_delta_response.txt",
     [["type": "thinking_dropped", "path": "messages.0.content.0", "reason": "model_binding_mismatch"]]),
    ("input_transformations_start_only_response.txt",
     [["type": "thinking_dropped", "path": "messages.0.content.0", "reason": "model_binding_mismatch"]]),
    ("input_transformations_empty_delta_response.txt", []),
]

/// Stands in for a `@beta_tool` / toolset object: `tools=` takes its tool param.
let weatherTool: JSONValue = ["name": "get_weather", "description": "Weather lookup.", "input_schema": ["type": "object"]]

@Suite struct BetaMessageStreamTests {
    func open(_ server: MockServer, model: String = "claude-opus-4-5", tools: [BetaToolUnionParam]? = nil) async throws -> BetaMessageStream<Never> {
        try await server.client().beta.messages.stream(maxTokens: 1024, messages: [betaUserMessage("Say hello there!")],
                                                       model: ModelParam(rawValue: model), tools: tools)
    }

    @Test func basicResponse() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"))])
        let stream = try await open(server)
        let events = try await collect(stream)
        #expect(try jsonExcludingNone(try await stream.getFinalMessage()) == expectedBetaBasicMessage)
        #expect(events.map(\.type) == expectedBetaBasicEventTypes)
        #expect(server.requests.last?.url.query == nil)
        #expect(server.requests.last?.headers["x-stainless-stream-helper"] == "beta.messages")
    }

    @Test func unknownEventsArePassedThrough() async throws {
        let server = MockServer([.sse(getResponse("unknown_events_response.txt"))])
        let stream = try await open(server)
        let events = try await collect(stream)
        #expect(try jsonExcludingNone(try await stream.getFinalMessage()) == expectedBetaBasicMessage)
        #expect(events.map(\.type) == [
            "future_event", "content_block_stop", "message_start", "content_block_start", "content_block_delta", "text",
            "content_block_delta", "text", "content_block_delta", "text", "content_block_stop", "future_event", "message_delta",
            "message_stop", "future_event",
        ])
        #expect(try JSONValue.from(events[0]) == ["type": "future_event", "usage": ["input_tokens": 99, "output_tokens": 99]])
    }

    @Test func contextManager() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"), headers: ["request-id": "my-req-id", "anthropic-workspace-id": "wrkspc_123"])])
        let stream = try await open(server, model: "claude-3-opus-latest")
        #expect(!stream.response.isClosed)
        #expect(stream.requestID == "my-req-id")
        #expect(stream.workspaceID == "wrkspc_123")
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
        let stream = try await open(server, model: "claude-sonnet-5-5", tools: [try weatherTool.decode()])
        let events = try await collect(stream)
        #expect(try jsonExcludingNone(try await stream.getFinalMessage()) == expectedBetaToolUseMessage)
        #expect(events.map(\.type) == expectedBetaToolUseEventTypes)
        #expect(server.bodies.last?["tools"] == [weatherTool])
    }

    @Test func toolUseRoundTrip() async throws {
        let server = MockServer([.sse(getResponse("tool_use_response.txt")), .json(followUpMessage)])
        let client = try server.client()
        let message = try await client.beta.messages.stream(maxTokens: 1024, messages: [betaUserMessage("What is the weather in Paris?")],
                                                            model: "claude-sonnet-5-5").getFinalMessage()
        _ = try await client.beta.messages.create(
            maxTokens: 1024,
            messages: [
                betaUserMessage("What is the weather in Paris?"),
                betaMessageParam(["role": "assistant", "content": try JSONValue.from(message.content)]),
                betaUserMessage([["type": "tool_result", "tool_use_id": "toolu_01NRLabsLyVHZPKxbKvkfSMn", "content": "Sunny"]]),
            ],
            model: "claude-sonnet-5-5")
        #expect(server.bodies.last?["messages"]?[1]?["content"]?[1] == expectedToolUseParam)
    }

    @Test func serverToolUse() async throws {
        let server = MockServer([.sse(getResponse("server_tool_use_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        let events = try await collect(stream)
        let message = try await stream.getFinalMessage()
        #expect(events.map(\.type) == expectedServerToolUseEventTypes)
        guard case .serverToolUse(let block) = message.content[0] else {
            Issue.record("expected server_tool_use")
            return
        }
        #expect(block.input == ["query": "anthropic claude release notes"])
        let inputs = events.compactMap { e -> InputJsonEvent? in if case .inputJson(let i) = e { return i } else { return nil } }
        #expect(inputs.map(\.partialJSON) == expectedServerToolPartials)
        #expect(inputs.last?.snapshot == ["query": "anthropic claude release notes"])
    }

    @Test func incompleteResponse() async throws {
        let server = MockServer([.sse(getResponse("incomplete_partial_json_response.txt"))])
        let stream = try await open(server, model: "claude-sonnet-5-5")
        let events = try await collect(stream)
        #expect(try jsonExcludingNone(try await stream.getFinalMessage()) == expectedIncompleteMessage)
        #expect(events.map(\.type) == expectedIncompleteEventTypes)
    }

    @Test func refusalStopDetailsPropagated() async throws {
        let server = MockServer([.sse(getResponse("refusal_response.txt"))])
        let message = try await open(server, model: "claude-opus-4-7").getFinalMessage()
        let d = message.stopDetails
        assertRefusalResponse(stopReason: message.stopReason?.rawValue, category: d?.category?.rawValue, explanation: d?.explanation, type: d?.type)
    }

    @Test func messageStopEventSerialization() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt") + "\n")])
        let events = try await collect(try await open(server, model: "claude-opus-4-7"))
        guard case .messageStop(let stop)? = events.last, case .text = stop.message.content[0] else {
            Issue.record("expected message_stop with a text block")
            return
        }
        #expect(try JSONValue.from(events.last!)["message"]?["content"]?[0]?["type"] == "text")
    }

    @Test func compaction() async throws {
        let server = MockServer([.sse(getResponse("compaction_response.txt"))])
        let stream = try await open(server, model: "claude-opus-4-7")
        let events = try await collect(stream)
        #expect(try jsonExcludingNone(try await stream.getFinalMessage()) == expectedCompactionMessage)
        #expect(events.map(\.type) == expectedCompactionEventTypes)
        // the emitted compaction event must carry encrypted_content, not just the accumulated block
        let compactions = events.compactMap { e -> BetaCompactionEvent? in if case .compaction(let c) = e { return c } else { return nil } }
        #expect(compactions.count == 1)
        #expect(compactions.first?.encryptedContent == "EpwBCioIDxgCEAEYASJALd_opaque_compaction_payload")
    }

    @Test func fallbackRelabelsModel() async throws {
        let server = MockServer([.sse(getResponse("fallback_response.txt"))])
        let stream = try await open(server, model: "claude-opus-4-7")
        let events = try await collect(stream)
        let message = try await stream.getFinalMessage()
        #expect(events.map(\.type) == expectedFallbackEventTypes)
        // `message_start` carried the declined model; the accumulated message is relabeled to the serving model
        #expect(message.model.rawValue == "claude-sonnet-4-5")
        guard case .fallback = message.content[0], case .text(let text) = message.content[1] else {
            Issue.record("unexpected content \(message.content)")
            return
        }
        #expect(text.text == "Hello there!")
    }

    @Test func fallbackCreditUsagePropagated() async throws {
        let server = MockServer([.sse(getResponse("fallback_credit_response.txt"))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        #expect(try JSONValue.from(message.usage.fallbackCredit)["status"]?["type"] == "redeemed")
        #expect(message.usage.outputTokens == 8)
    }

    @Test func messageDeltaFieldsPropagated() async throws {
        let server = MockServer([.sse(getResponse("message_delta_fields_response.txt"))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        #expect(message.container?.id == "container_01AbCdEfGh")
        #expect(message.usage.outputTokens == 8)
        #expect(message.usage.inputTokens == 40)
        #expect(message.usage.cacheCreationInputTokens == 12)
        #expect(message.usage.cacheReadInputTokens == 7)
        #expect(message.usage.outputTokensDetails?.thinkingTokens == 3)
        #expect(message.usage.serverToolUse?.webSearchRequests == 1)
        #expect(message.usage.serviceTier?.rawValue == "standard")
        #expect(message.usage.cacheCreation?.ephemeral5mInputTokens == 10)
    }

    @Test func contextManagementPropagated() async throws {
        let server = MockServer([.sse(getResponse("context_management_response.txt"))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        // `context_management` is a top-level key of the `message_delta` event only
        let edit = try JSONValue.from(message.contextManagement)["applied_edits"]?[0]
        #expect(edit?["type"] == "clear_tool_uses_20250919")
        #expect(edit?["cleared_tool_uses"] == 2)
        #expect(edit?["cleared_input_tokens"] == 1500)
    }

    @Test(arguments: inputTransformationsCases.indices)
    func inputTransformationsPropagated(_ i: Int) async throws {
        let (name, expected) = inputTransformationsCases[i]
        let server = MockServer([.sse(getResponse(name))])
        let message = try await open(server, model: "claude-sonnet-5-5").getFinalMessage()
        #expect(message.inputTransformations != nil)
        #expect(try JSONValue.from(message.inputTransformations) == expected)
    }
}

/// Tripwire: handle a new `message_delta` field in `accumulateBetaEvent`, then list it here.
@Test func betaMessageDeltaFieldsAreAllAccumulated() {
    #expect(fieldNames(BetaRawMessageDeltaEvent(delta: .init(), usage: BetaMessageDeltaUsage(outputTokens: 0))) == [
        "contextManagement", "delta", "inputTransformations", "type", "usage",
    ])
    #expect(fieldNames(BetaRawMessageDeltaEvent.Delta()) == ["container", "stopDetails", "stopReason", "stopSequence"])
    #expect(fieldNames(BetaMessageDeltaUsage(outputTokens: 0)) == [
        "cacheCreationInputTokens", "cacheReadInputTokens", "fallbackCredit", "inputTokens", "iterations", "outputTokens",
        "outputTokensDetails", "serverToolUse",
    ])
}

@Test func betaTracksToolInputIsUpToDate() throws {
    let samples: [JSONValue] = [
        ["type": "tool_use", "id": "a", "name": "n", "input": [:]],
        ["type": "server_tool_use", "id": "a", "name": "web_search", "input": [:]],
        ["type": "mcp_tool_use", "id": "a", "name": "n", "server_name": "s", "input": [:]],
    ]
    for sample in samples {
        let message = BetaMessage(id: "m", content: [], model: "m", usage: BetaUsage(inputTokens: 0, outputTokens: 0))
        var bufs: [Int: String] = [:]
        var snapshot = try accumulateBetaEvent(.contentBlockStart(BetaRawContentBlockStartEvent(contentBlock: try sample.decode(), index: 0)),
                                               snapshot: message, jsonBufs: &bufs, requestHeaders: nil)
        snapshot = try accumulateBetaEvent(
            .contentBlockDelta(BetaRawContentBlockDeltaEvent(delta: .inputJsonDelta(BetaInputJSONDelta(partialJson: #"{"k": 1}"#)), index: 0)),
            snapshot: snapshot, jsonBufs: &bufs, requestHeaders: nil)
        #expect(try JSONValue.from(snapshot.content[0])["input"] == ["k": 1])
    }
}
