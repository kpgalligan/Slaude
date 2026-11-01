import Foundation
import Testing
@testable import Anthropic

/// Records every request a mock transport receives (the counterpart of `respx_mock.calls`).
final class RequestRecorder: @unchecked Sendable {
    private let lock = NSLock()
    private var _requests: [HTTPRequest] = []
    let handler: @Sendable (HTTPRequest, Int) async throws -> HTTPResponse

    /// - Parameter handler: Answers a request; gets the request and its 0-based index.
    init(_ handler: @escaping @Sendable (HTTPRequest, Int) async throws -> HTTPResponse = { req, _ in platformMessageResponse(req) }) {
        self.handler = handler
    }

    /// Answers with the given responses in order (`side_effect=[...]`).
    convenience init(sequence: [@Sendable (HTTPRequest) -> HTTPResponse]) {
        self.init { req, i in sequence[min(i, sequence.count - 1)](req) }
    }

    var requests: [HTTPRequest] { lock.withLock { _requests } }
    var count: Int { requests.count }
    var urls: [String] { requests.map { $0.url.absoluteString } }

    var transport: MockTransport {
        MockTransport { [self] request in
            let index: Int = lock.withLock {
                _requests.append(request)
                return _requests.count - 1
            }
            return try await handler(request, index)
        }
    }
}

let platformMessageJSON = #"{"id": "msg_01", "type": "message", "role": "assistant", "model": "claude", "content": [{"type": "text", "text": "Hello"}], "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 1, "output_tokens": 1}}"#

/// A valid Messages response (the Python tests answer `{"foo": "bar"}`, which only loose
/// validation accepts; the Swift client always decodes).
@Sendable func platformMessageResponse(_ request: HTTPRequest) -> HTTPResponse {
    HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Data(platformMessageJSON.utf8), request: request)
}

@Sendable func platformJSON(_ json: String, status: Int = 200, headers: HTTPHeaders = HTTPHeaders()) -> @Sendable (HTTPRequest) -> HTTPResponse {
    { request in
        var h = headers
        h["content-type"] = "application/json"
        return HTTPResponse(statusCode: status, headers: h, body: Data(json.utf8), request: request)
    }
}

/// `[{"role": "user", "content": text}]` as `MessageParam`s (decoded, so the test does not depend
/// on generated union case names).
func userMessages(_ text: String) -> [MessageParam] {
    [try! JSONValue.object(["role": "user", "content": .string(text)]).decode()]
}

func betaUserMessages(_ text: String) -> [BetaMessageParam] {
    [try! JSONValue.object(["role": "user", "content": .string(text)]).decode()]
}

/// An isolated environment: no ambient credentials, config files or instance metadata.
func isolatedEnv(_ extra: [String: String] = [:]) -> [String: String] {
    var env = ["HOME": "/nonexistent-slaude-home", "AWS_EC2_METADATA_DISABLED": "true",
               "AWS_CONFIG_FILE": "/nonexistent-slaude-home/config", "AWS_SHARED_CREDENTIALS_FILE": "/nonexistent-slaude-home/credentials"]
    env.merge(extra) { $1 }
    return env
}

extension HTTPRequest {
    var json: JSONValue { jsonBody ?? .null }
}

/// Expects `body` to throw an error whose message contains / matches `pattern` (`pytest.raises(..., match=)`).
func expectThrows<E: Error>(_ errorType: E.Type, matching pattern: String, sourceLocation: SourceLocation = #_sourceLocation,
                            _ body: () async throws -> Void) async
{
    do {
        try await body()
        Issue.record("expected \(E.self) matching \(pattern)", sourceLocation: sourceLocation)
    } catch let e as E {
        let message = String(describing: e)
        #expect(message.range(of: pattern, options: .regularExpression) != nil, "\(message) does not match \(pattern)",
                sourceLocation: sourceLocation)
    } catch {
        Issue.record("expected \(E.self), got \(type(of: error)): \(error)", sourceLocation: sourceLocation)
    }
}

/// Writes a temporary file and returns its path.
func writeTempFile(_ contents: String, name: String = UUID().uuidString) -> String {
    let dir = NSTemporaryDirectory() + "slaude-platform-tests-" + UUID().uuidString
    try! FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
    let path = dir + "/" + name
    try! contents.write(toFile: path, atomically: true, encoding: .utf8)
    return path
}
