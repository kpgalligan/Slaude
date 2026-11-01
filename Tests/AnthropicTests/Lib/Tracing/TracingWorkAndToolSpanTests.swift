// The spans of `lib/_tracing/_tools.py` and `lib/_tracing/_work.py`: Swift-only checks of the helpers that the runners
// call. Their upstream tests, which drive the runners, the poller and the worker, are ported in
// `Lib/Tools/ToolRunnerSpanTests.swift`, `SessionRunnerSpanTests.swift` and `Lib/Environments/*SpanTests.swift`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TracingWorkAndToolSpanTests {
    @Test func workSpanEndsWithHowTheItemWasHandled() throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter())

        let work = WorkSpan()
        work.start(client, environmentID: "env_1", workID: "work_1", sessionID: "sesn_1")
        #expect(work.span != nil)
        work.end()
        work.end()
        work.start(client, environmentID: "env_1", workID: "work_2", sessionID: nil)
        work.end(error: TracingTestError("failed"))
        work.start(client, environmentID: "env_1", workID: "work_3", sessionID: nil)
        work.end(finished: false)
        work.start(client, environmentID: "env_1", workID: "work_4", sessionID: nil)
        work.end(error: CancellationError())

        let items = spans.named("anthropic.environment.work")
        try #require(items.count == 4)
        #expect(items[0].kind == .internal)
        #expect(items[0].attributes == ["gen_ai.provider.name": "anthropic", "anthropic.environment.id": "env_1",
                                        "anthropic.environment.work.id": "work_1", "anthropic.session.id": "sesn_1"])
        #expect(items.map(\.statusCode) == [.ok, .error, .unset, .unset])
        #expect(items[1]["error.type"] == "client_error")

        let quiet = try tracingClient(spans, TracingRouter(), openTelemetry: .disabled)
        let none = WorkSpan()
        none.start(quiet, environmentID: "env_1", workID: "work_5", sessionID: nil)
        #expect(none.span == nil)
    }

    @Test func toolUseSpanEndsWithTheResultOfTheRun() async throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: OpenTelemetryTraces(contentMode: .content),
                                                                                            conversationID: "conv_1"))

        let current = try await client.withToolUseSpan(toolUseID: "toolu_1", toolName: "get_weather", description: "The weather", input: ["city": "SF"]) {
            run in
            run.result = ["type": "tool_result", "tool_use_id": "toolu_1", "content": "sunny"]
            return TracingContext.currentSpan.context
        }
        await client.withToolUseSpan(toolUseID: "toolu_2", toolName: "click", input: [:], agentTool: true) { run in
            run.result = ["type": "tool_result", "tool_use_id": "toolu_2", "content": "no", "is_error": true]
        }
        await client.withToolUseSpan(toolUseID: "toolu_3", toolName: "echo", input: [:], mcpTool: true) { _ in }

        let weather = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(current.spanID == weather.spanID)
        #expect(weather.statusCode == .ok)
        #expect(weather["gen_ai.operation.name"] == "execute_tool")
        #expect(weather["gen_ai.tool.description"] == "The weather")
        #expect(weather["gen_ai.conversation.id"] == "conv_1")
        #expect(weather.json("gen_ai.tool.call.arguments") == ["city": "SF"])
        #expect(weather.json("anthropic.tool_result.content") == [["type": "text", "text": "sunny"]])
        let click = try spans.one("anthropic.tool_use click")
        #expect(click.statusCode == .error && click["error.type"] == "tool_error")
        // A run that made no result leaves the status unset.
        #expect(try spans.one("anthropic.mcp_tool_use echo").statusCode == .unset)
    }

    @Test func toolRunnerSpan() throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter())

        let span = client.startToolRunnerSpan(model: "claude-test", jsonOutput: true)
        setToolRunnerStatus(span)
        endToolRunnerSpan(span)

        let runner = try spans.one("anthropic.messages.tool_runner")
        #expect(runner.statusCode == .ok)
        #expect(runner.attributes == ["gen_ai.operation.name": "invoke_agent", "gen_ai.provider.name": "anthropic",
                                      "gen_ai.request.model": "claude-test", "gen_ai.output.type": "json"])
        #expect(try tracingClient(spans, TracingRouter(), openTelemetry: .disabled).startToolRunnerSpan(model: "m", jsonOutput: false) == nil)
    }
}
