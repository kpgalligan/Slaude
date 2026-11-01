// Port of tests/lib/tools/test_runners.py (part 1: the recorded runs, stop reasons and tool changes).
//
// Upstream runs each test against a sync and an async client; the Swift runner is async only, so each pair is
// ported once. Tests that only exist in a `_sync` form exercise behaviour the async runner shares and are ported
// as well.

import Foundation
import Testing
@testable import Anthropic

private func weatherRunner(_ client: Anthropic, tools: [any BetaToolLike], messages: [JSONValue]? = nil,
                           maxIterations: Int? = nil, thread: Bool? = nil, model: ModelParam = "claude-haiku-4-5") throws -> BetaToolRunner
{
    try client.beta.messages.toolRunner(
        maxTokens: 1024, messages: try (messages ?? [["role": "user", "content": "What is the weather in SF?"]]).map(param),
        model: model, tools: tools, maxIterations: maxIterations, thread: thread)
}

private func text(of message: BetaMessage) -> String? {
    for block in message.content { if case .text(let t) = block { return t.text } }
    return nil
}

@Suite struct RunToolsRecordedTests {
    @Test func basicCall() async throws {
        let mock = try snapshotMock("b38bbf6c-9a76-40ca-b09d-7a3911776e0f")
        let first = mock.bodiesServed()
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool()]).untilDone()
        #expect(message.stopReason == .endTurn)
        #expect(message.id == first[1]["id"]?.stringValue)
        #expect(text(of: message)?.contains("San Francisco") == true)
        #expect(mock.calls == 2)

        // On a message thread the first request creates the thread and the second sends only the tool result.
        let bodies = mock.bodies
        #expect(bodies[0]["thread"] == ["type": "create"])
        #expect(bodies[0]["messages"] == [["role": "user", "content": "What is the weather in SF?"]])
        #expect(bodies[0]["tools"] == [try weatherTool().toToolParam()])
        let toolUseID = first[0]["content"]?[0]?["id"] ?? .null
        #expect(bodies[1]["thread"] == ["type": "continue", "previous_message_id": first[0]["id"] ?? .null])
        #expect(bodies[1]["tools"] == nil)
        #expect(bodies[1]["messages"] == [[
            "role": "user",
            "content": [["type": "tool_result", "tool_use_id": toolUseID, "content": .string(getWeather("San Francisco, CA", "f"))]],
        ]])
        for request in mock.requests {
            #expect(request.headers["anthropic-beta"] == "message-threads-2026-08-12")
            #expect(request.headers["x-stainless-helper"] == "BetaToolRunner, message-thread")
        }
    }

    @Test func toolCallError() async throws {
        let mock = try snapshotMock("10e53c1d-51be-4c64-b5bf-99adb3fa4719")
        let served = mock.bodiesServed()
        let called = Box(false)
        let tool = weatherTool { input in
            if !called.value {
                called.value = true
                throw RuntimeError("Unexpected error, try again")
            }
            return .string(getWeather(input.location, input.units))
        }
        let runner = try weatherRunner(try mock.client(), tools: [tool])
        let (responses, capture) = try await ToolDiagnostics.capture { try await collectToolResults(runner) }
        #expect(capture.records.filter { $0.level == .error }.map { [$0.logger, $0.message] } == [
            ["anthropic.lib.tools._beta_runner", "Error occurred while calling tool: get_weather"],
        ])
        #expect(responses == [
            toolResultMessage(served[0]["content"]?[0]?["id"]?.stringValue ?? "", "RuntimeError('Unexpected error, try again')",
                              isError: true),
        ])
    }

    @Test func toolCallCaching() async throws {
        let mock = try snapshotMock("a8ac789b-f856-48cd-9ff3-d5f36799e432")
        let calls = Box(0)
        let tool = weatherTool { input in
            calls.mutate { $0 += 1 }
            if calls.value > 1 { throw RuntimeError("This tool should not be called again") }
            return .string(getWeather(input.location, input.units))
        }
        let runner = try weatherRunner(try mock.client(), tools: [tool],
                                       messages: [["role": "user", "content": "What's the weather in SF in Celsius?"]])
        for try await _ in runner {
            let response1 = try await runner.generateToolCallResponseJSON()
            let response2 = try await runner.generateToolCallResponseJSON()
            #expect(response1 == response2)
        }
        #expect(calls.value == 1)
    }

    @Test func maxIterations() async throws {
        let mock = try snapshotMock("e075a6c2-de4d-4125-9709-f0e178058190")
        let served = mock.bodiesServed()
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool()], messages: [[
            "role": "user",
            "content": "What's the weather in San Francisco, New York, London, Tokyo and Paris?If you need to use tools, call only one tool at a time. Wait for the tool'sresponse before making another call. Never call multiple tools at once.",
        ]], maxIterations: 2)
        var answers: [JSONValue?] = []
        for try await _ in runner { answers.append(try await runner.generateToolCallResponseJSON()) }
        #expect(answers.count == 2)
        #expect(mock.calls == 2)
        for (i, answer) in answers.enumerated() {
            let toolUse = served[i]["content"]?.arrayValue?.first { $0["type"] == "tool_use" } ?? .null
            let input = toolUse["input"] ?? .null
            #expect(answer == toolResultMessage(
                toolUse["id"]?.stringValue ?? "",
                .string(getWeather(input["location"]?.stringValue ?? "", input["units"]?.stringValue ?? ""))))
        }
    }

    @Test func serverSideTool() async throws {
        let mock = try snapshotMock("32da0815-2270-4d29-87be-3b5b63ab42e2")
        let runner = try weatherRunner(try mock.client(), tools: [JSONValue.object(["type": "web_search_20250305", "name": "web_search"])])
        let message = try #require(try await runner.next())
        let types = try message.content.map { try JSONValue.from($0)["type"]?.stringValue ?? "" }
        #expect(types.contains("server_tool_use"))
        #expect(types.contains("web_search_tool_result"))
    }

    @Test func programmaticToolCall() async throws {
        let mock = try snapshotMock("092be1de-d3f8-4c22-a4ea-a7ad54689836")
        let tool = BetaFunctionTool(name: "get_weather", description: "Lookup the weather for a given city.",
                                         inputSchema: weatherSchema, allowedCallers: [.codeExecution20260120]) { (input: WeatherInput) in
            .string(getWeather(input.location, input.units))
        }
        let runner = try weatherRunner(try mock.client(), tools: [tool],
                                       messages: [["role": "user", "content": "What is the weather in SF, NY, and London in Celsius?"]],
                                       model: "claude-opus-4-5")
        let first = try #require(try await runner.next())
        // One more iteration so the runner handles the tool call and adopts the container.
        _ = try await runner.next()
        let container = try #require(first.container)
        #expect(await runner.params["container"] == .string(container.id))
        #expect(mock.bodies[1]["container"] == .string(container.id))
    }

    @Test func basicCallAsync() async throws {
        let mock = try snapshotMock("64fe7974-681a-4023-9848-b32ba39c8664", dir: "__module__")
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool()]).untilDone()
        #expect(message.stopReason == .endTurn)
        #expect(mock.calls == 2)
    }
}

