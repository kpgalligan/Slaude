import Foundation
import Testing
@testable import Anthropic

/// `tests/lib/streaming/helpers.get_response`: the fixture's lines, each terminated by `\n`.
func getResponse(_ name: String) -> String {
    linesWithNewlines(fixture(name))
}

func linesWithNewlines(_ s: String) -> String {
    var lines = s.components(separatedBy: "\n")
    if lines.last == "" { lines.removeLast() }
    return lines.map { $0 + "\n" }.joined()
}

/// One canned answer of a `LibMockServer` (respx's `side_effect` entries).
enum MockReply: Sendable {
    case sse(String, status: Int = 200, headers: [String: String] = [:])
    case json(JSONValue, status: Int = 200, headers: [String: String] = [:])
    case text(String, status: Int = 200, headers: [String: String] = [:])
    case fail(any Error & Sendable)
    case handler(@Sendable (HTTPRequest) -> HTTPResponse)
}

/// A transport that answers requests with a queue of replies and records every request
/// (`respx_mock` with `side_effect=[...]`).
final class LibMockServer: @unchecked Sendable {
    private let lock = NSLock()
    private var replies: [MockReply]
    private let repeatLast: Bool
    private(set) var requestsStorage: [HTTPRequest] = []

    init(_ replies: [MockReply], repeatLast: Bool = false) {
        self.replies = replies
        self.repeatLast = repeatLast
    }

    var requests: [HTTPRequest] { lock.withLock { requestsStorage } }
    var callCount: Int { requests.count }
    /// The JSON bodies of the requests made so far.
    var bodies: [JSONValue] { requests.map { $0.jsonBody ?? .null } }
    func header(_ name: String) -> [String?] { requests.map { $0.headers[name] } }

    var transport: MockTransport {
        MockTransport { [self] request in try self.respond(request) }
    }

    func respond(_ request: HTTPRequest) throws -> HTTPResponse {
        let reply: MockReply? = lock.withLock {
            requestsStorage.append(request)
            if replies.isEmpty { return nil }
            if replies.count == 1 && repeatLast { return replies[0] }
            return replies.removeFirst()
        }
        guard let reply else {
            Issue.record("unexpected request \(request.method) \(request.url)")
            return HTTPResponse.json(["error": "no reply"], status: 500, for: request)
        }
        func headers(_ h: [String: String], _ contentType: String) -> HTTPHeaders {
            var out = HTTPHeaders(h)
            if out["content-type"] == nil { out["content-type"] = contentType }
            return out
        }
        switch reply {
        case .sse(let body, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, "text/event-stream"), stream: chunked(Data(body.utf8), size: 64), request: request)
        case .json(let value, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, "application/json"), body: try JSONValue.serialize(value), request: request)
        case .text(let body, let status, let h):
            return HTTPResponse(statusCode: status, headers: headers(h, "text/plain"), stream: chunked(Data(body.utf8), size: 64), request: request)
        case .fail(let error):
            throw error
        case .handler(let f):
            return f(request)
        }
    }

    func client(middleware: [Middleware]? = nil, maxRetries: Int = 0) throws -> Anthropic {
        try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: maxRetries, transport: transport, middleware: middleware,
                      environment: [:])
    }
}

/// Records what a `BetaRefusalFallbackMiddleware` logs (pytest's `caplog`).
final class LogRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var records: [(MiddlewareLogger.Level, String)] = []

    var logger: MiddlewareLogger { MiddlewareLogger { [self] level, message in self.lock.withLock { self.records.append((level, message)) } } }

    var all: [String] { lock.withLock { records.map(\.1) } }
    var warnings: [String] { lock.withLock { records.filter { $0.0 == .warning }.map(\.1) } }
    var errors: [String] { lock.withLock { records.filter { $0.0 >= .error }.map(\.1) } }
    /// `resend_warnings(caplog)`.
    var resendWarnings: [String] { all.filter { $0.contains("retrying without `speed`") } }
}

/// A user message built from its wire JSON.
func userMessage(_ content: JSONValue) -> MessageParam {
    try! JSONValue.object(["role": "user", "content": content]).decode(as: MessageParam.self)
}

func betaMessageParam(_ json: JSONValue) -> BetaMessageParam {
    try! json.decode(as: BetaMessageParam.self)
}

func betaUserMessage(_ content: JSONValue) -> BetaMessageParam {
    betaMessageParam(["role": "user", "content": content])
}

/// The JSON of an encodable value with every `null` removed (pydantic's `exclude_none=True`).
func jsonExcludingNone<T: Encodable>(_ value: T) throws -> JSONValue {
    func strip(_ v: JSONValue) -> JSONValue {
        switch v {
        case .object(let o): return .object(o.filter { !$0.value.isNull }.mapValues(strip))
        case .array(let a): return .array(a.map(strip))
        default: return v
        }
    }
    return strip(try JSONValue.from(value))
}

/// The stored property names of a value (`get_model_fields`), via reflection.
func fieldNames(_ value: Any) -> Set<String> {
    Set(Mirror(reflecting: value).children.compactMap(\.label))
}

/// Collects an async sequence.
func collect<S: AsyncSequence>(_ s: S) async throws -> [S.Element] {
    var out: [S.Element] = []
    for try await e in s { out.append(e) }
    return out
}

/// Records `AnthropicWarnings` while `body` runs.
func recordingWarnings(_ body: () async throws -> Void) async rethrows -> [String] {
    let box = WarningBox()
    AnthropicWarnings.setHandler { message, _ in box.append(message) }
    defer {
        AnthropicWarnings.setHandler { message, category in
            FileHandle.standardError.write(Data("\(category.rawValue): \(message)\n".utf8))
        }
    }
    try await body()
    return box.messages
}

final class WarningBox: @unchecked Sendable {
    private let lock = NSLock()
    private var _messages: [String] = []
    func append(_ m: String) { lock.withLock { _messages.append(m) } }
    var messages: [String] { lock.withLock { _messages } }
}
