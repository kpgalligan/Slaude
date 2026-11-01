// Shared helpers of the ports of tests/test_open_telemetry.py and tests/test_tracing.py.

import Foundation
import Testing
@testable import Anthropic

let tracingBaseURL = "http://127.0.0.1:4010"

/// `MESSAGE`.
let tracingMessage: JSONValue = [
    "id": "msg_1",
    "type": "message",
    "role": "assistant",
    "model": "claude-test",
    "content": [["type": "text", "text": "Hi there"]],
    "stop_reason": "end_turn",
    "stop_sequence": nil,
    "usage": [
        "input_tokens": 10,
        "output_tokens": 5,
        "cache_read_input_tokens": 2,
        "cache_creation_input_tokens": 3,
        "cache_creation": ["ephemeral_5m_input_tokens": 1, "ephemeral_1h_input_tokens": 2],
        "service_tier": "standard",
    ],
]

/// `RESPONSE_HEADERS`.
let tracingResponseHeaders: [String: String] = [
    "request-id": "req_1",
    "anthropic-organization-id": "org_1",
    "anthropic-workspace-id": "wrkspc_1",
]

struct TracingTestError: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
}

/// `Spans`: a tracer provider that records finished spans in memory.
final class TracingSpans: Sendable {
    let exporter = InMemorySpanExporter()
    let provider: SDKTracerProvider

    init(sampler: any Sampler = ParentBasedSampler(), idGenerator: any IDGenerator = RandomIDGenerator()) {
        provider = SDKTracerProvider(sampler: sampler, idGenerator: idGenerator)
        provider.addSpanProcessor(SimpleSpanProcessor(exporter))
    }

    var finished: [SpanData] { exporter.finishedSpans }
    func named(_ name: String) -> [SpanData] { finished.filter { $0.name == name } }

    func one(_ name: String, sourceLocation: SourceLocation = #_sourceLocation) throws -> SpanData {
        let spans = named(name)
        guard spans.count == 1 else {
            Issue.record("expected one \(name) span, got \(finished.map(\.name))", sourceLocation: sourceLocation)
            throw TracingTestError("expected one \(name) span")
        }
        return spans[0]
    }

    func option(propagation: Bool? = nil, traces: OpenTelemetryTraces? = nil, conversationID: String? = nil) -> OpenTelemetryOptions {
        OpenTelemetryOptions(tracerProvider: provider, propagation: propagation, traces: traces, conversationID: conversationID)
    }

    var contentOption: OpenTelemetryOptions { option(traces: OpenTelemetryTraces(contentMode: .content)) }
}

extension SpanData {
    subscript(_ key: String) -> AttributeValue? { attributes[key] }

    /// The JSON of a content attribute.
    func json(_ key: String) -> JSONValue? { attributes[key]?.stringValue.flatMap { try? JSONValue.parse($0) } }

    var statusCode: StatusCode { status.code }

    /// `url_attributes`.
    var urlAttributes: SpanAttributes { attributes.filter { $0.key.hasPrefix("url.") } }

    /// `content_size`: the bytes of UTF-8 that the content attributes that can be reduced hold.
    var contentSize: Int {
        ["gen_ai.input.messages", "gen_ai.output.messages", "gen_ai.system_instructions"].reduce(0) {
            $0 + (attributes[$1]?.stringValue?.utf8.count ?? 0)
        }
    }
}

// MARK: - Mock routes (`respx_mock`)

/// One canned answer of a `TracingRouter` route.
enum TracingReply: Sendable {
    case json(JSONValue, status: Int = 200, headers: [String: String] = [:])
    case text(String, status: Int = 200, headers: [String: String] = [:])
    /// Server-sent events, delivered in chunks, with `RESPONSE_HEADERS` (`stream_response`).
    case sse([JSONValue])
    /// A body delivered in chunks.
    case bytes(Data, status: Int = 200, headers: [String: String] = [:])
    /// A body whose connection is lost after `prefix` (`LostConnection`).
    case lostConnection(Data, headers: [String: String] = [:])
    case fail(any Error & Sendable)
    case custom(@Sendable (HTTPRequest) async throws -> HTTPResponse)
}

/// A route of a `TracingRouter`, with the requests that it answered.
final class TracingRoute: @unchecked Sendable {
    let method: String
    let path: String
    private let lock = NSLock()
    private var replies: [TracingReply]
    private var _requests: [HTTPRequest] = []
    private var _currentSpans: [SpanContext] = []

    init(method: String, path: String, replies: [TracingReply]) {
        self.method = method
        self.path = path
        self.replies = replies
    }

    var requests: [HTTPRequest] { lock.withLock { _requests } }
    /// The context of the span that was current while the client sent each request.
    var currentSpans: [SpanContext] { lock.withLock { _currentSpans } }
    var traceparents: [String?] { requests.map { $0.headers["traceparent"] } }

