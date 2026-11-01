// Port of tests/lib/tools/test_runners.py (part 3: `compact_before_next_turn()`, and runners made from params).

import Foundation
import Testing
@testable import Anthropic

private let compactionContentWithAnUnmodelledBlock: [JSONValue] = [
    ["type": "compaction", "content": "Summary so far.", "signature": "sig_01"],
    ["type": "mcp_tool_listing", "mcp_server_name": "docs", "tools": []],
]

private func compactedResponseWithAnUnmodelledBlock() -> JSONValue {
    var body = compactedResponse()
    body["content"] = .array(compactionContentWithAnUnmodelledBlock)
    return body
}

private func responseWithoutASummary(_ content: [JSONValue], _ stopReason: String) -> JSONValue {
    var body = compactedResponse()
    body["content"] = .array(content)
    body["stop_reason"] = .string(stopReason)
    return body
}

private let finalAssistantTurn: JSONValue = ["role": "assistant", "content": [["type": "text", "text": "Done."]]]

private func maxTokensWithToolUse() -> JSONValue {
    messageResponse(id: "msg_max_tokens", content: [[
        "type": "tool_use", "id": "toolu_max_tokens", "name": "get_weather", "input": sfInput,
    ]], stopReason: "max_tokens")
}

/// `_async_compact_runner` / `_sync_compact_runner`.
private func compactRunner(_ client: Anthropic, betas: [AnthropicBetaParam]? = nil,
                           contextManagement: BetaContextManagementConfigParam? = nil, maxIterations: Int? = nil,
                           thread: Bool? = nil) throws -> BetaToolRunner
{
    try client.beta.messages.toolRunner(
        maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5", tools: [toolsWeatherTool()],
        maxIterations: maxIterations, contextManagement: contextManagement.map { .some($0) }, thread: thread, betas: betas)
}

private func currentMessages(_ runner: BetaToolRunner) async -> [JSONValue] {
    await runner.params["messages"]?.arrayValue ?? []
}

private let clearToolUses: BetaContextManagementConfigParam = try! JSONValue.object([
    "edits": [["type": "clear_tool_uses_20250919"]],
]).decode()

