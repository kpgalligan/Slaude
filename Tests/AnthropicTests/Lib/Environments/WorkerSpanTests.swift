// Port of the OpenTelemetry span tests of tests/lib/environments/test_worker.py: the span of each work item.
//
// The worker polls with its real poller here, which starts the span of each item that a poll returns. The work API
// of its clients answers the polls with the given items and acks them (`_PolledWorkResource`), and sends the heartbeat
// and stop requests to `EnvWorkerAPI`; the session tool runner is replaced, as in the other worker tests.

import Foundation
import Testing
@testable import Anthropic

/// Ends a worker's poll loop once its queue is empty (`_StopRun`).
struct EnvSpanStopRun: Error {}

/// The work API of a client that has spans, which answers the worker's polls with `items` (`_PolledWorkResource`).
final class EnvSpanPolledWork: EnvironmentWorkAPI, @unchecked Sendable {
    let inner: any EnvironmentWorkAPI
    let items: ToolsBox<[BetaSelfHostedWork]>
    let spanClient: BaseClient?

    init(inner: any EnvironmentWorkAPI, items: ToolsBox<[BetaSelfHostedWork]>, spanClient: BaseClient) {
        self.inner = inner
        self.items = items
        self.spanClient = spanClient
    }

    func poll(_ environmentID: String, blockMs: Int?, reclaimOlderThanMs: Int?, workerID: String,
              extraHeaders: Headers?) async throws -> BetaSelfHostedWork?
    {
        var next: BetaSelfHostedWork?
        items.mutate { if !$0.isEmpty { next = $0.removeFirst() } }
        guard let next else { throw EnvSpanStopRun() }
        return next
    }

    func ack(_ workID: String, environmentID: String, extraHeaders: Headers?) async throws {}

    func stop(_ workID: String, environmentID: String, force: Bool?, extraHeaders: Headers?) async throws {
        try await inner.stop(workID, environmentID: environmentID, force: force, extraHeaders: extraHeaders)
    }

    func heartbeat(_ workID: String, environmentID: String, expectedLastHeartbeat: String,
                   extraHeaders: Headers?) async throws -> BetaSelfHostedWorkHeartbeatResponse
    {
        try await inner.heartbeat(workID, environmentID: environmentID, expectedLastHeartbeat: expectedLastHeartbeat, extraHeaders: extraHeaders)
    }
}

private let envSpanLeaseLostBody: JSONValue = [
    "type": "error",
    "error": [
        "type": "invalid_request_error", "message": "Heartbeat precondition failed: expected hb-1, actual was NULL",
        "details": [
            "error_code": "heartbeat_precondition_failed", "error_visibility": "user_facing",
            "current_state": ["state": "queued", "last_heartbeat": nil, "lease_updated_at": nil, "lease_extended": false, "ttl_seconds": 120],
        ],
    ],
]

/// `_polling_worker`: a worker that polls `items` and serves each session with `serve`.
private func envSpanPollingWorker(_ api: EnvWorkerAPI, _ spans: TracingSpans, items: [BetaSelfHostedWork],
                                  serve: @escaping @Sendable () async throws -> Void) throws -> EnvironmentWorker
{
    let queue = ToolsBox(items)
    let spanClient = try tracingClient(spans, TracingRouter())
    var hooks = EnvironmentWorkerHooks()
    hooks.environment = { [:] }
    hooks.workAPI = { client in
        EnvSpanPolledWork(inner: ResourceEnvironmentWork(resource: client.beta.environments.work), items: queue, spanClient: spanClient)
    }
    hooks.runSessionTools = { _ in
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    try await serve()
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }
    return try envWorker(api, hooks: hooks, tools: .list([]))
}

/// A session that never ends on its own (`_never`), and lets the heartbeat answer once it is being served.
private func envSpanServeUntilTheHeartbeatEndsIt(_ api: EnvWorkerAPI) -> @Sendable () async throws -> Void {
    let serve = envServeUntilTheHeartbeatEndsIt(api)
    return { await serve() }
}

