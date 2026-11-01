// Port of tests/lib/tools/test_runners.py (part 2: `add_tools()` / `remove_tools()`).

import Foundation
import Testing
@testable import Anthropic

func compactedResponse() -> JSONValue {
    messageResponse(id: "msg_compacted", content: [["type": "compaction", "content": "Summary so far.", "signature": "sig_01"]],
                    stopReason: "compaction")
}

let compactionBlockAlone: [JSONValue] = [
    ["role": "assistant", "content": [["type": "compaction", "content": "Summary so far.", "signature": "sig_01"]]],
]

let pausedServerToolUseResponse = messageResponse(id: "msg_paused", content: [[
    "type": "server_tool_use", "id": "srvtoolu_paused", "name": "web_search", "input": ["query": "weather in SF"],
]], stopReason: "pause_turn")

let webSearchWithMaxUses: JSONValue = ["type": "web_search_20250305", "name": "web_search", "max_uses": 3]

private func messages(_ body: JSONValue, last n: Int) -> [JSONValue] {
    Array((body["messages"]?.arrayValue ?? []).suffix(n))
}

@Suite struct RunnerToolChangesTests {
    @Test func addToolsSendsTheDefinitionWithTheNextRequest() async throws {
        let mock = MessagesMock([callsTool("get_time", "toolu_time"), callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        try await runWithToolChanges(mock, tools: [getTime], script: ["msg_toolu_time": { try await $0.addTools(getWeather) }])
        #expect(calls.value == ["get_time", "get_weather"])
        let requests = mock.bodies
        #expect(requests.map { $0["tools"] } == Array(repeating: [try getTime.toToolParam()], count: 3))
        #expect(messages(requests[1], last: 2) == [
            ranResult("toolu_time", "get_time"), toolChangesMessage(addition(try getWeather.toToolParam())),
        ])
        #expect(messages(requests[2], last: 1) == [ranResult("toolu_weather", "get_weather")])
        #expect(mock.requests.allSatisfy { !($0.headers["anthropic-beta"] ?? "").contains("inline-tools-2026-09-15") })
    }

    @Test func toolChangesMadeBeforeTheFirstRequestFollowATrailingAssistantMessage() async throws {
        let mock = MessagesMock([callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getWeather = recordingTool("get_weather", calls)
        try await runWithToolChanges(mock, tools: [], script: [:], beforeFirstRequest: { try await $0.addTools(getWeather) },
                                     messages: [compactionAssistantTurn])
        #expect(calls.value == ["get_weather"])
        #expect(mock.bodies[0]["messages"] == [compactionAssistantTurn, toolChangesMessage(addition(try getWeather.toToolParam()))])
    }

    @Test func toolRemovalAppliesWhenTheHistoryHasASystemMessageWithoutContent() async throws {
        let mock = MessagesMock([callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let history: [JSONValue] = [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "system", "output_config": ["effort": "low"]],
            ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]],
        ]
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runWithToolChanges(mock, tools: [recordingTool("get_weather", calls)], script: [:], messages: history)
        }
        #expect(calls.value == [])
        #expect(Array(mock.bodies[1]["messages"]?.arrayValue?.prefix(3) ?? []) == history)
    }

