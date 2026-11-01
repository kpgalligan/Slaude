// Port of tests/lib/threads/helpers.py: message and response builders, a queue of Messages API responses, and
// readers of the requests a thread sent.

import Foundation
import Testing
@testable import Anthropic

let THREADS_MODEL = "claude-sonnet-5"
let THREADS_MAX_TOKENS = 1024
let THREADS_BETA = "message-threads-2026-08-12"
let THREADS_STRUCTURED_OUTPUTS_BETA = "structured-outputs-2025-12-15"
let THREADS_CONTEXT_MANAGEMENT_BETA = "context-management-2025-06-27"
let THREADS_INLINE_TOOLS_BETA = "inline-tools-2026-09-15"
let THREADS_CREATE: JSONValue = ["type": "create"]
let THREADS_FALLBACK_MODEL = "claude-haiku-4-5"
let THREADS_FALLBACKS: JSONValue = [["model": .string(THREADS_FALLBACK_MODEL)]]
let THREADS_FALLBACK_BETA = "server-side-fallback-2026-07-01"
let THREADS_LOGGER = "anthropic.lib.threads"
let THREADS_NOOP_TOOL: JSONValue = ["name": "noop", "description": "Does nothing.", "input_schema": ["type": "object", "properties": [:]]]

struct ThreadsForecast: StructuredOutput, Equatable {
    var forecast: String
    static let jsonSchema: JSONValue = [
        "type": "object", "title": "Forecast", "properties": ["forecast": ["type": "string", "title": "Forecast"]], "required": ["forecast"],
    ]
}

// MARK: - Messages

func thUser(_ text: String) -> JSONValue { ["role": "user", "content": .string(text)] }

/// A user message whose only block has a `cache_control` marker.
func thMarked(_ text: String) -> JSONValue {
    ["role": "user", "content": [["type": "text", "text": .string(text), "cache_control": ["type": "ephemeral"]]]]
}

/// A user message with two blocks, each with a `cache_control` marker.
func thMarkedTwice(_ text: String) -> JSONValue {
    let block: JSONValue = ["type": "text", "text": .string(text), "cache_control": ["type": "ephemeral"]]
    return ["role": "user", "content": [block, block]]
}

/// `thMarked(text)` without the marker.
func thUnmarked(_ text: String) -> JSONValue { ["role": "user", "content": [["type": "text", "text": .string(text)]]] }

func thAssistant(_ text: String = "Hi!") -> JSONValue { ["role": "assistant", "content": [["type": "text", "text": .string(text)]]] }

func thToolUse(_ id: String, _ name: String = "get_weather") -> JSONValue {
    ["role": "assistant", "content": [["type": "tool_use", "id": .string(id), "name": .string(name), "input": ["location": "San Francisco"]]]]
}

func thToolResult(_ id: String, _ content: String = "Sunny in San Francisco") -> JSONValue {
    ["role": "user", "content": [["type": "tool_result", "tool_use_id": .string(id), "content": .string(content)]]]
}

func thToolAddition(_ definition: JSONValue) -> JSONValue {
    ["role": "system", "content": [["type": "tool_addition", "tool": ["type": "tool_definition", "definition": definition]]]]
}

func thToolRemoval(_ name: String) -> JSONValue {
    ["role": "system", "content": [["type": "tool_removal", "tool": ["type": "tool_reference", "name": .string(name)]]]]
}

func thContinueFrom(_ id: String) -> JSONValue { ["type": "continue", "previous_message_id": .string(id)] }

func thRoles(_ messages: [JSONValue]) -> [String] { messages.map { $0["role"]?.stringValue ?? "" } }

func thRoles(_ messages: JSONValue?) -> [String] { thRoles(messages?.arrayValue ?? []) }