    func matches(_ request: HTTPRequest) -> Bool {
        guard method == "*" || request.method.uppercased() == method.uppercased() else { return false }
        if path == "*" { return true }
        if path.hasPrefix("http") { return request.url.absoluteString.split(separator: "?").first.map(String.init) == path }
        if path.hasPrefix("~") { return request.url.absoluteString.range(of: String(path.dropFirst()), options: .regularExpression) != nil }
        return (URLComponents(url: request.url, resolvingAgainstBaseURL: false)?.percentEncodedPath ?? request.url.path) == path
    }

    func respond(_ request: HTTPRequest) async throws -> HTTPResponse {
        let reply: TracingReply = lock.withLock {
            _requests.append(request)
            _currentSpans.append(TracingContext.currentSpan.context)
            return replies.count > 1 ? replies.removeFirst() : replies[0]
        }
        func headers(_ h: [String: String], _ contentType: String?) -> HTTPHeaders {
            var out = HTTPHeaders(h)
            if let contentType, out["content-type"] == nil { out["content-type"] = contentType }
            return out
        }
        switch reply {
        case .json(let value, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, "application/json"), body: try JSONValue.serialize(value), request: request)
        case .text(let text, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, "text/plain"), body: Data(text.utf8), request: request)
        case .sse(let events):
            return HTTPResponse(statusCode: 200, headers: headers(tracingResponseHeaders, "text/event-stream"), stream: chunked(tracingSSE(events), size: 64),
                                request: request)
        case .bytes(let data, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, nil), stream: chunked(data, size: 64), request: request)
        case .lostConnection(let prefix, let h):
            let stream = ByteStream { c in
                c.yield(prefix)
                c.finish(throwing: URLError(.networkConnectionLost))
            }
            return HTTPResponse(statusCode: 200, headers: headers(h, nil), stream: stream, request: request)
        case .fail(let error):
            throw error
        case .custom(let f):
            return try await f(request)
        }
    }
}

/// What `respx_mock` gives the upstream tests: routes by method and path, each with its replies (the last repeats).
final class TracingRouter: @unchecked Sendable {
    private let lock = NSLock()
    private var routes: [TracingRoute] = []

    @discardableResult
    func route(_ method: String, _ path: String, _ replies: TracingReply...) -> TracingRoute {
        let route = TracingRoute(method: method, path: path, replies: replies)
        lock.withLock { routes.append(route) }
        return route
    }

    @discardableResult
    func route(_ method: String, _ path: String, replies: [TracingReply]) -> TracingRoute {
        let route = TracingRoute(method: method, path: path, replies: replies)
        lock.withLock { routes.append(route) }
        return route
    }

    var transport: MockTransport {
        MockTransport { [self] request in
            guard let route = lock.withLock({ routes.first(where: { $0.matches(request) }) }) else {
                Issue.record("unexpected request \(request.method) \(request.url)")
                return HTTPResponse.json(["error": "no route"], status: 404, for: request)
            }
            return try await route.respond(request)
        }
    }
}

/// `make_async_client`. Retries do not wait.
func tracingClient(_ spans: TracingSpans?, _ router: TracingRouter, openTelemetry: OpenTelemetryOptions?? = nil, maxRetries: Int = 2,
                   baseURL: String = tracingBaseURL, defaultHeaders: Headers? = nil, middleware: [Middleware]? = nil,
                   environment: [String: String] = [:]) throws -> Anthropic
{
    let option: OpenTelemetryOptions? = openTelemetry ?? spans?.option()
    let client = try Anthropic(apiKey: "key", baseURL: baseURL, maxRetries: maxRetries, defaultHeaders: defaultHeaders,
                               transport: router.transport, middleware: middleware, openTelemetry: option, environment: environment)
    client.sleeper = { _ in }
    return client
}

// MARK: - Requests and events

/// `sse`.
func tracingSSE(_ events: [JSONValue]) -> Data {
    var out = ""
    for event in events {
        out += "event: \(event["type"]?.stringValue ?? "")\ndata: \(event.description)\n\n"
    }
    return Data(out.utf8)
}

func tracingMessages(_ messages: [JSONValue]) -> [MessageParam] { messages.map { try! $0.decode(as: MessageParam.self) } }
func tracingBetaMessages(_ messages: [JSONValue]) -> [BetaMessageParam] { messages.map { try! $0.decode(as: BetaMessageParam.self) } }

let tracingHello: [JSONValue] = [["role": "user", "content": "Hello"]]

/// A client with the stable Messages resource.
protocol TracingMessagesClient: BaseClient {
    var messages: MessagesResource { get }
}

extension Anthropic: TracingMessagesClient {}
extension AnthropicBedrock: TracingMessagesClient {}
extension AnthropicVertex: TracingMessagesClient {}

/// `create(client, ...)`: `messages.create` with `REQUEST`, and whatever else the test sends as `extraBody`.
@discardableResult
func tracingCreate(_ client: any TracingMessagesClient, messages: [JSONValue] = tracingHello, maxTokens: Int = 1024, extraHeaders: Headers? = nil,
                   extraBody: Body? = nil) async throws -> Message
{
    try await client.messages.create(maxTokens: maxTokens, messages: tracingMessages(messages), model: "claude-test", extraHeaders: extraHeaders,
                                     extraBody: extraBody)
}

