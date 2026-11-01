// Port of tests/test_middleware.py (the async variants, plus the sync-only tests run against the
// Swift client). See docs/porting/core-tests.md for the tests that have no Swift meaning.

import Foundation
import Testing
@testable import Anthropic

// MARK: - Middleware used by the tests

final class RecordingMiddleware: Middleware, @unchecked Sendable {
    let name: String
    let events: Locked<[String]>
    let requests = Locked<[APIRequest]>([])
    let results = Locked<[RawAPIResponse]>([])

    init(_ name: String = "middleware", events: Locked<[String]>? = nil) {
        self.name = name
        self.events = events ?? Locked([])
    }

    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        requests.withValue { $0.append(request) }
        events.withValue { $0.append("\(name):enter") }
        let result = try await next(request)
        events.withValue { $0.append("\(name):exit") }
        results.withValue { $0.append(result) }
        return result
    }
}

struct MutateBody: Middleware {
    let changes: [String: JSONValue]
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        guard case .object(var body)? = request.json else { throw ValueError("expected an object body") }
        for (k, v) in changes { body[k] = v }
        return try await next(request.copy(body: .object(body)))
    }
}

/// Retries with the same request after setting `key` when the response has `status`.
struct RetryWithChange: Middleware {
    let status: Int
    let key: String
    let value: JSONValue
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        let response = try await next(request)
        if response.statusCode == status {
            guard case .object(var body)? = request.json else { throw ValueError("expected an object body") }
            body[key] = value
            return try await next(request.copy(body: .object(body)))
        }
        return response
    }
}

/// `ModelFallback`.
func modelFallback(_ model: String) -> RetryWithChange { RetryWithChange(status: 529, key: "model", value: .string(model)) }

/// `ShrinkMaxTokensOnTooLarge`.
func shrinkMaxTokensOnTooLarge(_ maxTokens: Int) -> RetryWithChange { RetryWithChange(status: 413, key: "max_tokens", value: .int(maxTokens)) }

final class ShortCircuit: Middleware, @unchecked Sendable {
    let message: Message
    let requests = Locked<[APIRequest]>([])
    init(_ message: Message) { self.message = message }
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        requests.withValue { $0.append(request) }
        return RawAPIResponse.shortCircuit(message, for: request)
    }
}

/// Records the `retriesTaken` and response status of every attempt the chain runs for.
final class AttemptRecorder: Middleware, @unchecked Sendable {
    let attempts = Locked<[Int]>([])
    let statuses = Locked<[Int]>([])
    let errors = Locked<[String]>([])
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        attempts.withValue { $0.append(request.retriesTaken) }
        do {
            let response = try await next(request)
            statuses.withValue { $0.append(response.statusCode) }
            return response
        } catch {
            errors.withValue { $0.append("\(error)") }
            throw error
        }
    }
}

struct Boom: Error, ChainedError, CustomStringConvertible {
    let message: String
    var cause: (any Error)? = nil
    var description: String { message }
}

struct Exploding: Middleware {
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        throw Boom(message: "middleware failure")
    }
}

/// Records the response returned by `next` and passes it through.
final class InspectResponse: Middleware, @unchecked Sendable {
    let responses = Locked<[RawAPIResponse]>([])
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        let response = try await next(request)
        responses.withValue { $0.append(response) }
        return response
    }
}

/// Parses the response inside the middleware before returning it.
final class ParseInMiddleware: Middleware, @unchecked Sendable {
    let parsed = Locked<[Message]>([])
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        let response = try await next(request)
        let message = try await response.parse(as: Message.self)
        parsed.withValue { $0.append(message) }
        return response
    }
}

/// Retries the same request once on a 5xx error, recording the request headers seen each time.
final class RetryOnInternalServerError: Middleware, @unchecked Sendable {
    let headersSeen = Locked<[Headers]>([])
    func handle(_ request: APIRequest, next: @escaping CallNext) async throws -> RawAPIResponse {
        headersSeen.withValue { $0.append(request.headers) }
        var result = try await next(request)
        if result.statusCode >= 500 {
            headersSeen.withValue { $0.append(request.headers) }
            result = try await next(request)
        }
        return result
    }
}

/// A middleware that relies on the protocol's default (pass-through) `handle`.
struct DefaultMiddleware: Middleware {}