/// A history with `marker` in every block, nested ones included (`history_with_nested_blocks`). Its free-form data
/// has `cache_control` keys of its own, and so do the `tool_changes` of its compaction block, whatever `marker` is.
func thHistoryWithNestedBlocks(_ marker: [String: JSONValue]) -> [JSONValue] {
    func with(_ object: [String: JSONValue], _ marker: [String: JSONValue]) -> JSONValue {
        .object(object.merging(marker) { a, _ in a })
    }
    func addedTool(_ marker: [String: JSONValue]) -> JSONValue {
        let definition = with([
            "name": "fetch", "input_schema": ["type": "object", "properties": ["cache_control": [:]]],
            "input_examples": [["cache_control": "no-store"]],
        ], marker)
        return with(["type": "tool_addition", "tool": ["type": "tool_definition", "definition": definition]], marker)
    }
    return [
        ["role": "user", "content": "Hello"],
        ["role": "assistant", "content": [with([
            "type": "compaction", "content": "Said hello.", "tool_changes": [addedTool(["cache_control": ["type": "ephemeral"]])],
        ], marker)]],
        ["role": "system", "content": [addedTool(marker)]],
        ["role": "user", "content": "Fetch it."],
        ["role": "assistant", "content": [
            with([
                "type": "tool_search_tool_result", "tool_use_id": "srvtoolu_a",
                "content": [
                    "type": "tool_search_tool_search_result",
                    "tool_references": [with(["type": "tool_reference", "tool_name": "fetch"], marker)],
                ],
            ], marker),
            with([
                "type": "tool_use", "id": "toolu_a", "name": "fetch",
                "input": ["cache_control": "no-store", "headers": [["cache_control": "no-store"]]],
            ], marker),
        ]],
        ["role": "user", "content": [
            with(["type": "tool_result", "tool_use_id": "toolu_a", "content": [with(["type": "text", "text": "Fetched."], marker)]], marker),
            with(["type": "document", "source": ["type": "content", "content": [with(["type": "text", "text": "Notes."], marker)]]], marker),
        ]],
    ]
}

// MARK: - Responses

/// One queued answer to a Messages API request.
enum ThreadsReply: Sendable {
    case json(JSONValue, status: Int, headers: [String: String])
    /// A streamed body, which may fail after its events (`error`).
    case sse([String], error: (any Error)?)
    /// Raised in place of a response.
    case failure(any Error)
}

func thMessageResponse(_ id: String, _ text: String = "Hi!", toolUseID: String? = nil, toolName: String = "get_weather",
                       container: String? = nil, stopReason: String? = nil, iterations: JSONValue? = nil,
                       headers: [String: String] = [:]) -> ThreadsReply
{
    .json(thMessageBody(id, text, toolUseID: toolUseID, toolName: toolName, container: container, stopReason: stopReason,
                        iterations: iterations), status: 200, headers: headers)
}

func thMessageBody(_ id: String, _ text: String = "Hi!", toolUseID: String? = nil, toolName: String = "get_weather",
                   container: String? = nil, stopReason: String? = nil, iterations: JSONValue? = nil) -> JSONValue
{
    let content = (toolUseID == nil ? thAssistant(text) : thToolUse(toolUseID!, toolName))["content"] ?? []
    var usage: [String: JSONValue] = ["input_tokens": 10, "output_tokens": 5]
    if let iterations, iterations != [] { usage["iterations"] = iterations }
    return [
        "id": .string(id), "type": "message", "role": "assistant", "model": .string(THREADS_MODEL), "content": content,
        "container": container.map { ["id": .string($0), "expires_at": "2026-08-19T00:00:00Z"] } ?? .null,
        "stop_reason": .string(stopReason ?? (toolUseID != nil ? "tool_use" : "end_turn")), "stop_sequence": nil, "usage": .object(usage),
    ]
}

private func thIteration(_ type: String, _ model: String) -> JSONValue {
    ["type": .string(type), "model": .string(model), "input_tokens": 10, "output_tokens": 5, "cache_creation_input_tokens": 0,
     "cache_read_input_tokens": 0]
}

/// The `usage.iterations` of a reply that `THREADS_FALLBACK_MODEL` wrote after `THREADS_MODEL` declined.
let THREADS_FALLBACK_ITERATIONS: JSONValue = [
    thIteration("message", THREADS_MODEL), thIteration("fallback_message", THREADS_FALLBACK_MODEL),
    thIteration("advisor_message", "claude-opus-4-8"),
]