private func refusalWithToolUse() -> JSONValue {
    messageResponse(id: "msg_refusal", content: [[
        "type": "tool_use", "id": "toolu_refusal", "name": "get_weather", "input": sfInput,
    ]], stopReason: "refusal")
}

private func pausedServerToolUse() -> JSONValue {
    messageResponse(id: "msg_paused", content: [[
        "type": "server_tool_use", "id": "srvtoolu_paused", "name": "web_search", "input": ["query": "weather in SF"],
    ]], stopReason: "pause_turn")
}

private let pausedAssistantTurn: JSONValue = [
    "role": "assistant",
    "content": [["type": "server_tool_use", "id": "srvtoolu_paused", "name": "web_search", "input": ["query": "weather in SF"]]],
]

private func compactionResponse() -> JSONValue {
    messageResponse(id: "msg_compaction", content: [["type": "compaction", "content": "Summary of the conversation so far."]],
                    stopReason: "compaction")
}

let compactionAssistantTurn: JSONValue = [
    "role": "assistant", "content": [["type": "compaction", "content": "Summary of the conversation so far."]],
]

private let webSearch: JSONValue = ["type": "web_search_20250305", "name": "web_search"]

@Suite struct RunnerStopReasonTests {
    @Test func refusalEndsRunnerWithoutExecutingTools() async throws {
        let mock = MessagesMock([refusalWithToolUse()])
        let calls = Box(0)
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool(calls: calls)]).untilDone()
        #expect(message.stopReason == .refusal)
        #expect(calls.value == 0)
        #expect(mock.calls == 1)
    }

    @Test func pauseTurnResumesRunner() async throws {
        let mock = MessagesMock([pausedServerToolUse(), endTurnResponse()])
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool(), webSearch], thread: false).untilDone()
        #expect(message.stopReason == .endTurn)
        #expect(mock.calls == 2)
        #expect(mock.lastBody["messages"]?.arrayValue?.last == pausedAssistantTurn)
    }

    @Test func pauseTurnRespectsMaxIterations() async throws {
        let mock = MessagesMock(Array(repeating: pausedServerToolUse(), count: 5))
        let message = try await weatherRunner(try mock.client(), tools: [webSearch], maxIterations: 3).untilDone()
        #expect(message.stopReason == .pauseTurn)
        #expect(mock.calls == 3)
    }

    @Test func everyStopReasonIsClassified() {
        // A newly generated stop reason must be mapped to a step in `STOP_REASON_STEPS` before this passes.
        #expect(Set(BetaStopReason.allCases) == Set(STOP_REASON_STEPS.keys))
        let expected: [BetaStopReason: ToolRunnerStep] = [
            .toolUse: .runTools, .pauseTurn: .resume, .compaction: .resume, .endTurn: .stop, .stopSequence: .stop,
            .maxTokens: .stop, .modelContextWindowExceeded: .stop, .refusal: .stop,
        ]
        for reason in BetaStopReason.allCases { #expect(determineNextStep(reason) == expected[reason]) }
        #expect(determineNextStep(nil) == .stop)
        #expect(determineNextStep(.unknown("some_future_reason")) == .stop)
    }

    @Test func compactionResumesRunner() async throws {
        let mock = MessagesMock([compactionResponse(), endTurnResponse()])
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool()], thread: false).untilDone()
        #expect(message.stopReason == .endTurn)
        #expect(mock.calls == 2)
        #expect(mock.lastBody["messages"]?.arrayValue?.last == compactionAssistantTurn)
    }

    @Test func maxTokensEndsRunnerWithoutExecutingTools() async throws {
        let mock = MessagesMock([messageResponse(id: "msg_max_tokens", content: [[
            "type": "tool_use", "id": "toolu_max_tokens", "name": "get_weather", "input": sfInput,
        ]], stopReason: "max_tokens")])
        let calls = Box(0)
        let message = try await weatherRunner(try mock.client(), tools: [weatherTool(calls: calls)]).untilDone()
        #expect(message.stopReason == .maxTokens)
        #expect(calls.value == 0)
        #expect(mock.calls == 1)
    }
}

