// Port of tests/lib/tools/test_open_telemetry.py, `TestSessionToolRunnerSpans`: the spans of the tools that the
// Sessions tool runner runs, and the conversation ID of the requests that send their results.
//
// Upstream gives a stand-in client a tracer (`_FakeClient` with `_tracer` / `_otel`); here a runner over the fake events
// endpoints (`FakeSessionEvents`) is given a client with spans as its `spanClient`. The other tests go through the
// client over a mock transport.

import Foundation
import Testing
@testable import Anthropic

private func sessionSpanToolUse(_ id: String, _ name: String, _ input: JSONValue = [:], thread: String? = nil,
                                toolset: String? = nil) -> JSONValue
{
    var event: JSONValue = [
        "type": "agent.tool_use", "id": .string(id), "name": .string(name), "input": input, "evaluated_permission": nil,
        "session_thread_id": thread.map { .string($0) } ?? nil,
    ]
    if let toolset { event["toolset_name"] = .string(toolset) }
    return event
}

private func sessionSpanCustomToolUse(_ id: String, _ name: String, _ input: JSONValue = [:], thread: String? = nil) -> JSONValue {
    ["type": "agent.custom_tool_use", "id": .string(id), "name": .string(name), "input": input,
     "session_thread_id": thread.map { .string($0) } ?? nil]
}

private let sessionSpanTerminatedStub: JSONValue = ["type": "session.status_terminated"]

/// `_FakeTool`: a tool without a description.
private func sessionSpanTool(_ name: String, _ run: @escaping @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult?)
    -> BetaFunctionTool
{
    BetaFunctionTool(name: name, inputSchema: ["type": "object"], run)
}

/// A runner over `events` whose tool runs have the spans of `client` (`SessionToolRunner(_FakeClient(...), ...)`).
private func sessionSpanRunner(_ events: any SessionEventsAPI, client: BaseClient, tools: [any BetaRunnableTool],
                               conversationEvents: (@Sendable (String) throws -> any SessionEventsAPI)? = nil) -> SessionToolRunner
{
    SessionToolRunner(events: events, sessionID: "sesn_1", tools: tools, maxIdle: nil, extraHeaders: nil, timings: SessionRunnerTimings(),
                      sendRetryWindow: { nil }, spanClient: client, conversationEvents: conversationEvents)
}

private func sessionSpanCollect(_ runner: SessionToolRunner) async throws -> [DispatchedToolCall] {
    var items: [DispatchedToolCall] = []
    for try await item in runner { items.append(item) }
    return items
}

/// `session_event`.
private func sessionSpanEvent(_ type: String, _ id: String, _ fields: [String: JSONValue] = [:]) -> JSONValue {
    var event: [String: JSONValue] = ["type": .string(type), "id": .string(id), "processed_at": "2026-01-01T00:00:00Z"]
    event.merge(fields) { $1 }
    return .object(event)
}

/// `PRIMARY_THREAD_RUNS`.
private let sessionSpanPrimaryThreadRuns: [JSONValue] = [
    sessionSpanEvent("session.status_running", "sevt_1"),
    sessionSpanEvent("session.thread_status_running", "sevt_2", ["session_thread_id": "sthr_primary", "agent_name": "assistant"]),
    sessionSpanEvent("user.message", "sevt_3", ["content": [["type": "text", "text": "Hello"]]]),
]

/// `TERMINATED`.
private let sessionSpanTerminated = sessionSpanEvent("session.status_terminated", "sevt_9")

/// `echo`.
private func sessionSpanEcho() -> BetaFunctionTool {
    BetaFunctionTool(name: "echo", description: "Gives `x` back.",
                     inputSchema: ["type": "object", "properties": ["x": ["type": "integer", "default": 0]]]) { input in
        .string(String(input["x"]?.intValue ?? 0))
    }
}

/// The routes of the session `sesn_1` (`session_api`): its event history is `history`, and its event stream gives
/// `live`. Reading the history fails when `history` is `nil`.
private struct SessionSpanAPI {
    let router = TracingRouter()
    let stream: TracingRoute
    let list: TracingRoute
    let send: TracingRoute

