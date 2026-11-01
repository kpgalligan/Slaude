// The fixtures of tests/lib/tools/test_runner_eager_tools.py, shared with the eager toolset tests.
//
// Most tests assert a timeline: what the caller saw, in order, and where each tool started.
//
//     "a: content_block_stop"   the caller got this stream event
//     "lookup(a) STARTS"        the runner called the tool
//     "loop body ends"          the caller finished its `for stream in runner` body
//
// Every reply is made of `streamingRunnerCall("a")`, which is the model calling `lookup(key="a")` with the id
// `toolu_a`, and `streamingRunnerText("...")`.

import Foundation
import Testing
@testable import Anthropic

/// A canned reply (`Reply`), optionally sent one event at a time as a server still generating would
/// (`EventByEvent`), whose events then go on the timeline as they are sent.
struct StreamingRunnerReply: Sendable {
    var blocks: [JSONValue]
    var stopReason: String
    var eventByEvent = false
    var failsBefore: String?
}

/// The model calls `lookup(key=key)` with the id `toolu_<key>`. `jsonInput` is the input as sent, which may be cut
/// off.
func streamingRunnerCall(_ key: String, _ jsonInput: String? = nil) -> JSONValue {
    ["type": "tool_use", "key": .string(key), "json": .string(jsonInput ?? #"{"key": "\#(key)"}"#)]
}

/// The model calls the tool `name` of a toolset with the id `toolu_<key>`: by default the computer toolset's `key`
/// tool. Without a `toolsetName` it is a call named like a toolset, which the runner can't route.
func streamingRunnerToolsetCall(_ key: String, _ name: String = "key", _ input: JSONValue? = nil,
                                _ toolsetName: String? = "computer") -> JSONValue
{
    var block: [String: JSONValue] = [
        "type": "tool_use", "key": .string(key), "name": .string(name),
        "json": .string(String(decoding: try! JSONValue.serialize(input ?? ["text": .string(key)]), as: UTF8.self)),
    ]
    if let toolsetName { block["toolset_name"] = .string(toolsetName) }
    return .object(block)
}

func streamingRunnerText(_ value: String) -> JSONValue { ["type": "text", "text": .string(value)] }

/// The block a refusal starts when it hands the reply to a fallback model.
func streamingRunnerFallback() -> JSONValue {
    [
        "type": "fallback", "from": ["model": "claude-haiku-4-5"], "to": ["model": "claude-opus-4-8"],
        "trigger": ["type": "refusal", "category": nil],
    ]
}

/// The block that a compaction request is answered with.
func streamingRunnerCompaction() -> JSONValue {
    ["type": "compaction", "content": "Summary so far.", "signature": "sig_01"]
}

/// A reply that asks for tool results.
func streamingRunnerToolReply(_ blocks: JSONValue...) -> StreamingRunnerReply {
    StreamingRunnerReply(blocks: blocks, stopReason: "tool_use")
}

/// A reply that ends for another reason.
func streamingRunnerReplyEnding(_ stopReason: String, _ blocks: JSONValue...) -> StreamingRunnerReply {
    StreamingRunnerReply(blocks: blocks, stopReason: stopReason)
}

/// The reply that ends the conversation.
func streamingRunnerDone() -> StreamingRunnerReply { streamingRunnerReplyEnding("end_turn", streamingRunnerText("Done.")) }

func streamingRunnerEventByEvent(_ reply: StreamingRunnerReply, failsBefore: String? = nil) -> StreamingRunnerReply {
    var r = reply
    r.eventByEvent = true
    r.failsBefore = failsBefore
    return r
}

func streamingRunnerNotFound(_ toolUseID: String) -> JSONValue {
    ["type": "tool_result", "tool_use_id": .string(toolUseID), "content": "Error: Tool 'lookup' not found", "is_error": true]
}

func streamingRunnerIDs(_ toolUses: [BetaToolUseBlock]) -> [String] { toolUses.map(\.id) }

/// The timeline up to the second request, which is everything about the first reply.
func streamingRunnerFirstReply(_ timeline: [String]) -> [String] {
    guard let end = timeline.firstIndex(of: "request 2") else { return timeline }
    return Array(timeline[..<end])
}

/// The timeline between two requests.
func streamingRunnerBetween(_ timeline: [String], _ start: String, _ end: String) -> [String] {
    guard let s = timeline.firstIndex(of: start), let e = timeline.firstIndex(of: end) else { return [] }
    return Array(timeline[s..<e])
}

func streamingRunnerToolResults(_ message: JSONValue?) -> [JSONValue] {
    guard let message, message["role"] == "user", case .array(let content)? = message["content"] else { return [] }
    return content.filter { $0["type"] == "tool_result" }
}

/// Names a stream event, given as JSON, after the block it belongs to, such as `a: content_block_stop`.
func streamingRunnerLabel(_ event: JSONValue, _ blocks: inout [Int: String]) -> String {
    let type = event["type"]?.stringValue ?? ""
    if type == "content_block_start", let index = event["index"]?.intValue, let block = event["content_block"] {
        if block["type"] == "tool_use" {
            let id = block["id"]?.stringValue ?? ""
            blocks[index] = id.hasPrefix("toolu_") ? String(id.dropFirst("toolu_".count)) : id
        } else {
            blocks[index] = block["type"]?.stringValue ?? ""
        }
    }
    if ["content_block_start", "content_block_delta", "content_block_stop"].contains(type), let index = event["index"]?.intValue {
        return "\(blocks[index] ?? "?"): \(type)"
    }
    if type == "message_delta" {
        return "message_delta (\(event["delta"]?["stop_reason"]?.stringValue ?? "None"))"
    }
    return type
}

func streamingRunnerEmptyMessage() -> JSONValue {
    [
        "id": "msg_1", "type": "message", "role": "assistant", "model": "claude-haiku-4-5", "content": [],
        "stop_reason": nil, "stop_sequence": nil, "usage": ["input_tokens": 10, "output_tokens": 0],
    ]
}

/// The reply as the stream events the API sends for it.
func streamingRunnerEvents(_ reply: StreamingRunnerReply) -> [JSONValue] {
    var events: [JSONValue] = [["type": "message_start", "message": streamingRunnerEmptyMessage()]]
    for (index, block) in reply.blocks.enumerated() {
        var start = block
        var delta: JSONValue?
        if block["type"] == "tool_use" {
            var s: [String: JSONValue] = [
                "type": "tool_use", "id": .string("toolu_\(block["key"]?.stringValue ?? "")"),
                "name": block["name"] ?? "lookup", "input": [:],
            ]
            if let toolsetName = block["toolset_name"] { s["toolset_name"] = toolsetName }
            start = .object(s)
            delta = ["type": "input_json_delta", "partial_json": block["json"] ?? ""]
        } else if block["type"] == "text" {
            start = ["type": "text", "text": ""]
            delta = ["type": "text_delta", "text": block["text"] ?? ""]
        }
        events.append(["type": "content_block_start", "index": .int(index), "content_block": start])
        if let delta { events.append(["type": "content_block_delta", "index": .int(index), "delta": delta]) }
        events.append(["type": "content_block_stop", "index": .int(index)])
    }
    events.append([
        "type": "message_delta", "delta": ["stop_reason": .string(reply.stopReason), "stop_sequence": nil],
        "usage": ["output_tokens": 20],
    ])
    events.append(["type": "message_stop"])
    return events
}

/// The reply as the message the API sends for it when not streaming.
func streamingRunnerMessage(_ reply: StreamingRunnerReply) -> JSONValue {
    let content: [JSONValue] = reply.blocks.map { block in
        guard block["type"] == "tool_use" else { return block }
        var b: [String: JSONValue] = [
            "type": "tool_use", "id": .string("toolu_\(block["key"]?.stringValue ?? "")"), "name": block["name"] ?? "lookup",
            "input": (try? JSONValue.parse(block["json"]?.stringValue ?? "{}")) ?? [:],
        ]
        if let toolsetName = block["toolset_name"] { b["toolset_name"] = toolsetName }
        return .object(b)
    }
    var message = streamingRunnerEmptyMessage()
    message["content"] = .array(content)
    message["stop_reason"] = .string(reply.stopReason)
    return message
}

func streamingRunnerSSE(_ event: JSONValue) -> String {
    let data = String(decoding: try! JSONValue.serialize(event), as: UTF8.self)
    return "event: \(event["type"]?.stringValue ?? "")\ndata: \(data)\n\n"
}

/// The error a server that fails mid-reply raises (`httpx2.ReadError`).
struct StreamingRunnerReadError: Error {}

/// Answers `/v1/messages` with the canned replies, in order, recording each request and putting `request <n>` on the
/// timeline from the second request on.
final class StreamingRunnerServer: @unchecked Sendable {
    let timeline: ToolsBox<[String]>
    private let lock = NSLock()
    private var queue: [StreamingRunnerReply]
    private var _requests: [HTTPRequest] = []
    let stream: Bool

    init(_ replies: [StreamingRunnerReply], timeline: ToolsBox<[String]>, stream: Bool = true) {
        queue = replies
        self.timeline = timeline
        self.stream = stream
    }

    var requests: [HTTPRequest] { lock.withLock { _requests } }
    var bodies: [JSONValue] { requests.map { $0.jsonBody ?? .null } }

    func client() throws -> Anthropic {
        try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { [self] request in
            self.respond(request)
        }, environment: [:])
    }

    private func respond(_ request: HTTPRequest) -> HTTPResponse {
        let (count, reply): (Int, StreamingRunnerReply?) = lock.withLock {
            _requests.append(request)
            return (_requests.count, queue.isEmpty ? nil : queue.removeFirst())
        }
        if count > 1 { timeline.mutate { $0.append("request \(count)") } }
        guard let reply else {
            Issue.record("unexpected request \(request.method) \(request.url) (no replies left)")
            return HTTPResponse.json(["type": "error", "error": ["type": "api_error", "message": "no more replies"]], status: 500, for: request)
        }
        if !stream { return HTTPResponse.json(streamingRunnerMessage(reply), for: request) }
        let events = streamingRunnerEvents(reply)
        let headers: HTTPHeaders = ["content-type": "text/event-stream"]
        guard reply.eventByEvent else {
            return HTTPResponse(statusCode: 200, headers: headers, stream: chunked(Data(events.map(streamingRunnerSSE).joined().utf8)),
                                request: request)
        }
        let state = StreamingRunnerEventCursor(events)
        let timeline = self.timeline
        let failsBefore = reply.failsBefore
        let body = ByteStream(unfolding: {
            guard let event = state.next() else { return nil }
            let label = state.label(event)
            if label == failsBefore {
                timeline.mutate { $0.append("server fails") }
                throw StreamingRunnerReadError()
            }
            timeline.mutate { $0.append("server sends \(label)") }
            return Data(streamingRunnerSSE(event).utf8)
        })
        return HTTPResponse(statusCode: 200, headers: headers, stream: body, request: request)
    }
}

private final class StreamingRunnerEventCursor: @unchecked Sendable {
    private let lock = NSLock()
    private var events: [JSONValue]
    private var blocks: [Int: String] = [:]

    init(_ events: [JSONValue]) { self.events = events }

    func next() -> JSONValue? {
        lock.withLock { () -> JSONValue? in events.isEmpty ? Optional<JSONValue>.none : events.removeFirst() }
    }
    func label(_ event: JSONValue) -> String { lock.withLock { streamingRunnerLabel(event, &blocks) } }
}

struct StreamingRunnerLookupInput: Decodable, Sendable {
    var key: String
}

/// A `lookup` tool that writes to `timeline` when it starts, and returns `value of <key>` unless `lookup` says
/// otherwise.
func streamingRunnerLookupTool(_ timeline: ToolsBox<[String]>, lookup: (@Sendable (String) throws -> String)? = nil,
                               logReturns: Bool = false) -> BetaFunctionTool
{
    BetaFunctionTool(name: "lookup", description: "Look up a key.",
                     inputSchema: ["type": "object", "properties": ["key": ["type": "string"]], "required": ["key"]]) {
        (input: StreamingRunnerLookupInput) in
        timeline.mutate { $0.append("lookup(\(input.key)) STARTS") }
        let value = try lookup?(input.key) ?? "value of \(input.key)"
        if logReturns { timeline.mutate { $0.append("lookup(\(input.key)) returns") } }
        return .string(value)
    }
}

/// A toolset whose calls are written to the timeline when they start (the `TimelineDesktop` and `TimelineWorld` of
/// the upstream fixtures, over the runnable-toolset contract). A member named in `fail` raises its error.
final class StreamingRunnerTimelineToolset: BetaRunnableToolset, @unchecked Sendable {
    let family: String
    let timeline: ToolsBox<[String]>
    /// The members called, in order.
    let calls = ToolsBox<[String]>([])
    let fail = ToolsBox<[String: ToolError]>([:])

    init(family: String, timeline: ToolsBox<[String]>) {
        self.family = family
        self.timeline = timeline
    }

    override var toolsetName: String { family }
    override func toDict() throws -> JSONValue { ["type": .string("\(family)_toolset_20260801")] }
    override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        timeline.mutate { $0.append("\(family) \(name) STARTS") }
        calls.mutate { $0.append(name) }
        if let error = fail.value[name] { throw error }
        return .string("\(name) done")
    }
}

