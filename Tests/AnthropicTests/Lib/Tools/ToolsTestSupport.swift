import Foundation
import Testing
@testable import Anthropic

/// A thread-safe box for state a tool closure changes.
final class Box<T>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: T
    init(_ value: T) { _value = value }
    var value: T {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
    func mutate(_ f: (inout T) -> Void) { lock.withLock { f(&_value) } }
}

/// The counterpart of `respx_mock.post("/v1/messages").mock(side_effect=[...])`: answers each request with the
/// next response of a queue and records the requests.
final class MessagesMock: @unchecked Sendable {
    enum Reply: Sendable {
        case json(JSONValue, status: Int)
        case sse(String)
    }

    private let lock = NSLock()
    private var queue: [Reply]
    private var _requests: [HTTPRequest] = []

    /// Every response the mock was given, served or not.
    let replies: [Reply]

    convenience init(_ responses: [JSONValue]) { self.init(replies: responses.map { .json($0, status: 200) }) }
    init(replies: [Reply]) {
        queue = replies
        self.replies = replies
    }

    /// The JSON bodies of the responses, in order.
    func bodiesServed() -> [JSONValue] {
        replies.compactMap { if case .json(let b, _) = $0 { return b } else { return nil } }
    }

    var requests: [HTTPRequest] { lock.withLock { _requests } }
    var calls: Int { requests.count }
    var bodies: [JSONValue] { requests.map { $0.jsonBody ?? .null } }
    var lastBody: JSONValue { bodies.last ?? .null }

    func client(maxRetries: Int = 0) throws -> Anthropic {
        try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: maxRetries, transport: MockTransport { [self] request in
            self.respond(request)
        }, environment: [:])
    }

    private func respond(_ request: HTTPRequest) -> HTTPResponse {
        let reply: Reply? = lock.withLock {
            _requests.append(request)
            return queue.isEmpty ? nil : queue.removeFirst()
        }
        guard let reply else {
            Issue.record("unexpected request \(request.method) \(request.url) (no responses left)")
            return HTTPResponse.json(["type": "error", "error": ["type": "api_error", "message": "no more responses"]], status: 500, for: request)
        }
        switch reply {
        case .json(let body, let status): return HTTPResponse.json(body, status: status, for: request)
        case .sse(let text):
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(text.utf8)), request: request)
        }
    }
}

/// A `Message` response body.
func messageResponse(id: String, content: [JSONValue], stopReason: String?, model: String = "claude-haiku-4-5") -> JSONValue {
    [
        "id": .string(id), "type": "message", "role": "assistant", "model": .string(model), "content": .array(content),
        "stop_reason": stopReason.map { .string($0) } ?? .null, "stop_sequence": nil,
        "usage": ["input_tokens": 1, "output_tokens": 1],
    ]
}

let sfInput: JSONValue = ["location": "San Francisco, CA", "units": "f"]

func toolUseResponse(_ toolName: String, _ toolUseID: String, input: JSONValue? = nil) -> JSONValue {
    messageResponse(
        id: "msg_\(toolUseID)",
        content: [["type": "tool_use", "id": .string(toolUseID), "name": .string(toolName), "input": input ?? sfInput]],
        stopReason: "tool_use")
}

func endTurnResponse() -> JSONValue {
    messageResponse(id: "msg_end_turn", content: [["type": "text", "text": "Done."]], stopReason: "end_turn")
}

/// `json.dumps(_get_weather(location, units))`.
func getWeather(_ location: String, _ units: String) -> String {
    let temperature = units == "c" ? "20\\u00b0C" : "68\\u00b0F"
    return #"{"location": "\#(location)", "temperature": "\#(temperature)", "condition": "Sunny"}"#
}

struct WeatherInput: Codable, Sendable {
    var location: String
    var units: String
}

let weatherSchema: [String: JSONValue] = [
    "additionalProperties": false, "type": "object",
    "properties": [
        "location": ["description": "The city and state, e.g. San Francisco, CA", "title": "Location", "type": "string"],
        "units": [
            "description": "Unit for the output, either 'c' for celsius or 'f' for fahrenheit", "enum": ["c", "f"],
            "title": "Units", "type": "string",
        ],
    ],
    "required": ["location", "units"],
]

/// The `get_weather` tool the runner tests use; `calls` counts its runs.
func weatherTool(name: String = "get_weather", calls: Box<Int>? = nil,
                 run: (@Sendable (WeatherInput) async throws -> BetaFunctionToolResult?)? = nil) -> BetaFunctionTool
{
    BetaFunctionTool(name: name, description: "Lookup the weather for a given city.", inputSchema: weatherSchema) {
        (input: WeatherInput) in
        calls?.mutate { $0 += 1 }
        if let run { return try await run(input) }
        return .string(getWeather(input.location, input.units))
    }
}