func passThroughMiddleware() -> MiddlewareFunction { MiddlewareFunction(name: "passthrough") { req, next in try await next(req) } }

func createHello(_ client: Anthropic) async throws -> Message {
    try await client.messages.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
}

func shortCircuitMessage(model: String = "claude-opus-4-6") -> Message {
    var body = messageBody(model: model)
    body["model"] = .string(model)
    return try! body.decode()
}

// MARK: - TestAPIRequest

@Suite("APIRequest (test_middleware.py)")
struct APIRequestTests {
    @Test func properties() {
        let options = FinalRequestOptions(method: "post", url: "/v1/messages", params: [("beta", "true")], headers: ["x-foo": "bar"],
                                          maxRetries: 3, timeout: 10.0, jsonData: ["model": "claude-opus-4-6", "max_tokens": 16])
        let request = APIRequest(options: options, castTo: Message.self, stream: false)
        #expect(request.method == "post")
        #expect(request.url == "/v1/messages")
        #expect(request.json == ["model": "claude-opus-4-6", "max_tokens": 16])
        #expect(request.headers == ["x-foo": "bar"])
        #expect(request.queryParams == ["beta": "true"])
        #expect(request.timeout == Timeout(10.0))
        #expect(request.maxRetries == 3)
        #expect(sameType(request.castTo, Message.self))
        #expect(request.stream == false)
        #expect(request.options.url == options.url)
    }

    @Test func headersDefaultToEmptyMapping() {
        let request = APIRequest(options: FinalRequestOptions(method: "get", url: "/v1/models"), castTo: Message.self)
        #expect(request.headers == [:])
    }

    @Test func copyReturnsNewInstanceWithChanges() {
        let options = FinalRequestOptions(method: "post", url: "/v1/messages", maxRetries: 3,
                                          jsonData: ["model": "claude-opus-4-6", "max_tokens": 16])
        let request = APIRequest(options: options, castTo: Message.self)
        let copied = request.copy(headers: ["x-trace-id": "123"], body: .some(["model": "claude-sonnet-5-5"]))
        #expect(copied.json == ["model": "claude-sonnet-5-5"])
        #expect(copied.headers == ["x-trace-id": "123"])
        #expect(copied.method == "post")
        #expect(copied.url == "/v1/messages")
        #expect(sameType(copied.castTo, Message.self))
        #expect(copied.stream == false)
        // the original request is untouched
        #expect(request.json == ["model": "claude-opus-4-6", "max_tokens": 16])
        #expect(request.headers == [:])
    }

    @Test func retriesTakenDefaultsToZeroAndCopyPreservesIt() {
        let options = FinalRequestOptions(method: "post", url: "/v1/messages")
        #expect(APIRequest(options: options, castTo: Message.self).retriesTaken == 0)
        let attempt = APIRequest(options: options, castTo: Message.self, retriesTaken: 2)
        #expect(attempt.copy(headers: ["x-trace-id": "123"]).retriesTaken == 2)
    }

    @Test func copyDeepCopiesBody() {
        let body: JSONValue = ["model": "claude-opus-4-6", "messages": [["role": "user", "content": "hi"]]]
        let request = APIRequest(options: FinalRequestOptions(method: "post", url: "/v1/messages", jsonData: body))
        var copied = request.copy()
        copied.options.jsonData?["messages"] = [["role": "user", "content": "changed"]]
        #expect(request.json == body)
    }

    @Test func copyDoesNotDeepCopyFileObjects() {
        let file = FileUpload(data: Data("file contents".utf8), filename: "upload.txt")
        let options = FinalRequestOptions(method: "post", url: "/v1/files?beta=true", files: [("file", file)], jsonData: ["purpose": "test"])
        let request = APIRequest(options: options)
        var copied = request.copy(headers: ["x-trace-id": "123"])
        #expect(copied.options.files?.first?.1 == file)
        copied.options.jsonData?["purpose"] = "changed"
        #expect(request.json == ["purpose": "test"])
        #expect(request.headers == [:])
    }

    @Test func copyHeaderMutationsDoNotAffectOriginal() {
        let options = FinalRequestOptions(method: "post", url: "/v1/messages", headers: ["x-foo": "bar"], jsonData: ["model": "claude-opus-4-6"])
        let request = APIRequest(options: options)
        var copied = request.copy()
        copied.options.headers?["x-added"] = "value"
        copied.options.headers?["x-foo"] = "changed"
        #expect(request.headers == ["x-foo": "bar"])
    }
}

