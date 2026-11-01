// Shared helpers of the port of tests/lib/tools/test_open_telemetry.py (`ToolSpan...`): the replies of a weather
// tool loop, the tools, and the runners that the upstream `run` / `async_run` make.

import Foundation
import Testing
@testable import Anthropic

let toolSpanUsage: JSONValue = ["input_tokens": 3, "output_tokens": 4]

/// `FINAL`.
let toolSpanFinal: JSONValue = [
    "id": "msg_final", "type": "message", "role": "assistant", "model": "claude-test",
    "content": [["type": "text", "text": "It is sunny."]], "stop_reason": "end_turn", "stop_sequence": nil, "usage": toolSpanUsage,
]

/// `COMPACTION`.
let toolSpanCompaction: JSONValue = [
    "id": "msg_compaction", "type": "message", "role": "assistant", "model": "claude-test",
    "content": [["type": "compaction", "content": "Summary of the conversation so far."]], "stop_reason": "compaction",
    "stop_sequence": nil, "usage": toolSpanUsage,
]

/// `CONTENT_ATTRIBUTES`.
let toolSpanContentAttributes = ("gen_ai.tool.call.arguments", "anthropic.tool_result.content")

/// `tool_use_message`.
func toolSpanToolUseMessage(_ city: String = "SF") -> JSONValue {
    [
        "id": .string("msg_\(city)"), "type": "message", "role": "assistant", "model": "claude-test",
        "content": [["type": "tool_use", "id": .string("toolu_\(city)"), "name": "get_weather", "input": ["city": .string(city)]]],
        "stop_reason": "tool_use", "stop_sequence": nil, "usage": toolSpanUsage,
    ]
}

/// `member_calls`: a reply with one `tool_use` for each call (its id, its name and its `toolset_name`, if any).
func toolSpanMemberCalls(_ calls: (String, String, String?)...) -> JSONValue {
    var reply = toolSpanToolUseMessage()
    reply["content"] = .array(calls.enumerated().map { step, call in
        var block: JSONValue = ["type": "tool_use", "id": .string(call.0), "name": .string(call.1), "input": ["step": .int(step)]]
        if let toolset = call.2 { block["toolset_name"] = .string(toolset) }
        return block
    })
    return reply
}

/// `sse`: `message` as the events of a streamed response.
func toolSpanSSEEvents(_ message: JSONValue) -> [JSONValue] {
    var start = message
    start["content"] = []
    start["stop_reason"] = nil
    var events: [JSONValue] = [["type": "message_start", "message": start]]
    for (index, block) in (message["content"]?.arrayValue ?? []).enumerated() {
        let empty: JSONValue
        let delta: JSONValue
        switch block["type"]?.stringValue {
        case "tool_use":
            empty = block.with("input", [:])
            delta = ["type": "input_json_delta", "partial_json": .string(pythonJSONDumps(block["input"] ?? [:]))]
        case "compaction":
            empty = ["type": "compaction", "content": nil]
            delta = ["type": "compaction_delta", "content": block["content"] ?? nil]
        default:
            empty = ["type": "text", "text": ""]
            delta = ["type": "text_delta", "text": block["text"] ?? ""]
        }
        events += [
            ["type": "content_block_start", "index": .int(index), "content_block": empty],
            ["type": "content_block_delta", "index": .int(index), "delta": delta],
            ["type": "content_block_stop", "index": .int(index)],
        ]
    }
    events += [
        ["type": "message_delta", "delta": ["stop_reason": message["stop_reason"] ?? nil], "usage": toolSpanUsage],
        ["type": "message_stop"],
    ]
    return events
}

func toolSpanReply(_ message: JSONValue, stream: Bool) -> TracingReply {
    stream ? .sse(toolSpanSSEEvents(message)) : .json(message)
}

/// The route of `/v1/messages`, which answers with `messages` in order.
@discardableResult
func toolSpanMessages(_ router: TracingRouter, _ messages: [JSONValue], stream: Bool = false) -> TracingRoute {
    router.route("POST", "/v1/messages", replies: messages.map { toolSpanReply($0, stream: stream) })
}

struct ToolSpanValueError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) { self.message = message }
    var description: String { message }
}

struct ToolSpanCity: Decodable, Sendable { var city: String }

let toolSpanCitySchema: [String: JSONValue] = [
    "type": "object", "properties": ["city": ["type": "string", "description": "The city."]], "required": ["city"],
]

