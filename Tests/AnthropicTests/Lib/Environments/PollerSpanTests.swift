// Port of the OpenTelemetry span tests of tests/lib/environments/test_poller_method.py: the span of each work item.
//
// These go through a real client over a mock transport, so that the spans of the poller's own requests are there to
// be the children of the item's span. The sync `iter_work` case of each test is its async twin here.

import Foundation
import Testing
@testable import Anthropic

/// `_work_json`.
func envSpanWorkJSON(_ workID: String) -> JSONValue {
    [
        "id": .string(workID), "type": "work", "environment_id": "env_1", "state": "active", "created_at": "2026-01-01T00:00:00Z",
        "metadata": [:], "data": ["type": "session", "id": .string("sesn_\(workID)")],
    ]
}

/// `NO_WORK`.
let envSpanNoWork: TracingReply = .text("null", headers: ["content-type": "application/json"])

/// `_mock_work_api`: the poll route answers with `polls`, and each action route with the work item.
@discardableResult
func envSpanMockWorkAPI(_ router: TracingRouter, _ polls: [TracingReply], actions: [String] = ["ack", "stop"]) -> [String: TracingRoute] {
    var routes = ["poll": router.route("GET", "/v1/environments/env_1/work/poll", replies: polls)]
    for action in actions {
        routes[action] = router.route("POST", "~/v1/environments/env_1/work/\\w+/\(action)$", .json(envSpanWorkJSON("work_1")))
    }
    return routes
}

/// The poller of `client.beta.environments.work.poller(environment_id="env_1", environment_key="env_key", ...)`.
func envSpanPoller(_ client: Anthropic, blockMs: Int? = POLL_BLOCK_MS, drain: Bool = false, autoStop: Bool = true) throws -> EnvironmentWorkPoller {
    try client.beta.environments.work.poller(environmentID: "env_1", environmentKey: "env_key", blockMs: blockMs, drain: drain, autoStop: autoStop)
}

@Suite struct PollerSpanTests {
    @Test func eachWorkItemHasASpanUntilTheNextItem() async throws {
        let sampler = TracingStartAttributes()
        let spans = TracingSpans(sampler: sampler)
        let router = TracingRouter()
        envSpanMockWorkAPI(router, [.json(envSpanWorkJSON("work_1")), .json(envSpanWorkJSON("work_2")), envSpanNoWork])
        let client = try tracingClient(spans, router)
        let app = spans.provider.tracer("app", version: nil)

        // What the consumer sees while it has each item: the current span, and how many item spans have ended.
        var seen: [(String, SpanID, Int)] = []
        let appSpan = try await app.withActiveSpan("app") { appSpan in
            for try await item in try envSpanPoller(client, blockMs: nil, drain: true) {
                seen.append((item.id, TracingContext.currentSpan.context.spanID, spans.named("anthropic.environment.work").count))
                app.withActiveSpan("app.handle") { _ in }
            }
            return appSpan.context.spanID
        }

        // An item's span is open, and not current, in the consumer's code, and asking for the next item ends it.
        #expect(seen.map { $0.0 } == ["work_1", "work_2"])
        #expect(seen.map { $0.1 } == [appSpan, appSpan])
        #expect(seen.map { $0.2 } == [0, 1])
        let items = spans.named("anthropic.environment.work")
        try #require(items.count == 2)
        for (span, workID) in zip(items, ["work_1", "work_2"]) {
            #expect(toolSpanParent(span) == appSpan)
            #expect(span.kind == .internal)
            #expect(span.statusCode == .ok)
            #expect(span.attributes == [
                "gen_ai.provider.name": "anthropic", "anthropic.environment.id": "env_1", "anthropic.environment.work.id": .string(workID),
                "anthropic.session.id": .string("sesn_\(workID)"),
            ])
        }
        #expect(sampler.started.last { $0.0 == "anthropic.environment.work" }?.1 == items[1].attributes)
        // The requests for an item are in its span, and a poll is in the span that is current when it is sent.
        for name in ["anthropic.environments.work.ack", "anthropic.environments.work.stop"] {
            #expect(spans.named(name).map(toolSpanParent) == [items[0].spanID, items[1].spanID])
        }
        #expect(Set(spans.named("anthropic.environments.work.poll").map(toolSpanParent)) == [appSpan])
        // So is a span that the consumer starts for an item, which makes it a sibling of the item's span.
        #expect(spans.named("app.handle").map(toolSpanParent) == [appSpan, appSpan])
    }

    @Test func workSpanEndsOKWhenTheConsumerStopsPolling() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        // The consumer owns the stop request, so the poller sends none.
        envSpanMockWorkAPI(router, [.json(envSpanWorkJSON("work_1"))], actions: ["ack"])
        let poller = try envSpanPoller(try tracingClient(spans, router), autoStop: false)

        _ = try await poller.next()
        #expect(spans.named("anthropic.environment.work").isEmpty)
        await poller.close()

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .ok)
        // No span was current around the consumer's calls, so the item's span is a root span.
        #expect(span.parent == nil)
    }

    @Test func workSpanFailsWhenTheItemCannotBeAcked() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/environments/env_1/work/poll", .json(envSpanWorkJSON("work_1")), envSpanNoWork)
        router.route("POST", "/v1/environments/env_1/work/work_1/ack",
                     .json(["type": "error", "error": ["type": "not_found_error", "message": "No such work."]], status: 404))
        router.route("POST", "/v1/environments/env_1/work/work_1/stop", .json(envSpanWorkJSON("work_1")))

        var ids: [String] = []
        let (_, _) = try await ToolDiagnostics.capture {
            for try await item in try envSpanPoller(try tracingClient(spans, router), blockMs: nil, drain: true) { ids.append(item.id) }
        }
        #expect(ids.isEmpty)

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .error)
        // The type of the failed request's span.
        let ack = try spans.one("anthropic.environments.work.ack")
        #expect(span["error.type"] == "not_found_error")
        #expect(ack["error.type"] == "not_found_error")
        #expect(toolSpanParent(try spans.one("anthropic.environments.work.stop")) == span.spanID)
    }

    @Test func workSpanHasNoStatusWhenPollingIsInterruptedDuringTheAck() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("GET", "/v1/environments/env_1/work/poll", .json(envSpanWorkJSON("work_1")))
        // A cancellation is the application stopping the poller.
        router.route("POST", "/v1/environments/env_1/work/work_1/ack", .fail(CancellationError()))
        let poller = try envSpanPoller(try tracingClient(spans, router))

        await #expect(throws: CancellationError.self) { _ = try await poller.next() }

        let span = try spans.one("anthropic.environment.work")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
    }

    @Test(arguments: ["sampler", "on_start", "on_end"]) func tracingThatFailsLeavesThePollerAsItIs(failure: String) async throws {
        let router = TracingRouter()
        let routes = envSpanMockWorkAPI(router, [.json(envSpanWorkJSON("work_1")), .json(envSpanWorkJSON("work_2")), envSpanNoWork])
        let client = try tracingClient(nil, router, openTelemetry: tracingFailingOption(failure))

        var ids: [String] = []
        for try await item in try envSpanPoller(client, blockMs: nil, drain: true) { ids.append(item.id) }

        #expect(ids == ["work_1", "work_2"])
        // Three polls, and an ack and a stop for each item.
        #expect(routes.values.reduce(0) { $0 + $1.requests.count } == 7)
    }
}