// MARK: - TestDefaultMiddleware

@Suite("Default middleware (test_middleware.py)")
struct DefaultMiddlewareTests {
    @Test func handleAsyncIsPassthrough() async throws {
        let request = APIRequest(options: FinalRequestOptions(method: "post", url: "/v1/messages"), castTo: Message.self)
        let sentinel = RawAPIResponse.shortCircuit("sentinel", for: request)
        let seen = Locked<[String]>([])
        let result = try await DefaultMiddleware().handle(request) { req in
            seen.withValue { $0.append(req.url) }
            return sentinel
        }
        #expect(result === sentinel)
        #expect(seen.value == ["/v1/messages"])
    }
}

// MARK: - TestMiddlewareValidation

@Suite("Middleware validation (test_middleware.py)")
struct MiddlewareValidationTests {
    @Test func asyncCallableObjectHandlesRequests() async throws {
        let middleware = RecordingMiddleware()
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [middleware])
        #expect(client.middleware.count == 1)
        _ = try await createHello(client)
        #expect(middleware.requests.value.count == 1)
    }
}

// MARK: - TestAsyncMiddleware

@Suite("Async middleware (test_middleware.py)")
struct AsyncMiddlewareTests {
    @Test func middlewareSeesRequestAndReturnsResponse() async throws {
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [recorder])
        let message = try await createHello(client)
        #expect(recorder.requests.value.count == 1)
        let request = recorder.requests.value[0]
        #expect(request.method == "post")
        #expect(request.url == "/v1/messages")
        #expect(sameType(request.castTo, Message.self))
        #expect(request.stream == false)
        #expect(request.json?["model"] == "claude-opus-4-6")
        // the middleware itself saw the response wrapper; the caller's value is parsed from it
        #expect(recorder.results.value.count == 1)
        let response = recorder.results.value[0]
        #expect(try await response.parse(as: Message.self) == message)
        #expect(response.cachedValue(as: Message.self) == message)
    }

    @Test func middlewareSeesPreparedBody() async throws {
        let server = MockServer(json: messageBody())
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(server, middleware: [recorder])
        _ = try await client.messages.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6",
                                             extraQuery: ["r": 1], extraBody: ["zzz": 1])
        // by the time middleware runs, `extra_body` / `extra_query` have been merged in
        #expect(recorder.requests.value.count == 1)
        let request = recorder.requests.value[0]
        #expect(request.json?["zzz"] == 1)
        #expect(request.json?["system"] == nil)
        #expect(request.queryParams == ["r": 1])
        #expect(server.callCount == 1)
        #expect(bodyJSON(server.lastRequest)?["zzz"] == 1)
        #expect(server.lastRequest?.query("r") == "1")
    }

    @Test func middlewareOrdering() async throws {
        let events = Locked<[String]>([])
        let outer = RecordingMiddleware("outer", events: events)
        let inner = RecordingMiddleware("inner", events: events)
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [outer, inner])
        _ = try await createHello(client)
        #expect(events.value == ["outer:enter", "inner:enter", "inner:exit", "outer:exit"])
    }

    @Test func requestMutationChangesOutgoingRequest() async throws {
        let server = MockServer(json: messageBody())
        let client = try makeTestClient(server, middleware: [MutateBody(changes: ["model": "claude-sonnet-5-5", "max_tokens": 4096])])
        _ = try await createHello(client)
        #expect(server.callCount == 1)
        #expect(bodyJSON(server.lastRequest)?["model"] == "claude-sonnet-5-5")
        #expect(bodyJSON(server.lastRequest)?["max_tokens"] == 4096)
    }

    @Test func fallbackOnOverloadedError() async throws {
        let server = MockServer(sequence: [
            { .json(errorBody(type: "overloaded_error", message: "Overloaded"), status: 529, for: $0) },
            { .json(messageBody(model: "claude-sonnet-5-5"), for: $0) },
        ])
        let client = try makeTestClient(server, maxRetries: 0, middleware: [modelFallback("claude-sonnet-5-5")])
        let message = try await createHello(client)
        #expect(message.model.rawValue == "claude-sonnet-5-5")
        #expect(server.callCount == 2)
        #expect(bodyJSON(server.request(0))?["model"] == "claude-opus-4-6")
        #expect(bodyJSON(server.request(1))?["model"] == "claude-sonnet-5-5")
    }

    /// Sync-only upstream (`test_retry_with_modified_params_on_request_too_large`).
    @Test func retryWithModifiedParamsOnRequestTooLarge() async throws {
        let server = MockServer(sequence: [
            { .json(errorBody(type: "invalid_request_error", message: "Request too large"), status: 413, for: $0) },
            { .json(messageBody(), for: $0) },
        ])
        let client = try makeTestClient(server, middleware: [shrinkMaxTokensOnTooLarge(256)])
        _ = try await client.messages.create(maxTokens: 4096, messages: helloMessages(), model: "claude-opus-4-6")
        #expect(server.callCount == 2)
        #expect(bodyJSON(server.request(0))?["max_tokens"] == 4096)
        #expect(bodyJSON(server.request(1))?["max_tokens"] == 256)
    }

    @Test func shortCircuitSkipsHTTPRequest() async throws {
        let server = MockServer(json: messageBody())
        let cached = shortCircuitMessage(model: "claude-cached")
        let middleware = ShortCircuit(cached)
        let client = try makeTestClient(server, middleware: [middleware])
        let message = try await createHello(client)
        #expect(message == cached)
        #expect(middleware.requests.value.count == 1)
        #expect(server.callCount == 0)
    }

    @Test func shortCircuitWithRawResponse() async throws {
        let server = MockServer(json: messageBody())
        let cached = shortCircuitMessage(model: "claude-cached")
        let client = try makeTestClient(server, middleware: [ShortCircuit(cached)])
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
        #expect(try await response.parse() == cached)
        #expect(server.callCount == 0)
    }

    @Test func shortCircuitWithTheWrongTypeIsReported() async throws {
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [
            MiddlewareFunction { req, _ in RawAPIResponse.shortCircuit("not a message", for: req) },
        ])
        await expectThrows(ArgumentTypeError.self) { _ = try await createHello(client) }
    }

    @Test func functionalMiddleware() async throws {
        let server = MockServer(json: messageBody())
        let addTraceHeader = MiddlewareFunction(name: "add_trace_header") { request, next in
            var headers = request.headers
            headers["x-trace-id"] = "abc-123"
            return try await next(request.copy(headers: headers))
        }
        let client = try makeTestClient(server, middleware: [addTraceHeader])
        _ = try await createHello(client)
        #expect(server.request(0).headers["x-trace-id"] == "abc-123")
    }

    @Test func callNextReturnsAPIResponse() async throws {
        let server = MockServer(json: messageBody(), headers: ["x-custom-header": "custom-value"])
        let middleware = InspectResponse()
        let client = try makeTestClient(server, middleware: [middleware])
        _ = try await createHello(client)
        #expect(middleware.responses.value.count == 1)
        let response = middleware.responses.value[0]
        #expect(response.statusCode == 200)
        #expect(response.headers["x-custom-header"] == "custom-value")
    }

    @Test func parseInMiddlewareSharesParseCache() async throws {
        let middleware = ParseInMiddleware()
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [middleware])
        let message = try await createHello(client)
        // the value parsed inside the middleware is the value the caller receives
        #expect(middleware.parsed.value == [message])
    }

    @Test func withRawResponseFlowsThroughMiddleware() async throws {
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [recorder])
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
        _ = try await response.parse()
        #expect(recorder.requests.value.count == 1)
        #expect(recorder.requests.value[0].url == "/v1/messages")
    }

    @Test func withRawResponseMiddlewareSeesAPIResponse() async throws {
        let middleware = InspectResponse()
        let client = try makeTestClient(MockServer(json: messageBody(), headers: ["x-custom-header": "custom-value"]), middleware: [middleware])
        let response = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
        #expect(middleware.responses.value.count == 1)
        #expect(middleware.responses.value[0].http === response.http)
        #expect(response.statusCode == 200)
        #expect(response.headers["x-custom-header"] == "custom-value")
        let message = try await response.parse()
        #expect(message.id == "msg_013Zva2CMHLNnXjNJJKqJ2EF")
    }

    @Test func withStreamingResponseMiddlewareSeesAPIResponse() async throws {
        let middleware = InspectResponse()
        let client = try makeTestClient(MockServer(json: messageBody(), headers: ["x-custom-header": "custom-value"]), middleware: [middleware])
        try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6") { response in
            #expect(middleware.responses.value.count == 1)
            #expect(middleware.responses.value[0].http === response.http)
            #expect(response.statusCode == 200)
            #expect(response.headers["x-custom-header"] == "custom-value")
            let message = try await response.parse()
            #expect(message.id == "msg_013Zva2CMHLNnXjNJJKqJ2EF")
        }
    }

    @Test func responseWrapperCastToIsReturnedUnparsed() async throws {
        let server = MockServer { req, _ in .text("file contents", for: req) }
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(server, middleware: [recorder])
        // `download()` asks for the binary wrapper itself; the chain hands it back unparsed
        let file = try await client.beta.files.download("file_id")
        #expect(try await file.read() == Data("file contents".utf8))
        #expect(recorder.requests.value.count == 1)
        #expect(sameType(recorder.requests.value[0].castTo, BinaryResponse.self))
        #expect(recorder.results.value.count == 1)
        #expect(recorder.results.value[0].http === file.response)
    }

    @Test func fallbackRetrySeesIdenticalRequestState() async throws {
        let server = MockServer(sequence: [
            { .json(errorBody(type: "api_error", message: "Service unavailable"), status: 503, for: $0) },
            { .json(messageBody(), for: $0) },
        ])
        let middleware = RetryOnInternalServerError()
        let client = try makeTestClient(server, maxRetries: 0, middleware: [middleware])
        _ = try await createHello(client)
        #expect(server.callCount == 2)
        // both invocations observed identical request state
        #expect(middleware.headersSeen.value.count == 2)
        #expect(middleware.headersSeen.value[0] == middleware.headersSeen.value[1])
        // and both outgoing requests carried an identical body
        #expect(bodyJSON(server.request(0)) == bodyJSON(server.request(1)))
    }

    @Test func middlewareOrderingAcrossSequentialRequests() async throws {
        let events = Locked<[String]>([])
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [
            RecordingMiddleware("outer", events: events), RecordingMiddleware("inner", events: events),
        ])
        for _ in 0..<3 { _ = try await createHello(client) }
        #expect(events.value == Array(repeating: ["outer:enter", "inner:enter", "inner:exit", "outer:exit"], count: 3).flatMap { $0 })
    }

    @Test func middlewareExceptionPropagates() async throws {
        let server = MockServer(json: messageBody())
        let client = try makeTestClient(server, middleware: [Exploding()])
        let error = await expectThrows(Boom.self) { _ = try await createHello(client) }
        #expect(error?.message == "middleware failure")
        #expect(server.callCount == 0)
    }

    @Test func middlewareRunsPerAttempt() async throws {
        let server = MockServer(sequence: [{ .empty(500, for: $0) }, { .empty(500, for: $0) }, { .json(messageBody(), for: $0) }])
        let recorder = AttemptRecorder()
        let client = try makeTestClient(server, maxRetries: 2, middleware: [recorder])
        _ = try await createHello(client)
        // the chain ran once per HTTP attempt, seeing each failure's response
        #expect(recorder.attempts.value == [0, 1, 2])
        #expect(recorder.statuses.value == [500, 500, 200])
        #expect(recorder.errors.value == [])
        #expect(server.callCount == 3)
    }

    @Test func retryableErrorIsRetriedThenPropagates() async throws {
        let server = MockServer(json: messageBody())
        let attempts = Locked<[Int]>([])
        let giveUp = MiddlewareFunction(name: "give_up") { request, _ in
            attempts.withValue { $0.append(request.retriesTaken) }
            throw RetryableError("try again")
        }
        let client = try makeTestClient(server, maxRetries: 2, middleware: [giveUp])
        await expectThrows(RetryableError.self) { _ = try await createHello(client) }
        #expect(attempts.value == [0, 1, 2])
        #expect(server.callCount == 0)
    }

    /// Sync-only upstream (`test_error_with_retryable_cause_is_retried`).
    @Test func errorWithRetryableCauseIsRetried() async throws {
        struct ConnectError: Error {}
        let server = MockServer(sequence: [{ _ in throw ConnectError() }, { .json(messageBody(), for: $0) }])
        let wrapErrors = MiddlewareFunction(name: "wrap_errors") { request, next in
            do {
                return try await next(request)
            } catch let err as APIConnectionError {
                // wrapping a retryable failure with a cause keeps it on the retry path
                throw Boom(message: "wrapped", cause: err)
            }
        }
        let client = try makeTestClient(server, maxRetries: 2, middleware: [wrapErrors])
        _ = try await createHello(client)
        #expect(server.callCount == 2)
    }

    /// Sync-only upstream (`test_returned_error_response_raises_typed_error_for_caller`).
    @Test func returnedErrorResponseRaisesTypedErrorForCaller() async throws {
        let server = MockServer(json: errorBody(type: "invalid_request_error", message: "bad request"), status: 400)
        let recorder = AttemptRecorder()
        let client = try makeTestClient(server, maxRetries: 2, middleware: [recorder])
        await expectThrows(BadRequestError.self) { _ = try await createHello(client) }
        // middleware saw the error response rather than an error; the SDK threw the typed error
        // for the caller, without retrying the 400
        #expect(recorder.statuses.value == [400])
        #expect(recorder.errors.value == [])
        #expect(server.callCount == 1)
    }

    /// Sync-only upstream (`test_request_modifications_do_not_persist_across_attempts`).
    @Test func requestModificationsDoNotPersistAcrossAttempts() async throws {
        let server = MockServer(sequence: [{ .empty(500, for: $0) }, { .json(messageBody(), for: $0) }])
        let leaked = Locked(false)
        let tagAttempt = MiddlewareFunction(name: "tag_attempt") { request, next in
            // each attempt starts from the original request, not the previous attempt's copy
            if request.headers["x-attempt"] != nil { leaked.value = true }
            var headers = request.headers
            headers["x-attempt"] = .value(String(request.retriesTaken))
            return try await next(request.copy(headers: headers))
        }
        let client = try makeTestClient(server, maxRetries: 2, middleware: [tagAttempt])
        _ = try await createHello(client)
        #expect(leaked.value == false)
        #expect(server.request(0).headers["x-attempt"] == "0")
        #expect(server.request(1).headers["x-attempt"] == "1")
    }

    /// Sync-only upstream (`test_streaming_flows_through_middleware`).
    @Test func streamingFlowsThroughMiddleware() async throws {
        let server = MockServer { req, _ in HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], body: Data(), request: req) }
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(server, middleware: [recorder])
        let stream = try await client.messages.createStreaming(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
        #expect(recorder.requests.value.count == 1)
        #expect(recorder.requests.value[0].stream == true)
        #expect(sameType(recorder.requests.value[0].castTo, SSEStream<RawMessageStreamEvent>.self))
        // the middleware sees the response wrapper, not the stream
        #expect(recorder.results.value[0].http === stream.response)
        stream.close()
    }

    /// Sync-only upstream (`test_streaming_error_response_is_visible_to_middleware`).
    @Test func streamingErrorResponseIsVisibleToMiddleware() async throws {
        let server = MockServer(sequence: [
            { .json(errorBody(type: "overloaded_error", message: "Overloaded"), status: 529, for: $0) },
            { HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], body: Data(), request: $0) },
        ])
        let client = try makeTestClient(server, maxRetries: 0, middleware: [modelFallback("claude-sonnet-5-5")])
        let stream = try await client.messages.createStreaming(maxTokens: 1024, messages: helloMessages(), model: "claude-opus-4-6")
        #expect(server.callCount == 2)
        #expect(bodyJSON(server.request(1))?["model"] == "claude-sonnet-5-5")
        stream.close()
    }

    /// Sync-only upstream (`test_file_upload_with_request_copying_middleware`).
    @Test func fileUploadWithRequestCopyingMiddleware() async throws {
        let server = MockServer(json: [
            "id": "file_123", "created_at": "2024-01-01T00:00:00Z", "filename": "upload.txt",
            "mime_type": "text/plain", "size_bytes": 13, "type": "file",
        ])
        let addTraceHeader = MiddlewareFunction { request, next in
            var headers = request.headers
            headers["x-trace-id"] = "abc-123"
            return try await next(request.copy(headers: headers))
        }
        let client = try makeTestClient(server, middleware: [addTraceHeader])
        let file = try await client.beta.files.upload(file: FileUpload(data: Data("file contents".utf8), filename: "upload.txt"))
        #expect(file.id == "file_123")
        #expect(server.callCount == 1)
        #expect(server.request(0).headers["x-trace-id"] == "abc-123")
        #expect(String(decoding: server.request(0).body ?? Data(), as: UTF8.self).contains("file contents"))
    }

    @Test func copyInheritsReplacesAndClearsMiddleware() throws {
        let first = RecordingMiddleware("first")
        let second = RecordingMiddleware("second")
        let client = try makeTestClient(middleware: [first])
        func names(_ c: Anthropic) -> [String] { c.middleware.map { ($0 as? RecordingMiddleware)?.name ?? "?" } }
        #expect(names(client) == ["first"])
        #expect(names(try client.copy()) == ["first"])
        #expect(names(try client.withOptions(maxRetries: 7)) == ["first"])
        #expect(names(try client.copy(middleware: [second])) == ["second"])
        #expect(names(try client.copy(middleware: [])) == [])
    }

    /// Sync-only upstream (`test_with_middleware_appends_without_mutating_original`).
    @Test func withMiddlewareAppendsWithoutMutatingOriginal() throws {
        let client = try makeTestClient(middleware: [RecordingMiddleware("first")])
        let derived = try client.withMiddleware(RecordingMiddleware("second"), RecordingMiddleware("third"))
        #expect(derived !== client)
        #expect(derived.middleware.compactMap { ($0 as? RecordingMiddleware)?.name } == ["first", "second", "third"])
        #expect(client.middleware.compactMap { ($0 as? RecordingMiddleware)?.name } == ["first"])
    }

    @Test func withMiddlewareClientRunsAppendedMiddlewareInnermost() async throws {
        let events = Locked<[String]>([])
        let outer = RecordingMiddleware("outer", events: events)
        let extra = RecordingMiddleware("extra", events: events)
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [outer])
        let derived = try client.withMiddleware(extra)
        #expect(derived.middleware.count == 2)
        #expect(client.middleware.count == 1)
        _ = try await createHello(derived)
        // the appended middleware runs inside the client's own middleware
        #expect(events.value == ["outer:enter", "extra:enter", "extra:exit", "outer:exit"])
        // the original client is unaffected by the derived client's calls
        events.value = []
        _ = try await createHello(client)
        #expect(events.value == ["outer:enter", "outer:exit"])
    }

    /// Sync-only upstream (`test_with_options_client_runs_inherited_middleware`).
    @Test func withOptionsClientRunsInheritedMiddleware() async throws {
        let recorder = RecordingMiddleware()
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [recorder])
        _ = try await createHello(try client.withOptions(maxRetries: 0))
        #expect(recorder.requests.value.count == 1)
    }

    @Test func noMiddlewareBehaviorUnchanged() async throws {
        let client = try makeTestClient(MockServer(json: messageBody()))
        #expect(client.middleware.isEmpty)
        _ = try await createHello(client)
    }

    @Test func constructionAcceptsAsyncMiddleware() throws {
        let client = try makeTestClient(middleware: [DefaultMiddleware(), RecordingMiddleware(), passThroughMiddleware()])
        #expect(client.middleware.count == 3)
    }

    @Test func defaultMiddlewareRunsRequests() async throws {
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [DefaultMiddleware(), passThroughMiddleware()])
        let message = try await createHello(client)
        #expect(message.id == "msg_013Zva2CMHLNnXjNJJKqJ2EF")
    }
}

// MARK: - TestMiddlewareProperty

@Suite("Middleware property (test_middleware.py)")
struct MiddlewarePropertyTests {
    @Test func exposesConfiguredMiddleware() throws {
        let recorder = RecordingMiddleware()
        #expect(try makeTestClient(middleware: [recorder]).middleware.first as? RecordingMiddleware === recorder)
        #expect(try makeTestClient().middleware.isEmpty)
    }

    @Test func withOptionsAppendIdiom() async throws {
        let events = Locked<[String]>([])
        let outer = RecordingMiddleware("outer", events: events)
        let inner = RecordingMiddleware("inner", events: events)
        let client = try makeTestClient(MockServer(json: messageBody()), middleware: [outer])
        let derived = try client.withOptions(middleware: client.middleware + [inner])
        _ = try await createHello(derived)
        #expect(events.value == ["outer:enter", "inner:enter", "inner:exit", "outer:exit"])
        // the parent client is unchanged
        #expect(client.middleware.count == 1)
    }
}