@Suite struct RunnerCompactionTests {
    @Test func compactBeforeNextTurnIsSentAfterTheToolsRunWithoutAThread() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1"), compactedResponseWithAnUnmodelledBlock(), endTurnResponse()])
        let runner = try compactRunner(try mock.client(), betas: ["compact-2026-09-04"], contextManagement: clearToolUses,
                                       maxIterations: 2, thread: false)
        var yielded: [BetaMessage] = []
        for try await message in runner {
            yielded.append(message)
            if message.stopReason == .toolUse {
                try await runner.compactBeforeNextTurn(try JSONValue.object(["type": "summarize", "instructions": "Keep the city."]).decode())
            }
        }
        #expect(yielded.map(\.stopReason) == [.toolUse, .compaction, .endTurn])
        if case .compaction(let block) = yielded[1].content[0] { #expect(block.content == "Summary so far.") } else {
            Issue.record("expected a compaction block")
        }
        let requests = mock.bodies
        #expect(requests.count == 3)
        let (first, compaction, after) = (requests[0], requests[1], requests[2])
        #expect(compaction["compaction"] == ["type": "summarize", "instructions": "Keep the city."])
        #expect(compaction["context_management"] == nil)
        #expect(compaction["messages"] == [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "assistant", "content": [["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": sfInput]]],
            toolResultMessage("toolu_1", .string(getWeather("San Francisco, CA", "f"))),
        ])
        // The response goes back as it came.
        #expect(after["messages"] == [["role": "assistant", "content": .array(compactionContentWithAnUnmodelledBlock)]])
        #expect(after["compaction"] == nil)
        #expect(after["context_management"] == first["context_management"])
        // The beta is the caller's to pass; the runner sends what it was given and nothing more.
        #expect(mock.requests.map { $0.headers["anthropic-beta"] } == Array(repeating: "compact-2026-09-04", count: 3))
    }

    @Test func compactBeforeNextTurnIsSentAfterTheToolsRun() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1"), compactedResponseWithAnUnmodelledBlock(), endTurnResponse()])
        let runner = try compactRunner(try mock.client(), contextManagement: clearToolUses, maxIterations: 2)
        var stopReasons: [BetaStopReason?] = []
        for try await message in runner {
            stopReasons.append(message.stopReason)
            if message.stopReason == .toolUse { try await runner.compactBeforeNextTurn() }
        }
        #expect(stopReasons == [.toolUse, .compaction, .endTurn])
        let requests = mock.bodies
        #expect(requests.count == 3)
        let (first, compaction, after) = (requests[0], requests[1], requests[2])
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["context_management"] == nil)
        #expect(compaction["messages"]?.arrayValue?.map { $0["role"] } == ["user", "assistant", "user"])
        #expect(compaction["messages"]?.arrayValue?.last?["content"]?[0]?["type"] == "tool_result")
        #expect(after["messages"] == [["role": "assistant", "content": .array(compactionContentWithAnUnmodelledBlock)]])
        #expect(after["compaction"] == nil)
        #expect(after["context_management"] == first["context_management"])
        #expect(mock.requests.allSatisfy { !($0.headers["anthropic-beta"] ?? "").contains("compact-2026-09-04") })
    }

    @Test func compactBeforeNextTurnOnTheFinalTurnIsSentBeforeStopping() async throws {
        let mock = MessagesMock([endTurnResponse(), compactedResponse()])
        // The final answer is also the last iteration allowed; the compaction still goes out.
        let runner = try compactRunner(try mock.client(), maxIterations: 1)
        var stopReasons: [BetaStopReason?] = []
        for try await message in runner {
            stopReasons.append(message.stopReason)
            if message.stopReason == .endTurn { try await runner.compactBeforeNextTurn() }
        }
        #expect(stopReasons == [.endTurn, .compaction])
        let compaction = mock.bodies[1]
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["messages"] == [["role": "user", "content": "What is the weather in SF?"], finalAssistantTurn])
        #expect(await currentMessages(runner) == compactionBlockAlone)
    }

    @Test func pendingCompactionIsSkippedOnAFinalTurnWithUnrunToolCalls() async throws {
        let mock = MessagesMock([maxTokensWithToolUse()])
        let runner = try compactRunner(try mock.client())
        var stopReasons: [BetaStopReason?] = []
        let (_, capture) = try await ToolDiagnostics.capture {
            for try await message in runner {
                stopReasons.append(message.stopReason)
                try await runner.compactBeforeNextTurn()
            }
        }
        #expect(stopReasons == [.maxTokens])
        #expect(mock.calls == 1)
        // Nothing was compacted: the history is the prompt and the final turn.
        #expect(await currentMessages(runner) == [
            ["role": "user", "content": "What is the weather in SF?"],
            ["role": "assistant", "content": maxTokensWithToolUse()["content"] ?? nil],
        ])
        #expect(capture.records.contains { $0.message.contains("pending compaction was skipped") })
    }

    @Test func compactBeforeNextTurnWaitsOutAPausedTurn() async throws {
        let mock = MessagesMock([pausedServerToolUseResponse, toolUseResponse("get_weather", "toolu_1"), compactedResponse(), endTurnResponse()])
        let runner = try compactRunner(try mock.client(), thread: false)
        for try await message in runner {
            if message.stopReason == .pauseTurn { try await runner.compactBeforeNextTurn() }
        }
        let requests = mock.bodies
        #expect(requests.count == 4)
        let (resumed, compaction, after) = (requests[1], requests[2], requests[3])
        #expect(resumed["compaction"] == nil)
        #expect(resumed["messages"]?.arrayValue?.last?["role"] == "assistant")
        #expect(resumed["messages"]?.arrayValue?.last?["content"]?[0]?["type"] == "server_tool_use")
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["messages"]?.arrayValue?.last?["content"]?[0]?["type"] == "tool_result")
        #expect(after["messages"] == .array(compactionBlockAlone))
    }

    @Test func compactBeforeNextTurnBeforeTheFirstIterationIsTheFirstRequest() async throws {
        let mock = MessagesMock([compactedResponse(), endTurnResponse()])
        let runner = try compactRunner(try mock.client())
        // An edit made before the compaction request is part of what gets summarized.
        try await runner.appendMessages(toolsUserMessage("And in NYC?"))
        try await runner.compactBeforeNextTurn()
        let final = try await runner.untilDone()
        #expect(final.stopReason == .endTurn)
        let requests = mock.bodies
        #expect(requests[0]["compaction"] == ["type": "summarize"])
        #expect(requests[0]["messages"]?.arrayValue?.map { $0["content"] } == ["What is the weather in SF?", "And in NYC?"])
        #expect(requests[1]["messages"] == .array(compactionBlockAlone))
    }

    @Test func compactBeforeNextTurnAgainReplacesThePendingCompaction() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1"), compactedResponse(), endTurnResponse()])
        let runner = try compactRunner(try mock.client())
        for try await message in runner where message.stopReason == .toolUse {
            try await runner.compactBeforeNextTurn(try JSONValue.object(["type": "summarize", "instructions": "Keep the city."]).decode())
            try await runner.compactBeforeNextTurn(try JSONValue.object(["type": "summarize", "instructions": "Keep the units."]).decode())
        }
        #expect(mock.bodies.map { $0["compaction"] } == [nil, ["type": "summarize", "instructions": "Keep the units."], nil])
    }

    @Test func compactBeforeNextTurnOnTheCompactionResponseIsIgnored() async throws {
        // A fourth request would exhaust the mocked responses and fail the test.
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1"), compactedResponse(), endTurnResponse()])
        let runner = try compactRunner(try mock.client())
        var stopReasons: [BetaStopReason?] = []
        for try await message in runner {
            stopReasons.append(message.stopReason)
            if message.stopReason != .endTurn { try await runner.compactBeforeNextTurn() }
        }
        #expect(stopReasons == [.toolUse, .compaction, .endTurn])
        #expect(mock.bodies.map { $0["compaction"] } == [nil, ["type": "summarize"], nil])
    }

    @Test func aToolRemovedInTheHistoryStaysRemovedAfterCompaction() async throws {
        let mock = MessagesMock([compactedResponse(), toolUseResponse("get_weather", "toolu_1", input: [:]), endTurnResponse()])
        let calls = ToolsBox<[String]>([])
        let getWeather = BetaFunctionTool(name: "get_weather", description: "Lookup the weather.", inputSchema: ["type": "object"]) { _ in
            calls.mutate { $0.append("get_weather") }
            return "sunny"
        }
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5", tools: [getWeather])
        try await runner.appendMessages(json: ["role": "system", "content": [toolReferenceBlock("tool_removal", "get_weather")]])
        try await runner.compactBeforeNextTurn()
        try await expectWarning("Tool 'get_weather' not found in tool runner") { try await runner.untilDone() }
        #expect(calls.value == [])
        #expect(mock.bodies[2]["messages"]?.arrayValue?.last == notFoundResult("toolu_1"))
    }

    @Test func pendingCompactionIsSkippedWhenMaxIterationsEndsTheRun() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1")])
        let runner = try compactRunner(try mock.client(), maxIterations: 1)
        for try await _ in runner { try await runner.compactBeforeNextTurn() }
        #expect(mock.calls == 1)
    }

    @Test(arguments: [
        ([JSONValue.object(["type": "compaction", "content": nil])], "compaction"),
        ([JSONValue](), "max_tokens"),
    ])
    func compactionWithoutASummaryKeepsTheHistoryAndWarns(content: [JSONValue], stopReason: String) async throws {
        let mock = MessagesMock([responseWithoutASummary(content, stopReason), toolUseResponse("get_weather", "toolu_1"), endTurnResponse()])
        let runner = try compactRunner(try mock.client(), thread: false)
        try await runner.appendMessages(toolsUserMessage("And in NYC?"))
        try await runner.compactBeforeNextTurn()
        var yielded = 0
        let (_, capture) = try await ToolDiagnostics.capture {
            for try await _ in runner {
                yielded += 1
                // This call is made on the compaction response, so it is ignored: no retry is sent.
                if yielded == 1 { try await runner.compactBeforeNextTurn() }
            }
        }
        let requests = mock.bodies
        #expect(requests.count == 3)
        let (compaction, after, last) = (requests[0], requests[1], requests[2])
        #expect(after["messages"] == compaction["messages"])
        #expect(after["compaction"] == nil)
        // The edit made before the compaction request doesn't keep the turn that follows out of the history.
        #expect(last["messages"]?.arrayValue?.map { $0["role"] } == ["user", "user", "assistant", "user"])
        #expect(capture.records.contains { $0.message.contains("Compaction produced no summary") })
    }

    @Test func untilDoneReturnsTheFinalTurnAfterACompactionWithoutASummary() async throws {
        let mock = MessagesMock([endTurnResponse(), responseWithoutASummary([], "max_tokens")])
        let runner = try compactRunner(try mock.client())
        var stopReasons: [BetaStopReason?] = []
        for try await message in runner {
            stopReasons.append(message.stopReason)
            try await runner.compactBeforeNextTurn()
        }
        let final = try await runner.untilDone()
        #expect(stopReasons == [.endTurn, .maxTokens])
        #expect(final.stopReason == .endTurn)
    }

    @Test func messagesCannotBeReplacedWhileCompacting() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_1"), compactedResponse(), endTurnResponse()])
        let runner = try compactRunner(try mock.client())
        for try await message in runner {
            if message.stopReason == .toolUse {
                try await runner.compactBeforeNextTurn()
            } else if message.stopReason == .compaction {
                try await expectValueError("Message params can't be changed") { try await runner.appendMessages(toolsUserMessage("And in NYC?")) }
                try await expectValueError("while the conversation is being compacted") {
                    try await runner.setMessagesParams { params in
                        var p = params
                        p["messages"] = []
                        return p
                    }
                }
                // Other params can still change, and the change is kept after the history is replaced.
                try await runner.setMessagesParams { params in
                    var p = params
                    p["max_tokens"] = 2048
                    return p
                }
            }
        }
        let after = mock.bodies[2]
        #expect(after["messages"] == .array(compactionBlockAlone))
        #expect(after["max_tokens"] == 2048)
    }

    @Test func failedCompactionRequestIsNotRetriedAndFreesTheMessages() async throws {
        let mock = MessagesMock(replies: [.json(toolUseResponse("get_weather", "toolu_1"), status: 200), .json(["type": "error"], status: 500)])
        let runner = try compactRunner(try mock.client())
        await #expect(throws: InternalServerError.self) {
            for try await _ in runner { try await runner.compactBeforeNextTurn() }
        }
        try await runner.appendMessages(toolsUserMessage("And in NYC?"))
        var rest: [BetaMessage] = []
        for try await message in runner { rest.append(message) }
        #expect(rest.isEmpty)
        #expect(mock.bodies.map { $0["compaction"] } == [nil, ["type": "summarize"]])
    }

    @Test func compactionParamIsRefusedOnAToolRunner() async throws {
        let refusal = "`compaction` cannot be set on a tool runner: every request in the loop would compact again. "
            + "Call `runner.compact_before_next_turn()` when the conversation should be compacted instead."
        let client = try mockClient()
        let runner = try compactRunner(client)
        try await expectValueError(refusal) {
            try await runner.setMessagesParams { params in
                var p = params
                p["compaction"] = ["type": "summarize"]
                return p
            }
        }
        try await expectValueError(refusal) {
            _ = try BetaToolRunner(params: [
                "max_tokens": 1024, "model": "claude-haiku-4-5",
                "messages": [["role": "user", "content": "What is the weather in SF?"]], "compaction": ["type": "summarize"],
            ], tools: [toolsWeatherTool()], client: client)
        }
    }

    @Test func compactBeforeNextTurnIsRefusedBesideACompactionEdit() async throws {
        let client = try mockClient()
        let compactEdit: BetaContextManagementConfigParam = try JSONValue.object(["edits": [["type": "compact_20260112"]]]).decode()
        let runner = try compactRunner(client, contextManagement: compactEdit)
        try await expectValueError("has a compaction edit") { try await runner.compactBeforeNextTurn() }

        let other = try compactRunner(client, contextManagement: try JSONValue.object(["edits": []]).decode())
        try await other.compactBeforeNextTurn()
        try await expectValueError("has a compaction edit") {
            try await other.setMessagesParams { params in
                var p = params
                p["context_management"] = ["edits": [["type": "compact_20260112"]]]
                return p
            }
        }
    }

    static let forecastFormat: JSONValue = [
        "type": "json_schema",
        "schema": [
            "type": "object", "properties": ["summary": ["type": "string"]], "required": ["summary"], "additionalProperties": false,
        ],
    ]

    /// `_REPLY_PARAMS_CASES`, `forced tool and output_format` case: the runner's output format is left off the
    /// compaction request too, and the reply after it is parsed.
    @Test func compactionRequestLeavesOffReplyParamsWithAnOutputFormat() async throws {
        var forecast = endTurnResponse()
        forecast["content"] = [["type": "text", "text": #"{"summary": "Sunny"}"#]]
        let mock = MessagesMock([compactedResponse(), forecast])
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5", tools: [toolsWeatherTool()],
            outputConfig: try JSONValue.object(["effort": "low"]).decode(), outputFormat: RunnerForecast.self,
            stopSequences: ["STOP"], system: "Be brief.", toolChoice: try JSONValue.object(["type": "tool", "name": "get_weather"]).decode(),
            betas: ["compact-2026-09-04"])
        try await runner.compactBeforeNextTurn()
        let final = try await runner.untilDone()
        #expect(final.parsedOutput == RunnerForecast(summary: "Sunny"))

        let requests = mock.bodies
        #expect(requests.count == 2)
        let (compaction, after) = (requests[0], requests[1])
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["stop_sequences"] == nil)
        #expect(compaction["output_format"] == nil)
        #expect(compaction["output_config"] == ["effort": "low"])
        #expect(compaction["tool_choice"] == nil)
        #expect(compaction["fallbacks"] == nil)
        for kept in ["max_tokens", "system", "tools"] { #expect(compaction[kept] == after[kept]) }
        #expect(after["stop_sequences"] == ["STOP"])
        #expect(after["tool_choice"] == ["type": "tool", "name": "get_weather"])
        #expect(after["output_config"]?["effort"] == "low")
        #expect(after["output_config"]?["format"]?["type"] == "json_schema")
        #expect(after["output_config"]?["format"]?["schema"] == .object(try jsonOutputFormat(RunnerForecast.self)))
        #expect(mock.requests.map { $0.headers["anthropic-beta"] } == Array(
            repeating: "compact-2026-09-04,message-threads-2026-08-12", count: 2))
    }

    /// The other `_REPLY_PARAMS_CASES`.
    @Test(arguments: [
        ("any tool and output_config.format", JSONValue.object(["type": "any"]), JSONValue.null, JSONValue.null),
        ("auto tool_choice stays", JSONValue.object(["type": "auto"]), JSONValue.null, JSONValue.object(["type": "auto"])),
        ("fallback output_config.format", JSONValue.object(["type": "auto"]), JSONValue.array([
            ["model": "claude-sonnet-5-5", "output_config": ["effort": "medium", "format": forecastFormat]],
            ["model": "claude-opus-4-5", "max_tokens": 512],
        ]), JSONValue.object(["type": "auto"])),
    ])
    func compactionRequestLeavesOffReplyParams(id: String, toolChoice: JSONValue, fallbacks: JSONValue,
                                               toolChoiceOnCompaction: JSONValue) async throws
    {
        var forecast = endTurnResponse()
        forecast["content"] = [["type": "text", "text": #"{"summary": "Sunny"}"#]]
        let mock = MessagesMock([compactedResponse(), forecast])
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5", tools: [toolsWeatherTool()],
            fallbacks: fallbacks.isNull ? nil : .some(try fallbacks.decode(as: BetaFallbacksParam.self)),
            outputConfig: try JSONValue.object(["effort": "low", "format": Self.forecastFormat]).decode(),
            stopSequences: ["STOP"], system: "Be brief.", toolChoice: try toolChoice.decode(as: BetaToolChoiceParam.self), betas: ["compact-2026-09-04"])
        try await runner.compactBeforeNextTurn()
        _ = try await runner.untilDone()

        let requests = mock.bodies
        #expect(requests.count == 2)
        let (compaction, after) = (requests[0], requests[1])
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["stop_sequences"] == nil)
        #expect(compaction["output_format"] == nil)
        #expect(compaction["output_config"] == ["effort": "low"])
        #expect((compaction["tool_choice"] ?? .null) == toolChoiceOnCompaction)
        if fallbacks.isNull {
            #expect(compaction["fallbacks"] == nil)
        } else {
            #expect(compaction["fallbacks"] == [
                ["model": "claude-sonnet-5-5", "output_config": ["effort": "medium"]],
                ["model": "claude-opus-4-5", "max_tokens": 512],
            ])
            #expect(after["fallbacks"] == fallbacks)
        }
        for kept in ["max_tokens", "system", "tools"] { #expect(compaction[kept] == after[kept]) }
        #expect(compaction["system"] == "Be brief.")
        #expect(compaction["tools"]?.arrayValue?.map { $0["name"] } == ["get_weather"])
        #expect(after["stop_sequences"] == ["STOP"])
        #expect(after["tool_choice"] == toolChoice)
        #expect(after["output_config"]?["effort"] == "low")
        #expect(after["output_config"]?["format"]?["type"] == "json_schema")
        // Every request on a message thread carries the threads beta.
        #expect(mock.requests.map { $0.headers["anthropic-beta"] } == Array(
            repeating: "compact-2026-09-04,message-threads-2026-08-12", count: 2))
    }

    @Test func runnerSendsNoBetaHeaderWhenGivenNoBetas() async throws {
        let mock = MessagesMock([toolUseResponse("get_weather", "toolu_weather"), endTurnResponse()])
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5", tools: [toolsWeatherTool()],
            outputConfig: try JSONValue.object(["format": Self.forecastFormat]).decode(), thread: false)
        _ = try await runner.untilDone()
        #expect(mock.bodies.map { $0["output_config"]?["format"] } == [Self.forecastFormat, Self.forecastFormat])
        #expect(mock.requests.map { $0.headers["anthropic-beta"] } == [nil, nil])
    }
}