/// A runner whose requests are answered by the replies, in order, and whose `lookup` tool writes to the timeline when
/// it starts (`SetupFactory`).
final class StreamingRunnerSetup: @unchecked Sendable {
    let timeline = ToolsBox<[String]>([])
    let server: StreamingRunnerServer
    let runner: BetaStreamingToolRunner<Never>
    let computer: StreamingRunnerTimelineToolset?
    let browser: StreamingRunnerTimelineToolset?
    private let blocks = ToolsBox<[Int: String]>([:])

    init(_ replies: [StreamingRunnerReply], runToolsEagerly: Bool = true, lookup: (@Sendable (String) throws -> String)? = nil,
         logReturns: Bool = false, messages: [JSONValue]? = nil, computer: Bool = false, browser: Bool = false,
         extraTools: [any BetaToolLike] = []) throws
    {
        server = StreamingRunnerServer(replies, timeline: timeline)
        var tools: [any BetaToolLike] = [streamingRunnerLookupTool(timeline, lookup: lookup, logReturns: logReturns)]
        self.computer = computer ? StreamingRunnerTimelineToolset(family: "computer", timeline: timeline) : nil
        self.browser = browser ? StreamingRunnerTimelineToolset(family: "browser", timeline: timeline) : nil
        if let c = self.computer { tools.append(c) }
        if let b = self.browser { tools.append(b) }
        tools += extraTools
        runner = try server.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: try (messages ?? [["role": "user", "content": "Look these up."]]).map(param),
            model: "claude-haiku-4-5", tools: tools, runToolsEagerly: runToolsEagerly)
    }

    var lines: [String] { timeline.value }
    var requests: [JSONValue] { server.bodies }

    func label(_ event: ParsedBetaMessageStreamEvent) -> String {
        let json = (try? JSONValue.from(event)) ?? .null
        var label = ""
        blocks.mutate { label = streamingRunnerLabel(json, &$0) }
        return label
    }

    /// Adds a stream event to the timeline, as the caller saw it.
    func see(_ event: ParsedBetaMessageStreamEvent) {
        let label = label(event)
        timeline.mutate { $0.append(label) }
    }

    func append(_ line: String) { timeline.mutate { $0.append(line) } }

    /// The tool results the runner sent back for the first reply.
    func resultsSent() -> [JSONValue] {
        let messages = requests.count > 1 ? requests[1]["messages"]?.arrayValue ?? [] : []
        return messages.lazy.map(streamingRunnerToolResults).first { !$0.isEmpty } ?? []
    }
}

/// The `tool_use` block a `content_block_start` or `content_block_stop` event is about.
func streamingRunnerToolUse(_ event: ParsedBetaMessageStreamEvent) -> BetaToolUseBlock? {
    switch event {
    case .contentBlockStart(let e): if case .toolUse(let t) = e.contentBlock { return t }
    case .contentBlockStop(let e): if case .toolUse(let t) = e.contentBlock { return t }
    default: break
    }
    return nil
}

func streamingRunnerIsToolUseStop(_ event: ParsedBetaMessageStreamEvent) -> BetaToolUseBlock? {
    if case .contentBlockStop = event { return streamingRunnerToolUse(event) }
    return nil
}

func streamingRunnerIsToolUseStart(_ event: ParsedBetaMessageStreamEvent) -> BetaToolUseBlock? {
    if case .contentBlockStart = event { return streamingRunnerToolUse(event) }
    return nil
}
