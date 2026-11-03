// Port of tests/lib/threads/test_thread_tool_runner.py and the runner tests of test_async_beta_threads.py: a tool
// runner over a thread (`thread.toolRunner()`) and a runner's own thread.
//
// The streaming runner (`tool_runner(stream=True)`) is ported separately; the `streaming` cases are deferred (see
// docs/porting/threads-environments-sessions.md).

import Foundation
import Testing
@testable import Anthropic

private let COMPACT_BETA = "compact-2026-09-04"

/// `{**params, key: value}` as a `setMessagesParams` transform.
private func thWith(_ key: String, _ value: JSONValue) -> (BetaToolRunnerParams) throws -> BetaToolRunnerParams {
    { params in
        var p = params
        p[key] = value
        return p
    }
}

private func thAppending(_ added: JSONValue...) -> (BetaToolRunnerParams) throws -> BetaToolRunnerParams {
    { params in
        var p = params
        p["messages"] = .array((params["messages"]?.arrayValue ?? []) + added)
        return p
    }
}

@Suite struct ThreadsToolRunnerTests {
    @Test func runnerOverADefaultThreadRaisesOnAnUnsupportedRequest() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        await #expect(throws: BadRequestError.self) { try await runner.untilDone() }

        #expect(mock.threads == [THREADS_CREATE])
    }

    @Test func runnerOverAContinueUnthreadedThreadContinuesWithoutAThread() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()], behavior: .continueUnthreaded)
        try thread.append(THREADS_WEATHER_QUESTION)

        let final = try await thread.toolRunner().untilDone()

        #expect(mock.threads == [THREADS_CREATE, nil])
        #expect(final.id == "msg_b")
    }

    @Test func runnerContinuesTheThreadInTheAdoptedContainer() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", container: "container_a"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)

        let final = try await thread.toolRunner().untilDone()

        let created = mock.bodies[0], continued = mock.bodies[1]
        #expect(created["container"] == nil)
        #expect(continued["container"] == "container_a")
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["messages"] == [thToolResult("toolu_a")])
        #expect(thread.previousMessageID == final.id)
        #expect(final.id == "msg_b")
    }

    @Test(arguments: [false, true])
    func runnerRequestOptionsReplaceTheThreadsForItsTurnsOnly(headersGiven: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()], extraHeaders: ["X-Thread": "thread"])
        try thread.append(THREADS_WEATHER_QUESTION)

        try await thread.toolRunner(extraHeaders: headersGiven ? ["X-Run": "run"] : nil).untilDone()
        try await thread.send(thUser("Thanks"))

        let sent: [String?] = headersGiven ? [nil, "run"] : ["thread", nil]
        #expect(mock.requests.map { [$0.headers["X-Thread"], $0.headers["X-Run"]] } == [sent, sent, ["thread", nil]])
    }

    @Test func paramsReturnsTheRunnableToolsAsGiven() throws {
        let weather = thWeatherTool()
        let raw = THREADS_NOOP_TOOL
        let thread = try thMakeThread(ThreadsMock(), tools: [weather, raw])

        for params in [thread.params, try mockClient().beta.messages.thread(params: thread.params).params] {
            let tools = params.tools ?? []
            #expect(tools.count == 2)
            #expect((tools.first as? BetaFunctionTool) === weather)
            #expect(tools.last as? JSONValue == raw)
        }
    }

    @Test func setMessagesParamsLeavesTheToolsOfTheThreadToALaterRunner() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b", toolUseID: "toolu_b"), thMessageResponse("msg_c"))
        let tool = thWeatherTool()
        let thread = try thMakeThread(mock, messages: [THREADS_WEATHER_QUESTION], tools: [tool])

        let runner = try thread.toolRunner()
        try await runner.setMessagesParams(thWith("max_tokens", 12))
        try await runner.untilDone()
        try thread.append(thUser("And now?"))
        try await thread.toolRunner().untilDone()

        #expect(thread.params.tools?.count == 1)
        #expect((thread.params.tools?.first as? BetaFunctionTool) === tool)
        #expect(mock.bodies[2]["messages"] == [thToolResult("toolu_b")])
    }

    @Test func setMessagesParamsHandsOutRequestParamsOnly() async throws {
        let runner = try thMakeThread(ThreadsMock(), tools: [thWeatherTool()]).toolRunner()
        let handedOut = ToolsBox<[String]>([])

        try await runner.setMessagesParams { params in
            handedOut.value = Array(params.keys)
            return params
        }

        #expect(handedOut.value.sorted() == ["max_tokens", "messages", "model", "tools"])
    }

    @Test func setMessagesParamsWithSomeFieldsDropsTheOthers() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let runner = try mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [try param(thUser("Hello"))], model: ModelParam(rawValue: THREADS_MODEL), tools: [thWeatherTool()],
            system: "Be brief.")

        try await runner.setMessagesParams { params in
            ["model": params["model"]!, "max_tokens": 2048, "messages": params["messages"]!]
        }
        try await runner.untilDone()

        let body = mock.bodies[0]
        #expect(body["max_tokens"] == 2048)
        #expect(body["system"] == nil && body["tools"] == nil)
    }

    @Test func runnerSetMessagesParamsReplacesTheHistoryMidLoop() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.setMessagesParams(thWith("messages", [thUser("Start over: Oakland?")]))
        try await runner.untilDone()

        let replaced = mock.bodies[1]
        #expect(replaced["thread"] == THREADS_CREATE)
        #expect(replaced["messages"] == [thUser("Start over: Oakland?"), thToolUse("toolu_a"), thToolResult("toolu_a")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thread.previousMessageID == "msg_b")
    }

    @Test func forkDuringATurnHasTheHistoryThatSetMessagesParamsReplacedTheThreadsWith() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "Sunny."), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        let runner = try thread.toolRunner()

        let stream = try await thread.stream(THREADS_WEATHER_QUESTION)
        try await runner.setMessagesParams(thWith("messages", [thUser("Start over: Oakland?")]))
        try await thread.fork().send()
        stream.close()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Start over: Oakland?")])
    }

    @Test func setMessagesParamsWithoutToolsStillRunsTheCallTheReplyMade() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let runner = try thMakeRunner(mock, thread: false)

        _ = try await runner.next()
        try await runner.setMessagesParams { params in ["model": params["model"]!, "max_tokens": 1024, "messages": params["messages"]!] }
        try await runner.untilDone()

        #expect(mock.bodies[1]["tools"] == nil)
        #expect(mock.bodies[1]["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")])
    }

    @Test func runnerRefusesAChangedSystemBeforeItRunsATool() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"))
        let calls = ToolsBox(0)
        let runner = try thMakeRunner(mock, fields: ["system": "Be brief."], tools: [thWeatherTool(calls: calls)])

        _ = try await runner.next()
        try await runner.setMessagesParams(thWith("system", "Be very brief."))
        do {
            try await runner.untilDone()
            Issue.record("expected the turn to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("Cannot change `system`"))
        }

        #expect(calls.value == 0)
        #expect(mock.calls == 1)
    }

    @Test func runnerStopsThreadingAfterACompactionRequestThatCannotBeThreaded() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thUnsupportedResponse("context_management"),
                               thCompactionResponse("msg_b"), thMessageResponse("msg_c", "Sunny."))
        let runner = try thMakeRunner(mock, fields: ["betas": [.string(COMPACT_BETA)]])

        _ = try await runner.next()
        try await runner.compactBeforeNextTurn()
        try await runner.untilDone()

        let rejected = mock.bodies[1], compaction = mock.bodies[2], later = mock.bodies[3]
        #expect(mock.threads == [THREADS_CREATE, THREADS_CREATE, nil, nil])
        #expect(rejected["messages"] == compaction["messages"])
        #expect(later["messages"] == [THREADS_COMPACTED])
    }

    @Test func runnerKeepsAMessageAppendedToTheThreadWhileItCompacts() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thCompactionResponse("msg_b"), thMessageResponse("msg_c", "Sunny."))
        let thread = try thMakeThread(mock, ["betas": [.string(COMPACT_BETA)]], tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.compactBeforeNextTurn()
        #expect(try await runner.next()?.stopReason == .compaction)
        try await expectValueError("being compacted") { try await runner.appendMessages(json: thUser("In two words.")) }
        try thread.append(thUser("In one word."))
        try await runner.untilDone()

        #expect(mock.bodies[2]["messages"] == [THREADS_COMPACTED, thUser("In one word.")])
        #expect(thread.messagesJSON[1] == thUser("In one word."))
        #expect(thRoles(thread.messagesJSON) == ["assistant", "user", "assistant"])
    }

    @Test func runnerKeepsAMessageAppendedToTheThreadWhileItCompactsAfterTheFinalTurn() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Sunny."), thCompactionResponse("msg_b"), thMessageResponse("msg_c", "Sunny."))
        let thread = try thMakeThread(mock, ["betas": [.string(COMPACT_BETA)]], tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.compactBeforeNextTurn()
        #expect(try await runner.next()?.stopReason == .compaction)
        try thread.append(thUser("In one word."))
        try await runner.untilDone()
        let messagesAfterTheRunner = thread.messagesJSON, requestsOfTheRunner = mock.calls
        try await thread.send()

        #expect(requestsOfTheRunner == 2)
        #expect(Array(messagesAfterTheRunner.dropFirst()) == [thUser("In one word.")])
        #expect(mock.bodies[2]["messages"] == [THREADS_COMPACTED, thUser("In one word.")])
    }

    @Test func runnerSendsTheCompactionOnceWhenItIsAppendedToTheThreadAgain() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thCompactionResponse("msg_b"), thMessageResponse("msg_c", "Sunny."))
        let thread = try thMakeThread(mock, ["betas": [.string(COMPACT_BETA)]], tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.compactBeforeNextTurn()
        let compaction = try #require(try await runner.next())
        try thread.append(compaction, thUser("In one word."))
        try await runner.untilDone()

        #expect(mock.bodies[2]["messages"] == [THREADS_COMPACTED, thUser("In one word.")])
        #expect(thRoles(thread.messagesJSON) == ["assistant", "user", "assistant"])
    }

    @Test(arguments: ["block_left_early", "events_run_out"])
    func runnerCompactsAThreadThatEndsInAPartialReplyWithoutThatReply(ending: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"),
                               ending == "block_left_early" ? thStreamResponse("msg_b", "one two three") : thInterruptedStreamResponse("msg_b", "one"),
                               thCompactionResponse("msg_c"), thMessageResponse("msg_d", "Three."))
        let thread = try thMakeThread(mock, ["betas": [.string(COMPACT_BETA)]], tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        let stream = try await thread.stream(thUser("Count"))
        if ending == "block_left_early" {
            var text = stream.textStream.makeAsyncIterator()
            _ = try await text.next()
        } else {
            await #expect(throws: StreamEndedEarlyError.self) { try await stream.untilDone() }
        }
        stream.close()
        let messagesAfterTheStream = thread.messagesJSON
        let runner = try thread.toolRunner()

        try await runner.compactBeforeNextTurn()
        try await runner.untilDone()

        let compaction = mock.bodies[2], later = mock.bodies[3]
        #expect(thRoles(messagesAfterTheStream) == ["user", "assistant", "user", "assistant"])
        #expect(compaction["compaction"] == ["type": "summarize"])
        #expect(compaction["thread"] == THREADS_CREATE)
        #expect(compaction["messages"] == [thUser("Hello"), thAssistant(), thUser("Count")])
        #expect(later["thread"] == THREADS_CREATE)
        #expect(later["messages"] == [THREADS_COMPACTED])
        #expect(thRoles(thread.messagesJSON) == ["assistant", "assistant"])
    }

    @Test func runnerTakesOtherParamsAfterAMessageIsAppendedToTheThreadWhileItCompacts() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thCompactionResponse("msg_b"), thMessageResponse("msg_c", "Sunny."))
        let thread = try thMakeThread(mock, ["betas": [.string(COMPACT_BETA)]], tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.compactBeforeNextTurn()
        #expect(try await runner.next()?.stopReason == .compaction)
        try thread.append(thUser("In one word."))
        try await runner.setMessagesParams(thWith("max_tokens", 12))
        try await expectValueError("being compacted") { try await runner.setMessagesParams(thWith("messages", [thUser("Hello")])) }
        try await runner.untilDone()

        #expect(mock.bodies[2]["max_tokens"] == 12)
        #expect(mock.bodies[2]["messages"] == [THREADS_COMPACTED, thUser("In one word.")])
    }

    @Test func runnerAddsToolResultsAheadOfMessagesAppendedToTheThreadMidLoop() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try thread.append(thUser("In one word."))
        try await runner.untilDone()

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thToolResult("toolu_a"), thUser("In one word.")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "user", "assistant"])
    }

    @Test func runnerOnAThreadWhoseStreamEndedEarlySendsThatTurnAgain() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two three"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        let stream = try await thread.stream(thUser("Count"))
        var text = stream.textStream.makeAsyncIterator()
        _ = try await text.next()
        stream.close()

        let final = try await thread.toolRunner().untilDone()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Count")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thread.previousMessageID == final.id)
        #expect(final.id == "msg_c")
    }

    @Test func runnerSendsAMessageAppendedToTheThreadDuringAYield() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Which city?", stopReason: "tool_use"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        let first = try await runner.next()
        try thread.append(thUser("San Francisco"))
        let final = try await runner.untilDone()

        #expect(first?.id == "msg_a")
        #expect(final.id == "msg_b")
        #expect(mock.bodies[1]["messages"] == [thUser("San Francisco")])
    }

    @Test func runnerSendsAMessageAppendedToTheThreadWhileATurnIsPausedWithTheResume() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thServerError())
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try thread.append(thUser("In one word."))
        await #expect(throws: InternalServerError.self) { try await runner.untilDone() }

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thUser("In one word.")])
        #expect(Array(thread.messagesJSON.dropFirst(2)) == [thUser("In one word.")])
    }

    @Test func runnerSetMessagesParamsTrimmedHistoryKeepsOneCopyOfTheReply() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b", toolUseID: "toolu_b"), thMessageResponse("msg_c", "Sunny."))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.setMessagesParams { params in
            var p = params
            p["messages"] = .array(Array((params["messages"]?.arrayValue ?? []).dropFirst(2)))
            return p
        }
        try await runner.untilDone()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_b"), thToolResult("toolu_b")])
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func runnerOverAnExistingThreadContinuesIt() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b", toolUseID: "toolu_b"), thMessageResponse("msg_c", "Sunny."),
                               thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        try thread.append(THREADS_WEATHER_QUESTION)

        let final = try await thread.toolRunner().untilDone()
        let messagesAfterTheRunner = thRoles(thread.messagesJSON)
        try await thread.send(thUser("Thanks"))

        #expect(final.id == "msg_c")
        #expect(messagesAfterTheRunner == ["user", "assistant", "user", "assistant", "user", "assistant"])
        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), thContinueFrom("msg_b"), thContinueFrom("msg_c")])
        #expect(mock.betas == Array(repeating: [THREADS_BETA], count: 4))
        #expect(mock.helperTags == ["message-thread", "BetaToolRunner, message-thread", "BetaToolRunner, message-thread", "message-thread"])
    }

    @Test func runnerOverAnExistingThreadAddsAndRemovesToolsOnIt() async throws {
        let mock = ThreadsMock(replies: [thMessageResponse("msg_0")] + thToolChangeReplies() + [thMessageResponse("msg_e")])
        let added = thLookupTool()
        let thread = try thMakeThread(mock, ["betas": [.string(THREADS_INLINE_TOOLS_BETA)]], tools: [thWeatherTool()])
        try await thread.send(thUser("Hello"))
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner()

        _ = try await runner.next()
        try await runner.addTools(added)
        _ = try await runner.next()
        try await runner.removeTools("get_weather")
        try await expectWarning("Tool 'get_weather' not found in tool runner") { try await runner.untilDone() }
        try await thread.send(thUser("Thanks"))

        let bodies = mock.bodies
        #expect(bodies.map { $0["thread"] } == [THREADS_CREATE] + ["msg_0", "msg_a", "msg_b", "msg_c", "msg_d"].map(thContinueFrom))
        #expect(bodies.map { $0["tools"] != nil } == [true, false, false, false, false, false])
        let turns = thToolChangeTurns(try added.toToolParam())
        #expect(bodies.dropFirst().map { $0["messages"] } == [[THREADS_WEATHER_QUESTION]] + turns.map { .array($0) } + [[thUser("Thanks")]])
        #expect(thread.messagesJSON.filter { $0["role"] == "system" } == [thToolAddition(try added.toToolParam()), thToolRemoval("get_weather")])
    }

    @Test(arguments: [nil, [String](), ["container"]] as [[String]?])
    func runnerThatStopsAtItsLimitLeavesTheToolResultsAndTheContainerOnTheThread(dropped: [String]?) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", container: "container_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let runner = try thread.toolRunner(maxIterations: 1)

        _ = try await runner.next()
        if let dropped {
            try await runner.setMessagesParams { params in params.filter { !dropped.contains($0.key) } }
        }
        try await runner.untilDone()
        try await thread.send(thUser("Thanks"))

        let continued = mock.bodies[1]
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["container"] == "container_a")
        #expect(continued["messages"] == [thToolResult("toolu_a"), thUser("Thanks")])
    }

    @Test func runnerEndsOnARefusedTurnAndLeavesItsToolResultsStaged() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"),
                               thMessageResponse("msg_b", "I can't help with that.", stopReason: "refusal"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)

        let final = try await thread.toolRunner().untilDone()
        try await thread.send(thUser("Never mind"))

        let refused = mock.bodies[1], created = mock.bodies[2]
        #expect(final.id == "msg_b")
        #expect(final.stopReason == .refusal)
        #expect(refused["thread"] == thContinueFrom("msg_a"))
        #expect(refused["messages"] == [thToolResult("toolu_a")])
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["tools"] == [try thWeatherTool().toToolParam()])
        #expect(created["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a"), thUser("Never mind")])
    }

    @Test func runnerOverAForkCallsTheOriginalTools() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let calls = ToolsBox(0)
        let thread = try thMakeThread(mock, tools: [thWeatherTool(calls: calls)])
        let fork = thread.fork()
        try fork.append(THREADS_WEATHER_QUESTION)

        let final = try await fork.toolRunner().untilDone()

        #expect(final.id == "msg_b")
        #expect(calls.value == 1)
        #expect(mock.bodies[0]["tools"] == [try thWeatherTool().toToolParam()])
        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thToolResult("toolu_a")])
        #expect(thread.messagesJSON.isEmpty)
        #expect(thread.previousMessageID == nil)
    }

    @Test(arguments: [THREADS_CREATE, thContinueFrom("msg_a")])
    func runnerRefusesAThreadValueWhenItIsCreated(thread: JSONValue) async throws {
        let mock = ThreadsMock()
        let params: BetaToolRunnerParams = ["model": .string(THREADS_MODEL), "max_tokens": 1024, "messages": [THREADS_WEATHER_QUESTION],
                                            "thread": thread]
        do {
            _ = try BetaToolRunner(params: params, tools: [thWeatherTool()], client: try mock.client())
            Issue.record("expected the thread to be refused")
        } catch let error as ArgumentTypeError {
            #expect(error.message.contains("`thread` cannot be set in the params of a tool runner"))
        }
        #expect(mock.calls == 0)
    }

    @Test(arguments: [THREADS_CREATE, thContinueFrom("msg_a")])
    func runnerRefusesAThreadValueInSetMessagesParams(thread: JSONValue) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let runner = try thMakeRunner(mock)
        _ = try await runner.next()

        do {
            try await runner.setMessagesParams { params in
                var p = params
                p["max_tokens"] = 12
                p["thread"] = thread
                return p
            }
            Issue.record("expected the thread to be refused")
        } catch let error as ArgumentTypeError {
            #expect(error.message.contains("`thread` cannot be set in the params of a tool runner"))
        }
        try await runner.untilDone()

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["max_tokens"] == .int(THREADS_MAX_TOKENS))
    }

    @Test func runnerWithThreadNilThreadsAsByDefault() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        try await mock.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [try param(THREADS_WEATHER_QUESTION)], model: ModelParam(rawValue: THREADS_MODEL), tools: [thWeatherTool()],
            thread: nil
        ).untilDone()
        #expect(mock.threads == [THREADS_CREATE])
    }

    // test_async_beta_threads.py

    @Test func runnerGivenNoBetasSendsTheThreadsBetaAndNoOther() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        try await thMakeRunner(mock).untilDone()
        #expect(mock.betas == [[THREADS_BETA]])
    }

    @Test func runnerWithThreadFalseSendsNoThread() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        try await thMakeRunner(mock, thread: false).untilDone()
        #expect(mock.threads == [nil])
        #expect(mock.betas == [[]])
        #expect(mock.helperTags == ["BetaToolRunner"])
    }
}
