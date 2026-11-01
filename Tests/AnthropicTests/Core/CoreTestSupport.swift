import Foundation
import Testing
@testable import Anthropic

/// A thread-safe box, for state shared with `@Sendable` mock handlers and middleware.
final class Locked<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value
    init(_ value: Value) { _value = value }
    var value: Value {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
    func withValue<R>(_ body: (inout Value) throws -> R) rethrows -> R { try lock.withLock { try body(&_value) } }
}

extension Locked where Value == [HTTPRequest] {
    func append(_ r: HTTPRequest) { withValue { $0.append(r) } }
    var last: HTTPRequest? { value.last }
    var count: Int { value.count }
}

/// What `respx_mock` gives the upstream tests: a transport that records every request and answers
/// with a handler.
final class MockServer: @unchecked Sendable {
    let calls = Locked<[HTTPRequest]>([])
    let handler: @Sendable (HTTPRequest, Int) async throws -> HTTPResponse

    init(_ handler: @escaping @Sendable (HTTPRequest, Int) async throws -> HTTPResponse) { self.handler = handler }

    /// Answers every request with the same JSON.
    convenience init(json: JSONValue, status: Int = 200, headers: HTTPHeaders = HTTPHeaders()) {
        self.init { req, _ in HTTPResponse.json(json, status: status, headers: headers, for: req) }
    }

    /// Answers the n-th request with the n-th response (`side_effect=[...]`); the last one repeats.
    convenience init(sequence: [@Sendable (HTTPRequest) throws -> HTTPResponse]) {
        self.init { req, i in try sequence[min(i, sequence.count - 1)](req) }
    }

    var transport: MockTransport {
        MockTransport { [self] req in
            let index: Int = calls.withValue { c in
                c.append(req)
                return c.count - 1
            }
            return try await handler(req, index)
        }
    }

    var callCount: Int { calls.count }
    var lastRequest: HTTPRequest? { calls.last }
    func request(_ i: Int) -> HTTPRequest { calls.value[i] }
}

/// The `async_client` fixture: an `Anthropic` client against `MockServer`, whose retries don't sleep.
func makeTestClient(_ server: MockServer? = nil, apiKey: String? = testAPIKey, authToken: String? = nil, baseURL: String = testBaseURL,
                    maxRetries: Int = DEFAULT_MAX_RETRIES, timeout: Timeout? = nil, defaultHeaders: Headers? = nil,
                    defaultQuery: Query? = nil, middleware: [Middleware]? = nil,
                    environment: [String: String] = [:]) throws -> Anthropic
{
    let server = server ?? MockServer(json: [:])
    let client = try Anthropic(apiKey: apiKey, authToken: authToken, baseURL: baseURL, timeout: timeout, maxRetries: maxRetries,
                               defaultHeaders: defaultHeaders, defaultQuery: defaultQuery, transport: server.transport,
                               middleware: middleware, environment: environment)
    client.sleeper = { _ in }
    return client
}

/// `[{"role": "user", "content": "Hello"}]` (built from JSON, independent of generated case names).
func helloMessages(_ text: String = "Hello") -> [MessageParam] {
    try! JSONValue.array([["role": "user", "content": .string(text)]]).decode()
}

/// `message_body()` from `test_middleware.py`.
func messageBody(model: String = "claude-opus-4-6") -> JSONValue {
    [
        "id": "msg_013Zva2CMHLNnXjNJJKqJ2EF",
        "type": "message",
        "role": "assistant",
        "model": .string(model),
        "content": [["type": "text", "text": "Hello!"]],
        "stop_reason": "end_turn",
        "stop_sequence": nil,
        "usage": ["input_tokens": 10, "output_tokens": 5],
    ]
}

func errorBody(type: String, message: String) -> JSONValue {
    ["type": "error", "error": ["type": .string(type), "message": .string(message)]]
}

extension HTTPResponse {
    /// `httpx2.Response(status)` with an empty body.
    static func empty(_ status: Int, headers: HTTPHeaders = HTTPHeaders(), for request: HTTPRequest) -> HTTPResponse {
        HTTPResponse(statusCode: status, headers: headers, body: Data(), request: request)
    }
}

/// `FinalRequestOptions(method=..., url=...)` built by `client._build_request`.
func buildRequest(_ client: BaseClient, _ options: FinalRequestOptions) throws -> HTTPRequest {
    try client.buildRequest(client.copyAndPrepare(options))
}

/// `dict(url.params)` of a built request.
func queryDict(_ request: HTTPRequest) -> [String: String] {
    var d: [String: String] = [:]
    for item in request.queryItems { d[item.name] = item.value ?? "" }
    return d
}

/// `_get_params(client)`.
func defaultParams(_ client: BaseClient) throws -> [String: String] {
    queryDict(try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo")))
}

/// The JSON body of a recorded request.
func bodyJSON(_ request: HTTPRequest?) -> JSONValue? { request?.jsonBody }

/// Builds a streamed HTTP response from chunks, counting how often it's closed (`tests/utils.Body`).
final class CountingBody: @unchecked Sendable {
    let closes = Locked(0)
    let chunks: [Data]
    init(_ chunks: [Data]) { self.chunks = chunks }
    init(strings: [String]) { self.chunks = strings.map { Data($0.utf8) } }

    func response(status: Int = 200, headers: HTTPHeaders = ["content-type": "text/event-stream"], for request: HTTPRequest) -> HTTPResponse {
        let chunks = self.chunks
        let stream = ByteStream { c in
            for chunk in chunks { c.yield(chunk) }
            c.finish()
        }
        return HTTPResponse(statusCode: status, headers: headers, stream: stream, request: request,
                            onClose: { [closes] in closes.withValue { $0 += 1 } })
    }

    var closeCount: Int { closes.value }
}

/// `a is b` for metatypes (`#expect` can't compare `Any.Type` values directly).
func sameType(_ a: Any.Type, _ b: Any.Type) -> Bool { ObjectIdentifier(a) == ObjectIdentifier(b) }

let dummyRequest = HTTPRequest(method: "GET", url: URL(string: "https://example.com")!)

/// Expects `body` to throw an error of type `E`, returning it.
@discardableResult
func expectThrows<E: Error>(_ errorType: E.Type, sourceLocation: SourceLocation = #_sourceLocation, _ body: () async throws -> Void) async -> E? {
    do {
        try await body()
        Issue.record("expected \(E.self) to be thrown", sourceLocation: sourceLocation)
        return nil
    } catch let e as E {
        return e
    } catch {
        Issue.record("expected \(E.self), got \(Swift.type(of: error)): \(error)", sourceLocation: sourceLocation)
        return nil
    }
}