/// A tool that records its runs by name (`_recording_tool`).
func recordingTool(_ name: String, _ calls: Box<[String]>, label: String? = nil) -> BetaFunctionTool {
    BetaFunctionTool(name: name, description: "Run \(name).",
                          inputSchema: ["additionalProperties": false, "properties": [:], "type": "object"]) { _ in
        calls.mutate { $0.append(label ?? name) }
        return .string("\(label ?? name) ran")
    }
}

func userMessage(_ text: String) -> BetaMessageParam {
    .user(BetaUserMessageParam(content: .string(text)))
}

/// A message param written as JSON.
func param(_ json: JSONValue) throws -> BetaMessageParam { try json.decode() }

/// A Python-style `RuntimeError` for tools to raise.
struct RuntimeError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) { self.message = message }
    var description: String { message }
}

/// Drives a runner and collects the tool_result messages it generated (`_run_sync_tool_use`).
func collectToolResults(_ runner: BetaToolRunner) async throws -> [JSONValue] {
    var responses: [JSONValue] = []
    for try await _ in runner {
        if let response = try await runner.generateToolCallResponseJSON() { responses.append(response) }
    }
    return responses
}

/// A tool_result user message.
func toolResultMessage(_ toolUseID: String, _ content: JSONValue, isError: Bool = false) -> JSONValue {
    var block: [String: JSONValue] = ["type": "tool_result", "tool_use_id": .string(toolUseID), "content": content]
    if isError { block["is_error"] = true }
    return ["role": "user", "content": [.object(block)]]
}

/// The recorded responses of an upstream http snapshot (`external("uuid:...")`), replayed in order.
func snapshotMock(_ uuid: String, dir: String = "TestSyncRunTools") throws -> MessagesMock {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let url = root.appendingPathComponent(
        "upstream/anthropic-sdk-python/tests/lib/tools/__inline_snapshot__/test_runners/\(dir)/\(uuid).json")
    let entries = try JSONValue.parse(Data(contentsOf: url)).arrayValue ?? []
    return MessagesMock(replies: entries.map { entry in
        let body = entry["response"]?["body"] ?? .null
        if case .string(let text) = body { return .sse(text) }
        return .json(body, status: entry["response"]?["status_code"]?.intValue ?? 200)
    })
}

func toolReferenceBlock(_ kind: String, _ name: String) -> JSONValue {
    ["type": .string(kind), "tool": ["type": "tool_reference", "name": .string(name)]]
}

func toolChangesMessage(_ blocks: JSONValue...) -> JSONValue { ["role": "system", "content": .array(blocks)] }

func addition(_ definition: JSONValue) -> JSONValue {
    ["type": "tool_addition", "tool": ["type": "tool_definition", "definition": definition]]
}

func ranResult(_ toolUseID: String, _ label: String) -> JSONValue { toolResultMessage(toolUseID, .string("\(label) ran")) }

func notFoundResult(_ toolUseID: String, _ name: String = "get_weather") -> JSONValue {
    toolResultMessage(toolUseID, .string("Error: Tool '\(name)' not found"), isError: true)
}

func callsTool(_ name: String, _ toolUseID: String) -> JSONValue { toolUseResponse(name, toolUseID, input: [:]) }

typealias ToolChangeScript = [String: @Sendable (BetaToolRunner) async throws -> Void]

/// Drives a runner to the end, running `script[message.id]` while each message is handled
/// (`_run_with_tool_changes`, `thread=False`).
func runWithToolChanges(_ mock: MessagesMock, tools: [any BetaToolLike], script: ToolChangeScript,
                        beforeFirstRequest: (@Sendable (BetaToolRunner) async throws -> Void)? = nil,
                        maxIterations: Int? = nil, messages: [JSONValue]? = nil) async throws
{
    let client = try mock.client()
    let runner = try client.beta.messages.toolRunner(
        maxTokens: 1024,
        messages: try (messages ?? [["role": "user", "content": "What time is it, and what is the weather in SF?"]]).map(param),
        model: "claude-haiku-4-5", tools: tools, maxIterations: maxIterations, thread: false)
    if let beforeFirstRequest { try await beforeFirstRequest(runner) }
    for try await message in runner {
        if let step = script[message.id] { try await step(runner) }
    }
}

/// Runs `body` and checks a warning containing `match` was emitted (`pytest.warns(UserWarning, match=...)`).
@discardableResult
func expectWarning<T>(_ match: String, sourceLocation: SourceLocation = #_sourceLocation,
                      _ body: () async throws -> T) async throws -> T
{
    let (value, capture) = try await ToolDiagnostics.capture(body)
    #expect(capture.warnings.contains { $0.contains(match) }, "expected a warning matching \(match), got \(capture.warnings)",
            sourceLocation: sourceLocation)
    return value
}