@Suite struct WorkerSpanTests {
    @Test func environmentWorkerHandlesAnItemInItsSpan() async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        let current = ToolsBox<[SpanID]>([])
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1"), envWork("w_2", environmentID: "e_1")]) {
            current.mutate { $0.append(TracingContext.currentSpan.context.spanID) }
        }

        let appSpan = await spans.provider.tracer("app", version: nil).withActiveSpan("app") { app in
            await #expect(throws: EnvSpanStopRun.self) { try await envWithTimeout { try await worker.run() } }
            return app.context.spanID
        }

        let items = spans.named("anthropic.environment.work")
        try #require(items.count == 2)
        // Whatever the worker does for an item has the item's span current, so its spans are children of it.
        #expect(current.value == [items[0].spanID, items[1].spanID])
        for (span, workID) in zip(items, ["w_1", "w_2"]) {
            #expect(toolSpanParent(span) == appSpan)
            #expect(span.kind == .internal)
            #expect(span.statusCode == .ok)
            #expect(span.attributes == [
                "gen_ai.provider.name": "anthropic", "anthropic.environment.id": "e_1", "anthropic.environment.work.id": .string(workID),
                "anthropic.session.id": "s_1",
            ])
        }
    }

    @Test func environmentWorkerEndsTheSpanOKWhenTheItemIsStopped() async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        // The first heartbeat says that the item is stopping, which ends its handling without an error.
        api.heartbeatState = "stopping"
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1")],
                                              serve: envSpanServeUntilTheHeartbeatEndsIt(api))

        await #expect(throws: EnvSpanStopRun.self) { try await envWithTimeout { try await worker.run() } }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .ok)
        // No span was current when the worker started, so the item's span is a root span.
        #expect(span.parent == nil)
    }

    @Test(arguments: ["api-error", "other-error"]) func environmentWorkerFailsTheSpanOfAnItemThatItCannotHandle(error: String) async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        let failure: any Error = error == "api-error"
            ? envAPIStatusError(404, body: ["type": "error", "error": ["type": "not_found_error", "message": "gone"]])
            : RuntimeError("the tools could not start")
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1")]) { throw failure }

        _ = await ToolDiagnostics.capture {
            await #expect(throws: EnvSpanStopRun.self) { try await envWithTimeout { try await worker.run() } }
        }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .error)
        #expect(span["error.type"] == (error == "api-error" ? "not_found_error" : "client_error"))
    }

    @Test(arguments: ["lease-lost", "heartbeat-rejected"]) func environmentWorkerLeavesTheSpanUnsetWhenItLosesTheLease(heartbeat: String) async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        if heartbeat == "lease-lost" {
            api.heartbeatStatus = 412
            api.heartbeatBody = envSpanLeaseLostBody
        } else {
            api.heartbeatStatus = 403
        }
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1")],
                                              serve: envSpanServeUntilTheHeartbeatEndsIt(api))

        _ = await ToolDiagnostics.capture {
            await #expect(throws: EnvSpanStopRun.self) { try await envWithTimeout { try await worker.run() } }
        }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
    }

    @Test func environmentWorkerLeavesTheSpanUnsetWhenLosingTheLeaseRaisesAnError() async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        api.heartbeatStatus = 412
        api.heartbeatBody = envSpanLeaseLostBody
        // The heartbeat finds the lease lost once the worker serves the session.
        let serving = EnvEvent()
        api.heartbeatGate = serving
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1")]) {
            serving.set()
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            // What the lost lease interrupts fails in turn.
            throw RuntimeError("the connection was dropped")
        }

        _ = await ToolDiagnostics.capture {
            await #expect(throws: EnvSpanStopRun.self) { try await envWithTimeout { try await worker.run() } }
        }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
    }

    @Test func environmentWorkerLeavesTheSpanUnsetWhenItIsStopped() async throws {
        let spans = TracingSpans()
        let api = EnvWorkerAPI()
        let serving = EnvEvent()
        let worker = try envSpanPollingWorker(api, spans, items: [envWork("w_1", environmentID: "e_1")]) {
            serving.set()
            try await Task.sleep(nanoseconds: 30_000_000_000)
        }

        let run = Task { try await worker.run() }
        try await envWithTimeout { await serving.wait() }
        run.cancel()
        await #expect(throws: (any Error).self) { try await run.value }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
    }
}