/// A first-party client without message threads (what `AnthropicVertex` is upstream).
final class NoThreadsClient: Anthropic, MessageThreadsUnsupported, @unchecked Sendable {}

private let weatherFields: BetaToolRunnerParams = [
    "max_tokens": 1024, "model": "claude-haiku-4-5", "messages": [["role": "user", "content": "What is the weather in SF?"]],
]

private func weatherThenBrowserReplies() -> [JSONValue] {
    let calls: [JSONValue] = [
        ["type": "tool_use", "id": "toolu_weather", "name": "get_weather", "input": ["location": "SF", "units": "f"]],
        ["type": "tool_use", "id": "toolu_open", "name": "open", "toolset_name": "browser", "input": ["url": "a.test"]],
    ]
    return calls.map { call in
        var reply = endTurnResponse()
        reply["id"] = .string("msg_\(call["id"]?.stringValue ?? "")")
        reply["content"] = [call]
        reply["stop_reason"] = "tool_use"
        return reply
    } + [endTurnResponse()]
}

private final class TaggedEchoToolset: BetaRunnableToolset, @unchecked Sendable {
    let calls = ToolsBox<[JSONValue]>([])
    override var toolsetName: String { "browser" }
    override var helperTag: String? { "browser-toolset" }
    override func toDict() throws -> JSONValue { ["type": "browser_toolset_20260801"] }
    override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        calls.mutate { $0.append([.string(name), .object(input)]) }
        return .string("opened")
    }
}

