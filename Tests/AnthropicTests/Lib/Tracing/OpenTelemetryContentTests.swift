// Port of `TestContent` in tests/test_open_telemetry.py. See docs/porting/tracing.md for what is skipped.
//
// A Swift request is typed, so requests whose content no param type has (a block without a `type`, a result block sent
// back as it is) send their `messages` as `extraBody`, which is merged into the body that the span reads.

import Foundation
import Testing
@testable import Anthropic

let SYSTEM_KEY = "gen_ai.system_instructions"
let INPUT_KEY = "gen_ai.input.messages"
let OUTPUT_KEY = "gen_ai.output.messages"
let STOPS_KEY = "gen_ai.request.stop_sequences"

func ojText(_ content: String) -> OrderedJSON { .obj(("type", "text"), ("content", .string(content))) }
func ojMessage(_ role: String, _ parts: OrderedJSON...) -> OrderedJSON { ojMessage(role, parts) }
func ojMessage(_ role: String, _ parts: [OrderedJSON]) -> OrderedJSON { .obj(("role", .string(role)), ("parts", .array(parts))) }
func ojReasoning(_ content: String) -> OrderedJSON { .obj(("type", "reasoning"), ("content", .string(content))) }
func ojToolCall(_ id: String, _ name: String, _ arguments: OrderedJSON) -> OrderedJSON {
    .obj(("type", "tool_call"), ("id", .string(id)), ("name", .string(name)), ("arguments", arguments))
}

/// `tool_stream_events`: the events of `stream_events`, with a `tool_use` block after the text.
func tracingToolStreamEvents() -> [JSONValue] {
    var events = tracingStreamEvents()
    events.insert(contentsOf: [
        ["type": "content_block_start", "index": 1, "content_block": ["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": [:]]],
        ["type": "content_block_delta", "index": 1, "delta": ["type": "input_json_delta", "partial_json": "{\"city\": "]],
        ["type": "content_block_delta", "index": 1, "delta": ["type": "input_json_delta", "partial_json": "\"SF\"}"]],
        ["type": "content_block_stop", "index": 1],
    ], at: 4)
    return events
}

let tracingToolStreamOutput: JSONValue = [["role": "assistant", "parts": [
    ["type": "text", "content": "Hi there"], ["type": "tool_call", "id": "toolu_1", "name": "get_weather", "arguments": ["city": "SF"]],
]]]

/// `cut_tool_stream_events`.
func tracingCutToolStreamEvents() -> [JSONValue] {
    Array(tracingToolStreamEvents()[..<5]) + [["type": "content_block_delta", "index": 1,
                                               "delta": ["type": "input_json_delta", "partial_json": "{\"city\": \"SF\", \"days\": "]]]
}

/// `CUT_STREAMS`.
let tracingCutStreams: [([JSONValue], JSONValue)] = [
    (Array(tracingStreamEvents()[..<3]), [["type": "text", "content": "Hi there"]]),
    (tracingCutToolStreamEvents(), [["type": "text", "content": "Hi there"],
                                    ["type": "tool_call", "id": "toolu_1", "name": "get_weather", "arguments": ["city": "SF"]]]),
]

/// Reads a stream helper to its end, with the stable or the beta resource.
func tracingHelperUntilDone(_ client: Anthropic, beta: Bool, messages: [JSONValue] = tracingHello, stopSequences: [String]? = nil) async throws {
    if beta {
        try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(messages), model: "claude-test", stopSequences: stopSequences)
            .untilDone()
    } else {
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(messages), model: "claude-test", stopSequences: stopSequences)
            .untilDone()
    }
}

func tracingContentClient(_ spans: TracingSpans, _ router: TracingRouter, maxContentBytes: Int? = nil) throws -> Anthropic {
    try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content, maxContentBytes: maxContentBytes)))
}