    init(history: [JSONValue]?, live: [JSONValue]) {
        stream = router.route("GET", "/v1/sessions/sesn_1/events/stream", .sse(live))
        list = router.route("GET", "/v1/sessions/sesn_1/events", history.map { .json(["data": .array($0), "next_page": nil]) }
            ?? .json(["type": "error", "error": ["type": "invalid_request_error", "message": "bad"]], status: 400))
        send = router.route("POST", "/v1/sessions/sesn_1/events", .json(["data": []]))
    }

    func client(_ spans: TracingSpans, _ option: OpenTelemetryOptions? = nil, environment: [String: String] = [:]) throws -> Anthropic {
        try tracingClient(spans, router, openTelemetry: option ?? spans.option(), environment: environment)
    }
}

/// The events endpoints of a runner whose stream and history are stand-ins, and whose results the client sends.
private struct SessionSpanSplitEvents: SessionEventsAPI {
    let fake: FakeSessionEvents
    let real: any SessionEventsAPI

    func listEvents(_ sessionID: String, limit: Int, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        try await fake.listEvents(sessionID, limit: limit, extraHeaders: extraHeaders)
    }

    func streamEvents(_ sessionID: String, extraHeaders: Headers?) async throws -> AsyncThrowingStream<JSONValue, Error> {
        try await fake.streamEvents(sessionID, extraHeaders: extraHeaders)
    }

    func sendEvents(_ sessionID: String, events: [JSONValue], extraHeaders: Headers?) async throws {
        try await real.sendEvents(sessionID, events: events, extraHeaders: extraHeaders)
    }
}

@Suite struct SessionRunnerSpanTests {
    let content = OpenTelemetryTraces(contentMode: .content)
    let metadataOnly = OpenTelemetryTraces(contentMode: .metadataOnly)