/// `_Forecast`: the structured output of the runner tests.
struct RunnerForecast: StructuredOutput, Equatable {
    var summary: String
    static let jsonSchema: JSONValue = [
        "title": "_Forecast", "type": "object", "properties": ["summary": ["title": "Summary", "type": "string"]],
        "required": ["summary"],
    ]
}

/// `_sse_message`: a streamed message with one content block.
func runnerSSEMessage(_ contentBlock: JSONValue, _ stopReason: String, _ deltas: JSONValue...) -> MessagesMock.Reply {
    var events: [JSONValue] = [
        ["type": "message_start", "message": [
            "id": "msg_streamed", "type": "message", "role": "assistant", "model": "claude-haiku-4-5", "content": [],
            "stop_reason": nil, "stop_sequence": nil, "usage": ["input_tokens": 1, "output_tokens": 1],
        ]],
        ["type": "content_block_start", "index": 0, "content_block": contentBlock],
    ]
    events += deltas.map { ["type": "content_block_delta", "index": 0, "delta": $0] }
    events.append(["type": "content_block_stop", "index": 0])
    events.append(["type": "message_delta", "delta": ["stop_reason": .string(stopReason), "stop_sequence": nil], "usage": ["output_tokens": 1]])
    events.append(["type": "message_stop"])
    return .sse(events.map(streamingRunnerSSE).joined())
}