/// `create(client.beta, ...)`.
@discardableResult
func tracingBetaCreate(_ client: Anthropic, messages: [JSONValue] = tracingHello, extraHeaders: Headers? = nil,
                       extraBody: Body? = nil) async throws -> BetaMessage
{
    try await client.beta.messages.create(maxTokens: 1024, messages: tracingBetaMessages(messages), model: "claude-test",
                                          extraHeaders: extraHeaders, extraBody: extraBody)
}

/// `create(client, stream=True)`.
func tracingCreateStream(_ client: any TracingMessagesClient, messages: [JSONValue] = tracingHello, extraBody: Body? = nil) async throws
    -> SSEStream<RawMessageStreamEvent>
{
    try await client.messages.createStreaming(maxTokens: 1024, messages: tracingMessages(messages), model: "claude-test", extraBody: extraBody)
}

func tracingBetaCreateStream(_ client: Anthropic, messages: [JSONValue] = tracingHello) async throws -> SSEStream<BetaRawMessageStreamEvent> {
    try await client.beta.messages.createStreaming(maxTokens: 1024, messages: tracingBetaMessages(messages), model: "claude-test")
}

/// Reads a stream to its end, and gives the type of each event. An error ends the reading, and is returned.
@discardableResult
func tracingDrain<E>(_ stream: SSEStream<E>) async -> (types: [String], error: Error?) {
    var types: [String] = []
    do {
        for try await event in stream {
            let encodable = event as! any Encodable
            types.append((try? JSONValue.from(encodable))?["type"]?.stringValue ?? "?")
        }
        return (types, nil)
    } catch {
        return (types, error)
    }
}

/// `stream_events`.
func tracingStreamEvents(index: JSONValue = 0) -> [JSONValue] {
    var start = tracingMessage
    start["content"] = []
    start["stop_reason"] = nil
    var usage = tracingMessage["usage"]!
    usage["output_tokens"] = 0
    start["usage"] = usage
    return [
        ["type": "message_start", "message": start],
        ["type": "content_block_start", "index": index, "content_block": ["type": "text", "text": ""]],
        ["type": "content_block_delta", "index": index, "delta": ["type": "text_delta", "text": "Hi there"]],
        ["type": "content_block_stop", "index": index],
        ["type": "message_delta", "delta": ["stop_reason": "end_turn"], "usage": ["output_tokens": 5]],
        ["type": "message_stop"],
    ]
}

/// `iteration`.
func tracingIteration(_ type: String, _ input: Int = 10, _ output: Int = 5, _ cacheRead: Int = 0, _ cacheCreation: Int = 0) -> JSONValue {
    ["type": .string(type), "input_tokens": .int(input), "output_tokens": .int(output), "cache_read_input_tokens": .int(cacheRead),
     "cache_creation_input_tokens": .int(cacheCreation)]
}

/// `message_with`.
func tracingMessageWith(iterations: JSONValue) -> JSONValue {
    var message = tracingMessage
    message["usage"]?["iterations"] = iterations
    return message
}

/// `text_part`.
func tracingTextPart(_ content: String) -> JSONValue { ["type": "text", "content": .string(content)] }

/// `chat_message`.
func tracingChatMessage(_ role: String, _ parts: JSONValue...) -> JSONValue { ["role": .string(role), "parts": .array(parts)] }

extension JSONValue {
    /// A copy without `keys` (`without`).
    func without(_ keys: String...) -> JSONValue {
        guard case .object(var o) = self else { return self }
        for k in keys { o.removeValue(forKey: k) }
        return .object(o)
    }

    func with(_ key: String, _ value: JSONValue) -> JSONValue {
        var copy = self
        copy[key] = value
        return copy
    }
}

// MARK: - Tracing doubles

/// `StartAttributes`: keeps the name and the attributes that each span starts with, which is all that a sampler is given.
final class TracingStartAttributes: Sampler, @unchecked Sendable {
    private let lock = NSLock()
    private var _started: [(String, SpanAttributes)] = []
    var started: [(String, SpanAttributes)] { lock.withLock { _started } }

    func shouldSample(parent: SpanContext?, traceID: TraceID, name: String, kind: SpanKind, attributes: SpanAttributes) -> SamplingResult {
        lock.withLock { _started.append((name, attributes)) }
        return SamplingResult(.recordAndSample)
    }

    func startedWith(_ name: String) -> SpanAttributes? { started.first(where: { $0.0 == name })?.1 }
}

/// `StartedSpans`: keeps each span from its start, so that a test can read the attributes of one that has not ended.
final class TracingStartedSpans: SpanProcessor, @unchecked Sendable {
    private let lock = NSLock()
    private var _spans: [RecordingSpan] = []
    var spans: [RecordingSpan] { lock.withLock { _spans } }
    func onStart(_ span: RecordingSpan, parent: TracingContext) { lock.withLock { _spans.append(span) } }
}

/// Answers every request the same way after `delay` (`asyncio.sleep` in a handler).
func tracingRespondAfter(_ seconds: Double, _ reply: @escaping @Sendable (HTTPRequest) -> HTTPResponse) -> TracingReply {
    .custom { request in
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        return reply(request)
    }
}