/// `_run_sync_tool_use`: drives a runner over `messages` without a thread and collects its tool results.
private func runToolUse(_ mock: MessagesMock, tools: [any BetaToolLike], messages: [JSONValue]) async throws -> [JSONValue] {
    try await collectToolResults(try weatherRunner(try mock.client(), tools: tools, messages: messages, thread: false))
}

private let getTime = BetaFunctionTool(name: "get_time", description: "Lookup the current time in a timezone.",
                                            inputSchema: ["type": "object", "properties": ["timezone": ["type": "string"]]]) { input in
    .string("12:00 \(input["timezone"]?.stringValue ?? "")")
}

@Suite struct ToolChangeHistoryTests {
    @Test func toolRemovalRoutesCallDownUnknownToolPath() async throws {
        let mock = MessagesMock([
            toolUseResponse("get_weather", "toolu_change"), endTurnResponse(),
            toolUseResponse("get_weather", "toolu_change"), endTurnResponse(),
        ])
        let calls = Box(0)
        let removed = try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runToolUse(mock, tools: [weatherTool(calls: calls)], messages: [
                ["role": "user", "content": "What is the weather in SF?"],
                ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
            ])
        }
        let neverDefined = try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runToolUse(mock, tools: [getTime], messages: [["role": "user", "content": "What is the weather in SF?"]])
        }
        #expect(calls.value == 0)
        #expect(removed == neverDefined)
        #expect(removed == [notFoundResult("toolu_change")])
    }

    @Test func toolAdditionReEnablesRemovedTool() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_change"), endTurnResponse()])
        let calls = Box(0)
        let results = try await runToolUse(mock, tools: [weatherTool(calls: calls)], messages: [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
            ["role": "system", "content": [toolReferenceBlock("tool_addition", "get_weather")]],
        ])
        #expect(calls.value == 1)
        #expect(results == [toolResultMessage("toolu_change", .string(getWeather("San Francisco, CA", "f")))])
    }

    @Test func toolAdditionByValueReEnablesRemovedTool() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_change"), endTurnResponse()])
        let calls = Box(0)
        let tool = weatherTool(calls: calls)
        let results = try await runToolUse(mock, tools: [tool], messages: [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
            ["role": "system", "content": [addition(try tool.toToolParam())]],
        ])
        #expect(calls.value == 1)
        #expect(results == [toolResultMessage("toolu_change", .string(getWeather("San Francisco, CA", "f")))])
    }

    @Test func toolRemovalRoutesCallDownUnknownToolPathOnAThread() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_change"), endTurnResponse()])
        let calls = Box(0)
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool(calls: calls)], messages: [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
        ])
        let results = try await expectWarning("Tool 'get_weather' not found in tool runner") { try await collectToolResults(runner) }
        #expect(calls.value == 0)
        #expect(results == [notFoundResult("toolu_change")])
    }

    @Test func toolRemovalViaAppendMessagesBetweenTurns() async throws {
        let mock = MessagesMock([
            toolUseResponse("get_time", "toolu_time", input: ["timezone": "UTC"]), toolUseResponse("get_weather", "toolu_weather"),
            endTurnResponse(),
        ])
        let calls = Box(0)
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool(calls: calls), getTime],
                                       messages: [["role": "user", "content": "What time is it, and what is the weather in SF?"]])
        var results: [JSONValue] = []
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            for try await message in runner {
                if message.content.contains(where: { if case .toolUse(let t) = $0 { return t.name == "get_time" } else { return false } }) {
                    try await runner.appendMessages(json: ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]])
                }
                if let response = try await runner.generateToolCallResponseJSON() { results.append(response) }
            }
        }
        #expect(calls.value == 0)
        #expect(results == [toolResultMessage("toolu_time", "12:00 UTC"), notFoundResult("toolu_weather")])
    }

    @Test func toolRemovalViaAppendMessagesSameTurn() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box(0)
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool(calls: calls)])
        var results: [JSONValue] = []
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            for try await message in runner {
                if message.content.contains(where: { if case .toolUse = $0 { return true } else { return false } }) {
                    // The loop body runs before dispatch, so a removal appended here still applies.
                    try await runner.appendMessages(json: ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]])
                }
                if let response = try await runner.generateToolCallResponseJSON() { results.append(response) }
            }
        }
        #expect(calls.value == 0)
        #expect(results == [notFoundResult("toolu_weather")])
    }

    @Test func toolRemovalViaSetMessagesParams() async throws {
        let mock = MessagesMock([
            toolUseResponse("get_time", "toolu_time", input: ["timezone": "UTC"]), toolUseResponse("get_weather", "toolu_weather"),
            endTurnResponse(),
        ])
        let calls = Box(0)
        let replacement: [JSONValue] = [
            ["role": "user", "content": "What time is it, and what is the weather in SF?"],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
        ]
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool(calls: calls), getTime], messages: [replacement[0]])
        var results: [JSONValue] = []
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            for try await message in runner {
                if message.content.contains(where: { if case .toolUse(let t) = $0 { return t.name == "get_time" } else { return false } }) {
                    try await runner.setMessagesParams { params in
                        var p = params
                        p["messages"] = .array(replacement)
                        return p
                    }
                }
                if let response = try await runner.generateToolCallResponseJSON() { results.append(response) }
            }
        }
        #expect(calls.value == 0)
        #expect(results == [toolResultMessage("toolu_time", "12:00 UTC"), notFoundResult("toolu_weather")])
    }

    @Test func toolAdditionViaAppendMessagesReEnablesRemovedTool() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box(0)
        let runner = try weatherRunner(try mock.client(), tools: [weatherTool(calls: calls)], messages: [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
        ])
        var results: [JSONValue] = []
        for try await message in runner {
            if message.content.contains(where: { if case .toolUse = $0 { return true } else { return false } }) {
                try await runner.appendMessages(json: ["role": "system", "content": [toolReferenceBlock("tool_addition", "get_weather")]])
            }
            if let response = try await runner.generateToolCallResponseJSON() { results.append(response) }
        }
        #expect(calls.value == 1)
        #expect(results == [toolResultMessage("toolu_weather", .string(getWeather("San Francisco, CA", "f")))])
    }

    @Test func toolRemovalInEchoedCompactionTurnRoutesCallDownUnknownToolPath() async throws {
        let mock = MessagesMock([
            messageResponse(id: "msg_compaction", content: [[
                "type": "compaction", "content": "Earlier turns, summarized.", "encrypted_content": nil,
                "tool_changes": [["type": "tool_removal", "tool": ["type": "tool_reference", "name": "get_weather"]]],
            ]], stopReason: "compaction"),
            toolUseResponse("get_weather", "toolu_change"), endTurnResponse(),
        ])
        let calls = Box(0)
        let results = try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runToolUse(mock, tools: [weatherTool(calls: calls)], messages: [["role": "user", "content": "What is the weather in SF?"]])
        }
        #expect(calls.value == 0)
        #expect(results == [notFoundResult("toolu_change")])
        let echoed = mock.bodies[1]["messages"]?[1]
        #expect(echoed?["content"]?[0]?["tool_changes"] == [["type": "tool_removal", "tool": ["type": "tool_reference", "name": "get_weather"]]])
    }

    @Test func toolRemovalInCompactionToolChangesRoutesCallDownUnknownToolPath() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_change"), endTurnResponse()])
        let calls = Box(0)
        let results = try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runToolUse(mock, tools: [weatherTool(calls: calls)], messages: [
                ["role": "assistant", "content": [[
                    "type": "compaction", "content": "Earlier turns, summarized.",
                    "tool_changes": [["type": "tool_removal", "tool": ["type": "tool_reference", "name": "get_weather"]]],
                ]]],
                ["role": "user", "content": "What is the weather in SF?"],
            ])
        }
        #expect(calls.value == 0)
        #expect(results == [notFoundResult("toolu_change")])
    }
}