/// `get_weather`.
func toolSpanGetWeather(_ city: String) throws -> String {
    if city == "Atlantis" { throw ToolSpanValueError("no such city") }
    return #"{"city": "\#(city)", "weather": "sunny"}"#
}

/// `beta_tool(get_weather)`: the description is the first line of upstream's docstring. `body` replaces the function.
func toolSpanWeatherTool(name: String = "get_weather", description: String = "The weather in a city.",
                         _ body: (@Sendable (String) async throws -> BetaFunctionToolResult?)? = nil) -> BetaFunctionTool
{
    BetaFunctionTool(name: name, description: description, inputSchema: toolSpanCitySchema) { (input: ToolSpanCity) in
        if let body { return try await body(input.city) }
        return .string(try toolSpanGetWeather(input.city))
    }
}

let toolSpanQuestion: BetaMessageParam = .user(BetaUserMessageParam(content: .string("What is the weather in SF?")))

/// A copy of `client` whose option has `conversationID` (`run(client, conversation_id=...)`).
func toolSpanWithConversation(_ client: Anthropic, _ conversationID: String?) throws -> Anthropic {
    guard let conversationID else { return client }
    var option = client.openTelemetry
    option.conversationID = conversationID
    return try client.withOptions(openTelemetry: option)
}

/// `run(client)` / `async_run(client)`.
func toolSpanRun(_ client: Anthropic, conversationID: String? = nil, tools: [any BetaToolLike]? = nil,
                 outputConfig: BetaOutputConfigParam? = nil) throws -> BetaToolRunner
{
    try toolSpanWithConversation(client, conversationID).beta.messages.toolRunner(
        maxTokens: 1024, messages: [toolSpanQuestion], model: "claude-test", tools: tools ?? [toolSpanWeatherTool()],
        outputConfig: outputConfig)
}

/// `run(client, stream=True, run_tools_eagerly=...)`.
func toolSpanStreamingRun(_ client: Anthropic, eager: Bool = false, tools: [any BetaToolLike]? = nil,
                          messages: [BetaMessageParam] = [toolSpanQuestion]) throws -> BetaStreamingToolRunner<Never>
{
    try client.beta.messages.streamingToolRunner(
        maxTokens: 1024, messages: messages, model: "claude-test", tools: tools ?? [toolSpanWeatherTool()], runToolsEagerly: eager)
}

/// `RUNNER_MODES`.
enum ToolSpanMode: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case whole, streamed, eager
    var stream: Bool { self != .whole }
    var testDescription: String { rawValue }
}

/// `tool_spans`.
func toolSpanToolSpans(_ spans: TracingSpans) -> [SpanData] { spans.finished.filter { $0["gen_ai.operation.name"] == "execute_tool" } }

/// `run_with_a_browser_toolset`: runs the loop of a tool runner that has `toolset` on `reply` and then `FINAL`, and
/// returns the route. A streamed reply is read to its end, and `atTheEndOfEachReply` is called on its `message_stop`.
@discardableResult
func toolSpanRunWithABrowserToolset(_ router: TracingRouter, _ reply: JSONValue, client: Anthropic, mode: ToolSpanMode,
                                    toolset: BetaRunnableToolset = ToolsetEchoBrowser(),
                                    atTheEndOfEachReply: @escaping @Sendable () -> Void = {}) async throws -> TracingRoute
{
    let route = toolSpanMessages(router, [reply, toolSpanFinal], stream: mode.stream)
    let messages: [BetaMessageParam] = [.user(BetaUserMessageParam(content: .string("Open the page.")))]
    if mode.stream {
        let runner = try toolSpanStreamingRun(client, eager: mode == .eager, tools: [toolset], messages: messages)
        for try await stream in runner {
            for try await event in stream {
                if case .messageStop = event { atTheEndOfEachReply() }
            }
        }
    } else {
        let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: messages, model: "claude-test", tools: [toolset])
        for try await _ in runner {}
    }
    return route
}

/// The content of the last message that `route` was sent.
func toolSpanSent(_ route: TracingRoute) -> [JSONValue] {
    route.requests.last?.jsonBody?["messages"]?.arrayValue?.last?["content"]?.arrayValue ?? []
}

func toolSpanParent(_ span: SpanData) -> SpanID? { span.parent?.spanID }
