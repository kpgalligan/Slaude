// Port of `TestCallSpans` in tests/test_open_telemetry.py (the async variants, and the sync-only tests run against
// the Swift client). See docs/porting/tracing.md for the tests that have no Swift meaning.

import Foundation
import Testing
@testable import Anthropic

/// A Message Batch that decodes.
func tracingBatch(_ id: String = "msgbatch_1", resultsURL: JSONValue = nil) -> JSONValue {
    [
        "id": .string(id), "type": "message_batch", "processing_status": "in_progress",
        "request_counts": ["processing": 1, "succeeded": 0, "errored": 0, "canceled": 0, "expired": 0],
        "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-02T00:00:00Z", "ended_at": nil, "cancel_initiated_at": nil,
        "archived_at": nil, "results_url": resultsURL,
    ]
}

let tracingOverloaded: JSONValue = ["type": "error", "error": ["type": "overloaded_error", "message": "busy"]]

/// `STREAM_ENDS`: the events of a stream, and the status and `error.type` of the span of a stream that has them.
let tracingStreamEnds: [([JSONValue], StatusCode, String?)] = [
    (tracingStreamEvents(), .ok, nil),
    (Array(tracingStreamEvents()[..<3]), .error, "api_error"),
    ([], .error, "api_error"),
    ([tracingStreamEvents()[0], tracingOverloaded], .error, "overloaded_error"),
]

/// `events_up_to_message_delta`.
func tracingEventsUpToMessageDelta() -> [JSONValue] {
    var events = Array(tracingStreamEvents().dropLast(2))
    let usage: JSONValue = ["output_tokens": 5, "output_tokens_details": ["thinking_tokens": 3],
                            "iterations": [tracingIteration("compaction", 100, 20, 10)]]
    events.append(tracingStreamEvents()[4].with("usage", usage))
    return events
}

/// `fallback_stream_events`.
func tracingFallbackStreamEvents() -> [JSONValue] {
    let fallback: JSONValue = ["type": "fallback", "from": ["model": "claude-test"], "to": ["model": "claude-fallback"],
                               "trigger": ["type": "refusal", "category": nil]]
    let events = tracingStreamEvents(index: 1)
    return [events[0], ["type": "content_block_start", "index": 0, "content_block": fallback], ["type": "content_block_stop", "index": 0]]
        + events.dropFirst()
}

/// `events_with_first_delta`.
func tracingEventsWithFirstDelta(_ block: JSONValue, _ delta: JSONValue) -> [JSONValue] {
    let events = tracingStreamEvents()
    let first = events[2].with("delta", delta)
    return [events[0], ["type": "ping"], events[1].with("content_block", block), first, first] + events[3...]
}

/// `events_without_a_delta`.
func tracingEventsWithoutADelta() -> [JSONValue] {
    let events = tracingStreamEvents()
    return [events[0], events[1].with("content_block", ["type": "text", "text": "Hi there"])] + events[3...]
}

/// A response whose body was given whole, as one that a middleware has read is (Python's response made from bytes).
func tracingReadStreamResponse(_ events: [JSONValue], request: HTTPRequest) -> HTTPResponse {
    HTTPResponse(statusCode: 200, headers: HTTPHeaders(tracingResponseHeaders.merging(["content-type": "text/event-stream"]) { $1 }),
                 body: tracingSSE(events), request: request)
}

/// Opens once, for any number of waiters.
final class TracingGate: @unchecked Sendable {
    private let lock = NSLock()
    private var opened = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func open() {
        let toResume: [CheckedContinuation<Void, Never>] = lock.withLock {
            opened = true
            defer { waiters = [] }
            return waiters
        }
        for w in toResume { w.resume() }
    }

    func wait() async {
        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            let resumeNow: Bool = lock.withLock {
                if opened { return true }
                waiters.append(c)
                return false
            }
            if resumeNow { c.resume() }
        }
    }
}