@Suite struct OpenTelemetryContentTests {
    @Test func contentMode() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [
            ["type": "text", "text": "Let me check"], ["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": ["city": "SF"]],
        ])))
        let client = try tracingContentClient(spans, router)

        try await tracingCreate(client, messages: [
            ["role": "user", "content": "Weather?"],
            ["role": "assistant", "content": [["type": "tool_use", "id": "toolu_0", "name": "get_weather", "input": ["city": "LA"]]]],
            ["role": "user", "content": [
                ["type": "tool_result", "tool_use_id": "toolu_0", "content": "sunny"],
                ["type": "image", "source": ["type": "url", "url": "https://example.com/cat.png"]],
                ["type": "document", "source": ["type": "text", "media_type": "text/plain", "data": "Cats"]],
            ]],
        ], extraBody: ["system": "Be brief"])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(SYSTEM_KEY) == [["type": "text", "content": "Be brief"]])
        #expect(span.json(INPUT_KEY) == [
            ["role": "user", "parts": [["type": "text", "content": "Weather?"]]],
            ["role": "assistant", "parts": [["type": "tool_call", "id": "toolu_0", "name": "get_weather", "arguments": ["city": "LA"]]]],
            ["role": "user", "parts": [
                ["type": "tool_call_response", "id": "toolu_0", "response": [["type": "text", "text": "sunny"]]],
                // Any other block is its type after `anthropic_`.
                ["type": "anthropic_image"],
                ["type": "anthropic_document"],
            ]],
        ])
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": [
            ["type": "text", "content": "Let me check"], ["type": "tool_call", "id": "toolu_1", "name": "get_weather", "arguments": ["city": "SF"]],
        ]]])
    }

    @Test func toolResultContentIsContentBlocks() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let text: JSONValue = [
            "type": "text", "text": "Cats sleep a lot.",
            "citations": [["type": "char_location", "cited_text": "Cats sleep", "document_index": 0, "document_title": "Cats",
                           "start_char_index": 0, "end_char_index": 10]],
            "cache_control": ["type": "ephemeral"],
        ]
        let searchResult: JSONValue = ["type": "search_result", "source": "https://example.com/cats", "title": "Cats",
                                       "content": [["type": "text", "text": "Cats sleep a lot."]], "citations": ["enabled": true]]

        try await tracingCreate(try tracingContentClient(spans, router), extraBody: ["messages": [["role": "user", "content": [
            ["type": "tool_result", "tool_use_id": "toolu_0", "content": "sunny"],
            ["type": "tool_result", "tool_use_id": "toolu_1", "content": [
                text, searchResult, ["type": "image", "source": ["type": "url", "url": "https://example.com/cat.png"]], ["data": "no type"],
            ]],
            ["type": "tool_result", "tool_use_id": "toolu_2"],
            ["data": "no type"],
        ]]]])

        let message = try #require(try spans.one("anthropic.messages.create").json(INPUT_KEY)?[0])
        #expect(message["parts"] == [
            ["type": "tool_call_response", "id": "toolu_0", "response": [["type": "text", "text": "sunny"]]],
            // A text block and a search result keep all of their fields. Any other block is its type, with no prefix.
            ["type": "tool_call_response", "id": "toolu_1", "response": [text, searchResult, ["type": "image"], ["type": "unknown"]]],
            ["type": "tool_call_response", "id": "toolu_2", "response": []],
            ["type": "anthropic_unknown"],
        ])
    }

    @Test func toolResultContentLeavesOutEncryptedFields() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let text: JSONValue = ["type": "text", "text": "Cats sleep a lot.", "citations": [[
            "type": "web_search_result_location", "cited_text": "Cats sleep", "encrypted_index": "encrypted_0", "title": "Cats",
            "url": "https://example.com/cats",
        ]]]

        try await tracingCreate(try tracingContentClient(spans, router), messages: [
            ["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_0", "content": [text]]]],
        ])

        let message = try #require(try spans.one("anthropic.messages.create").json(INPUT_KEY)?[0])
        #expect(message["parts"] == [["type": "tool_call_response", "id": "toolu_0", "response": [[
            "type": "text", "text": "Cats sleep a lot.",
            "citations": [["type": "web_search_result_location", "cited_text": "Cats sleep", "title": "Cats", "url": "https://example.com/cats"]],
        ]]]])
    }

    @Test func serverAndMCPToolBlocksAreToolCallsAndTheirResponses() async throws {
        let document: JSONValue = ["type": "document", "source": ["type": "text", "media_type": "text/plain", "data": "Cats sleep a lot."], "title": "Cats"]
        let response = tracingMessage.with("content", [
            // Only a `tool_use` block has a `toolset_name`: on any other block it is left out.
            ["type": "server_tool_use", "id": "srvtoolu_1", "name": "code_execution", "input": ["code": "1 + 1"], "toolset_name": "computer"],
            ["type": "code_execution_tool_result", "tool_use_id": "srvtoolu_1", "content": [
                "type": "code_execution_result", "stdout": "2", "stderr": "", "return_code": 0,
                "content": [["type": "code_execution_output", "file_id": "file_1"]],
            ]],
            ["type": "web_search_tool_result", "tool_use_id": "srvtoolu_2", "content": ["type": "web_search_tool_result_error", "error_code": "too_many_requests"]],
            ["type": "text_editor_code_execution_tool_result", "tool_use_id": "srvtoolu_3", "content": [
                "type": "text_editor_code_execution_view_result", "file_type": "image", "content": "aGVsbG8=", "num_lines": nil,
            ]],
            ["type": "web_fetch_tool_result", "tool_use_id": "srvtoolu_4", "content": ["type": "web_fetch_result", "url": "https://example.com/cats",
                                                                                         "content": document]],
            ["type": "mcp_tool_use", "id": "mcptoolu_1", "name": "echo", "server_name": "tools", "input": ["x": 1], "toolset_name": "computer"],
            ["type": "mcp_tool_result", "tool_use_id": "mcptoolu_1", "is_error": false, "content": [["type": "text", "text": "one"]]],
        ])
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(response))

        try await tracingBetaCreate(try tracingContentClient(spans, router), extraBody: ["messages": [
            ["role": "user", "content": "Cats?"],
            ["role": "assistant", "content": [
                ["type": "server_tool_use", "id": "srvtoolu_0", "name": "web_search", "input": ["query": "cats"], "toolset_name": "computer"],
                ["type": "web_search_tool_result", "tool_use_id": "srvtoolu_0", "content": [[
                    "type": "web_search_result", "url": "https://example.com/cats", "title": "Cats", "encrypted_content": "encrypted_0", "page_age": "1 day",
                ]]],
                ["type": "mcp_tool_use", "id": "mcptoolu_0", "name": "echo", "server_name": "tools", "input": ["x": 0], "toolset_name": "computer"],
                ["type": "mcp_tool_result", "tool_use_id": "mcptoolu_0", "content": "zero"],
                ["type": "mcp_tool_result", "tool_use_id": "mcptoolu_9"],
            ]],
            ["role": "user", "content": "More"],
        ]])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(INPUT_KEY)?[1]?["parts"] == [
            ["type": "tool_call", "id": "srvtoolu_0", "name": "web_search", "arguments": ["query": "cats"]],
            // A web search result is kept, without the field that is encrypted.
            ["type": "tool_call_response", "id": "srvtoolu_0", "response": [
                ["type": "web_search_result", "url": "https://example.com/cats", "title": "Cats", "page_age": "1 day"],
            ]],
            ["type": "tool_call", "id": "mcptoolu_0", "name": "echo", "arguments": ["x": 0], "anthropic_mcp_server_name": "tools"],
            ["type": "tool_call_response", "id": "mcptoolu_0", "response": [["type": "text", "text": "zero"]]],
            ["type": "tool_call_response", "id": "mcptoolu_9", "response": []],
        ])
        #expect(span.json(OUTPUT_KEY)?[0]?["parts"] == [
            ["type": "tool_call", "id": "srvtoolu_1", "name": "code_execution", "arguments": ["code": "1 + 1"]],
            ["type": "tool_call_response", "id": "srvtoolu_1", "response": [
                "type": "code_execution_result", "stdout": "2", "stderr": "", "return_code": 0,
                "content": [["type": "code_execution_output", "file_id": "file_1"]],
            ]],
            ["type": "tool_call_response", "id": "srvtoolu_2", "response": ["type": "web_search_tool_result_error", "error_code": "too_many_requests"]],
            // The data of an image or of a document is left out.
            ["type": "tool_call_response", "id": "srvtoolu_3", "response": [
                "type": "text_editor_code_execution_view_result", "file_type": "image", "num_lines": nil,
            ]],
            ["type": "tool_call_response", "id": "srvtoolu_4", "response": [
                "type": "web_fetch_result", "url": "https://example.com/cats", "content": ["type": "document"],
            ]],
            ["type": "tool_call", "id": "mcptoolu_1", "name": "echo", "arguments": ["x": 1], "anthropic_mcp_server_name": "tools"],
            ["type": "tool_call_response", "id": "mcptoolu_1", "response": [["type": "text", "text": "one"]]],
        ])
        for name in [INPUT_KEY, OUTPUT_KEY] {
            let value = span[name]?.stringValue ?? ""
            #expect(!value.contains("encrypted_") && !value.contains("aGVsbG8="))
        }
    }

    @Test(arguments: [false, true])
    func toolsetNameOfAToolUseBlockIsOnItsToolCall(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [
            ["type": "tool_use", "id": "toolu_4", "name": "screenshot", "input": [:], "toolset_name": "computer"],
            ["type": "tool_use", "id": "toolu_5", "name": "get_weather", "input": [:], "toolset_name": nil],
            ["type": "tool_use", "id": "toolu_6", "name": "get_time", "input": [:]],
        ])))
        let client = try tracingContentClient(spans, router)
        let messages: [JSONValue] = [
            ["role": "user", "content": "Look"],
            ["role": "assistant", "content": [
                ["type": "tool_use", "id": "toolu_0", "name": "click", "input": [:], "toolset_name": "computer"],
                ["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": [:], "toolset_name": nil],
                ["type": "tool_use", "id": "toolu_2", "name": "get_time", "input": [:]],
            ]],
            ["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_0", "content": "done", "toolset_name": "computer"]]],
        ]

        if beta { try await tracingBetaCreate(client, extraBody: ["messages": .array(messages)]) } else {
            try await tracingCreate(client, extraBody: ["messages": .array(messages)])
        }

        let span = try spans.one("anthropic.messages.create")
        let inputs = try #require(span.json(INPUT_KEY))
        #expect(inputs[1]?["parts"] == [
            ["type": "tool_call", "id": "toolu_0", "name": "click", "arguments": [:], "anthropic_toolset_name": "computer"],
            // A `toolset_name` that is null is left out, like one that is absent.
            ["type": "tool_call", "id": "toolu_1", "name": "get_weather", "arguments": [:]],
            ["type": "tool_call", "id": "toolu_2", "name": "get_time", "arguments": [:]],
        ])
        #expect(inputs[2]?["parts"] == [["type": "tool_call_response", "id": "toolu_0", "response": [["type": "text", "text": "done"]]]])
        #expect(span.json(OUTPUT_KEY)?[0]?["parts"] == [
            ["type": "tool_call", "id": "toolu_4", "name": "screenshot", "arguments": [:], "anthropic_toolset_name": "computer"],
            ["type": "tool_call", "id": "toolu_5", "name": "get_weather", "arguments": [:]],
            ["type": "tool_call", "id": "toolu_6", "name": "get_time", "arguments": [:]],
        ])
        // The key comes after `arguments`.
        #expect(span[OUTPUT_KEY]?.stringValue?.contains("{\"type\":\"tool_call\",\"id\":\"toolu_4\",\"name\":\"screenshot\",\"arguments\":{},\"anthropic_toolset_name\":\"computer\"}") == true)
    }

    @Test func streamedServerAndMCPToolBlocksAreToolCallsAndTheirResponses() async throws {
        var events = tracingStreamEvents(index: 4)
        events.insert(contentsOf: [
            ["type": "content_block_start", "index": 0, "content_block": ["type": "server_tool_use", "id": "srvtoolu_1", "name": "web_search", "input": [:],
                                                                          "toolset_name": "computer"]],
            ["type": "content_block_delta", "index": 0, "delta": ["type": "input_json_delta", "partial_json": "{\"query\": "]],
            ["type": "content_block_delta", "index": 0, "delta": ["type": "input_json_delta", "partial_json": "\"cats\"}"]],
            ["type": "content_block_stop", "index": 0],
            ["type": "content_block_start", "index": 1, "content_block": ["type": "web_search_tool_result", "tool_use_id": "srvtoolu_1", "content": [[
                "type": "web_search_result", "url": "https://example.com/cats", "title": "Cats", "encrypted_content": "encrypted_1", "page_age": nil,
            ]]]],
            ["type": "content_block_stop", "index": 1],
            ["type": "content_block_start", "index": 2, "content_block": ["type": "mcp_tool_use", "id": "mcptoolu_1", "name": "echo", "server_name": "tools",
                                                                          "input": [:], "toolset_name": "computer"]],
            ["type": "content_block_delta", "index": 2, "delta": ["type": "input_json_delta", "partial_json": "{\"x\": 1}"]],
            ["type": "content_block_stop", "index": 2],
            ["type": "content_block_start", "index": 3, "content_block": ["type": "mcp_tool_result", "tool_use_id": "mcptoolu_1", "is_error": false,
                                                                          "content": "one"]],
            ["type": "content_block_stop", "index": 3],
        ], at: 1)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: true)

        // The model of the result's search result has no `page_age` when it is null.
        let parts = try #require(try spans.one("anthropic.messages.create").json(OUTPUT_KEY)?[0]?["parts"]?.arrayValue)
        #expect(parts.count == 5)
        #expect(parts[0] == ["type": "tool_call", "id": "srvtoolu_1", "name": "web_search", "arguments": ["query": "cats"]])
        #expect(parts[1]["type"] == "tool_call_response" && parts[1]["id"] == "srvtoolu_1")
        let result = parts[1]["response"]?[0]
        #expect(result?["url"] == "https://example.com/cats" && result?["title"] == "Cats" && result?["encrypted_content"] == nil)
        #expect(parts[2] == ["type": "tool_call", "id": "mcptoolu_1", "name": "echo", "arguments": ["x": 1], "anthropic_mcp_server_name": "tools"])
        #expect(parts[3] == ["type": "tool_call_response", "id": "mcptoolu_1", "response": [["type": "text", "text": "one"]]])
        #expect(parts[4] == ["type": "text", "content": "Hi there"])
    }

    @Test(arguments: [false, true])
    func streamedToolsetNameOfAToolUseBlockIsOnItsToolCall(beta: Bool) async throws {
        func toolUse(_ index: Int, _ name: String, _ fields: [String: JSONValue] = [:]) -> [JSONValue] {
            var block: JSONValue = ["type": "tool_use", "id": .string("toolu_\(index)"), "name": .string(name), "input": [:]]
            for (k, v) in fields { block[k] = v }
            return [["type": "content_block_start", "index": .int(index), "content_block": block],
                    ["type": "content_block_delta", "index": .int(index), "delta": ["type": "input_json_delta", "partial_json": "{}"]],
                    ["type": "content_block_stop", "index": .int(index)]]
        }
        var events = tracingStreamEvents(index: 3)
        events.insert(contentsOf: toolUse(0, "screenshot", ["toolset_name": "computer"]) + toolUse(1, "get_weather", ["toolset_name": nil])
            + toolUse(2, "get_time"), at: 1)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: beta)

        #expect(try spans.one("anthropic.messages.create").json(OUTPUT_KEY)?[0]?["parts"] == [
            ["type": "tool_call", "id": "toolu_0", "name": "screenshot", "arguments": [:], "anthropic_toolset_name": "computer"],
            ["type": "tool_call", "id": "toolu_1", "name": "get_weather", "arguments": [:]],
            ["type": "tool_call", "id": "toolu_2", "name": "get_time", "arguments": [:]],
            ["type": "text", "content": "Hi there"],
        ])
    }

    @Test func thinkingIsAReasoningPartWithoutItsSignature() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [
            ["type": "thinking", "thinking": "SF is foggy in summer.", "signature": "sig_response"],
            // The API hides the thinking of this block.
            ["type": "thinking", "thinking": "", "signature": "sig_hidden"],
            ["type": "redacted_thinking", "data": "encrypted_response"],
            ["type": "text", "text": "Foggy"],
        ])))
        let messages: [JSONValue] = [
            ["role": "user", "content": "Weather?"],
            ["role": "assistant", "content": [
                ["type": "thinking", "thinking": "I should ask where.", "signature": "sig_request"],
                ["type": "redacted_thinking", "data": "encrypted_request"],
                ["type": "text", "text": "Where?"],
            ]],
            ["role": "user", "content": "SF"],
        ]

        try await tracingCreate(try tracingContentClient(spans, router), messages: messages)
        try await tracingCreate(try tracingClient(spans, router), messages: messages)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        let (span, withoutContent) = (calls[0], calls[1])
        #expect(span.json(INPUT_KEY) == [
            ["role": "user", "parts": [["type": "text", "content": "Weather?"]]],
            ["role": "assistant", "parts": [["type": "reasoning", "content": "I should ask where."], ["type": "anthropic_redacted_thinking"],
                                            ["type": "text", "content": "Where?"]]],
            ["role": "user", "parts": [["type": "text", "content": "SF"]]],
        ])
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": [
            ["type": "reasoning", "content": "SF is foggy in summer."], ["type": "reasoning", "content": ""],
            ["type": "anthropic_redacted_thinking"], ["type": "text", "content": "Foggy"],
        ]]])
        for value in span.attributes.values { #expect(!value.description.contains("sig_") && !value.description.contains("encrypted_")) }
        #expect(withoutContent[INPUT_KEY] == nil)
        #expect(withoutContent[OUTPUT_KEY] == nil)
    }

    @Test(arguments: [false, true])
    func streamedThinkingIsAReasoningPartWithoutItsSignature(beta: Bool) async throws {
        var events = tracingStreamEvents(index: 2)
        events.insert(contentsOf: [
            ["type": "content_block_start", "index": 0, "content_block": ["type": "thinking", "thinking": "", "signature": ""]],
            ["type": "content_block_delta", "index": 0, "delta": ["type": "thinking_delta", "thinking": "SF is "]],
            ["type": "content_block_delta", "index": 0, "delta": ["type": "thinking_delta", "thinking": "foggy."]],
            ["type": "content_block_delta", "index": 0, "delta": ["type": "signature_delta", "signature": "sig_1"]],
            ["type": "content_block_stop", "index": 0],
            ["type": "content_block_start", "index": 1, "content_block": ["type": "redacted_thinking", "data": "encrypted_1"]],
            ["type": "content_block_stop", "index": 1],
        ], at: 1)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: beta)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": [
            ["type": "reasoning", "content": "SF is foggy."], ["type": "anthropic_redacted_thinking"], ["type": "text", "content": "Hi there"],
        ]]])
        #expect(span[OUTPUT_KEY]?.stringValue?.contains("sig_1") == false)
        #expect(span[OUTPUT_KEY]?.stringValue?.contains("encrypted_1") == false)
    }

    @Test func environmentVariableEnablesContent() async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let env = ["ANTHROPIC_OPEN_TELEMETRY_TRACES_CONTENT_MODE": "Content"]

        try await OpenTelemetry.withTracerProvider(registered.provider) {
            try await tracingCreate(try tracingClient(nil, router, openTelemetry: .some(nil), environment: env))
            // The variable is for a client that is given no option.
            for option in [OpenTelemetryOptions(traces: true), OpenTelemetryOptions(traces: OpenTelemetryTraces(maxContentBytes: 4096)),
                           OpenTelemetryOptions(traces: OpenTelemetryTraces(contentMode: .metadataOnly))]
            {
                try await tracingCreate(try tracingClient(nil, router, openTelemetry: option, environment: env))
            }
        }

        let calls = registered.named("anthropic.messages.create")
        try #require(calls.count == 4)
        #expect(calls[0][INPUT_KEY] != nil)
        #expect(calls.dropFirst().allSatisfy { $0[INPUT_KEY] == nil })
    }

    @Test func theFormerNameOfTheContentModeVariableIsNotRead() async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await OpenTelemetry.withTracerProvider(registered.provider) {
            try await tracingCreate(try tracingClient(nil, router, openTelemetry: .some(nil), environment: ["ANTHROPIC_OPEN_TELEMETRY_CONTENT_MODE": "content"]))
        }
        #expect(try registered.one("anthropic.messages.create")[INPUT_KEY] == nil)
    }

    @Test(arguments: [false, true])
    func streamHelperContentComesFromItsSnapshot(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingToolStreamEvents()))
        let client = try tracingContentClient(spans, router)

        if beta {
            let stream = try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
            try await stream.untilDone()
            // The span has ended, with the content of the Message that the helper still holds.
            _ = try spans.one("anthropic.messages.create")
            #expect(stream.currentMessageSnapshot?.message.content.count == 2)
        } else {
            let stream = try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
            try await stream.untilDone()
            _ = try spans.one("anthropic.messages.create")
            #expect(stream.currentMessageSnapshot?.message.content.count == 2)
        }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span.json(OUTPUT_KEY) == tracingToolStreamOutput)
    }

    @Test(arguments: [false, true], 0..<2)
    func streamHelperStreamEndedByTheServerHasThePartialOutput(beta: Bool, cut: Int) async throws {
        let (events, parts) = tracingCutStreams[cut]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: beta)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "api_error")
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": parts]])
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["anthropic.message.stop_reason"] == nil)
        #expect(span["gen_ai.usage.output_tokens"] == nil)
    }

    @Test func partialOutputIsContent() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(Array(tracingStreamEvents()[..<3])))

        try await tracingHelperUntilDone(try tracingClient(spans, router), beta: false)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span[OUTPUT_KEY] == nil)
    }

    @Test(arguments: [false, true])
    func streamHelperErrorEventHasThePartialOutput(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(Array(tracingStreamEvents()[..<3]) + [tracingOverloaded]))

        await #expect(throws: APIStatusError.self) { try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: beta) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "overloaded_error")
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": [["type": "text", "content": "Hi there"]]]])
    }

    @Test func streamHelperReadErrorHasThePartialOutput() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .lostConnection(tracingSSE(tracingCutToolStreamEvents()),
                                                            headers: tracingResponseHeaders.merging(["content-type": "text/event-stream"]) { $1 }))

        await #expect(throws: URLError.self) { try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: false) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "connection_error")
        #expect(span.json(OUTPUT_KEY)?[0]?["parts"]?[1]?["arguments"] == ["city": "SF"])
    }

    @Test(arguments: [false, true], [("message_start", JSONValue.array([])), ("text", [["type": "text", "content": "Hi there"]])] as [(String, JSONValue)])
    func streamHelperClosedEarlyHasThePartialOutput(beta: Bool, last: (String, JSONValue)) async throws {
        let (lastEvent, parts) = last
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingToolStreamEvents()))
        let client = try tracingContentClient(spans, router)

        func isLast(_ event: Any) -> Bool {
            ((event as? ParsedMessageStreamEvent)?.type ?? (event as? ParsedBetaMessageStreamEvent)?.type) == lastEvent
        }
        if beta {
            let stream = try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
            for try await event in stream where isLast(event) { break }
            stream.close()
        } else {
            let stream = try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
            for try await event in stream where isLast(event) { break }
            stream.close()
        }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(span[INPUT_KEY] != nil)
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": parts]])
    }

    @Test(arguments: [false, true])
    func streamHelperWithoutAMessageStartHasNoOutput(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse([]), .sse(tracingStreamEvents()))
        let client = try tracingContentClient(spans, router)

        try await tracingHelperUntilDone(client, beta: beta)
        if beta {
            try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test").close()
        } else {
            try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").close()
        }

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls[0].statusCode == .error)
        #expect(calls[1].statusCode == .unset)
        for span in calls {
            #expect(span[INPUT_KEY] != nil)
            #expect(span[OUTPUT_KEY] == nil)
        }
    }

    @Test(arguments: [false, true])
    func streamHelperThatCannotAccumulateAnEventHasNoOutput(beta: Bool) async throws {
        var events = tracingToolStreamEvents()
        events[5] = events[5].with("delta", ["type": "input_json_delta", "partial_json": "{\"city\": nowhere"])
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        await #expect(throws: (any Error).self) { try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: beta) }

        // The snapshot stopped following the stream, so it is no output. What the span has from it besides stays.
        let span = try spans.one("anthropic.messages.create")
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span[INPUT_KEY] != nil)
        #expect(span[OUTPUT_KEY] == nil)
    }

    @Test(arguments: [false, true])
    func streamReadWithoutTheStreamHelperRecordsEverythingButItsContent(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingToolStreamEvents()))
        let client = try tracingContentClient(spans, router)

        if beta { await tracingDrain(try await tracingBetaCreateStream(client)) } else { await tracingDrain(try await tracingCreateStream(client)) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["gen_ai.usage.output_tokens"] == 5)
        #expect(span["anthropic.message.stop_reason"] == "end_turn")
        #expect(span[INPUT_KEY] != nil)
        // `createStreaming` accumulates no Message for the application, and the span accumulates no block's deltas either.
        #expect(span[OUTPUT_KEY] == nil)
    }

    @Test(arguments: [false, true])
    func streamReadWithoutTheStreamHelperThatEndsEarlyHasNoOutput(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingCutToolStreamEvents()))
        let client = try tracingContentClient(spans, router)

        if beta { await tracingDrain(try await tracingBetaCreateStream(client)) } else { await tracingDrain(try await tracingCreateStream(client)) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span[INPUT_KEY] != nil)
        #expect(span[OUTPUT_KEY] == nil)
    }

    @Test func closedStreamHasNoOutput() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))

        let stream = try await tracingCreateStream(try tracingContentClient(spans, router))
        var iterator = stream.makeAsyncIterator()
        _ = try await iterator.next()
        stream.close()

        let span = try spans.one("anthropic.messages.create")
        #expect(span[INPUT_KEY] != nil)
        #expect(span[OUTPUT_KEY] == nil)
    }

    @Test func sizeBoundRemovesTheOldestInputParts() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let big = String(repeating: "x", count: 300_000)

        try await tracingCreate(try tracingContentClient(spans, router), messages: [
            ["role": "user", "content": .string("first " + big)], ["role": "assistant", "content": .string("second " + big)],
            ["role": "user", "content": .string("third " + big)], ["role": "assistant", "content": "fourth"], ["role": "user", "content": "fifth"],
        ])

        let span = try spans.one("anthropic.messages.create")
        let messages = try #require(span.json(INPUT_KEY)?.arrayValue)
        // Removing the part of the first message brings the three large ones under the bound. The message stays.
        #expect(messages.map { $0["role"]! } == ["user", "assistant", "user", "assistant", "user"])
        #expect(messages[0]["parts"] == [])
        // The span says that content was removed, and the content itself holds no marker.
        #expect(messages[1]["parts"] == [tracingTextPart("second " + big)])
        #expect(span["anthropic.content.truncated"] == true)
        #expect(span.contentSize <= CONTENT_LIMIT)
    }

    @Test func sizeBoundCountsTheContentOfAToolResult() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let big = String(repeating: "x", count: 600_000)
        let searchResult: JSONValue = ["type": "search_result", "source": "https://example.com/cats", "title": "Cats",
                                       "content": [["type": "text", "text": .string(big)]]]

        try await tracingCreate(try tracingContentClient(spans, router), messages: [
            ["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_0", "content": [["type": "text", "text": .string(big)]]]]],
            ["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_1", "content": [searchResult]]]],
            ["role": "user", "content": "third"],
        ])

        let span = try spans.one("anthropic.messages.create")
        // The two tool results are over the bound together, so the part of the first one is removed whole.
        #expect(span.json(INPUT_KEY)?.arrayValue?.map { $0["parts"]! } == [
            [], [["type": "tool_call_response", "id": "toolu_1", "response": [searchResult]]], [["type": "text", "content": "third"]],
        ])
        #expect(span["anthropic.content.truncated"] == true)
        #expect(span.contentSize <= CONTENT_LIMIT)
    }

    @Test func sizeBoundCountsAResultThatIsOneObject() async throws {
        func result(_ id: String, _ stdout: String) -> JSONValue {
            ["type": "code_execution_tool_result", "tool_use_id": .string(id),
             "content": ["type": "code_execution_result", "stdout": .string(stdout), "stderr": "", "return_code": 0, "content": []]]
        }
        let big = String(repeating: "x", count: 600_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage),
                     .json(tracingMessage.with("content", [["type": "text", "text": "Done"], result("srvtoolu_2", big)])))
        let client = try tracingContentClient(spans, router)

        try await tracingCreate(client, extraBody: ["messages": [
            ["role": "assistant", "content": [result("srvtoolu_0", big)]], ["role": "assistant", "content": [result("srvtoolu_1", big)]],
            ["role": "user", "content": "third"],
        ]])
        try await tracingCreate(client, extraBody: ["system": .string(String(repeating: "s", count: 600_000))])

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        let (ofInput, ofOutput) = (calls[0], calls[1])
        // The two large results are over the bound together, so the part of the first one is removed whole.
        let inputs = try #require(ofInput.json(INPUT_KEY))
        #expect(inputs[0] == ["role": "assistant", "parts": []])
        #expect(inputs[1]?["parts"]?[0]?["id"] == "srvtoolu_1")
        // The output's large result counts too: the system instructions make room for it, and it stays whole.
        #expect(ofOutput[SYSTEM_KEY] == "[]")
        let output = try #require(ofOutput.json(OUTPUT_KEY)?[0])
        #expect(output["parts"]?.arrayValue?.map { $0["type"]! } == ["text", "tool_call_response"])
        #expect(output["parts"]?[1]?["response"]?["stdout"] == .string(big))
        for span in calls {
            #expect(span["anthropic.content.truncated"] == true)
            #expect(span.contentSize <= CONTENT_LIMIT)
        }
    }

    @Test func spanWithoutContentAttributesIsNeverMarkedTruncated() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let big = String(repeating: "x", count: 600_000)

        try await tracingCreate(try tracingClient(spans, router), messages: [["role": "user", "content": .string(big)],
                                                                             ["role": "assistant", "content": .string(big)]])

        let span = try spans.one("anthropic.messages.create")
        #expect(span[INPUT_KEY] == nil)
        #expect(span["anthropic.content.truncated"] == nil)
    }

    func bigStream(_ deltas: [JSONValue]) -> [JSONValue] {
        var events = tracingStreamEvents()
        events.replaceSubrange(2..<3, with: deltas)
        return events
    }

    @Test func sizeBoundCountsStreamedOutputAndRemovesTheOldestInputParts() async throws {
        let delta: JSONValue = ["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": .string(String(repeating: "y", count: 225_000))]]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(bigStream([delta, delta])))
        let big = String(repeating: "x", count: 225_000)

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: false, messages: [
            ["role": "user", "content": .string("first " + big)], ["role": "assistant", "content": .string("second " + big)],
            ["role": "user", "content": "third"],
        ])

        let span = try spans.one("anthropic.messages.create")
        // The output is whole, and the part of the oldest input message makes room for it.
        #expect(span.json(OUTPUT_KEY) == [["role": "assistant", "parts": [tracingTextPart(String(repeating: "y", count: 450_000))]]])
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("assistant", tracingTextPart("second " + big)),
                                         tracingChatMessage("user", tracingTextPart("third"))])
        #expect(span["anthropic.content.truncated"] == true)
        #expect(span.contentSize <= CONTENT_LIMIT)
    }

    @Test func oneStreamedOutputPartOverTheBoundIsCutFromItsEnd() async throws {
        let delta: JSONValue = ["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": .string(String(repeating: "y", count: 300_000))]]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(bigStream([delta, delta, delta, delta])))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: false, messages: [["role": "user", "content": "only"]])

        let span = try spans.one("anthropic.messages.create")
        // The input's part goes first, and then the end of the output's only part. The input message stays.
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        let content = try #require(span.json(OUTPUT_KEY)?[0]?["parts"]?[0]?["content"]?.stringValue)
        #expect(content.allSatisfy { $0 == "y" })
        #expect(span.contentSize == CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func sizeBoundRemovesTheFirstOutputPartsOnceNoInputPartRemains() async throws {
        let big = String(repeating: "y", count: 300_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", .array(["first ", "second ", "third "].map {
            ["type": "text", "text": .string($0 + big)]
        }))))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": "first"], ["role": "user", "content": "second"]],
                                extraBody: ["system": "be brief"])

        let span = try spans.one("anthropic.messages.create")
        // The system instructions go first, and then the parts of the input messages, all of them.
        #expect(span[SYSTEM_KEY] == "[]")
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("user")])
        // Then the output's first part goes, whole. That is enough, so the newest two are whole.
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("second " + big), tracingTextPart("third " + big))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func sizeBoundRemovesTheOutputPartsOfAStreamFromTheStart() async throws {
        var events = tracingStreamEvents()
        var blocks: [JSONValue] = []
        for (index, text) in ["first ", "second ", "third "].enumerated() {
            blocks += [
                ["type": "content_block_start", "index": .int(index), "content_block": ["type": "text", "text": ""]],
                ["type": "content_block_delta", "index": .int(index), "delta": ["type": "text_delta", "text": .string(text)]],
                ["type": "content_block_delta", "index": .int(index), "delta": ["type": "text_delta", "text": .string(String(repeating: "y", count: 600_000))]],
                ["type": "content_block_stop", "index": .int(index)],
            ]
        }
        events.replaceSubrange(1..<4, with: blocks)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))

        try await tracingHelperUntilDone(try tracingContentClient(spans, router), beta: false, messages: [["role": "user", "content": "only"]])

        let span = try spans.one("anthropic.messages.create")
        // The part of the only input message went, and then the output's first two parts. The last is whole.
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("third " + String(repeating: "y", count: 600_000)))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func oneOutputPartOverTheBoundIsCutFromItsEnd() async throws {
        let text = String(repeating: "y", count: 1_100_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [["type": "text", "text": .string(text)]])))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": "only"]])

        let span = try spans.one("anthropic.messages.create")
        // The message without parts stays in its attribute, and the last part keeps the start of its text that fits.
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        let content = try #require(span.json(OUTPUT_KEY)?[0]?["parts"]?[0]?["content"]?.stringValue)
        #expect(text.hasPrefix(content))
        #expect(span.contentSize == CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func oneInputPartOverTheBoundLeavesAMessageWithoutParts() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": .string(String(repeating: "x", count: 1_100_000))]])

        let span = try spans.one("anthropic.messages.create")
        // It was the last part until the response came, so it was cut. With the output after it, it is removed whole.
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        // That was enough, so the output is whole.
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("Hi there"))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func sizeBoundRemovesTheOutputPartsFromTheStart() {
        let part = ojText(String(repeating: "x", count: 100))
        let last = ojText(String(repeating: "y", count: 100))
        let output: OrderedJSON = [ojMessage("assistant", part, part), ojMessage("assistant", last)]
        let whole = output.json

        let (fit, fitTruncated) = fitContent([OUTPUT_KEY: output], limit: whole.utf8.count)
        #expect(fit == [OUTPUT_KEY: whole] && !fitTruncated)

        // A part goes whole, however little there is to remove, and the comma after it goes with it.
        let (values, truncated) = fitContent([OUTPUT_KEY: output], limit: whole.utf8.count - 1)
        #expect(truncated)
        #expect(values[OUTPUT_KEY] == ([ojMessage("assistant", part), ojMessage("assistant", last)] as OrderedJSON).json)
        #expect(values[OUTPUT_KEY]?.utf8.count == whole.utf8.count - part.json.utf8.count - 1)

        // The parts of every message are one list: a message that lost all of its parts stays, and the next one loses
        // parts after it.
        let (cut, cutTruncated) = fitContent([OUTPUT_KEY: output], limit: whole.utf8.count - 2 * part.json.utf8.count - 2)
        #expect(cutTruncated)
        let shell = ojMessage("assistant")
        #expect(cut[OUTPUT_KEY] == ([shell, ojMessage("assistant", ojText(String(repeating: "y", count: 99)))] as OrderedJSON).json)
        #expect(cut[OUTPUT_KEY]?.utf8.count == whole.utf8.count - 2 * part.json.utf8.count - 2)

        let (shells, shellsTruncated) = fitContent([OUTPUT_KEY: [shell, shell]], limit: -100)
        #expect(shells == [OUTPUT_KEY: ([shell, shell] as OrderedJSON).json] && !shellsTruncated)
    }

    @Test func sizeBoundKeepsTheLastTextPartWithEmptyContentWhenNoneOfItFits() {
        let text = ojText(String(repeating: "x", count: 100))
        let emptied: OrderedJSON = [ojMessage("user"), ojMessage("user", ojText(""))]
        let messages: OrderedJSON = [ojMessage("user", text), ojMessage("user", text)]

        // There is room for the part and not for any of its text, and then for neither: the part stays either way.
        for limit in [emptied.json.utf8.count, emptied.json.utf8.count - 1, -100] {
            let (values, truncated) = fitContent([INPUT_KEY: messages], limit: limit)
            #expect(values == [INPUT_KEY: emptied.json] && truncated)
        }
        // A part that has no text to lose is no reason to mark the span.
        let (values, truncated) = fitContent([INPUT_KEY: emptied], limit: -100)
        #expect(values == [INPUT_KEY: emptied.json] && !truncated)
    }

    @Test func sizeBoundCutsTextBetweenTwoCharacters() {
        // Each of these is one character of the text. In JSON they take three bytes, four, two, and six.
        let characters = ["\u{4e16}", "\u{1f600}", "\n", "\u{01}"]
        let text = String(repeating: characters.joined(), count: 5)
        let part = ojText(text)
        let whole = ([part] as OrderedJSON).json

        for limit in ([ojText("")] as OrderedJSON).json.utf8.count..<whole.utf8.count {
            let (values, truncated) = fitContent([SYSTEM_KEY: [part]], limit: limit)

            #expect(truncated)
            #expect(values[SYSTEM_KEY]!.utf8.count <= limit)
            let cut = try! JSONValue.parse(values[SYSTEM_KEY]!)[0]!["content"]!.stringValue!
            #expect(text.hasPrefix(cut))
            // The next character would not have fitted.
            let next = String(text.unicodeScalars.prefix(cut.unicodeScalars.count + 1))
            #expect(([ojText(next)] as OrderedJSON).json.utf8.count > limit)
        }
    }

    @Test func sizeBoundRemovesAPartWithoutTextWhole() {
        let text = ojText(String(repeating: "x", count: 100))
        let call = ojToolCall("toolu_1", "f", .obj(("content", .string(String(repeating: "y", count: 100)))))
        let reasoning = ojReasoning(String(repeating: "z", count: 100))
        let image: OrderedJSON = .obj(("type", "anthropic_image"))

        func fit(_ parts: [OrderedJSON], _ limit: Int) -> (String, Bool) {
            let (values, truncated) = fitContent([OUTPUT_KEY: [ojMessage("assistant", parts)]], limit: limit)
            let json = values[OUTPUT_KEY]!
            let prefix = "[{\"role\":\"assistant\",\"parts\":"
            return (String(json.dropFirst(prefix.count).dropLast(2)), truncated)
        }
        func size(_ parts: [OrderedJSON]) -> Int { ([ojMessage("assistant", parts)] as OrderedJSON).json.utf8.count }
        func json(_ parts: [OrderedJSON]) -> String { OrderedJSON.array(parts).json }

        #expect(fit([image, call, reasoning, text], size([image, call, reasoning, text])) == (json([image, call, reasoning, text]), false))
        #expect(fit([image, call, reasoning, text], size([image, call, reasoning, text]) - 1) == (json([call, reasoning, text]), true))
        // The tool call goes whole, which is more than it takes, so the parts after it stay whole.
        #expect(fit([call, reasoning, text], size([call, reasoning, text]) - 1) == (json([reasoning, text]), true))
        // The reasoning is not cut as text is: it goes whole when it is the first part, and when it is the last one left.
        #expect(fit([reasoning, text], size([reasoning, text]) - 1) == (json([text]), true))
        #expect(fit([text, reasoning], size([reasoning]) - 1) == ("[]", true))
        #expect(fit([text, call], size([call]) - 1) == ("[]", true))
        #expect(fit([text, image], size([image]) - 1) == ("[]", true))
        // Only the text of the last part left is cut.
        #expect(fit([call, text], size([text]) - 1) == (json([ojText(String(repeating: "x", count: 99))]), true))
    }

    @Test func sizeBoundRemovesTheToolCallBeforeTheTextThatItCuts() async throws {
        let text = String(repeating: "\u{1f600}", count: 1_100_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [
            ["type": "tool_use", "id": "toolu_1", "name": "f", "input": ["a": 1]], ["type": "text", "text": .string(text)],
        ])))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": "only"]])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        let parts = try #require(span.json(OUTPUT_KEY)?[0]?["parts"]?.arrayValue)
        #expect(parts.count == 1)
        #expect(text.hasPrefix(parts[0]["content"]?.stringValue ?? "?"))
        // Each character of the text is four bytes, and the cut is not inside one.
        #expect(CONTENT_LIMIT - 4 < span.contentSize && span.contentSize <= CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func rawResponseOverTheBoundIsRecordedLikeAParsedOne() async throws {
        let text = String(repeating: "y", count: 1_100_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [["type": "text", "text": .string(text)]])))

        let raw = try await tracingContentClient(spans, router).messages.withRawResponse.create(maxTokens: 1024, messages: tracingMessages([
            ["role": "user", "content": "first"], ["role": "assistant", "content": "second"], ["role": "user", "content": "third"],
        ]), model: "claude-test")

        #expect(try await raw.read().count > CONTENT_LIMIT)
        let span = try spans.one("anthropic.messages.create")
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["gen_ai.response.model"] == "claude-test")
        #expect(span["gen_ai.usage.output_tokens"] == 5)
        #expect(span["anthropic.message.stop_reason"] == "end_turn")
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("assistant"), tracingChatMessage("user")])
        let content = try #require(span.json(OUTPUT_KEY)?[0]?["parts"]?[0]?["content"]?.stringValue)
        #expect(text.hasPrefix(content))
        #expect(span.contentSize == CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func sizeBoundCountsBytesNotCharacters() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        // 225,000 characters that are 675,000 bytes of UTF-8: two such messages fit as characters, not as bytes.
        let big = String(repeating: "\u{20ac}", count: 225_000)

        try await tracingCreate(try tracingContentClient(spans, router), messages: [
            ["role": "user", "content": .string(big)], ["role": "assistant", "content": .string(big)], ["role": "user", "content": "last"],
        ])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("assistant", tracingTextPart(big)),
                                         tracingChatMessage("user", tracingTextPart("last"))])
        #expect(675_000 < span.contentSize && span.contentSize <= CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func inputMessagesUnderTheBoundAreTheJSONOfTheWholeList() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [
            ["role": "user", "content": "h\u{e9}llo \u{20ac}, [1]"],
            ["role": "assistant", "content": [["type": "text", "text": "hi"],
                                              ["type": "tool_use", "id": "toolu_1", "name": "f", "input": ["a": [1, "\u{e9}"], "b": nil]]]],
            ["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_1", "content": "done"]]],
        ])

        let expected: OrderedJSON = [
            ojMessage("user", ojText("h\u{e9}llo \u{20ac}, [1]")),
            ojMessage("assistant", ojText("hi"), ojToolCall("toolu_1", "f", .obj(("a", [1, "\u{e9}"]), ("b", nil)))),
            ojMessage("user", .obj(("type", "tool_call_response"), ("id", "toolu_1"), ("response", [.obj(("type", "text"), ("text", "done"))]))),
        ]
        let span = try spans.one("anthropic.messages.create")
        #expect(span[INPUT_KEY] == .string(expected.json))
        #expect(span["anthropic.content.truncated"] == nil)
        let (values, truncated) = fitContent([INPUT_KEY: expected], limit: CONTENT_LIMIT)
        #expect(values == [INPUT_KEY: expected.json] && !truncated)
    }

    @Test func sizeBoundRemovesInputPartsNotWholeMessages() {
        let part = ojText(String(repeating: "x", count: 100))
        let message = ojMessage("user", part, part)
        let messages: OrderedJSON = [message, message, message]
        let whole = messages.json
        // One part less, and the comma after it: nothing is set aside for a marker.
        let limit = whole.utf8.count - part.json.utf8.count - 1

        for room in [whole.utf8.count - 1, limit] {
            let (values, truncated) = fitContent([INPUT_KEY: messages], limit: room)
            #expect(truncated)
            #expect(values[INPUT_KEY] == ([ojMessage("user", part), message, message] as OrderedJSON).json)
            #expect(values[INPUT_KEY]?.utf8.count == limit)
        }

        let (values, truncated) = fitContent([INPUT_KEY: messages], limit: limit - 1)
        #expect(truncated)
        #expect(values[INPUT_KEY] == ([ojMessage("user"), message, message] as OrderedJSON).json)
    }

    @Test func sizeBoundCutsTheNewestInputPartWhenNoOtherIsLeft() {
        let messages: OrderedJSON = [ojMessage("user", ojText("old")), ojMessage("user", ojText(String(repeating: "x", count: 1000)))]
        let kept: OrderedJSON = [ojMessage("user"), ojMessage("user", ojText(String(repeating: "x", count: 30)))]

        let (values, truncated) = fitContent([INPUT_KEY: messages], limit: kept.json.utf8.count)
        #expect(values == [INPUT_KEY: kept.json] && truncated)
        // The older part goes although the newer one is cut all the same.
        let (more, moreTruncated) = fitContent([INPUT_KEY: messages], limit: kept.json.utf8.count + "{\"type\":\"text\",\"content\":\"old\"}".utf8.count)
        #expect(more == [INPUT_KEY: ([ojMessage("user"), ojMessage("user", ojText(String(repeating: "x", count: 61)))] as OrderedJSON).json])
        #expect(moreTruncated)
    }

    /// `test_size_bound_gives_what_removing_one_part_or_character_at_a_time_gives`, with a seeded generator of its own.
    @Test func sizeBoundGivesWhatRemovingOnePartOrCharacterAtATimeGives() {
        struct Generator {
            var state: UInt64
            mutating func next(_ bound: Int) -> Int {
                state = state &* 6364136223846793005 &+ 1442695040888963407
                return bound <= 0 ? 0 : Int((state >> 33) % UInt64(bound))
            }
        }
        /// A part: its type, and its content when it has one.
        typealias Part = (type: String, content: [Unicode.Scalar]?)
        func json(_ part: Part) -> OrderedJSON {
            guard let content = part.content else { return .obj(("type", .string(part.type))) }
            var s = ""
            s.unicodeScalars.append(contentsOf: content)
            return .obj(("type", .string(part.type)), ("content", .string(s)))
        }
        func values(_ system: [Part]?, _ input: [[Part]], _ output: [[Part]]?) -> [String: OrderedJSON?] {
            [SYSTEM_KEY: system.map { .array($0.map(json)) },
             INPUT_KEY: .array(input.map { .obj(("role", "user"), ("parts", .array($0.map(json)))) }),
             OUTPUT_KEY: output.map { .array($0.map { .obj(("role", "assistant"), ("parts", .array($0.map(json)))) }) }]
        }
        func size(_ v: [String: OrderedJSON?]) -> Int { v.values.compactMap { $0 }.reduce(0) { $0 + $1.json.utf8.count } }

        func oneAtATime(_ system: [Part]?, _ input: [[Part]], _ output: [[Part]]?, _ limit: Int) -> ([String: String], Bool) {
            var lists: [[Part]] = (system.map { [$0] } ?? []) + input + (output ?? [])
            func current() -> [String: OrderedJSON?] {
                var i = 0
                let s = system.map { _ -> [Part] in defer { i += 1 }; return lists[0] }
                let inputs = input.indices.map { _ -> [Part] in defer { i += 1 }; return lists[i] }
                let outputs = output.map { o in o.indices.map { _ -> [Part] in defer { i += 1 }; return lists[i] } }
                return values(s, inputs, outputs)
            }
            var truncated = false
            while size(current()) > limit && lists.reduce(0, { $0 + $1.count }) > 1 {
                let i = lists.firstIndex { !$0.isEmpty }!
                lists[i].removeFirst()
                truncated = true
            }
            for i in lists.indices {
                if size(current()) > limit, let first = lists[i].first, first.type != "text" {
                    lists[i].removeFirst()
                    truncated = true
                }
                while size(current()) > limit, let first = lists[i].first, let content = first.content, !content.isEmpty {
                    lists[i][0].content = Array(content.dropLast())
                    truncated = true
                }
            }
            var out: [String: String] = [:]
            for (k, v) in current() { if let v { out[k] = v.json } }
            return (out, truncated)
        }

        var random = Generator(state: 613)
        for _ in 0..<500 {
            let kinds = ["text", "text", "text", "reasoning", "anthropic_image"]
            let parts: [Part] = (0..<random.next(6)).map { _ in
                let kind = kinds[random.next(kinds.count)]
                if kind == "anthropic_image" { return (kind, nil) }
                return (kind, Array(String(repeating: "\u{e9}\n", count: 1 + random.next(19)).unicodeScalars))
            }
            func someOf() -> [Part] { Array(parts[random.next(parts.count + 1)...]) }
            let system: [Part]? = random.next(2) == 0 ? nil : someOf()
            let input: [[Part]] = (0..<random.next(4)).map { _ in someOf() }
            let output: [[Part]]? = random.next(2) == 0 ? nil : (0..<(1 + random.next(2))).map { _ in someOf() }
            let attributes = values(system, input, output)
            let limit = random.next(size(attributes) + 10) - 5

            let (fit, fitTruncated) = fitContent(attributes, limit: limit)
            let (expected, expectedTruncated) = oneAtATime(system, input, output, limit)
            #expect(fit == expected)
            #expect(fitTruncated == expectedTruncated)
        }
    }

    /// `SIZE_BOUND_CASES`: the limit, the content, what is kept of it, whether it was truncated, and the sizes before and after.
    static let sizeBoundCases: [(Int, [String: OrderedJSON], [String: OrderedJSON?], Bool, (Int, Int))] = [
        (1000, [SYSTEM_KEY: [ojText("Be brief.")], INPUT_KEY: [ojMessage("user", ojText("hi"))], OUTPUT_KEY: [ojMessage("assistant", ojText("hello"))]],
         [SYSTEM_KEY: [ojText("Be brief.")], INPUT_KEY: [ojMessage("user", ojText("hi"))], OUTPUT_KEY: [ojMessage("assistant", ojText("hello"))]],
         false, (163, 163)),
        (163, [SYSTEM_KEY: [ojText("Be brief.")], INPUT_KEY: [ojMessage("user", ojText("hi"))], OUTPUT_KEY: [ojMessage("assistant", ojText("hello"))]],
         [SYSTEM_KEY: [ojText("Be brief.")], INPUT_KEY: [ojMessage("user", ojText("hi"))], OUTPUT_KEY: [ojMessage("assistant", ojText("hello"))]],
         false, (163, 163)),
        (260, [SYSTEM_KEY: [ojText("S1-" + String(repeating: "s", count: 60)), ojText("S2 stays")], INPUT_KEY: [ojMessage("user", ojText("question"))],
               OUTPUT_KEY: [ojMessage("assistant", ojText("answer"))]],
         [SYSTEM_KEY: [ojText("S2 stays")], INPUT_KEY: [ojMessage("user", ojText("question"))], OUTPUT_KEY: [ojMessage("assistant", ojText("answer"))]],
         true, (261, 169)),
        (222, [SYSTEM_KEY: [ojText("sys-" + String(repeating: "s", count: 30))],
               INPUT_KEY: [ojMessage("user", ojText("old-" + String(repeating: "o", count: 40)), .obj(("type", "anthropic_image"))),
                           ojMessage("assistant", ojText("mid")), ojMessage("user", ojText("last"))],
               OUTPUT_KEY: [ojMessage("assistant", ojText("answer"))]],
         [SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user"), ojMessage("assistant", ojText("mid")), ojMessage("user", ojText("last"))],
          OUTPUT_KEY: [ojMessage("assistant", ojText("answer"))]],
         true, (380, 219)),
        (180, [INPUT_KEY: [ojMessage("user", ojText("a-" + String(repeating: "a", count: 30)), ojText("b-" + String(repeating: "b", count: 30)),
                                     ojText("c stays")), ojMessage("user", ojText("newest"))]],
         [INPUT_KEY: [ojMessage("user", ojText("c stays")), ojMessage("user", ojText("newest"))]],
         true, (246, 124)),
        (183, [SYSTEM_KEY: [ojText("sys")], INPUT_KEY: [ojMessage("user", ojText("question " + String(repeating: "q", count: 20)))],
               OUTPUT_KEY: [ojMessage("assistant", ojReasoning("think-" + String(repeating: "t", count: 50)), ojText("final answer"))]],
         [SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant", ojText("final answer"))]],
         true, (281, 103)),
        (126, [SYSTEM_KEY: [ojText("sys")], INPUT_KEY: [ojMessage("user", ojText("question"))],
               OUTPUT_KEY: [ojMessage("assistant", ojToolCall("toolu_1", "get_weather", .obj(("city", "Paris"))),
                                      ojText("012345678901234567890123456789012345678901234567890123456789"))]],
         [SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant", ojText("01234567890123456789012345678901234"))]],
         true, (304, 126)),
        (133, [INPUT_KEY: [ojMessage("user", ojText(String(repeating: "say \"hi\"\n", count: 8)))]],
         [INPUT_KEY: [ojMessage("user", ojText(String(repeating: "say \"hi\"\n", count: 6) + "say "))]],
         true, (152, 132)),
        (117, [OUTPUT_KEY: [ojMessage("assistant", ojText(String(repeating: "a\u{20ac}\u{1f600}\u{e9}", count: 6)))]],
         [OUTPUT_KEY: [ojMessage("assistant", ojText(String(repeating: "a\u{20ac}\u{1f600}\u{e9}", count: 5) + "a\u{20ac}"))]],
         true, (121, 115)),
        (120, [SYSTEM_KEY: [ojText("sys")], INPUT_KEY: [ojMessage("user", ojText("question"))],
               OUTPUT_KEY: [ojMessage("assistant", ojToolCall("toolu_1", "write_file", .obj(("path", "a.txt"), ("text", .string(String(repeating: "w", count: 80))))))]],
         [SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant")]],
         true, (304, 63)),
        (110, [INPUT_KEY: [ojMessage("user", ojText("q"))], OUTPUT_KEY: [ojMessage("assistant", ojReasoning(String(repeating: "r", count: 100)))]],
         [INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant")]],
         true, (223, 61)),
        (100, [STOPS_KEY: [.string("STOP-" + String(repeating: "x", count: 100))], SYSTEM_KEY: [ojText("sys")], INPUT_KEY: [ojMessage("user", ojText("question"))],
               OUTPUT_KEY: [ojMessage("assistant", ojToolCall("toolu_1", "f", .obj()))]],
         [STOPS_KEY: nil, SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant")]],
         true, (296, 63)),
        (100, [STOPS_KEY: [.string("STOP-" + String(repeating: "x", count: 100))], INPUT_KEY: [ojMessage("user")]],
         [STOPS_KEY: nil, INPUT_KEY: [ojMessage("user")]],
         true, (133, 28)),
        (10, [SYSTEM_KEY: [ojText("sys")], INPUT_KEY: [ojMessage("user", ojText("question"))],
              OUTPUT_KEY: [ojMessage("assistant", ojToolCall("toolu_1", "f", .obj()))]],
         [SYSTEM_KEY: [], INPUT_KEY: [ojMessage("user")], OUTPUT_KEY: [ojMessage("assistant")]],
         true, (191, 63)),
        (100, [INPUT_KEY: [ojMessage("user", ojText(String(repeating: "\u{e9}", count: 30)))]],
         [INPUT_KEY: [ojMessage("user", ojText(String(repeating: "\u{e9}", count: 22)))]],
         true, (116, 100)),
        (100, [INPUT_KEY: [ojMessage("user", ojText("cost 5\u{20ac} \u{1f600} cost 5\u{20ac} \u{1f600} total: 10\u{20ac}\u{1f600} thanks, see you again next week! Bye for now."))]],
         [INPUT_KEY: [ojMessage("user", ojText("cost 5\u{20ac} \u{1f600} cost 5\u{20ac} \u{1f600} total: 10\u{20ac}"))]],
         true, (148, 98)),
    ]

    @Test(arguments: 0..<16)
    func sizeBoundCases(index: Int) throws {
        let (limit, content, expected, truncated, sizes) = Self.sizeBoundCases[index]
        let stops = (content[STOPS_KEY]?.arrayValue ?? []).compactMap(\.stringValue)
        let given: [String: OrderedJSON?] = [SYSTEM_KEY: content[SYSTEM_KEY], INPUT_KEY: content[INPUT_KEY], OUTPUT_KEY: content[OUTPUT_KEY]]
        let sizeBefore = stops.reduce(0) { $0 + $1.utf8.count } + given.values.compactMap { $0 }.reduce(0) { $0 + $1.json.utf8.count }
        let span = try TracingSpans().provider.tracer("test", version: nil).startSpan("anthropic.messages.create") as! RecordingSpan

        #expect(sizeBefore == sizes.0)

        setContentAttributes(span, given, limit: limit, stopSequences: stops)

        // An attribute that the span does not have is not created. One that it has stays, except for stop sequences
        // that exceed the bound by themselves: `nil` for them in `expected` says that the span has none.
        let attributes = span.attributes
        let expectedStops = (expected[STOPS_KEY] ?? nil)?.arrayValue?.compactMap(\.stringValue)
        #expect(attributes[STOPS_KEY]?.stringArrayValue == expectedStops)
        var values: [String: String] = [:]
        for key in [SYSTEM_KEY, INPUT_KEY, OUTPUT_KEY] { if let v = attributes[key]?.stringValue { values[key] = v } }
        var expectedValues: [String: String] = [:]
        for (k, v) in expected where k != STOPS_KEY { if let v { expectedValues[k] = v.json } }
        #expect(values == expectedValues)
        #expect((attributes["anthropic.content.truncated"]?.boolValue ?? false) == truncated)
        #expect((attributes[STOPS_KEY]?.stringArrayValue ?? []).reduce(0) { $0 + $1.utf8.count } + values.values.reduce(0) { $0 + $1.utf8.count }
            == sizes.1)
    }

    @Test func systemInstructionsAreRemovedFirst() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let inputs: [JSONValue] = [["role": "user", "content": "first"], ["role": "assistant", "content": "second"], ["role": "user", "content": "third"]]

        try await tracingCreate(try tracingContentClient(spans, router), messages: inputs,
                                extraBody: ["system": .string(String(repeating: "s", count: 1_100_000))])

        let span = try spans.one("anthropic.messages.create")
        // The system instructions go first, whole. The emptied list stays, and so does everything after it.
        #expect(span[SYSTEM_KEY] == "[]")
        #expect(span.json(INPUT_KEY) == .array(inputs.map { tracingChatMessage($0["role"]!.stringValue!, tracingTextPart($0["content"]!.stringValue!)) }))
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("Hi there"))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func systemInstructionsGoBeforeTheInputAndTheOutput() async throws {
        let text = String(repeating: "y", count: 600_000)
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [["type": "text", "text": .string(text)]])))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": "only"]], extraBody: [
            "system": [["type": "text", "text": "first"], ["type": "text", "text": .string(String(repeating: "s", count: 600_000))]],
        ])

        let span = try spans.one("anthropic.messages.create")
        #expect(span[SYSTEM_KEY] == "[]")
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user", tracingTextPart("only"))])
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart(text))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func systemInstructionsLosePartsFromTheirStart() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": "only"]], extraBody: [
            "system": .array(["a", "b", "c"].map { ["type": "text", "text": .string(String(repeating: $0, count: 600_000))] }),
        ])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(SYSTEM_KEY) == [tracingTextPart(String(repeating: "c", count: 600_000))])
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user", tracingTextPart("only"))])
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("Hi there"))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test func noInputMessagesAreAnEmptyListEvenWhenTheOtherContentAttributesExceedTheLimit() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))

        try await tracingCreate(try tracingContentClient(spans, router), messages: [],
                                extraBody: ["system": .string(String(repeating: "s", count: 1_100_000))])

        let span = try spans.one("anthropic.messages.create")
        #expect(span[INPUT_KEY] == "[]")
        // There was no input part to remove, and the system instructions went before the output's part.
        #expect(span[SYSTEM_KEY] == "[]")
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("Hi there"))])
        #expect(span["anthropic.content.truncated"] == true)
        let (values, truncated) = fitContent([INPUT_KEY: []], limit: -100)
        #expect(values == [INPUT_KEY: "[]"] && !truncated)
    }

    @Test(arguments: [false, true])
    func stopSequences(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .sse(tracingStreamEvents()))
        let client = try tracingContentClient(spans, router)
        let stops = ["END", "\n\nHuman:"]

        if beta {
            _ = try await client.beta.messages.create(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test", stopSequences: stops)
            await tracingDrain(try await client.beta.messages.createStreaming(maxTokens: 1024, messages: tracingBetaMessages(tracingHello),
                                                                              model: "claude-test", stopSequences: stops))
        } else {
            _ = try await client.messages.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test", stopSequences: stops)
            await tracingDrain(try await client.messages.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test",
                                                                         stopSequences: stops))
        }
        try await tracingHelperUntilDone(client, beta: beta, stopSequences: stops)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 3)
        for span in calls {
            // An array with one element for each stop sequence, not a JSON string.
            #expect(span[STOPS_KEY] == .stringArray(stops))
            #expect(span["anthropic.content.truncated"] == nil)
        }
    }

    @Test func stopSequencesAreContent() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await tracingCreate(try tracingClient(spans, router), extraBody: ["stop_sequences": ["END"]])
        #expect(try spans.one("anthropic.messages.create")[STOPS_KEY] == nil)
    }

    @Test func noStopSequencesSetNoAttribute() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingContentClient(spans, router)

        try await tracingCreate(client)
        try await tracingCreate(client, extraBody: ["stop_sequences": []])

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls[0][INPUT_KEY] != nil)
        #expect(calls[0][STOPS_KEY] == nil)
        #expect(calls[1][STOPS_KEY] == nil)
    }

    @Test func sizeBoundCountsTheStopSequencesThatStay() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let big = String(repeating: "x", count: 300_000)

        try await tracingCreate(try tracingContentClient(spans, router), messages: [["role": "user", "content": .string("first " + big)],
                                                                                    ["role": "user", "content": "second"]],
                                extraBody: ["stop_sequences": [.string("a" + big), .string("b" + big)]])

        let span = try spans.one("anthropic.messages.create")
        // The messages alone are under the limit: the part of the first goes because the stop sequences count too.
        #expect(span[STOPS_KEY] == .stringArray(["a" + big, "b" + big]))
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("user", tracingTextPart("second"))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test(arguments: [false, true], [false, true])
    func stopSequencesAtOrOverTheBound(beta: Bool, over: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .sse(tracingStreamEvents()))
        let client = try tracingContentClient(spans, router)
        let stops = [String(repeating: "a", count: over ? 50_001 : 50_000), String(repeating: "b", count: 700_000)]
        #expect(stops.reduce(0) { $0 + $1.count } == CONTENT_LIMIT + (over ? 1 : 0))

        if beta {
            _ = try await client.beta.messages.create(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test", stopSequences: stops)
        } else {
            _ = try await client.messages.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test", stopSequences: stops)
        }
        try await tracingHelperUntilDone(client, beta: beta, stopSequences: stops)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            if over {
                // The stop sequences go whole and no longer count, so everything else has the whole limit and stays.
                #expect(span[STOPS_KEY] == nil)
                #expect(span.json(INPUT_KEY) == [tracingChatMessage("user", tracingTextPart("Hello"))])
                #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart("Hi there"))])
            } else {
                // They leave no room, so everything that can go does. The last part left is text: it stays, without its text.
                #expect(span[STOPS_KEY] == .stringArray(stops))
                #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
                #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart(""))])
            }
            #expect(span["anthropic.content.truncated"] == true)
        }
    }

    @Test(arguments: [false, true])
    func stopSequencesAloneOverASmallBoundAreRemovedWhole(over: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .sse(tracingStreamEvents()))
        let client = try tracingContentClient(spans, router, maxContentBytes: 100)
        let stops = [String(repeating: "a", count: 40), String(repeating: "b", count: over ? 61 : 60)]

        _ = try await client.messages.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test", stopSequences: stops)
        try await tracingHelperUntilDone(client, beta: false, stopSequences: stops)

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span[STOPS_KEY] == (over ? nil : .stringArray(stops)))
            // Without the stop sequences there is room for the output, and not for the input before it.
            #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
            #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart(over ? "Hi there" : ""))])
            #expect(span["anthropic.content.truncated"] == true)
        }
    }

    @Test(arguments: [false, true])
    func stopSequencesAreMeasuredInBytes(over: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        // Each `é` is one character and two bytes, so these are 80 or 81 characters, and 100 or 101 bytes.
        let stops = [String(repeating: "\u{e9}", count: 20), String(repeating: "b", count: over ? 61 : 60)]
        #expect(stops.reduce(0) { $0 + $1.utf8.count } == (over ? 101 : 100))

        _ = try await tracingContentClient(spans, router, maxContentBytes: 100).messages.create(
            maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test", stopSequences: stops)

        let span = try spans.one("anthropic.messages.create")
        #expect(span[STOPS_KEY] == (over ? nil : .stringArray(stops)))
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user")])
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart(over ? "Hi there" : ""))])
        #expect(span["anthropic.content.truncated"] == true)
    }

    @Test(arguments: [(142, true, 10, 142), (141, false, 10, 109), (101, false, 6, 101), (100, false, 5, 99)])
    func partsAndTheCutOfTheLastTextPartAreMeasuredInBytes(limit: Int, inputPart: Bool, outputCharacters: Int, size: Int) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [["type": "text", "text": .string(String(repeating: "\u{e9}", count: 10))]])))

        try await tracingCreate(try tracingContentClient(spans, router, maxContentBytes: limit))

        let span = try spans.one("anthropic.messages.create")
        #expect(span.json(INPUT_KEY) == (inputPart ? [tracingChatMessage("user", tracingTextPart("Hello"))] : [tracingChatMessage("user")]))
        #expect(span.json(OUTPUT_KEY) == [tracingChatMessage("assistant", tracingTextPart(String(repeating: "\u{e9}", count: outputCharacters)))])
        #expect(span.contentSize == size && size <= limit)
        #expect((span["anthropic.content.truncated"]?.boolValue ?? false) == (limit < 142))
    }

    @Test func stopSequencesOverTheBoundAreRemovedBeforeTheParts() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let big = String(repeating: "x", count: 300_000)

        try await tracingCreate(try tracingContentClient(spans, router), messages: ["first ", "second ", "third "].map {
            ["role": "user", "content": .string($0 + big)]
        }, extraBody: ["stop_sequences": .array(["a", "b", "c"].map { .string($0 + big) })])

        let span = try spans.one("anthropic.messages.create")
        // Without the stop sequences the messages are still over the limit, so the oldest part goes as it did before.
        #expect(span[STOPS_KEY] == nil)
        #expect(span.json(INPUT_KEY) == [tracingChatMessage("user"), tracingChatMessage("user", tracingTextPart("second " + big)),
                                         tracingChatMessage("user", tracingTextPart("third " + big))])
        #expect(span.contentSize <= CONTENT_LIMIT)
        #expect(span["anthropic.content.truncated"] == true)
    }
}