/// `_weather_then_browser_replies(stream=True)`.
private func streamedWeatherThenBrowserReplies() -> [MessagesMock.Reply] {
    let calls: [JSONValue] = [
        ["type": "tool_use", "id": "toolu_weather", "name": "get_weather", "input": ["location": "SF", "units": "f"]],
        ["type": "tool_use", "id": "toolu_open", "name": "open", "toolset_name": "browser", "input": ["url": "a.test"]],
    ]
    return calls.map { call in
        var start = call
        start["input"] = [:]
        let partial = String(decoding: try! JSONValue.serialize(call["input"] ?? [:]), as: UTF8.self)
        return runnerSSEMessage(start, "tool_use", ["type": "input_json_delta", "partial_json": .string(partial)])
    } + [runnerSSEMessage(["type": "text", "text": ""], "end_turn", ["type": "text_delta", "text": "Done."])]
}

@Suite struct RunnerFromParamsTests {
    @Test(arguments: ["message_thread", "thread_false", "client_without_message_threads"], ["plain", "streaming", "streaming_eagerly"])
    func aRunnerMadeFromParamsSendsTheRequestsOfToolRunner(threading: String, stream: String) async throws {
        var fields = weatherFields
        fields["system"] = "Be brief."
        fields["betas"] = ["inline-tools-2026-09-15"]
        if threading == "thread_false" { fields["thread"] = false }
        let eagerly = stream == "streaming_eagerly"
        typealias UntilDone = () async throws -> Void

        func requests(_ makeRunner: (Anthropic, BetaFunctionTool, TaggedEchoToolset) throws -> UntilDone) async throws
            -> [(String, [String: String], JSONValue)]
        {
            let mock = stream == "plain" ? MessagesMock(weatherThenBrowserReplies()) : MessagesMock(replies: streamedWeatherThenBrowserReplies())
            let client: Anthropic = threading == "client_without_message_threads"
                ? try NoThreadsClient(apiKey: testAPIKey, baseURL: testBaseURL, maxRetries: 0,
                                      transport: try mock.client().transport, environment: [:])
                : try mock.client()
            let browser = TaggedEchoToolset()
            try await makeRunner(client, toolsWeatherTool(), browser)()
            #expect(browser.calls.value == [["open", ["url": "a.test"]]])
            return mock.requests.map { request in
                var headers: [String: String] = [:]
                for name in ["anthropic-beta", "x-example", "content-type", "anthropic-version", "x-stainless-helper-method",
                             "x-stainless-stream-helper"] { headers[name] = request.headers[name] }
                headers["x-stainless-helper"] = (request.headers["x-stainless-helper"] ?? "").split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }.sorted().joined(separator: ",")
                return (request.url.absoluteString, headers, request.jsonBody ?? .null)
            }
        }