@Suite struct OpenTelemetryCallSpanTests {
    @Test func unaryAttributes() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage, headers: tracingResponseHeaders))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(conversationID: "conv_1"))

        let app = try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { app in
            try await tracingCreate(client, extraHeaders: ["anthropic-beta": "beta-one, beta-two"], extraBody: [
                "output_config": ["effort": "high"], "service_tier": "auto", "thinking": ["type": "enabled", "budget_tokens": 2048],
            ])
            return app.context
        }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.kind == .client)
        #expect(span.statusCode == .ok)
        #expect(span.parent?.spanID == app.spanID)
        #expect(span.instrumentationScope.name == "com.anthropic.sdk.swift")
        #expect(span.instrumentationScope.version == client.version)
        #expect(span.attributes == [
            "gen_ai.provider.name": "anthropic",
            "gen_ai.conversation.id": "conv_1",
            "gen_ai.operation.name": "chat",
            "gen_ai.request.model": "claude-test",
            "gen_ai.request.max_tokens": 1024,
            "gen_ai.request.reasoning.level": "high",
            "anthropic.request.service_tier": "auto",
            "anthropic.thinking.type": "enabled",
            "anthropic.thinking.budget_tokens": 2048,
            "anthropic.beta": .stringArray(["beta-one", "beta-two"]),
            "server.address": "127.0.0.1",
            "server.port": 4010,
            "http.request.method": "POST",
            "http.route": "/v1/messages",
            "url.scheme": "http",
            "url.path": "/v1/messages",
            "url.full": "http://127.0.0.1:4010/v1/messages",
            "http.response.status_code": 200,
            "anthropic.request.id": "req_1",
            "anthropic.organization.id": "org_1",
            "anthropic.workspace.id": "wrkspc_1",
            "gen_ai.response.id": "msg_1",
            "gen_ai.response.model": "claude-test",
            "gen_ai.usage.input_tokens": 15,
            "gen_ai.usage.output_tokens": 5,
            "gen_ai.usage.cache_write.input_tokens": 3,
            "gen_ai.usage.cache_read.input_tokens": 2,
            "anthropic.usage.cache_creation.ephemeral_5m_input_tokens": 1,
            "anthropic.usage.cache_creation.ephemeral_1h_input_tokens": 2,
            "anthropic.response.service_tier": "standard",
            "anthropic.message.stop_reason": "end_turn",
        ])
        #expect(span["gen_ai.input.messages"] == nil)
    }

    @Test func temperatureAndTopPAreDoubles() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await tracingCreate(try tracingClient(spans, router), extraBody: ["temperature": 1, "top_p": 1])

        let span = try spans.one("anthropic.messages.create")
        // An exporter sends an `int` as an integer, and these two attributes are doubles.
        #expect(span["gen_ai.request.temperature"] == .double(1.0))
        #expect(span["gen_ai.request.top_p"] == .double(1.0))
    }

    @Test func errorResponse() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(["type": "error", "error": ["type": "rate_limit_error", "message": "slow down"]],
                                                  status: 429, headers: tracingResponseHeaders))
        await #expect(throws: RateLimitError.self) { try await tracingCreate(try tracingClient(spans, router, maxRetries: 0)) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "rate_limit_error")
        #expect(span["http.response.status_code"] == 429)
        #expect(span["anthropic.request.id"] == "req_1")
        #expect(span["gen_ai.response.id"] == nil)
        #expect(span["anthropic.message.stop_reason"] == nil)
    }

    @Test func errorResponseWithoutEnvelope() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .text("bad gateway", status: 502))
        await #expect(throws: APIStatusError.self) { try await tracingCreate(try tracingClient(spans, router, maxRetries: 0)) }
        #expect(try spans.one("anthropic.messages.create")["error.type"] == "502")
    }

    @Test func connectionError() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .fail(URLError(.cannotConnectToHost)))
        await #expect(throws: APIConnectionError.self) { try await tracingCreate(try tracingClient(spans, router, maxRetries: 0)) }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "connection_error")
        #expect(span["server.address"] == "127.0.0.1")
        #expect(span["server.port"] == 4010)
        #expect(span["http.response.status_code"] == nil)
    }

    @Test func timeout() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .fail(TransportTimeoutError()))
        await #expect(throws: APITimeoutError.self) { try await tracingCreate(try tracingClient(spans, router, maxRetries: 0)) }
        #expect(try spans.one("anthropic.messages.create")["error.type"] == "client_timeout_error")
    }

    @Test func aRetriedCallHasOneSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingOverloaded, status: 529), .json(tracingOverloaded, status: 529),
                                 .json(tracingMessage))
        try await tracingCreate(try tracingClient(spans, router, maxRetries: 2))

        // The SDK emits no span for an attempt, so the call span, with the final attempt's status, is the only one.
        #expect(spans.finished.count == 1)
        let call = try spans.one("anthropic.messages.create")
        #expect(call.statusCode == .ok)
        #expect(call["http.response.status_code"] == 200)
        let context = "00-\(call.traceID.hex)-\(call.spanID.hex)-"
        #expect(route.traceparents.map { $0.map { String($0.prefix(context.count)) } } == [context, context, context])
    }

    @Test func timeToFirstChunkCountsFromTheFirstAttempt() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingOverloaded, status: 529), .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router, maxRetries: 1)
        client.sleeper = { _ in try await Task.sleep(nanoseconds: 200_000_000) }

        await tracingDrain(try await tracingCreateStream(client))

        #expect(try spans.one("anthropic.messages.create")["gen_ai.response.time_to_first_chunk"]!.doubleValue! >= 0.2)
    }

    @Test func batchResultsSpanCoversTheDownload() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let lines = (0..<3).map { "{\"custom_id\": \"\($0)\", \"result\": {\"type\": \"expired\"}}" }.joined(separator: "\n")
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch(resultsURL: "/v1/messages/batches/msgbatch_1/results")))
        router.route("GET", "/v1/messages/batches/msgbatch_1/results", .bytes(Data(lines.utf8), headers: tracingResponseHeaders))
        let client = try tracingClient(spans, router)

        let results = try await client.messages.batches.results("msgbatch_1")
        #expect(spans.named("anthropic.messages.batches.results").isEmpty)
        var ids: [String] = []
        for try await result in results { ids.append(result.customID) }
        #expect(ids == ["0", "1", "2"])
        let span = try spans.one("anthropic.messages.batches.results")
        #expect(span.statusCode == .ok)
        #expect(span["anthropic.message.batch.id"] == "msgbatch_1")
        #expect(span["anthropic.request.id"] == "req_1")

        let partly = try await client.messages.batches.results("msgbatch_1")
        var iterator = partly.makeAsyncIterator()
        #expect(try await iterator.next()?.customID == "0")
        partly.close()
        #expect(spans.named("anthropic.messages.batches.results")[1].statusCode == .unset)

        try await client.messages.batches.results("msgbatch_1").close()
        let closed = spans.named("anthropic.messages.batches.results")[2]
        #expect(closed.statusCode == .unset)
        #expect(closed.endTime != nil)
    }

    @Test func batchResultsDownloadFailureFailsTheSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch(resultsURL: "/v1/messages/batches/msgbatch_1/results")))
        router.route("GET", "/v1/messages/batches/msgbatch_1/results",
                     .lostConnection(Data("{\"custom_id\": \"0\", \"result\": {\"type\": \"expired\"}}\n".utf8)))
        let results = try await tracingClient(spans, router).messages.batches.results("msgbatch_1")
        await #expect(throws: URLError.self) { for try await _ in results {} }

        let span = try spans.one("anthropic.messages.batches.results")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "connection_error")
    }

    @Test func rawResponseEndsTheSpanWithItsBody() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage, headers: tracingResponseHeaders))
        let client = try tracingClient(spans, router)

        try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test") {
            response in
            #expect(spans.finished.isEmpty)
            #expect(try await response.parse().id == "msg_1")
            _ = try spans.one("anthropic.messages.create")
        }
        let raw = try await client.messages.withRawResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
        #expect(try await raw.parse().id == "msg_1")

        #expect(spans.provider.loggedWarnings == [])
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .ok)
            #expect(span["http.response.status_code"] == 200)
            #expect(span["anthropic.request.id"] == "req_1")
            #expect(span["gen_ai.request.model"] == "claude-test")
        }
        #expect(calls[0]["gen_ai.usage.output_tokens"] == nil)
        // `withRawResponse` has read the body when the call returns, so its span has the response's attributes.
        #expect(calls[1]["gen_ai.usage.output_tokens"] == 5)
        #expect(calls[1]["gen_ai.response.id"] == "msg_1")
    }

    @Test func rawResponseWhoseBodyIsNotReadToTheEndHasNoStatus() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage, headers: tracingResponseHeaders), .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router)

        try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test") {
            response in
            #expect(response.headers["request-id"] == "req_1")
            response.close()
        }
        #expect(spans.finished.count == 1)
        do {
            let raw = try await client.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello),
                                                                                model: "claude-test")
            #expect(raw.headers["request-id"] == "req_1")
            #expect(spans.finished.count == 1)
        }
        // The raw response was dropped.

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .unset)
            #expect(span["error.type"] == nil)
            #expect(span["anthropic.request.id"] == "req_1")
        }
    }

    @Test(arguments: [false, true], 0..<4)
    func streamParsedFromARawResponseIsRecordedLikeAStream(beta: Bool, end: Int) async throws {
        let (events, status, errorType) = tracingStreamEnds[end]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))
        let client = try tracingClient(spans, router)

        if beta {
            await tracingDrain(try await tracingBetaCreateStream(client))
            #expect(spans.finished.count == 1)
            let raw = try await client.beta.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: tracingBetaMessages(tracingHello),
                                                                                     model: "claude-test")
            await tracingDrain(try await raw.parse())
        } else {
            await tracingDrain(try await tracingCreateStream(client))
            #expect(spans.finished.count == 1)
            let raw = try await client.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello),
                                                                                model: "claude-test")
            await tracingDrain(try await raw.parse())
        }

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        let (plain, raw) = (calls[0], calls[1])
        #expect(raw.statusCode == status && plain.statusCode == status)
        #expect(raw["error.type"] == plain["error.type"])
        #expect(raw["error.type"] == errorType.map { .string($0) })
        #expect(raw["gen_ai.response.id"] == plain["gen_ai.response.id"])
        #expect(raw["gen_ai.response.id"] == (events.isEmpty ? nil : "msg_1"))
        #expect(raw["gen_ai.usage.output_tokens"] == plain["gen_ai.usage.output_tokens"])
    }

    @Test(arguments: 0..<4)
    func streamOverABodyThatWasReadBeforeTheCallReturned(end: Int) async throws {
        let (events, status, errorType) = tracingStreamEnds[end]
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .custom { tracingReadStreamResponse(events, request: $0) })

        let stream = try await tracingCreateStream(try tracingClient(spans, router))
        #expect(spans.finished.isEmpty)
        await tracingDrain(stream)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == status)
        #expect(span["error.type"] == errorType.map { .string($0) })
        #expect(span["gen_ai.response.id"] == (events.isEmpty ? nil : "msg_1"))
    }

    @Test func streamOverABodyThatWasReadIsClosedOrReadWithTheHelper() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .custom { tracingReadStreamResponse(tracingStreamEvents(), request: $0) })
        let client = try tracingClient(spans, router)

        let stream = try await tracingCreateStream(client)
        var iterator = stream.makeAsyncIterator()
        _ = try await iterator.next()
        #expect(spans.finished.isEmpty)
        stream.close()
        let closed = try spans.one("anthropic.messages.create")
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()

        #expect(closed.statusCode == .unset)
        let read = spans.named("anthropic.messages.create")[1]
        #expect(read.statusCode == .ok)
        #expect(read["gen_ai.usage.output_tokens"] == 5)
    }

    @Test func streamOverAResponseThatAMiddlewareMadeFromBytes() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let replay = MiddlewareFunction { request, next in
            let sent = try await next(request)
            sent.http.close()
            return RawAPIResponse(tracingReadStreamResponse(tracingStreamEvents(), request: sent.http.request), for: request)
        }
        let client = try tracingClient(spans, router, middleware: [replay])

        await tracingDrain(try await tracingCreateStream(client))
        let stream = try await tracingCreateStream(client)
        var iterator = stream.makeAsyncIterator()
        _ = try await iterator.next()
        stream.close()

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls[0].statusCode == .ok)
        #expect(calls[0]["gen_ai.usage.output_tokens"] == 5)
        #expect(calls[1].statusCode == .unset)
    }

    @Test func eventsReadAfterTheResponseWasClosedLeaveTheSpanAlone() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router)

        let raw = try await client.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
        let stream = try await raw.parse()
        var iterator = stream.makeAsyncIterator()
        _ = try await iterator.next()
        raw.http.close()
        while (try? await iterator.next()) != nil {}

        #expect(try spans.one("anthropic.messages.create").statusCode == .unset)
        #expect(spans.provider.loggedWarnings == [])
    }

    @Test func rawResponseWhoseEventsTheApplicationReadsItself() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(Array(tracingStreamEvents()[..<3])))
        let client = try tracingClient(spans, router)

        try await client.messages.withStreamingResponse.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello),
                                                                        model: "claude-test") { response in
            var lines = 0
            for try await _ in response.iterLines() { lines += 1 }
            #expect(lines > 0)
        }

        // The SDK has not parsed the events, so it cannot tell that `message_stop` is missing.
        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span["gen_ai.response.id"] == nil)
    }

    @Test func streamWhoseBytesTheApplicationReadsItself() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(Array(tracingStreamEvents()[..<3])))

        let stream = try await tracingCreateStream(try tracingClient(spans, router))
        var chunks = 0
        for try await _ in stream.response.bytes() { chunks += 1 }
        #expect(chunks > 0)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span["error.type"] == nil)
    }

    @Test func rawResponseWhoseConnectionIsLostInTheBody() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .lostConnection(Data("{".utf8), headers: tracingResponseHeaders))
        let client = try tracingClient(spans, router)

        try await client.messages.withStreamingResponse.create(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test") {
            response in
            await #expect(throws: URLError.self) { _ = try await response.read() }
        }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "connection_error")
    }

    @Test func elapsedOfAResponseWhoseBodyEndsTheSpan() async throws {
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let stream = try await tracingCreateStream(try tracingClient(TracingSpans(), router))
        await tracingDrain(stream)
        #expect(stream.response.elapsed >= 0)
    }

    @Test(arguments: [0, 2])
    func droppedStream(reads: Int) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router)

        func readAndDrop() async throws {
            let stream = try await tracingCreateStream(client)
            var iterator = stream.makeAsyncIterator()
            for _ in 0..<reads { _ = try await iterator.next() }
            #expect(spans.finished.isEmpty)
        }
        try await readAndDrop()

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(span["gen_ai.response.id"] == (reads > 0 ? "msg_1" : nil))
    }

    @Test func traceContextHeaders() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router)

        let parent = NonRecordingSpan(SpanContext(traceID: TraceID(low: 0x1234), spanID: SpanID(0x5678), traceFlags: .sampled,
                                                  traceState: TraceState([("vendor", "value")]), isRemote: true))
        try await TracingContext.withSpan(parent) { try await tracingCreate(client) }

        let request = try #require(route.requests.first)
        let call = try spans.one("anthropic.messages.create")
        #expect(request.headers["traceparent"] == "00-\(TraceID(low: 0x1234).hex)-\(call.spanID.hex)-01")
        #expect(request.headers["tracestate"] == "vendor=value")
        #expect(call.traceID == TraceID(low: 0x1234))
    }

    @Test func streamReadToTheEnd() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router)

        let message = try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
            .getFinalMessage()
        guard case .text = message.message.content[0] else { Issue.record("expected a text block"); return }

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span["gen_ai.request.stream"] == true)
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["gen_ai.usage.output_tokens"] == 5)
        #expect(span["anthropic.message.stop_reason"] == "end_turn")
        #expect(span["anthropic.response.service_tier"] == "standard")
        #expect(span["gen_ai.response.time_to_first_chunk"]?.doubleValue != nil)
    }

    @Test func streamClosedEarly() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))

        let stream = try await tracingCreateStream(try tracingClient(spans, router))
        var iterator = stream.makeAsyncIterator()
        guard case .messageStart? = try await iterator.next() else { Issue.record("expected message_start"); return }
        stream.close()

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["anthropic.response.service_tier"] == "standard")
        #expect(span["gen_ai.usage.input_tokens"] == 15)
        #expect(span["gen_ai.usage.output_tokens"] == nil)
        #expect(span["anthropic.message.stop_reason"] == nil)
        #expect(span["gen_ai.response.time_to_first_chunk"] == nil)
    }

    @Test(arguments: [false, true])
    func streamClosedAfterMessageStopBeforeTheEndOfTheBody(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router, openTelemetry: spans.contentOption)

        if beta {
            let stream = try await tracingBetaCreateStream(client)
            for try await event in stream { if case .messageStop = event { break } }
            stream.close()
            let helper = try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
            for try await event in helper { if case .messageStop = event { break } }
            helper.close()
        } else {
            let stream = try await tracingCreateStream(client)
            for try await event in stream { if case .messageStop = event { break } }
            stream.close()
            let helper = try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
            for try await event in helper { if case .messageStop = event { break } }
            helper.close()
        }

        // The application closed both before the API did, so neither is `OK`, with every attribute of a whole Message.
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .unset)
            #expect(span["error.type"] == nil)
            #expect(span["gen_ai.response.id"] == "msg_1")
            #expect(span["gen_ai.usage.output_tokens"] == 5)
            #expect(span["anthropic.message.stop_reason"] == "end_turn")
            #expect(span["gen_ai.response.time_to_first_chunk"]?.doubleValue != nil)
        }
        #expect(calls[0]["gen_ai.output.messages"] == nil)
        #expect(calls[1].json("gen_ai.output.messages") == [["role": "assistant", "parts": [["type": "text", "content": "Hi there"]]]])
    }

    static let firstDeltas: [(JSONValue, JSONValue)] = [
        (["type": "text", "text": ""], ["type": "text_delta", "text": "Hi"]),
        (["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": [:]], ["type": "input_json_delta", "partial_json": ""]),
        (["type": "thinking", "thinking": "", "signature": ""], ["type": "thinking_delta", "thinking": "Hm"]),
        (["type": "thinking", "thinking": "", "signature": ""], ["type": "signature_delta", "signature": "sig"]),
    ]

    @Test(arguments: 0..<4)
    func timeToFirstChunkIsSetAtTheFirstContentBlockDelta(delta: Int) async throws {
        let (block, firstDelta) = Self.firstDeltas[delta]
        let spans = TracingSpans()
        let started = TracingStartedSpans()
        spans.provider.addSpanProcessor(started)
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingEventsWithFirstDelta(block, firstDelta)))

        var times: [(String, AttributeValue?)] = []
        for try await event in try await tracingBetaCreateStream(try tracingClient(spans, router)) {
            let type = try JSONValue.from(event)["type"]!.stringValue!
            times.append((type, started.spans[0].attributes["gen_ai.response.time_to_first_chunk"]))
        }

        // `times` has the type of each event that the application read, and the span's time to first chunk then.
        #expect(times.filter { $0.1 == nil }.map(\.0) == ["message_start", "content_block_start"])
        // The second delta and the events after it left the time of the first.
        let later = Set(times.dropFirst(2).compactMap(\.1))
        #expect(later.count == 1)
        #expect(try spans.one("anthropic.messages.create")["gen_ai.response.time_to_first_chunk"] == later.first)
    }

    @Test(arguments: [false, true])
    func streamWithoutAContentBlockDeltaHasNoTimeToFirstChunk(beta: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingEventsWithoutADelta()))
        let client = try tracingClient(spans, router)

        if beta {
            await tracingDrain(try await tracingBetaCreateStream(client))
            let text = try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
                .getFinalText()
            #expect(text == "Hi there")
        } else {
            await tracingDrain(try await tracingCreateStream(client))
            let text = try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test")
                .getFinalText()
            #expect(text == "Hi there")
        }

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .ok)
            #expect(span["gen_ai.usage.output_tokens"] == 5)
            #expect(span["gen_ai.response.time_to_first_chunk"] == nil)
        }
    }

    @Test func streamClosedBeforeTheFirstRead() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router)

        try await tracingCreateStream(client).close()
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").close()

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .unset)
            #expect(span["error.type"] == nil)
            #expect(span["gen_ai.request.stream"] == true)
            #expect(span["gen_ai.response.id"] == nil)
            #expect(span["gen_ai.response.time_to_first_chunk"] == nil)
        }
    }

    @Test func streamClosedBeforeTheFirstReadHasTheRequestsContent() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))
        let client = try tracingClient(spans, router, openTelemetry: spans.contentOption)

        try await client.messages.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test",
                                                  stopSequences: ["END"], system: "Be brief").close()
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test", stopSequences: ["END"],
                                         system: "Be brief").close()

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .unset)
            #expect(span.json("gen_ai.input.messages") == [["role": "user", "parts": [["type": "text", "content": "Hello"]]]])
            #expect(span.json("gen_ai.system_instructions") == [["type": "text", "content": "Be brief"]])
            #expect(span["gen_ai.request.stop_sequences"] == .stringArray(["END"]))
            #expect(span["gen_ai.output.messages"] == nil)
        }
    }

    @Test(arguments: [false, true])
    func streamClosedFromAnotherTaskWhileItIsRead(traced: Bool) async throws {
        let spans = TracingSpans()
        let waiting = TracingGate()
        let released = TracingGate()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .custom { request in
            // A response body whose second read waits until the test lets it go.
            let body = ByteStream { c in
                Task {
                    c.yield(tracingSSE(Array(tracingStreamEvents()[..<1])))
                    waiting.open()
                    await released.wait()
                    c.finish()
                }
            }
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: body, request: request)
        })
        let client = try tracingClient(spans, router, openTelemetry: traced ? spans.option() : .disabled)
        let stream = try await tracingCreateStream(client)

        let reader = Task { await tracingDrain(stream) }
        await waiting.wait()
        // The read is in progress. Closing the stream ends the span as closed by the application, and the read then
        // ends by itself, which changes nothing on the span.
        try await Task.sleep(nanoseconds: 20_000_000)
        stream.close()
        released.open()
        _ = await reader.value
        if traced {
            let span = try spans.one("anthropic.messages.create")
            #expect(span.statusCode == .unset)
            #expect(span["error.type"] == nil)
            #expect(span["gen_ai.response.id"] == "msg_1")
        } else {
            #expect(spans.finished.isEmpty)
        }
    }

    @Test func streamEndedByTheServerBeforeMessageStop() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(Array(tracingStreamEvents()[..<3])))

        let (types, _) = await tracingDrain(try await tracingCreateStream(try tracingClient(spans, router)))
        #expect(types == ["message_start", "content_block_start", "content_block_delta"])

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "api_error")
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["gen_ai.usage.output_tokens"] == nil)
        #expect(span["anthropic.message.stop_reason"] == nil)
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content], [false, true])
    func compactionTokens(contentMode: OpenTelemetryContentMode, raw: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let iterations: JSONValue = [tracingIteration("compaction", 100, 20, 10, 5), tracingIteration("message"),
                                     tracingIteration("compaction", 200, 30)]
        router.route("POST", "/v1/messages", .json(tracingMessageWith(iterations: iterations)))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode)))

        if raw {
            _ = try await client.beta.messages.withRawResponse.create(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
        } else {
            try await tracingBetaCreate(client)
        }

        let span = try spans.one("anthropic.messages.create")
        // The sums of the compactions only, with their cached tokens as input tokens.
        #expect(span["anthropic.usage.compaction.input_tokens"] == .int(100 + 10 + 5 + 200))
        #expect(span["anthropic.usage.compaction.output_tokens"] == .int(20 + 30))
        #expect(span["gen_ai.usage.input_tokens"] == 15)
        #expect(span["gen_ai.usage.output_tokens"] == 5)
    }

    @Test func compactionTokensOfAResponseWithoutUsageOfItsOwn() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let usage: JSONValue = ["input_tokens": 0, "output_tokens": 0, "iterations": [tracingIteration("compaction", 100, 20)]]
        router.route("POST", "/v1/messages", .json(tracingMessage.with("usage", usage)))
        try await tracingBetaCreate(try tracingClient(spans, router))

        let span = try spans.one("anthropic.messages.create")
        #expect(span["anthropic.usage.compaction.input_tokens"] == 100)
        #expect(span["anthropic.usage.compaction.output_tokens"] == 20)
        #expect(span["gen_ai.usage.input_tokens"] == 0)
        #expect(span["gen_ai.usage.output_tokens"] == 0)
    }

    @Test(arguments: [JSONValue.null, [], [tracingIteration("message")]])
    func noCompactionTokensWithoutACompaction(iterations: JSONValue) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .json(tracingMessageWith(iterations: iterations)))
        let client = try tracingClient(spans, router)
        try await tracingBetaCreate(client)
        try await tracingBetaCreate(client)

        for span in spans.named("anthropic.messages.create") {
            #expect(span["anthropic.usage.compaction.input_tokens"] == nil)
            #expect(span["anthropic.usage.compaction.output_tokens"] == nil)
        }
    }

    @Test func stableUsageHasNoCompactionTokens() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessageWith(iterations: [tracingIteration("compaction", 100, 20)])))
        try await tracingCreate(try tracingClient(spans, router))

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .ok)
        #expect(span["gen_ai.usage.output_tokens"] == 5)
        #expect(span["anthropic.usage.compaction.input_tokens"] == nil)
    }

    @Test(arguments: [OpenTelemetryContentMode.metadataOnly, .content])
    func streamedCompactionTokens(contentMode: OpenTelemetryContentMode) async throws {
        var events = tracingStreamEvents()
        events[4] = events[4].with("usage", ["output_tokens": 5, "iterations": [tracingIteration("compaction", 100, 20, 10)]])
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: contentMode)))

        await tracingDrain(try await tracingBetaCreateStream(client))
        try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test").untilDone()

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span["anthropic.usage.compaction.input_tokens"] == 110)
            #expect(span["anthropic.usage.compaction.output_tokens"] == 20)
            #expect(span["gen_ai.usage.input_tokens"] == 15)
            #expect(span["gen_ai.usage.output_tokens"] == 5)
        }
    }

    /// Reads `events` with the stable or the beta stream, with or without the stream helper.
    func readStream(_ events: [JSONValue], beta: Bool, helper: Bool, spans: TracingSpans, strict: Bool = true) async throws -> Error? {
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(events))
        let client = try tracingClient(spans, router)
        do {
            switch (beta, helper) {
            case (true, true):
                try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test").untilDone()
            case (true, false): return await tracingDrain(try await tracingBetaCreateStream(client)).error
            case (false, true):
                try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()
            case (false, false): return await tracingDrain(try await tracingCreateStream(client)).error
            }
        } catch {
            return error
        }
        return nil
    }

    @Test(arguments: [false, true], [false, true])
    func streamEndedAfterMessageDeltaHasWhatMessageDeltaGave(beta: Bool, helper: Bool) async throws {
        let spans = TracingSpans()
        _ = try await readStream(tracingEventsUpToMessageDelta(), beta: beta, helper: helper, spans: spans)

        let span = try spans.one("anthropic.messages.create")
        // The stream still ended early, which fails the span as before.
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "api_error")
        #expect(span["anthropic.message.stop_reason"] == "end_turn")
        #expect(span["gen_ai.usage.output_tokens"] == 5)
        #expect(span["gen_ai.usage.reasoning.output_tokens"] == 3)
        // Only the beta usage has the iterations.
        let compaction = span.attributes.filter { $0.key.hasPrefix("anthropic.usage.compaction.") }
        #expect(compaction == (beta ? ["anthropic.usage.compaction.input_tokens": 110, "anthropic.usage.compaction.output_tokens": 20] : [:]))
    }

    @Test(arguments: [false, true], [false, true])
    func streamEndedBeforeMessageDeltaHasNothingThatMessageDeltaGives(beta: Bool, helper: Bool) async throws {
        let spans = TracingSpans()
        _ = try await readStream(Array(tracingEventsUpToMessageDelta().dropLast()), beta: beta, helper: helper, spans: spans)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "api_error")
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["gen_ai.usage.input_tokens"] == 15)
        for name in ["anthropic.message.stop_reason", "gen_ai.usage.output_tokens", "gen_ai.usage.reasoning.output_tokens",
                     "anthropic.usage.compaction.input_tokens", "anthropic.usage.compaction.output_tokens"]
        {
            #expect(span[name] == nil)
        }
    }

    @Test(arguments: [false, true], [false, true])
    func streamEndedAfterAMessageDeltaThatCannotBeAccumulatedHasNothingOfIt(beta: Bool, helper: Bool) async throws {
        var events = tracingEventsUpToMessageDelta()
        events[events.count - 1] = events[events.count - 1].without("usage")
        let spans = TracingSpans()
        // The event does not decode, and the reading fails on it.
        let error = try await readStream(events, beta: beta, helper: helper, spans: spans)
        #expect(error != nil)

        // The snapshot lacks what the event has, so the span has only what the events before it gave.
        let span = try spans.one("anthropic.messages.create")
        #expect(span["gen_ai.response.id"] == "msg_1")
        #expect(span["anthropic.message.stop_reason"] == nil)
        #expect(span["gen_ai.usage.output_tokens"] == nil)
    }

    @Test(arguments: ["tool_use", "max_tokens", "a_later_stop_reason"])
    func stopReasonIsTheOneInTheResponse(stopReason: String) async throws {
        var events = tracingStreamEvents()
        events[4] = events[4].with("delta", ["stop_reason": .string(stopReason)])
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("stop_reason", .string(stopReason))), .sse(events))
        let client = try tracingClient(spans, router)

        try await tracingCreate(client)
        await tracingDrain(try await tracingCreateStream(client))
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()

        // Not content, so it is there by default, and with the API's own value.
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 3)
        for span in calls {
            #expect(span["anthropic.message.stop_reason"] == .string(stopReason))
            #expect(span["gen_ai.response.finish_reasons"] == nil)
        }
    }

    @Test func streamedResponseModelIsTheOneThatAFallbackBlockNames() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingFallbackStreamEvents()))
        let client = try tracingClient(spans, router)

        var read: [BetaRawMessageStreamEvent] = []
        for try await event in try await tracingBetaCreateStream(client) { read.append(event) }
        let message = try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test")
            .getFinalMessage()

        // `message_start` has the model that declined, and the Message has the one that answered.
        guard case .messageStart(let start) = read[0] else { Issue.record("expected message_start"); return }
        #expect(start.message.model.rawValue == "claude-test")
        #expect(message.message.model.rawValue == "claude-fallback")
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for span in calls {
            #expect(span.statusCode == .ok)
            #expect(span["gen_ai.request.model"] == "claude-test")
            #expect(span["gen_ai.response.model"] == "claude-fallback")
        }
    }

    static let sessionEvent: JSONValue = ["type": "session.status_running", "id": "sevt_1", "processed_at": "2026-01-01T00:00:00Z"]

    @Test func eventStreamClosedEarly() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions/sesn_1/events/stream", .bytes(tracingSSE([Self.sessionEvent, Self.sessionEvent]),
                                                                       headers: ["content-type": "text/event-stream"]))

        let stream = try await tracingClient(spans, router).beta.sessions.events.stream("sesn_1")
        var iterator = stream.makeAsyncIterator()
        _ = try await iterator.next()
        stream.close()

        let span = try spans.one("anthropic.sessions.events.stream")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
    }

    @Test(arguments: [false, true])
    func eventStreamEndedByTheServer(raw: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/sessions/sesn_1/events/stream", .bytes(tracingSSE([Self.sessionEvent]),
                                                                       headers: ["content-type": "text/event-stream"]))
        let events = try tracingClient(spans, router).beta.sessions.events

        let stream = raw ? try await events.withRawResponse.stream("sesn_1").parse() : try await events.stream("sesn_1")
        let (types, _) = await tracingDrain(stream)
        stream.close()
        #expect(types == ["session.status_running"])

        // A stream without an end event is never read to the end, so the server ending it sets no status.
        let span = try spans.one("anthropic.sessions.events.stream")
        #expect(span.endTime != nil)
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(span["http.response.status_code"] == 200)
        #expect(span["gen_ai.provider.name"] == "anthropic")
    }

    @Test func streamErrorEvent() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse([tracingStreamEvents()[0], tracingOverloaded]))

        let (_, error) = await tracingDrain(try await tracingCreateStream(try tracingClient(spans, router)))
        #expect(error is APIStatusError)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == "overloaded_error")
    }

    @Test func streamErrorEventWithoutAType() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse([tracingStreamEvents()[0], ["type": "error", "error": ["message": "busy"]]]))

        let (_, error) = await tracingDrain(try await tracingCreateStream(try tracingClient(spans, router)))
        #expect(error is APIStatusError)

        let span = try spans.one("anthropic.messages.create")
        #expect(span.statusCode == .error)
        // The status of the response that opened the stream is no error, so it is no error type either.
        #expect(span["error.type"] == "client_error")
        #expect(span["http.response.status_code"] == 200)
    }

    @Test func concurrentCallsGetTheirOwnSpans() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        let client = try tracingClient(spans, router, openTelemetry: spans.option(conversationID: "shared"))

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<8 { group.addTask { try await tracingCreate(client, extraHeaders: ["x-test": "1"]) } }
            try await group.waitForAll()
        }

        let calls = spans.named("anthropic.messages.create")
        #expect(calls.count == 8)
        #expect(Set(calls.map(\.spanID)).count == 8)
        #expect(Set(calls.map(\.traceID)).count == 8)
        #expect(calls.allSatisfy { $0.statusCode == .ok })
    }

    @Test func betaHeaderOfTheClientsDefaultHeadersIsOnTheSpan() async throws {
        // The span starts with `anthropic.beta`, which is read from the client's headers.
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await tracingCreate(try tracingClient(spans, router, defaultHeaders: ["anthropic-beta": "beta-1"]))
        #expect(try spans.one("anthropic.messages.create")["anthropic.beta"] == .stringArray(["beta-1"]))
    }

    @Test func environmentVariableDisablesSpans() async throws {
        let registered = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "/v1/messages", .json(tracingMessage))
        try await OpenTelemetry.withTracerProvider(registered.provider) {
            let env = ["ANTHROPIC_OPEN_TELEMETRY": "FALSE"]
            try await tracingCreate(try tracingClient(nil, router, openTelemetry: .some(nil), environment: env))
            #expect(registered.finished.isEmpty)
            #expect(route.requests[0].headers["traceparent"] == nil)

            // The variable is for a client that is given no option.
            for option in [OpenTelemetryOptions(), OpenTelemetryOptions(traces: true), OpenTelemetryOptions(traces: OpenTelemetryTraces(enabled: true))] {
                try await tracingCreate(try tracingClient(nil, router, openTelemetry: option, environment: env))
            }
            #expect(registered.named("anthropic.messages.create").count == 3)
        }
    }

    @Test func optionDisablesSpans() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        try await tracingCreate(try tracingClient(spans, router, openTelemetry: .disabled))
        try await tracingCreate(try tracingClient(spans, router, openTelemetry: spans.option(traces: false)))
        #expect(spans.finished.isEmpty)
    }

    @Test func disabledSpansLeaveTheBodyOfTheResponseAlone() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))

        for (traced, client) in [(false, try tracingClient(spans, router, openTelemetry: .disabled)), (true, try tracingClient(spans, router))] {
            let stream = try await tracingCreateStream(client)
            let raw = try await client.messages.withRawResponse.createStreaming(maxTokens: 1024, messages: tracingMessages(tracingHello),
                                                                                model: "claude-test")
            for response in [stream.response, raw.http] {
                #expect((response.streamObserver != nil) == traced)
            }
            #expect(await tracingDrain(stream).types.count == tracingStreamEvents().count)
            #expect(await tracingDrain(try await raw.parse()).types.count == tracingStreamEvents().count)
        }
    }

    @Test(arguments: [true, false])
    func streamOverAResponseThatNoCallReturned(traces: Bool) async throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: OpenTelemetryTraces(enabled: traces)))
        let response = HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], body: tracingSSE(tracingStreamEvents()),
                                    request: HTTPRequest(method: "POST", url: URL(string: tracingBaseURL)!))

        let stream = SSEStream<RawMessageStreamEvent>(response: response, client: client)
        #expect(await tracingDrain(stream).types.count == tracingStreamEvents().count)
        #expect(spans.finished.isEmpty)
    }

    @Test func streamHelperOverAStreamWithoutEvents() async throws {
        let response = HTTPResponse(statusCode: 200, body: Data(), request: HTTPRequest(method: "POST", url: URL(string: tracingBaseURL)!))
        let helper = MessageStream<Never>(rawStream: SSEStream(response: response, client: try mockClient()))
        var events = 0
        for try await _ in helper { events += 1 }
        #expect(events == 0)
    }

    @Test func otherMethods() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages/count_tokens", .json(["input_tokens": 7]))
        router.route("POST", "/v1/messages/batches", .json(tracingBatch()))
        router.route("POST", "/v1/messages/batches/msgbatch_1/cancel", .json(tracingBatch()))
        router.route("GET", "/v1/models", .json(["data": [], "has_more": false, "first_id": nil, "last_id": nil]))
        let client = try tracingClient(spans, router)

        _ = try await client.messages.countTokens(messages: tracingMessages(tracingHello), model: "claude-test")
        let request: JSONValue = ["custom_id": "a", "params": ["max_tokens": 1, "messages": [["role": "user", "content": "Hi"]], "model": "m"]]
        _ = try await client.messages.batches.create(requests: [try request.decode()])
        _ = try await client.messages.batches.cancel("msgbatch_1")
        _ = try await client.beta.models.list()

        let count = try spans.one("anthropic.messages.count_tokens")
        #expect(count["gen_ai.request.model"] == "claude-test")
        #expect(count["anthropic.message.count_tokens.input_tokens"] == 7)
        #expect(count["gen_ai.operation.name"] == nil)
        #expect(try spans.one("anthropic.messages.batches.create")["anthropic.message.batch.id"] == "msgbatch_1")
        #expect(try spans.one("anthropic.messages.batches.cancel")["anthropic.message.batch.id"] == "msgbatch_1")
        // The `beta` namespace is not part of the name.
        #expect(try spans.one("anthropic.models.list").statusCode == .ok)
    }

    @Test func outputTypeIsJSONWhenTheRequestSetsAJSONOutputFormat() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage.with("content", [["type": "text", "text": "{\"city\": \"SF\"}"]])))
        let client = try tracingClient(spans, router)
        let schema: JSONValue = ["type": "object", "properties": ["city": ["type": "string"]]]

        try await tracingCreate(client, extraBody: ["output_config": ["format": ["type": "json_schema", "schema": schema]]])
        try await tracingCreate(client, extraBody: ["output_config": ["effort": "high"]])
        try await tracingCreate(client, extraBody: ["output_config": ["format": ["type": "other"]]])
        try await tracingBetaCreate(client, extraBody: ["output_format": ["type": "other"]])
        try await tracingBetaCreate(client, extraBody: ["output_format": ["type": "json_schema", "schema": schema]])
        _ = try await client.beta.messages.parse(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test",
                                                 outputFormat: TracingCity.self)
        try await client.beta.messages.stream(maxTokens: 1024, messages: tracingBetaMessages(tracingHello), model: "claude-test",
                                              outputFormat: TracingCity.self).close()

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 7)
        for span in calls[1...3] { #expect(span["gen_ai.output.type"] == nil) }
        for span in [calls[0], calls[4], calls[5], calls[6]] { #expect(span["gen_ai.output.type"] == "json") }
    }

    @Test func spansThatStartDuringTheCallAreChildrenOfTheCallSpan() async throws {
        let spans = TracingSpans()
        let tracer = try spans.provider.tracer("app", version: nil)
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .custom { request in
            // What an application's transport or HTTP instrumentation does while the SDK sends.
            tracer.withActiveSpan("app.transport") { _ in HTTPResponse.json(tracingMessage, for: request) }
        })
        try await tracingCreate(try tracingClient(spans, router))

        let call = try spans.one("anthropic.messages.create")
        #expect(try spans.one("app.transport").parent?.spanID == call.spanID)
        #expect(try spans.one("app.transport").traceID == call.traceID)
        #expect(!TracingContext.currentSpan.context.isValid)
    }

    @Test func callSpanIsOpenButNotCurrentWhileTheApplicationReadsAStream() async throws {
        let spans = TracingSpans()
        let tracer = try spans.provider.tracer("app", version: nil)
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .sse(tracingStreamEvents()))

        let stream = try await tracingCreateStream(try tracingClient(spans, router))
        #expect(!TracingContext.currentSpan.context.isValid)
        for try await _ in stream {
            #expect(!TracingContext.currentSpan.context.isValid)
            #expect(spans.named("anthropic.messages.create").isEmpty)
            // So what the application does between events is not a child of the call span.
            tracer.withActiveSpan("app.work") { _ in }
        }

        #expect(try spans.one("anthropic.messages.create").statusCode == .ok)
        #expect(spans.named("app.work").allSatisfy { $0.parent == nil })
    }

    @Test func requestAttributesAreOnTheSpanFromItsStart() async throws {
        let sampler = TracingStartAttributes()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage))
        router.route("POST", "/v1/messages/count_tokens", .json(["input_tokens": 7]))
        let client = try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))

        var option = client.openTelemetry
        option.conversationID = "conv_1"
        try await tracingCreate(try client.withOptions(openTelemetry: option), extraHeaders: ["anthropic-beta": "a, b"],
                                extraBody: ["service_tier": "auto"])
        _ = try await client.messages.countTokens(messages: tracingMessages(tracingHello), model: "claude-test")

        #expect(sampler.started.map(\.0) == ["anthropic.messages.create", "anthropic.messages.count_tokens"])
        #expect(sampler.started[0].1 == [
            "server.address": "127.0.0.1",
            "server.port": 4010,
            "http.request.method": "POST",
            "http.route": "/v1/messages",
            "gen_ai.provider.name": "anthropic",
            "gen_ai.conversation.id": "conv_1",
            "gen_ai.operation.name": "chat",
            "gen_ai.request.model": "claude-test",
            "gen_ai.request.max_tokens": 1024,
            "anthropic.request.service_tier": "auto",
            "anthropic.beta": .stringArray(["a", "b"]),
        ])
        #expect(sampler.started[1].1 == [
            "server.address": "127.0.0.1",
            "server.port": 4010,
            "http.request.method": "POST",
            "http.route": "/v1/messages/count_tokens",
            "gen_ai.provider.name": "anthropic",
            "gen_ai.request.model": "claude-test",
        ])
    }

    @Test(arguments: [false, true])
    func batchCreateStartsItsSpanWithTheRequestCount(beta: Bool) async throws {
        let sampler = TracingStartAttributes()
        let router = TracingRouter()
        router.route("POST", "/v1/messages/batches", .json(tracingBatch()))
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch()))
        router.route("GET", "/v1/messages/batches", .json(["data": [], "has_more": false, "first_id": nil, "last_id": nil]))
        let client = try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))
        let params: JSONValue = ["max_tokens": 1, "messages": [["role": "user", "content": "Hi"]], "model": "claude-test"]
        let requests: [JSONValue] = ["a", "b", "c"].map { ["custom_id": .string($0), "params": params] }

        if beta {
            _ = try await client.beta.messages.batches.create(requests: requests.map { try $0.decode() })
            _ = try await client.beta.messages.batches.retrieve("msgbatch_1")
            _ = try await client.beta.messages.batches.list()
            _ = try await client.beta.messages.batches.create(requests: [])
        } else {
            _ = try await client.messages.batches.create(requests: requests.map { try $0.decode() })
            _ = try await client.messages.batches.retrieve("msgbatch_1")
            _ = try await client.messages.batches.list()
            _ = try await client.messages.batches.create(requests: [])
        }

        let creates = sampler.started.filter { $0.0 == "anthropic.messages.batches.create" }
        #expect(creates.map { $0.1["anthropic.message.batch.request_count"] } == [3, 0])
        #expect(sampler.startedWith("anthropic.messages.batches.retrieve")?["anthropic.message.batch.request_count"] == nil)
        #expect(sampler.startedWith("anthropic.messages.batches.list")?["anthropic.message.batch.request_count"] == nil)
    }

    @Test func serverAttributesAreOnTheSpanFromItsStart() async throws {
        let sampler = TracingStartAttributes()
        let option = OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler))
        let router = TracingRouter()
        router.route("POST", "/v1/messages", .json(tracingMessage), .sse(tracingStreamEvents()))
        router.route("POST", "/v1/messages/count_tokens", .json(["input_tokens": 7]))
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch()))
        let model: JSONValue = ["id": "model_1", "type": "model", "display_name": "Model", "lifecycle": "active", "created_at": "2024-01-01T00:00:00Z"]
        router.route("GET", "/v1/models", .json(["data": [model], "has_more": true, "first_id": "model_1", "last_id": "model_1"]),
                     .json(["data": [model], "has_more": false, "first_id": "model_1", "last_id": "model_1"]))
        router.route("POST", "~^https://bedrock-runtime\\.us-east-1\\.amazonaws\\.com/", .json(tracingMessage))
        router.route("POST", "~^https://us-east5-aiplatform\\.googleapis\\.com/", .json(tracingMessage))

        let client = try tracingClient(nil, router, openTelemetry: option)
        try await tracingCreate(client)
        await tracingDrain(try await tracingCreateStream(client))
        try await client.messages.stream(maxTokens: 1024, messages: tracingMessages(tracingHello), model: "claude-test").untilDone()
        _ = try await client.messages.countTokens(messages: tracingMessages(tracingHello), model: "claude-test")
        _ = try await client.messages.batches.retrieve("msgbatch_1")
        var models = 0
        for try await _ in try await client.models.list() { models += 1 }
        #expect(models == 2)
        try await tracingCreate(try tracingBedrock(router, option))
        try await tracingCreate(try tracingVertex(router, option))

        #expect(sampler.started.map { "\($0.0) \($0.1["server.address"]!) \($0.1["server.port"]!)" } == [
            "anthropic.messages.create 127.0.0.1 4010",
            "anthropic.messages.create 127.0.0.1 4010",
            "anthropic.messages.create 127.0.0.1 4010",
            "anthropic.messages.count_tokens 127.0.0.1 4010",
            "anthropic.messages.batches.retrieve 127.0.0.1 4010",
            "anthropic.models.list 127.0.0.1 4010",
            "anthropic.models.list 127.0.0.1 4010",
            "anthropic.messages.create bedrock-runtime.us-east-1.amazonaws.com 443",
            "anthropic.messages.create us-east5-aiplatform.googleapis.com 443",
        ])
    }

    @Test func batchMethodsRecordTheBatchIDThatTheyAreGiven() async throws {
        // The ID comes from the method's argument, so the span has it whatever the URL is and however the call ends.
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/messages/batches/msgbatch_1", .json(tracingBatch(resultsURL: "https://files.example.com/download/abc")))
        router.route("GET", "https://files.example.com/download/abc", .text(""))
        router.route("DELETE", "/v1/messages/batches/msgbatch_1", .json([:], status: 404))
        let client = try tracingClient(spans, router, maxRetries: 0)

        _ = try await client.messages.batches.retrieve("msgbatch_1")
        try await client.messages.batches.results("msgbatch_1").close()
        _ = try await client.beta.messages.batches.retrieve("msgbatch_1")
        await #expect(throws: APIStatusError.self) { _ = try await client.messages.batches.delete("msgbatch_1") }

        let retrieves = spans.named("anthropic.messages.batches.retrieve")
        #expect(retrieves.count == 3)
        for span in retrieves + [try spans.one("anthropic.messages.batches.results")] {
            #expect(span["anthropic.message.batch.id"] == "msgbatch_1")
        }
        let failed = try spans.one("anthropic.messages.batches.delete")
        #expect(failed.statusCode == .error)
        #expect(failed["anthropic.message.batch.id"] == "msgbatch_1")
    }

    @Test func thirdPartyProviderNames() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "*", .json(tracingMessage))

        try await tracingCreate(try tracingBedrock(router, spans.option()))
        try await tracingCreate(try tracingVertex(router, spans.option()).withOptions(timeout: 10))

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        let (bedrock, vertex) = (calls[0], calls[1])
        #expect(bedrock["gen_ai.provider.name"] == "aws.bedrock")
        #expect(bedrock["server.address"] == "bedrock-runtime.us-east-1.amazonaws.com")
        #expect(bedrock["server.port"] == 443)
        #expect(vertex["gen_ai.provider.name"] == "gcp.vertex_ai")
        // These clients move the model from the body that they send into the URL. The span reads the body of the call.
        for span in calls {
            #expect(span["gen_ai.request.model"] == "claude-test")
            #expect(span["gen_ai.request.max_tokens"] == 1024)
            #expect(span["gen_ai.response.id"] == "msg_1")
            // The route is the one of the method that the application called, and the URL is where the request went.
            #expect(span["http.request.method"] == "POST")
            #expect(span["http.route"] == "/v1/messages")
        }
        #expect(bedrock.urlAttributes == [
            "url.scheme": "https",
            "url.path": "/model/claude-test/invoke",
            "url.full": "https://bedrock-runtime.us-east-1.amazonaws.com/model/claude-test/invoke",
        ])
        let vertexPath = "/v1/projects/project/locations/us-east5/publishers/anthropic/models/claude-test:rawPredict"
        #expect(vertex.urlAttributes == [
            "url.scheme": "https", "url.path": .string(vertexPath), "url.full": .string("https://us-east5-aiplatform.googleapis.com" + vertexPath),
        ])
    }

    @Test func thirdPartyStreamsAndTokenCountsHaveTheRequestModel() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "~:streamRawPredict$", .sse(tracingStreamEvents()))
        router.route("POST", "~/count-tokens:rawPredict$", .json(["input_tokens": 7]))
        let vertex = try tracingVertex(router, spans.option())

        await tracingDrain(try await tracingCreateStream(vertex))
        _ = try await vertex.messages.countTokens(messages: tracingMessages(tracingHello), model: "claude-test")

        let stream = try spans.one("anthropic.messages.create")
        #expect(stream["gen_ai.request.model"] == "claude-test")
        #expect(stream["gen_ai.request.stream"] == true)
        #expect(stream["gen_ai.usage.output_tokens"] == 5)
        let count = try spans.one("anthropic.messages.count_tokens")
        #expect(count["gen_ai.request.model"] == "claude-test")
        #expect(count["anthropic.message.count_tokens.input_tokens"] == 7)
    }

    @Test func sigV4SignatureDoesNotCoverTheTraceHeadersThatTheSDKReplaces() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = router.route("POST", "*", .json(tracingMessage))
        // A header of the application is a signed header like any other, and the SDK replaces this one's value.
        let headers: Headers = ["traceparent": .value("00-\(TraceID(low: 0xABCD).hex)-\(SpanID(0xEF).hex)-01")]

        try await tracingCreate(try tracingBedrock(router, spans.option()), extraHeaders: headers)

        let request = try #require(route.requests.first)
        let call = try spans.one("anthropic.messages.create")
        #expect(request.headers["traceparent"]?.hasPrefix("00-\(call.traceID.hex)-\(call.spanID.hex)-") == true)
        let authorization = try #require(request.headers["Authorization"])
        // The header is not signed, so that replacing it, here or in an instrumented HTTP client, keeps the signature valid.
        let signed = authorization.components(separatedBy: "SignedHeaders=")[1].split(separator: ",")[0].split(separator: ";")
        #expect(!signed.contains("traceparent"))
        #expect(signed.contains("host"))
    }
}

/// A structured output.
struct TracingCity: StructuredOutput {
    var city: String
    static var jsonSchema: JSONValue { ["type": "object", "properties": ["city": ["type": "string"]], "required": ["city"]] }
}

func tracingBedrock(_ router: TracingRouter, _ option: OpenTelemetryOptions?) throws -> AnthropicBedrock {
    let client = try AnthropicBedrock(awsSecretKey: "secret", awsAccessKey: "access", awsRegion: "us-east-1", transport: router.transport,
                                      openTelemetry: option, environment: [:])
    client.sleeper = { _ in }
    return client
}

func tracingVertex(_ router: TracingRouter, _ option: OpenTelemetryOptions?) throws -> AnthropicVertex {
    let client = try AnthropicVertex(region: "us-east5", projectID: "project", accessToken: "token", transport: router.transport,
                                     openTelemetry: option, environment: [:])
    client.sleeper = { _ in }
    return client
}