    @Test func toolSpan() async throws {
        let spans = TracingSpans()
        let events = FakeSessionEvents(streamEvents: [
            sessionSpanToolUse("sevt_1", "echo", ["x": 42], toolset: "computer"),
            sessionSpanCustomToolUse("sevt_2", "get_weather", thread: "sthr_1"),
            sessionSpanTerminatedStub,
        ])
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: content, conversationID: "c"))
        let tools = [
            sessionSpanTool("echo") { .string("got \($0["x"].map { "\($0)" } ?? "None")") },
            sessionSpanTool("get_weather") { _ in "sunny" },
        ]

        let (items, app) = try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { app in
            (try await sessionSpanCollect(sessionSpanRunner(events, client: client, tools: tools)), app.context.spanID)
        }

        #expect(items.count == 2)
        // An agent-toolset tool (`agent.tool_use`) runs in an anthropic.tool_use span, an application-defined tool
        // (`agent.custom_tool_use`) in an anthropic.custom_tool_use span.
        let custom = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(custom.statusCode == .ok)
        #expect(custom["gen_ai.tool.call.id"] == "sevt_2")
        let tool = try spans.one("anthropic.tool_use echo")
        #expect(tool.kind == .internal)
        #expect(tool.statusCode == .ok)
        #expect(toolSpanParent(tool) == app)
        #expect(tool["gen_ai.tool.call.id"] == "sevt_1")
        #expect(tool.json("gen_ai.tool.call.arguments") == ["x": 42])
        // The content of the `user.tool_result` event, and of the `user.custom_tool_result` event.
        #expect(tool.json("anthropic.tool_result.content") == [["type": "text", "text": "got 42"]])
        #expect(custom.json("anthropic.tool_result.content") == [["type": "text", "text": "sunny"]])
        // Both have the conversation ID that the application set, which comes before an event's thread, and the
        // runner's Session. Only the event of a thread other than the primary one names its thread.
        for span in [custom, tool] {
            #expect(span["gen_ai.tool.call.result"] == nil)
            #expect(span["gen_ai.conversation.id"] == "c")
            #expect(span["anthropic.session.id"] == "sesn_1")
        }
        #expect(custom["anthropic.session.thread.id"] == "sthr_1")
        #expect(tool["anthropic.session.thread.id"] == nil)
        // Only the event that has a `toolset_name` gives its span one.
        #expect(tool["anthropic.toolset.name"] == "computer")
        #expect(custom["anthropic.toolset.name"] == nil)
        // Neither stand-in tool has a description.
        #expect(custom["gen_ai.tool.description"] == nil)
        #expect(tool["gen_ai.tool.description"] == nil)
        #expect(spans.named("anthropic.messages.tool_runner").isEmpty)
        #expect(events.streamHeaders.count == 1 && events.streamHeaders[0] == nil)
    }

    @Test(arguments: ["sampler", "on_start", "on_end"]) func tracingThatFailsLeavesTheRunnerAsItIs(failure: String) async throws {
        let events = FakeSessionEvents(streamEvents: [sessionSpanToolUse("sevt_1", "echo", ["x": 42]), sessionSpanTerminatedStub])
        var option = tracingFailingOption(failure)
        option.traces = content
        let client = try tracingClient(nil, TracingRouter(), openTelemetry: option)

        let items = try await sessionSpanCollect(sessionSpanRunner(events, client: client, tools: [
            sessionSpanTool("echo") { .string("got \($0["x"].map { "\($0)" } ?? "None")") },
        ]))

        try #require(items.count == 1)
        #expect(items[0].isError == false)
        try #require(events.sendCalls.count == 1)
        #expect(events.sendCalls[0].events[0]["content"] == [["type": "text", "text": "got 42"]])
    }

    @Test func blockSentAsItsJSONIsRecordedByItsType() async throws {
        let spans = TracingSpans()
        let browserState: JSONValue = [
            "type": "browser_state", "screenshot": ["type": "base64", "media_type": "image/png", "data": "aGVsbG8="],
            "encrypted_content": "encrypted_0",
        ]
        let toolReference: JSONValue = ["type": "tool_reference", "tool_name": "get_weather"]
        let events = FakeSessionEvents(streamEvents: [sessionSpanCustomToolUse("sevt_1", "browse"), sessionSpanTerminatedStub])
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: content))

        let items = try await sessionSpanCollect(sessionSpanRunner(events, client: client, tools: [
            sessionSpanTool("browse") { _ in .unknown([["type": "text", "text": "Opened the page."], browserState, toolReference]) },
        ]))

        // The result event cannot hold these blocks, so it has each as the text of its JSON (Swift's `json.dumps`
        // sorts the keys).
        let result: JSONValue = [
            "type": "user.custom_tool_result", "custom_tool_use_id": "sevt_1", "is_error": false,
            "content": [
                ["type": "text", "text": "Opened the page."], ["type": "text", "text": .string(pythonJSONDumps(browserState))],
                ["type": "text", "text": .string(pythonJSONDumps(toolReference))],
            ],
        ]
        #expect(events.sendCalls.map { $0.events } == [[result]])
        try #require(items.count == 1)
        #expect(items[0].result == result)
        // A span keeps a text block whole, so it has these blocks by their own types, not as their JSON.
        let span = try spans.one("anthropic.custom_tool_use browse")
        #expect(span.json("anthropic.tool_result.content") == [
            ["type": "text", "text": "Opened the page."], ["type": "browser_state"], ["type": "tool_reference"],
        ])
        let text = try #require(span["anthropic.tool_result.content"]?.stringValue)
        #expect(!text.contains("aGVsbG8=") && !text.contains("encrypted_0"))
    }

    @Test func conversationIDIsTheEventsThreadWhenTheApplicationSetNone() async throws {
        let spans = TracingSpans()
        let events = FakeSessionEvents(streamEvents: [
            sessionSpanToolUse("sevt_1", "echo"), sessionSpanCustomToolUse("sevt_2", "get_weather", thread: "sthr_1"), sessionSpanTerminatedStub,
        ])
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: metadataOnly))
        let ok: @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult? = { _ in "ok" }

        let items = try await sessionSpanCollect(sessionSpanRunner(
            events, client: client, tools: [sessionSpanTool("echo", ok), sessionSpanTool("get_weather", ok)], conversationEvents: { _ in events }))
        #expect(items.count == 2)

        // The platform's spans have the thread ID as their conversation ID.
        let inThread = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(inThread["gen_ai.conversation.id"] == "sthr_1")
        #expect(inThread["anthropic.session.thread.id"] == "sthr_1")
        // An event of the primary thread names no thread, and the Session's ID is no conversation ID.
        let primary = try spans.one("anthropic.tool_use echo")
        #expect(primary["gen_ai.conversation.id"] == nil)
        #expect(primary["anthropic.session.id"] == "sesn_1")
    }

    @Test func requestThatSendsAToolsResultHasTheToolsConversationID() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/sessions/sesn_1/events", .json(["data": []]))
        let ok: @Sendable (BetaToolInput) async throws -> BetaFunctionToolResult? = { _ in "ok" }

        /// The spans of the requests that send the result of a tool call of the primary thread, and then of one of the
        /// thread `sthr_1`. The client sends them; the events that the runner reads are stand-ins.
        func sends(_ option: OpenTelemetryOptions) async throws -> [SpanData] {
            let fake = FakeSessionEvents(streamEvents: [
                sessionSpanToolUse("sevt_1", "echo"), sessionSpanCustomToolUse("sevt_2", "get_weather", thread: "sthr_1"), sessionSpanTerminatedStub,
            ])
            let client = try tracingClient(spans, router, openTelemetry: option)
            spans.exporter.clear()
            let runner = sessionSpanRunner(
                SessionSpanSplitEvents(fake: fake, real: ResourceSessionEvents(resource: client.beta.sessions.events)), client: client,
                tools: [sessionSpanTool("echo", ok), sessionSpanTool("get_weather", ok)],
                conversationEvents: sessionConversationEvents(client, bearer: false))
            #expect(try await sessionSpanCollect(runner).map(\.posted) == [true, true])
            return spans.named("anthropic.sessions.events.send")
        }

        // The application set no conversation ID: the request has the thread ID, as the tool's span has. An event of
        // the primary thread names no thread.
        let first = try await sends(spans.option())
        try #require(first.count == 2)
        #expect(first[0]["gen_ai.conversation.id"] == nil)
        #expect(first[1]["gen_ai.conversation.id"] == "sthr_1")
        #expect(try spans.one("anthropic.custom_tool_use get_weather")["gen_ai.conversation.id"] == "sthr_1")

        // The conversation ID that the application set comes before an event's thread.
        let second = try await sends(spans.option(conversationID: "c"))
        #expect(second.count == 2)
        for send in second { #expect(send["gen_ai.conversation.id"] == "c") }
    }

    @Test(arguments: ["history", "live_stream"]) func primaryThreadsToolHasTheThreadIDThatTheSessionsLogGives(statusEventsIn: String) async throws {
        let spans = TracingSpans()
        // What the platform writes when a session first runs, before the first tool call of its primary thread.
        let log = sessionSpanPrimaryThreadRuns + [sessionSpanEvent("agent.custom_tool_use", "sevt_4", ["name": "echo", "input": ["x": 1]])]
        let api = SessionSpanAPI(history: statusEventsIn == "history" ? log : [],
                                 live: statusEventsIn == "history" ? [sessionSpanTerminated] : log + [sessionSpanTerminated])
        let client = try api.client(spans)

        let runner = try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil)
        #expect(try await sessionSpanCollect(runner).map(\.posted) == [true])

        let tool = try spans.one("anthropic.custom_tool_use echo")
        #expect(tool["gen_ai.conversation.id"] == "sthr_primary")
        #expect(try spans.one("anthropic.sessions.events.send")["gen_ai.conversation.id"] == "sthr_primary")
        // The event names no thread, so neither does its span.
        #expect(tool["anthropic.session.thread.id"] == nil)
        #expect(tool["anthropic.session.id"] == "sesn_1")
        // Learning the thread costs no request: the runner reads the stream and the history, and sends the result.
        #expect(api.stream.requests.count == 1)
        #expect(api.list.requests.map { $0.url.query } == ["limit=1000"])
        #expect(api.send.requests.count == 1)
    }

    @Test func laterThreadEventsDoNotReplaceThePrimaryThread() async throws {
        let spans = TracingSpans()
        let child: [String: JSONValue] = ["session_thread_id": "sthr_child", "agent_name": "researcher"]
        let history = sessionSpanPrimaryThreadRuns + [
            sessionSpanEvent("session.thread_created", "sevt_4", child),
            sessionSpanEvent("session.thread_status_running", "sevt_5", child),
            sessionSpanEvent("agent.custom_tool_use", "sevt_6", ["name": "echo", "input": [:], "session_thread_id": "sthr_child"]),
        ]
        let live = [
            sessionSpanEvent("session.thread_status_idle", "sevt_7", child.merging(["stop_reason": ["type": "end_turn"]]) { $1 }),
            sessionSpanEvent("agent.custom_tool_use", "sevt_8", ["name": "echo", "input": [:]]),
            sessionSpanTerminated,
        ]
        let api = SessionSpanAPI(history: history, live: live)
        let client = try api.client(spans)

        let runner = try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil)
        #expect(try await sessionSpanCollect(runner).map(\.toolUseID) == ["sevt_6", "sevt_8"])

        let named = spans.named("anthropic.custom_tool_use echo")
        try #require(named.count == 2)
        #expect(named[0]["gen_ai.conversation.id"] == "sthr_child")
        #expect(named[0]["anthropic.session.thread.id"] == "sthr_child")
        #expect(named[1]["gen_ai.conversation.id"] == "sthr_primary")
        #expect(named[1]["anthropic.session.thread.id"] == nil)
        #expect(spans.named("anthropic.sessions.events.send").map { $0["gen_ai.conversation.id"] } == ["sthr_child", "sthr_primary"])
    }

    @Test func requestThatSendsAToolsResultHasTheEnvironmentKeysCredentialsAlone() async throws {
        let spans = TracingSpans()
        let history = sessionSpanPrimaryThreadRuns + [
            sessionSpanEvent("agent.custom_tool_use", "sevt_4", ["name": "echo", "input": [:]]),
            sessionSpanEvent("agent.custom_tool_use", "sevt_5", ["name": "echo", "input": [:], "session_thread_id": "sthr_child"]),
        ]
        let api = SessionSpanAPI(history: history, live: [sessionSpanTerminated])
        // A custom header goes before a client's own credentials, and each new client reads these again.
        let client = try api.client(spans, environment: [
            "ANTHROPIC_CUSTOM_HEADERS": "Authorization: Bearer env-secret\nX-Api-Key: env-api-key", "ANTHROPIC_API_KEY": "env-account-key",
        ])

        let runner = try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil, environmentKey: "env_key")
        #expect(try await sessionSpanCollect(runner).map(\.posted) == [true, true])

        #expect(spans.named("anthropic.sessions.events.send").map { $0["gen_ai.conversation.id"] } == ["sthr_primary", "sthr_child"])
        let requests = api.stream.requests + api.list.requests + api.send.requests
        #expect(requests.map { $0.method.uppercased() } == ["GET", "GET", "POST", "POST"])
        for request in requests {
            #expect(request.headers["authorization"] == "Bearer env_key")
            #expect(request.headers["x-api-key"] == nil)
        }
    }

    @Test(arguments: [nil, "env_key"] as [String?])
    func clientThatSendsAThreadsResultsHasTheClientsOtherOptions(environmentKey: String?) async throws {
        let spans = TracingSpans()
        let history = sessionSpanPrimaryThreadRuns + [
            sessionSpanEvent("agent.custom_tool_use", "sevt_4", ["name": "echo", "input": [:], "session_thread_id": "sthr_child"]),
        ]
        let traces = OpenTelemetryTraces(contentMode: .content, maxContentBytes: 4096)
        let api = SessionSpanAPI(history: history, live: [sessionSpanTerminated])
        let client = try api.client(spans, spans.option(traces: traces))

        let runner = try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil, environmentKey: environmentKey)
        #expect(try await sessionSpanCollect(runner).map(\.posted) == [true])

        // The copy is given a whole option, which replaces the client's: the client's own with the thread's ID.
        let scoped = try sessionScopedClient(client, environmentKey: environmentKey)
        let events = try sessionConversationEvents(scoped, bearer: environmentKey != nil)("sthr_child")
        let sender = try #require((events as? ResourceSessionEvents)?.resource.client as? Anthropic)
        #expect(sender !== client)
        var expected = client.openTelemetry
        expected.conversationID = "sthr_child"
        #expect(sender.openTelemetry == expected)
        #expect(sender.openTelemetry.traces == OpenTelemetryTraces(enabled: true, contentMode: .content, maxContentBytes: 4096))
        // Its span goes to the client's tracer provider.
        #expect(try spans.one("anthropic.sessions.events.send")["gen_ai.conversation.id"] == "sthr_child")
    }

    @Test func applicationsConversationIDComesBeforeThePrimaryThread() async throws {
        let spans = TracingSpans()
        let history = sessionSpanPrimaryThreadRuns + [sessionSpanEvent("agent.custom_tool_use", "sevt_4", ["name": "echo", "input": [:]])]
        let api = SessionSpanAPI(history: history, live: [sessionSpanTerminated])
        let client = try api.client(spans, spans.option(conversationID: "c"))

        let runner = try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil)
        #expect(try await sessionSpanCollect(runner).map(\.posted) == [true])

        #expect(try spans.one("anthropic.custom_tool_use echo")["gen_ai.conversation.id"] == "c")
        #expect(try spans.one("anthropic.sessions.events.send")["gen_ai.conversation.id"] == "c")
    }

    @Test func liveStreamAloneDoesNotTellThePrimaryThread() async throws {
        let spans = TracingSpans()
        // Without the history, the first thread event that the stream gives may be that of another thread.
        let live = [
            sessionSpanEvent("session.thread_status_running", "sevt_5", ["session_thread_id": "sthr_child", "agent_name": "a"]),
            sessionSpanEvent("agent.custom_tool_use", "sevt_6", ["name": "echo", "input": [:]]),
            sessionSpanTerminated,
        ]
        let api = SessionSpanAPI(history: nil, live: live)
        let client = try api.client(spans)

        let (calls, _) = try await ToolDiagnostics.capture {
            try await sessionSpanCollect(try client.beta.sessions.events.toolRunner("sesn_1", tools: [sessionSpanEcho()], maxIdle: nil))
        }
        #expect(calls.map(\.posted) == [true])

        #expect(try spans.one("anthropic.custom_tool_use echo")["gen_ai.conversation.id"] == nil)
        #expect(try spans.one("anthropic.sessions.events.send")["gen_ai.conversation.id"] == nil)
    }

    @Test func toolDescription() async throws {
        let spans = TracingSpans()
        let events = FakeSessionEvents(streamEvents: [
            sessionSpanToolUse("sevt_1", "read", ["city": "SF"]), sessionSpanCustomToolUse("sevt_2", "get_weather", ["city": "SF"]),
            sessionSpanTerminatedStub,
        ])
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: metadataOnly))

        let items = try await sessionSpanCollect(sessionSpanRunner(events, client: client, tools: [
            toolSpanWeatherTool(name: "read", description: "Reads the weather."), toolSpanWeatherTool(),
        ]))
        #expect(items.count == 2)

        // The description is metadata, so both spans have it without content mode.
        let agentTool = try spans.one("anthropic.tool_use read")
        #expect(agentTool["gen_ai.tool.description"] == "Reads the weather.")
        #expect(agentTool["gen_ai.tool.call.arguments"] == nil)
        let custom = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(custom["gen_ai.tool.description"] == "The weather in a city.")
        // The application set no conversation ID on this runner.
        #expect(custom["gen_ai.conversation.id"] == nil)
        #expect(custom["anthropic.session.id"] == "sesn_1")
    }
}