        let fromToolRunner = try await requests { client, weather, browser in
            let tools: [any BetaToolLike] = [weather, browser, webSearchWithMaxUses]
            let threadArgument: Bool? = threading == "thread_false" ? false : nil
            if stream == "plain" {
                let runner = try client.beta.messages.toolRunner(
                    maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
                    tools: tools, maxIterations: 5, system: "Be brief.", thread: threadArgument, betas: ["inline-tools-2026-09-15"],
                    extraHeaders: ["x-example": "yes"])
                return { _ = try await runner.untilDone() }
            }
            let runner = try client.beta.messages.streamingToolRunner(
                maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
                tools: tools, maxIterations: 5, runToolsEagerly: eagerly, system: "Be brief.", thread: threadArgument,
                betas: ["inline-tools-2026-09-15"], extraHeaders: ["x-example": "yes"])
            return { _ = try await runner.untilDone() }
        }
        let fromParams = try await requests { client, weather, browser in
            var params = fields
            params["tools"] = [try weather.toToolParam(), try browser.toToolParam(), webSearchWithMaxUses]
            let options = ToolRunnerRequestOptions(extraHeaders: ["x-example": "yes"])
            if stream == "plain" {
                let runner = try BetaToolRunner(params: params, tools: [weather, browser], client: client, options: options, maxIterations: 5)
                return { _ = try await runner.untilDone() }
            }
            let runner = try BetaStreamingToolRunner(params: params, tools: [weather, browser], client: client, options: options,
                                                     maxIterations: 5, runToolsEagerly: eagerly)
            return { _ = try await runner.untilDone() }
        }
        #expect(fromParams.count == 3)
        for (a, b) in zip(fromParams, fromToolRunner) {
            #expect(a.0 == b.0)
            #expect(a.1 == b.1)
            #expect(a.2 == b.2)
        }
        #expect(fromParams.map { $0.2["thread"]?["type"]?.stringValue } ==
            (threading == "message_thread" ? ["create", "continue", "continue"] : [nil, nil, nil]))
        #expect(fromParams.map { $0.2["stream"] } == Array(repeating: stream == "plain" ? nil : true, count: 3))
        let helpers = (["BetaToolRunner", "browser-toolset"] + (threading == "message_thread" ? ["message-thread"] : [])).sorted()
        #expect(fromParams.map { $0.1["x-stainless-helper"] } == Array(repeating: helpers.joined(separator: ","), count: 3))
    }

    @Test(arguments: [false, true])
    func aRunnerMadeFromParamsSendsTheirToolDefinitionsAndRunsItsTools(stream: Bool) async throws {
        let mock: MessagesMock
        if stream {
            let replies = streamedWeatherThenBrowserReplies()
            mock = MessagesMock(replies: [replies[0], replies[2]])
        } else {
            let replies = weatherThenBrowserReplies()
            mock = MessagesMock([replies[0], replies[2]])
        }
        let tool = toolsWeatherTool()
        var definition = try tool.toToolParam()
        definition["cache_control"] = ["type": "ephemeral"]
        var params = weatherFields
        params["tools"] = [definition]
        if stream {
            _ = try await BetaStreamingToolRunner(params: params, tools: [tool], client: try mock.client()).untilDone()
        } else {
            _ = try await BetaToolRunner(params: params, tools: [tool], client: try mock.client()).untilDone()
        }
        let requests = mock.bodies
        #expect(requests[0]["tools"] == [definition])
        #expect(requests[1]["messages"] == [toolResultMessage("toolu_weather", .string(getWeather("SF", "f")))])
    }

    /// `two_output_formats`: the error of `toolRunner(outputFormat:outputConfig:)`, from the plain and the streaming
    /// runner.
    @Test(arguments: [false, true])
    func aRunnerMadeFromParamsRaisesTheErrorsOfToolRunnerForTwoOutputFormats(stream: Bool) async throws {
        let client = try mockClient()
        let outputConfig: BetaOutputConfigParam = try JSONValue.object(["format": RunnerCompactionTests.forecastFormat]).decode()
        func message(_ body: () throws -> Void) -> String? {
            do {
                try body()
                Issue.record("expected an AnthropicError")
                return nil
            } catch let error as AnthropicError {
                return error.message
            } catch {
                Issue.record("unexpected \(error)")
                return nil
            }
        }
        let fromToolRunner = message {
            if stream {
                _ = try client.beta.messages.streamingToolRunner(
                    maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
                    tools: [toolsWeatherTool()], outputConfig: outputConfig, outputFormat: RunnerForecast.self)
            } else {
                _ = try client.beta.messages.toolRunner(
                    maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
                    tools: [toolsWeatherTool()], outputConfig: outputConfig, outputFormat: RunnerForecast.self)
            }
        }
        var params = weatherFields
        params["output_config"] = ["format": RunnerCompactionTests.forecastFormat]
        params["tools"] = [try toolsWeatherTool().toToolParam()]
        let fromParams = message {
            if stream {
                _ = try BetaStreamingToolRunner(params: params, outputFormat: RunnerForecast.self, tools: [toolsWeatherTool()], client: client)
            } else {
                _ = try BetaParsedToolRunner(params: params, outputFormat: RunnerForecast.self, tools: [toolsWeatherTool()], client: client)
            }
        }
        #expect(fromParams == fromToolRunner)
        #expect(fromParams?.hasPrefix("Both output_format and output_config.format were provided.") == true)
    }

    @Test(arguments: [false, true])
    func aRunnerMadeFromParamsRaisesTheErrorsOfToolRunner(stream: Bool) async throws {
        let client = try mockClient()
        var params = weatherFields
        params["thread"] = ["type": "create"]
        params["tools"] = [try toolsWeatherTool().toToolParam()]
        do {
            if stream {
                _ = try BetaStreamingToolRunner(params: params, tools: [toolsWeatherTool()], client: client)
            } else {
                _ = try BetaToolRunner(params: params, tools: [toolsWeatherTool()], client: client)
            }
            Issue.record("expected a TypeError")
        } catch let e as ArgumentTypeError {
            #expect(e.message.hasPrefix("`thread` cannot be set in the params of a tool runner, got {'type': 'create'}."))
        }
    }
}