    @Test(arguments: ["tool", "name"])
    func removeToolsStopsACallAlreadyInTheTurn(removeBy: String) async throws {
        let mock = MessagesMock([callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getWeather = recordingTool("get_weather", calls)
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runWithToolChanges(mock, tools: [getWeather], script: ["msg_toolu_weather": { runner in
                if removeBy == "tool" { try await runner.removeTools(getWeather) } else { try await runner.removeTools("get_weather") }
            }])
        }
        #expect(calls.value == [])
        let requests = mock.bodies
        #expect(requests.map { $0["tools"] } == Array(repeating: [try getWeather.toToolParam()], count: 2))
        #expect(messages(requests[1], last: 2) == [
            notFoundResult("toolu_weather"), toolChangesMessage(toolReferenceBlock("tool_removal", "get_weather")),
        ])
    }

    @Test(arguments: ["starting_tool", "tool_added_in_the_same_turn"])
    func aRemovedToolStaysRemovedWhenItsRemovalBlockLeavesTheHistory(removed: String) async throws {
        let mock = MessagesMock([
            callsTool("get_time", "toolu_time"), callsTool("get_time", "toolu_time_again"), callsTool("get_weather", "toolu_weather"),
            endTurnResponse(),
        ])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runWithToolChanges(
                mock, tools: removed == "starting_tool" ? [getWeather, getTime] : [getTime],
                script: [
                    "msg_toolu_time": { runner in
                        if removed == "tool_added_in_the_same_turn" { try await runner.addTools(getWeather) }
                        try await runner.removeTools(getWeather)
                    },
                    "msg_toolu_time_again": { runner in
                        try await runner.setMessagesParams { params in
                            var p = params
                            p["messages"] = .array(Array(params["messages"]?.arrayValue?.prefix(1) ?? []))
                            return p
                        }
                    },
                ])
        }
        #expect(calls.value == ["get_time", "get_time"])
        let requests = mock.bodies
        // Nothing left in the conversation removes get_weather.
        #expect(requests[2]["messages"]?.arrayValue?.map { $0["role"] } == ["user", "assistant", "user"])
        #expect(messages(requests[3], last: 1) == [notFoundResult("toolu_weather")])
    }

    @Test(arguments: ["add_then_remove", "remove_then_add"])
    func toolChangesInOneTurnAreSentTogetherInCallOrder(order: String) async throws {
        let mock = MessagesMock([callsTool("get_time", "toolu_time"), callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        let add = addition(try getWeather.toToolParam())
        let removal = toolReferenceBlock("tool_removal", "get_weather")
        let expectedChanges: [JSONValue]
        let expectedCalls: [String]
        if order == "add_then_remove" {
            try await expectWarning("Tool 'get_weather' not found in tool runner") {
                try await runWithToolChanges(mock, tools: [getTime], script: ["msg_toolu_time": { runner in
                    try await runner.addTools(getWeather)
                    try await runner.removeTools(getWeather)
                }])
            }
            (expectedChanges, expectedCalls) = ([add, removal], ["get_time"])
        } else {
            try await runWithToolChanges(mock, tools: [getWeather, getTime], script: ["msg_toolu_time": { runner in
                try await runner.removeTools(getWeather)
                try await runner.addTools(getWeather)
            }])
            (expectedChanges, expectedCalls) = ([removal, add], ["get_time", "get_weather"])
        }
        #expect(calls.value == expectedCalls)
        #expect(messages(mock.bodies[1], last: 2) == [
            ranResult("toolu_time", "get_time"), ["role": "system", "content": .array(expectedChanges)],
        ])
    }

    @Test func addToolsReplacesAToolOfTheSameNameStraightAway() async throws {
        let mock = MessagesMock([
            callsTool("get_weather", "toolu_weather"), callsTool("get_weather", "toolu_weather_again"), endTurnResponse(),
        ])
        let calls = Box<[String]>([])
        let old = recordingTool("get_weather", calls, label: "old get_weather")
        let new = recordingTool("get_weather", calls, label: "new get_weather")
        try await runWithToolChanges(mock, tools: [old], script: ["msg_toolu_weather": { try await $0.addTools(new) }])
        // Even the call the model made before the swap ran the new function.
        #expect(calls.value == ["new get_weather", "new get_weather"])
    }

    @Test func aCallAlreadyInTheTurnGetsTheInputErrorOfTheToolAddedUnderItsName() async throws {
        struct City: Decodable { var city: String }
        let mock = MessagesMock([callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let old = recordingTool("get_weather", calls)
        let new = BetaAsyncFunctionTool(
            name: "get_weather", description: "Lookup the weather for a given city.",
            inputSchema: ["type": "object", "properties": ["city": ["type": "string"]], "required": ["city"]]
        ) { (input: City) in
            calls.mutate { $0.append(input.city) }
            return .string("Raining in \(input.city)")
        }
        let (_, capture) = try await ToolDiagnostics.capture {
            try await runWithToolChanges(mock, tools: [old], script: ["msg_toolu_weather": { try await $0.addTools(new) }])
        }
        #expect(capture.records.contains { $0.message == "Error occurred while calling tool: get_weather" })
        #expect(calls.value == [])
        #expect(messages(mock.bodies[1], last: 2) == [
            toolResultMessage("toolu_weather", "ValueError('Invalid arguments for function get_weather')", isError: true),
            toolChangesMessage(addition(try new.toToolParam())),
        ])
    }

    @Test func aRemovedToolAddedBackWhileHandlingACallToItIsRun() async throws {
        let mock = MessagesMock([callsTool("get_time", "toolu_time"), callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        try await runWithToolChanges(mock, tools: [getTime, getWeather], script: [
            "msg_toolu_time": { try await $0.removeTools(getWeather) },
            "msg_toolu_weather": { try await $0.addTools(getWeather) },
        ])
        #expect(calls.value == ["get_time", "get_weather"])
        let requests = mock.bodies
        // The removal is in the history when the model calls the tool anyway.
        #expect(messages(requests[1], last: 1) == [toolChangesMessage(toolReferenceBlock("tool_removal", "get_weather"))])
        #expect(messages(requests[2], last: 2) == [
            ranResult("toolu_weather", "get_weather"), toolChangesMessage(addition(try getWeather.toToolParam())),
        ])
    }

    @Test func aRawDefinitionIsSentAsGivenAndNeverRun() async throws {
        let mock = MessagesMock([callsTool("get_time", "toolu_time"), callsTool("get_weather", "toolu_weather"), endTurnResponse()])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        let rawGetWeather: JSONValue = [
            "name": "get_weather", "description": "Lookup the weather for a given city.",
            "input_schema": ["type": "object", "properties": [:]],
        ]
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runWithToolChanges(mock, tools: [getTime, getWeather], script: ["msg_toolu_time": { runner in
                try await runner.addTools(webSearchWithMaxUses, rawGetWeather)
            }])
        }
        // The raw definition took over the name of the function tool, so the function is not run.
        #expect(calls.value == ["get_time"])
        let requests = mock.bodies
        #expect(messages(requests[1], last: 1) == [toolChangesMessage(addition(webSearchWithMaxUses), addition(rawGetWeather))])
        #expect(messages(requests[2], last: 1) == [notFoundResult("toolu_weather")])
    }

    @Test func toolChangesMadeDuringAPausedTurnAreSentOneRequestLater() async throws {
        let mock = MessagesMock([
            pausedServerToolUseResponse, callsTool("get_weather", "toolu_weather"), callsTool("get_time", "toolu_time"),
            endTurnResponse(),
        ])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        try await expectWarning("Tool 'get_weather' not found in tool runner") {
            try await runWithToolChanges(mock, tools: [getWeather, webSearchWithMaxUses], script: ["msg_paused": { runner in
                try await runner.removeTools(getWeather)
                try await runner.addTools(getTime)
            }])
        }
        #expect(calls.value == ["get_time"])
        let requests = mock.bodies
        // The paused turn is sent back as it came; it has to stay last to be continued.
        #expect(Array(requests[1]["messages"]?.arrayValue?.dropFirst() ?? []) == [[
            "role": "assistant",
            "content": [["type": "server_tool_use", "id": "srvtoolu_paused", "name": "web_search", "input": ["query": "weather in SF"]]],
        ]])
        #expect(messages(requests[2], last: 2) == [
            notFoundResult("toolu_weather"),
            toolChangesMessage(toolReferenceBlock("tool_removal", "get_weather"), addition(try getTime.toToolParam())),
        ])
    }

    @Test func toolChangesGoOutWithTheCompactionRequestAndFollowItsResponse() async throws {
        let mock = MessagesMock([
            callsTool("get_time", "toolu_time"), compactedResponse(), callsTool("get_forecast", "toolu_forecast"),
            callsTool("get_weather", "toolu_weather"), endTurnResponse(),
        ])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        let getForecast = recordingTool("get_forecast", calls)
        try await runWithToolChanges(mock, tools: [getTime], script: [
            "msg_toolu_time": { runner in
                try await runner.addTools(getWeather)
                try await runner.compactBeforeNextTurn()
            },
            "msg_compacted": { try await $0.addTools(getForecast) },
        ])
        // A tool added before the compaction is still run after it.
        #expect(calls.value == ["get_time", "get_forecast", "get_weather"])
        let requests = mock.bodies
        #expect(requests.count == 5)
        let compaction = requests[1], after = requests[2]
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(messages(compaction, last: 2) == [
            ranResult("toolu_time", "get_time"), toolChangesMessage(addition(try getWeather.toToolParam())),
        ])
        #expect(after["messages"] == .array(compactionBlockAlone + [toolChangesMessage(addition(try getForecast.toToolParam()))]))
    }

    @Test func aRemovedToolAddedBackWhileHandlingTheCompactionResponseIsRun() async throws {
        let mock = MessagesMock([
            callsTool("get_time", "toolu_time"), compactedResponse(), callsTool("get_weather", "toolu_weather"), endTurnResponse(),
        ])
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        try await runWithToolChanges(mock, tools: [getTime, getWeather], script: [
            "msg_toolu_time": { runner in
                try await runner.removeTools(getWeather)
                try await runner.compactBeforeNextTurn()
            },
            "msg_compacted": { try await $0.addTools(getWeather) },
        ])
        #expect(calls.value == ["get_time", "get_weather"])
        let requests = mock.bodies
        #expect(requests.count == 4)
        #expect(messages(requests[1], last: 1) == [toolChangesMessage(toolReferenceBlock("tool_removal", "get_weather"))])
        #expect(requests[2]["messages"] == .array(compactionBlockAlone + [toolChangesMessage(addition(try getWeather.toToolParam()))]))
    }

    @Test(arguments: ["end_turn", "max_iterations"])
    func toolChangesPendingWhenTheRunEndsAreNotSent(endedBy: String) async throws {
        let calls = Box<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        let swap: @Sendable (BetaToolRunner) async throws -> Void = { runner in
            try await runner.addTools(getTime)
            try await runner.removeTools(getWeather)
        }
        let mock: MessagesMock
        if endedBy == "end_turn" {
            mock = MessagesMock([endTurnResponse()])
            try await runWithToolChanges(mock, tools: [getWeather], script: ["msg_end_turn": swap])
        } else {
            mock = MessagesMock([callsTool("get_weather", "toolu_weather")])
            try await expectWarning("Tool 'get_weather' not found in tool runner") {
                try await runWithToolChanges(mock, tools: [getWeather], script: ["msg_toolu_weather": swap], maxIterations: 1)
            }
        }
        #expect(calls.value == [])
        #expect(mock.calls == 1)
    }

    @Test func aToolThatReturnsNoneSendsANullToolResult() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_none"), endTurnResponse()])
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [userMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
            tools: [weatherTool { _ in nil }], thread: false)
        let results = try await collectToolResults(runner)
        #expect(mock.calls == 2, "the follow-up request carrying the tool_result was sent")
        #expect(results.count == 1)
        let toolResult = results[0]["content"]?[0]
        #expect(toolResult?["is_error"] == nil)
        #expect(toolResult?["content"] == .null)
        #expect(mock.lastBody["messages"]?.arrayValue?.last?["content"]?[0]?["content"] == .null)
    }

    @Test func toolsetsCannotBeAddedOrRemoved() async throws {
        let mock = MessagesMock([])
        let toolset = EchoToolset(family: "browser")
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [userMessage("hi")], model: "claude-haiku-4-5", tools: [toolset], thread: false)
        await #expect(throws: ToolsetsFixedError.self) { try await runner.addTools(toolset) }
        await #expect(throws: ToolsetsFixedError.self) { try await runner.addTools(JSONValue.object(["type": "browser_toolset_20260801"])) }
        await #expect(throws: ToolsetContractError.self) {
            try await runner.addTools(recordingTool("browser", Box([])))
        }
        await #expect(throws: ToolsetsFixedError.self) { try await runner.removeTools("browser") }
        await #expect(throws: ToolsetsFixedError.self) { try await runner.removeTools(toolset) }
        #expect(mock.calls == 0)
    }
}

/// A toolset that answers each member call with its name and input (`EchoBrowserToolset`).
final class EchoToolset: BetaAsyncRunnableToolset, @unchecked Sendable {
    let family: String
    let calls = Box<[String]>([])
    var fail: Set<String> = []

    init(family: String) { self.family = family }

    override var toolsetName: String { family }

    override func toDict() throws -> JSONValue { ["type": .string("\(family)_toolset_20260801")] }

    override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        calls.mutate { $0.append(name) }
        if fail.contains(name) { throw ToolError("\(name) failed") }
        return .string("\(name) \(JSONValue.object(input))")
    }
}