/// The reply of `thFallbackResponse()`.
func thFallbackReply(_ text: String = "Hi!") -> JSONValue {
    ["role": "assistant", "content": [
        ["type": "fallback", "from": ["model": .string(THREADS_MODEL)], "to": ["model": .string(THREADS_FALLBACK_MODEL)],
         "trigger": ["type": "refusal", "category": "cyber"]],
        ["type": "text", "text": .string(text)],
    ]]
}

/// A reply that the fallback model wrote after the requested one declined.
func thFallbackResponse(_ id: String) -> ThreadsReply {
    var body = thMessageBody(id, iterations: THREADS_FALLBACK_ITERATIONS).objectValue!
    body["model"] = .string(THREADS_FALLBACK_MODEL)
    body["content"] = thFallbackReply()["content"]
    return .json(.object(body), status: 200, headers: [:])
}

/// The replies of a run that calls `get_weather`, then `lookup`, then `get_weather` again, and then ends.
func thToolChangeReplies() -> [ThreadsReply] {
    [
        thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", toolUseID: "toolu_b", toolName: "lookup"),
        thMessageResponse("msg_c", toolUseID: "toolu_c"), thMessageResponse("msg_d", "Sunny."),
    ]
}

/// What answers each of the first three `thToolChangeReplies()` when `lookup` is added while the first one is handled
/// and `get_weather` is removed while the second one is.
func thToolChangeTurns(_ lookupDefinition: JSONValue) -> [[JSONValue]] {
    [
        [thToolResult("toolu_a"), thToolAddition(lookupDefinition)],
        [thToolResult("toolu_b", "800,000 people live in San Francisco"), thToolRemoval("get_weather")],
        [["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_c", "content": "Error: Tool 'get_weather' not found",
                                       "is_error": true]]]],
    ]
}

let THREADS_COMPACTED: JSONValue = ["role": "assistant", "content": [["type": "compaction", "content": "Asked about SF; it is sunny."]]]

func thCompactionResponse(_ id: String) -> ThreadsReply {
    var body = thMessageBody(id, stopReason: "compaction").objectValue!
    body["content"] = THREADS_COMPACTED["content"]
    return .json(.object(body), status: 200, headers: [:])
}

private func thSSE(_ events: [(String, JSONValue)]) -> [String] {
    events.flatMap { name, data in ["event: \(name)\n", "data: \((try? String(decoding: JSONValue.serialize(data), as: UTF8.self)) ?? "")\n", "\n"] }
}

private func thTextDeltas(_ text: String) -> [String] {
    let words = text.components(separatedBy: " ")
    return [words[0]] + words.dropFirst().map { " \($0)" }
}

