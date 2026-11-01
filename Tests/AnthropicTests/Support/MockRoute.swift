import Foundation
import Testing
@testable import Anthropic

let testBaseURL = "http://127.0.0.1:4010"
let testAPIKey = "my-anthropic-api-key"

/// Stands in for the mock API server the upstream suite runs against.
///
/// A route checks that the request hits the expected method and path, optionally round-trips the
/// JSON body through the endpoint's params type, and answers with a sample response.
struct MockRoute: Sendable {
    enum Body: Sendable {
        case json(String)
        case sse(String)
        case binary(String)
        case jsonl(String)
    }

    let method: String
    let path: String
    let body: Body
    let validateBody: (@Sendable (JSONValue) throws -> Void)?

    init(method: String, path: String, json: String, validateBody: (@Sendable (JSONValue) throws -> Void)? = nil) {
        self.method = method
        self.path = path
        self.body = .json(json)
        self.validateBody = validateBody
    }

    init(method: String, path: String, sse: String, validateBody: (@Sendable (JSONValue) throws -> Void)? = nil) {
        self.method = method
        self.path = path
        self.body = .sse(sse)
        self.validateBody = validateBody
    }

    init(method: String, path: String, binary: String, validateBody: (@Sendable (JSONValue) throws -> Void)? = nil) {
        self.method = method
        self.path = path
        self.body = .binary(binary)
        self.validateBody = validateBody
    }

    init(method: String, path: String, jsonl: String, validateBody: (@Sendable (JSONValue) throws -> Void)? = nil) {
        self.method = method
        self.path = path
        self.body = .jsonl(jsonl)
        self.validateBody = validateBody
    }

    /// Whether `requestPath` matches this route's path template.
    func matches(_ requestPath: String) -> Bool {
        let pattern = "^" + NSRegularExpression.escapedPattern(for: path)
            .replacingOccurrences(of: "\\{", with: "{").replacingOccurrences(of: "\\}", with: "}")
            .replacingOccurrences(of: #"\{[A-Za-z0-9_]+\}"#, with: "[^/]+", options: .regularExpression) + "$"
        return requestPath.range(of: pattern, options: .regularExpression) != nil
    }

    func respond(_ request: HTTPRequest) -> HTTPResponse {
        func fail(_ message: String) -> HTTPResponse {
            Issue.record(Comment(rawValue: message))
            return HTTPResponse.json(["error": ["type": "invalid_request_error", "message": .string(message)]], status: 400, for: request)
        }
        guard request.method == method else { return fail("expected method \(method), got \(request.method)") }
        let p = request.url.path
        guard matches(p) else { return fail("path \(p) does not match \(path)") }
        if let validateBody, let body = request.body, !body.isEmpty,
           request.headers["Content-Type"]?.hasPrefix("application/json") ?? false
        {
            do {
                try validateBody(try JSONValue.parse(body))
            } catch {
                return fail("request body failed validation: \(error)")
            }
        }
        switch body {
        case .json(let s):
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Data(s.utf8), request: request)
        case .sse(let s):
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(s.utf8)), request: request)
        case .binary(let s):
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/octet-stream"], stream: chunked(Data(s.utf8)), request: request)
        case .jsonl(let s):
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/x-jsonl"], stream: chunked(Data(s.utf8)), request: request)
        }
    }

    func client() throws -> Anthropic {
        let route = self
        return try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0,
                             transport: MockTransport { request in route.respond(request) }, environment: [:])
    }

    /// Re-encodes a decoded response and checks it against the sample the route served.
    func verifyRoundTrip<T: Encodable>(_ value: T) throws {
        guard case .json(let s) = body else { return }
        let expected = try JSONValue.parse(s)
        let actual = try JSONValue.from(value)
        #expect(actual == expected, "round-tripped response differs from the served sample")
    }

    /// Consumes a stream to completion.
    func drain<S: AsyncSequence>(_ stream: S) async throws {
        var count = 0
        for try await _ in stream { count += 1 }
        #expect(count >= 1)
    }

    /// Decodes a request body as `T` and checks re-encoding it gives back the same JSON: a key the
    /// params type doesn't define, or a value of the wrong shape, fails.
    static func roundTrip<T: Codable>(_ type: T.Type, _ body: JSONValue, dropKeys: [String] = []) throws {
        var body = body
        for k in dropKeys { body[k] = nil }
        if case .object(var o) = body {
            for k in dropKeys { o.removeValue(forKey: k) }
            body = .object(o)
        }
        let decoded: T = try body.decode()
        let reencoded = try JSONValue.from(decoded)
        if reencoded != body {
            throw ValueError("body does not round-trip through \(T.self):\n sent: \(body)\n back: \(reencoded)")
        }
    }
}

/// Delivers a body in small chunks, as a network would.
func chunked(_ data: Data, size: Int = 7) -> ByteStream {
    ByteStream { c in
        var i = 0
        while i < data.count {
            c.yield(data.subdata(in: i..<min(i + size, data.count)))
            i += size
        }
        c.finish()
    }
}

/// A client whose every request fails the test (for argument-validation tests).
func mockClient() throws -> Anthropic {
    try Anthropic(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0, transport: MockTransport { request in
        Issue.record("unexpected request \(request.method) \(request.url)")
        return HTTPResponse.json([:], status: 500, for: request)
    }, environment: [:])
}

/// `pytest.raises(ValueError, match=...)`.
func expectValueError(_ message: String, sourceLocation: SourceLocation = #_sourceLocation, _ body: () async throws -> Void) async throws {
    do {
        try await body()
        Issue.record("expected ValueError(\(message))", sourceLocation: sourceLocation)
    } catch let e as ValueError {
        #expect(e.message.contains(message), sourceLocation: sourceLocation)
    }
}