/// The lines of a streamed reply (`_sse_body`).
func thSSEBody(_ id: String, _ text: String = "Hello there!", toolUseID: String? = nil, container: String? = nil,
               stopReason: String? = nil, iterations: JSONValue? = nil, contentEvents: [(String, JSONValue)]? = nil) -> [String]
{
    let content: [(String, JSONValue)] = contentEvents ?? (toolUseID == nil
        ? [("content_block_start", ["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]])]
            + thTextDeltas(text).map { ("content_block_delta", ["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": .string($0)]]) }
            + [("content_block_stop", ["type": "content_block_stop", "index": 0])]
        : [
            ("content_block_start", ["type": "content_block_start", "index": 0,
                                     "content_block": ["type": "tool_use", "id": .string(toolUseID!), "name": "get_weather", "input": [:]]]),
            ("content_block_delta", ["type": "content_block_delta", "index": 0,
                                     "delta": ["type": "input_json_delta", "partial_json": #"{"location": "San Francisco"}"#]]),
            ("content_block_stop", ["type": "content_block_stop", "index": 0]),
        ])
    var usage: [String: JSONValue] = ["output_tokens": 5]
    if let iterations, iterations != [] { usage["iterations"] = iterations }
    let events: [(String, JSONValue)] = [
        ("message_start", ["type": "message_start", "message": [
            "id": .string(id), "type": "message", "role": "assistant", "model": .string(THREADS_MODEL), "content": [], "container": nil,
            "stop_reason": nil, "stop_sequence": nil, "usage": ["input_tokens": 10, "output_tokens": 5],
        ]]),
    ] + content + [
        ("message_delta", ["type": "message_delta", "delta": [
            "stop_reason": .string(stopReason ?? (toolUseID != nil ? "tool_use" : "end_turn")), "stop_sequence": nil,
            "container": container.map { ["id": .string($0), "expires_at": "2026-08-19T00:00:00Z"] } ?? .null,
        ], "usage": .object(usage)]),
        ("message_stop", ["type": "message_stop"]),
    ]
    return thSSE(events)
}

/// A streamed reply. With `messageStop: false` the body ends after `message_delta`.
func thStreamResponse(_ id: String, _ text: String = "Hello there!", toolUseID: String? = nil, container: String? = nil,
                      stopReason: String? = nil, iterations: JSONValue? = nil, messageStop: Bool = true) -> ThreadsReply
{
    var body = thSSEBody(id, text, toolUseID: toolUseID, container: container, stopReason: stopReason, iterations: iterations)
    if !messageStop { body.removeLast(3) }
    return .sse(body, error: nil)
}

/// A streamed reply with a finished text block followed by a `tool_use` block whose input is cut off before
/// `content_block_stop`.
func thPartialToolUseStreamResponse(_ id: String, _ text: String, toolUseID: String) -> ThreadsReply {
    .sse(thSSEBody(id, contentEvents: [
        ("content_block_start", ["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]]),
        ("content_block_delta", ["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": .string(text)]]),
        ("content_block_stop", ["type": "content_block_stop", "index": 0]),
        ("content_block_start", ["type": "content_block_start", "index": 1,
                                 "content_block": ["type": "tool_use", "id": .string(toolUseID), "name": "get_weather", "input": [:]]]),
        ("content_block_delta", ["type": "content_block_delta", "index": 1,
                                 "delta": ["type": "input_json_delta", "partial_json": #"{"location": "San"#]]),
    ]), error: nil)
}

struct ThreadsConnectionDropped: Error, CustomStringConvertible {
    var description: String { "The connection dropped" }
}

/// A streamed reply cut off in its text block, once `text` has arrived: the body ends there, or reading on fails.
func thInterruptedStreamResponse(_ id: String, _ text: String, error: Bool = false) -> ThreadsReply {
    .sse(Array(thSSEBody(id, text).dropLast(9)), error: error ? URLError(.networkConnectionLost) : nil)
}

func thAPIErrorResponse(_ status: Int, _ type: String, _ message: String, errorCode: String? = nil,
                        details: [String: JSONValue] = [:]) -> ThreadsReply
{
    var error: [String: JSONValue] = ["type": .string(type), "message": .string(message)]
    if let errorCode { error["details"] = .object(details.merging(["error_code": .string(errorCode)]) { a, _ in a }) }
    return .json(["type": "error", "error": .object(error)], status: status, headers: ["x-should-retry": "false"])
}

func thServerError() -> ThreadsReply { thAPIErrorResponse(500, "api_error", "Internal server error") }

/// A stream whose first event is an error.
func thStreamErrorResponse() -> ThreadsReply {
    .sse(["event: error\n", #"data: {"type": "error", "error": {"type": "overloaded_error", "message": "Overloaded"}}"# + "\n", "\n"], error: nil)
}

let THREADS_NOT_FOUND = thAPIErrorResponse(404, "not_found_error", "No thread state was found for the requested `previous_message_id`.",
                                           errorCode: "thread_not_found")
let THREADS_FINGERPRINT_MISMATCH = thAPIErrorResponse(400, "invalid_request_error", "`tools` differs from the request that created this Thread.",
                                                      errorCode: "thread_fingerprint_mismatch")
let THREADS_ALREADY_CONTINUED_MESSAGE = "The requested `previous_message_id` has already been continued. Each response `id` may be continued at most once; continue from the Thread's most recent response `id`."
let THREADS_ALREADY_CONTINUED = thAPIErrorResponse(400, "invalid_request_error", THREADS_ALREADY_CONTINUED_MESSAGE,
                                                   errorCode: "thread_already_continued")
let THREADS_CONTINUE_IN_FLIGHT = thAPIErrorResponse(400, "invalid_request_error",
                                                    "Another request is already continuing the requested `previous_message_id`.",
                                                    errorCode: "thread_continue_in_flight")

func thUnsupportedResponse(_ unsupported: String...) -> ThreadsReply {
    thAPIErrorResponse(400, "invalid_request_error", "This request cannot be used with `thread`.", errorCode: "thread_unsupported_request",
                       details: ["unsupported": .array(unsupported.map { .string($0) })])
}

/// The failures before a reply that a turn raises (`FAILURES_BEFORE_A_REPLY`).
let THREADS_FAILURES_BEFORE_A_REPLY: [ThreadsReply] = [
    thAPIErrorResponse(400, "invalid_request_error", "messages.0.content: too long"),
    thAPIErrorResponse(529, "overloaded_error", "Overloaded"),
    .failure(URLError(.cannotConnectToHost)),
    .failure(URLError(.timedOut)),
]

// MARK: - The mock

/// The counterpart of `queue_responses(respx_mock, ...)`: answers each Messages API request with the next queued
/// response and records the requests.
final class ThreadsMock: @unchecked Sendable {
    private let lock = NSLock()
    private var queue: [ThreadsReply]
    private var _requests: [HTTPRequest] = []
    /// Called with each request before it is answered.
    var onRequest: (@Sendable (HTTPRequest) async throws -> Void)?

    init(_ replies: ThreadsReply...) { queue = replies }
    init(replies: [ThreadsReply]) { queue = replies }

    func enqueue(_ replies: ThreadsReply...) { lock.withLock { queue += replies } }

    var requests: [HTTPRequest] { lock.withLock { _requests } }
    var calls: Int { requests.count }
    var bodies: [JSONValue] { requests.map { $0.jsonBody ?? .null } }
    /// The `thread` param of each request, or `nil` for a request sent without one.
    var threads: [JSONValue?] { bodies.map { $0["thread"] } }
    var betas: [[String]] {
        requests.map { ($0.headers["anthropic-beta"] ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty } }
    }
    /// The helper telemetry header of each request.
    var helperTags: [String?] { requests.map { $0.headers["x-stainless-helper"] } }

    func client(maxRetries: Int = 0) throws -> Anthropic {
        try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: maxRetries, transport: transport, environment: [:])
    }

    /// A transport that answers every request from the queue (for platform clients).
    var transport: MockTransport { MockTransport { [self] request in try await self.respond(request) } }

    private func respond(_ request: HTTPRequest) async throws -> HTTPResponse {
        try await onRequest?(request)
        let reply: ThreadsReply? = lock.withLock {
            _requests.append(request)
            return queue.isEmpty ? nil : queue.removeFirst()
        }
        guard let reply else {
            Issue.record("unexpected request \(request.method) \(request.url) (no responses left)")
            return .json(["type": "error", "error": ["type": "api_error", "message": "no more responses"]], status: 500,
                         headers: ["x-should-retry": "false"], for: request)
        }
        switch reply {
        case .json(let body, let status, let headers):
            return .json(body, status: status, headers: HTTPHeaders(headers), for: request)
        case .sse(let lines, let error):
            let stream = ByteStream { c in
                for line in lines { c.yield(Data(line.utf8)) }
                if let error { c.finish(throwing: error) } else { c.finish() }
            }
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: stream, request: request)
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Threads and turns

/// A thread on a mock client (`make_thread`); `model` and `max_tokens` default to values no test depends on. A
/// `tools` entry of `fields` becomes the thread's tools.
func thMakeThread(_ mock: ThreadsMock, _ fields: [String: JSONValue] = [:], messages: [JSONValue] = [], tools: [any BetaToolLike]? = nil,
                  behavior: UnsupportedRequestBehavior = .error, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                  extraBody: Body? = nil, timeout: Timeout? = nil) throws -> BetaMessageThread<Never>
{
    try thMakeThread(try mock.client(), fields, messages: messages, tools: tools, behavior: behavior, extraHeaders: extraHeaders,
                     extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
}

func thMakeThread(_ client: BaseClient, _ fields: [String: JSONValue] = [:], messages: [JSONValue] = [], tools: [any BetaToolLike]? = nil,
                  behavior: UnsupportedRequestBehavior = .error, extraHeaders: Headers? = nil, extraQuery: Query? = nil,
                  extraBody: Body? = nil, timeout: Timeout? = nil) throws -> BetaMessageThread<Never>
{
    var f: [String: JSONValue] = ["model": .string(THREADS_MODEL), "max_tokens": .int(THREADS_MAX_TOKENS)]
    for (k, v) in fields { f[k] = v }
    var allTools = tools
    if let jsonTools = f.removeValue(forKey: "tools") {
        allTools = (allTools ?? []) + (jsonTools.arrayValue ?? []).map { $0 as any BetaToolLike }
    }
    return try BetaMessageThread(client: client, params: ThreadParams(fields: f, messages: messages, tools: allTools,
                                                                       unsupportedRequestBehavior: behavior),
                                 extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout)
}

/// A typed thread (`make_thread(output_format=Forecast)`).
func thMakeForecastThread(_ mock: ThreadsMock, outputConfig: BetaOutputConfigParam? = nil, messages: [JSONValue] = [])
    throws -> BetaMessageThread<ThreadsForecast>
{
    try mock.client().beta.messages.thread(maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL), messages: messages,
                                           outputFormat: ThreadsForecast.self, params: ThreadCreateParams(outputConfig: outputConfig))
}

/// Per-turn overrides: request fields as JSON (a `tools` entry is the turn's tools) and request options.
func thOverrides(_ fields: [String: JSONValue] = [:], extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil,
                 timeout: Timeout? = nil) -> TurnOverrides
{
    TurnOverrides(fields: fields, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody,
                                                                    timeout: timeout))
}

func thMessages(_ messages: [any BetaThreadMessageLike]) throws -> [ThreadMessage] { try threadMessages(messages) }

/// `thread.send(*messages, **overrides)`.
@discardableResult
func thSend<O>(_ thread: BetaMessageThread<O>, _ messages: any BetaThreadMessageLike..., fields: [String: JSONValue] = [:],
               extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil) async throws -> BetaMessage
{
    try await thread.send(try thMessages(messages), overrides: thOverrides(fields, extraHeaders: extraHeaders, extraQuery: extraQuery,
                                                                          extraBody: extraBody))
}

/// `thread.update(**fields)`.
func thUpdate<O>(_ thread: BetaMessageThread<O>, _ fields: [String: JSONValue] = [:], tools: [any BetaToolLike]? = nil,
                 extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil) throws
{
    try thread.inner.state.update(thOverrides(fields, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody), tools: tools)
}

enum ThreadsTurnMethod: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case send, parse, stream
    var testDescription: String { rawValue }
}

/// Run one turn with `method` (`run_turn`): a `stream` is read to its end.
@discardableResult
func thRunTurn<O>(_ thread: BetaMessageThread<O>, _ method: ThreadsTurnMethod, _ messages: any BetaThreadMessageLike...,
                  fields: [String: JSONValue] = [:]) async throws -> BetaMessage
{
    let m = try thMessages(messages)
    switch method {
    case .send: return try await thread.send(m, overrides: thOverrides(fields))
    case .parse: return try await thread.parse(m, overrides: thOverrides(fields)).message
    case .stream:
        let stream = try await thread.stream(m, overrides: thOverrides(fields))
        defer { stream.close() }
        return try await stream.getFinalMessage().message
    }
}

/// A queued reply of the kind `method` reads (`stream_response` for a stream).
func thRespond(_ method: ThreadsTurnMethod, _ id: String, _ text: String = "Hi!", stopReason: String? = nil,
               iterations: JSONValue? = nil) -> ThreadsReply
{
    method == .stream ? thStreamResponse(id, text, stopReason: stopReason, iterations: iterations)
        : thMessageResponse(id, text, stopReason: stopReason, iterations: iterations)
}

/// The (level, message) pairs logged under the `anthropic.lib.threads` logger or its children.
func thThreadLogs(_ capture: ToolDiagnostics.Capture) -> [String] {
    capture.records.filter { $0.logger.hasPrefix(THREADS_LOGGER) && $0.level == .info }.map(\.message)
}

/// The messages of `thread` as JSON.
func thMessagesOf<O>(_ thread: BetaMessageThread<O>) -> [JSONValue] { thread.messagesJSON }

/// `get_weather` as a tool for threads and runners (`beta_async_tool(async_get_weather, name="get_weather")`).
func thWeatherTool(name: String = "get_weather", calls: ToolsBox<Int>? = nil) -> BetaFunctionTool {
    BetaFunctionTool(name: name, description: "Lookup the weather for a given city.", inputSchema: [
        "type": "object", "properties": ["location": ["type": "string", "description": "The city, e.g. San Francisco"]], "required": ["location"],
    ]) { (input: JSONValue) in
        calls?.mutate { $0 += 1 }
        return .string("Sunny in \(input["location"]?.stringValue ?? "")")
    }
}

/// `lookup` as a tool (`beta_async_tool(async_lookup)`).
func thLookupTool(calls: ToolsBox<Int>? = nil) -> BetaFunctionTool {
    BetaFunctionTool(name: "lookup", description: "Lookup the population of a given city.", inputSchema: [
        "type": "object", "properties": ["location": ["type": "string", "description": "The city, e.g. San Francisco"]], "required": ["location"],
    ]) { (input: JSONValue) in
        calls?.mutate { $0 += 1 }
        return .string("800,000 people live in \(input["location"]?.stringValue ?? "")")
    }
}

let THREADS_WEATHER_QUESTION: JSONValue = ["role": "user", "content": "What is the weather in SF?"]

/// `client.beta.messages.tool_runner(...)` with the `get_weather` tool and the weather question unless replaced.
func thMakeRunner(_ mock: ThreadsMock, fields: [String: JSONValue] = [:], messages: [JSONValue]? = nil, tools: [any BetaToolLike]? = nil,
                  thread: Bool? = nil, maxIterations: Int? = nil, extraHeaders: Headers? = nil) throws -> BetaToolRunner
{
    var params: [String: JSONValue] = ["model": .string(THREADS_MODEL), "max_tokens": .int(THREADS_MAX_TOKENS)]
    for (k, v) in fields { params[k] = v }
    params["messages"] = .array(messages ?? [THREADS_WEATHER_QUESTION])
    if thread == false { params["thread"] = false }
    let toolList = tools ?? [thWeatherTool()]
    var fieldsOnly = params
    let messagesJSON = fieldsOnly.removeValue(forKey: "messages")?.arrayValue ?? []
    fieldsOnly.removeValue(forKey: "thread")
    let messageThread = try MessageThread.forToolRunner(
        client: try mock.client(), fields: fieldsOnly, messages: messagesJSON, tools: toolList, threading: thread != false)
    return try BetaToolRunner(thread: messageThread, options: ToolRunnerRequestOptions(extraHeaders: extraHeaders),
                              maxIterations: maxIterations)
}

/// Drives a runner to the end, collecting its messages.
@discardableResult
func thDrain(_ runner: BetaToolRunner) async throws -> [BetaMessage] {
    var messages: [BetaMessage] = []
    for try await message in runner { messages.append(message) }
    return messages
}

func thText(_ message: BetaMessage) -> [String] {
    message.content.compactMap { if case .text(let t) = $0 { return t.text } else { return nil } }
}
