// Port of tests/lib/threads/test_tool_runner_threading.py: the thread a tool runner made from params runs on.
//
// Upstream runs the runner tests both non-streaming and streaming (`RESPONSE_KINDS`); the streaming cases wait for
// the streaming runner (see docs/porting/threads-environments-sessions.md). `RUNNER_MODES` (default / `thread=False`)
// become a `threaded` argument.

import Foundation
import Testing
@testable import Anthropic

private let FOGGY = thToolResult("toolu_a", "Foggy")
private let CACHED_RESULT: JSONValue = ["role": "user", "content": [[
    "type": "tool_result", "tool_use_id": "toolu_a", "content": "Sunny in San Francisco", "cache_control": ["type": "ephemeral"],
]]]
private let EDITED_TOOL_USE: JSONValue = [
    "role": "assistant", "content": [["type": "tool_use", "id": "toolu_a", "name": "get_weather", "input": ["location": "Oakland"]]],
]

/// Assert that `request`, which follows the `toolu_a` reply `msg_a` to the weather question, shows the model
/// `conversation` (`assert_sends_conversation`). On a thread it leaves out the question and the reply when
/// `conversation` starts with them, and sends all of any other.
private func thExpectSendsConversation(_ request: JSONValue, threaded: Bool, _ conversation: [JSONValue],
                                       sourceLocation: SourceLocation = #_sourceLocation)
{
    if !threaded {
        #expect(request["thread"] == nil, sourceLocation: sourceLocation)
        #expect(request["messages"] == .array(conversation), sourceLocation: sourceLocation)
    } else if Array(conversation.prefix(2)) == [THREADS_WEATHER_QUESTION, thToolUse("toolu_a")] {
        #expect(request["thread"] == thContinueFrom("msg_a"), sourceLocation: sourceLocation)
        #expect(request["messages"] == .array(Array(conversation.dropFirst(2))), sourceLocation: sourceLocation)
    } else {
        #expect(request["thread"] == THREADS_CREATE, sourceLocation: sourceLocation)
        #expect(request["messages"] == .array(conversation), sourceLocation: sourceLocation)
    }
}

/// What a loop body does with the `toolu_a` reply to the weather question, and what the runner does next (`LoopBody`).
struct ThreadsLoopBody: Sendable, CustomTestStringConvertible {
    enum Reads: Sendable { case nothing, reply, toolResponse }
    let name: String
    let reads: Reads
    let change: @Sendable (BetaToolRunner, BetaMessage, JSONValue?) async throws -> Void
    /// The conversation the model sees with the next request.
    let conversation: [JSONValue]
    let toolRuns: Int
    var testDescription: String { name }
}

private func thSetMessages(_ added: JSONValue...) -> @Sendable (BetaToolRunner, BetaMessage, JSONValue?) async throws -> Void {
    { runner, _, _ in
        try await runner.setMessagesParams { params in
            var p = params
            p["messages"] = .array((params["messages"]?.arrayValue ?? []) + added)
            return p
        }
    }
}

let THREADS_LOOP_BODIES: [ThreadsLoopBody] = [
    ThreadsLoopBody(name: "reply_tool_response_and_text_appended", reads: .toolResponse, change: { runner, reply, toolResponse in
        try await runner.appendMessages(reply)
        try await runner.appendMessages(json: toolResponse!, thUser("Be concise."))
    }, conversation: [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a"), thUser("Be concise.")], toolRuns: 2),
    ThreadsLoopBody(name: "reply_and_changed_tool_response_appended", reads: .toolResponse, change: { runner, reply, toolResponse in
        var response = toolResponse!.objectValue!
        response["content"] = .array((response["content"]?.arrayValue ?? []).map { block in
            var b = block.objectValue!
            b["cache_control"] = ["type": "ephemeral"]
            return .object(b)
        })
        try await runner.appendMessages(reply)
        try await runner.appendMessages(json: .object(response))
    }, conversation: [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), CACHED_RESULT], toolRuns: 2),
    ThreadsLoopBody(name: "reply_and_own_result_appended", reads: .reply, change: { runner, reply, _ in
        try await runner.appendMessages(reply)
        try await runner.appendMessages(json: FOGGY)
    }, conversation: [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), FOGGY], toolRuns: 1),
    ThreadsLoopBody(name: "own_result_appended", reads: .nothing, change: { runner, _, _ in try await runner.appendMessages(json: FOGGY) },
                    conversation: [THREADS_WEATHER_QUESTION, FOGGY], toolRuns: 1),
    ThreadsLoopBody(name: "text_appended", reads: .nothing, change: { runner, _, _ in try await runner.appendMessages(json: thUser("In one word.")) },
                    conversation: [THREADS_WEATHER_QUESTION, thUser("In one word.")], toolRuns: 1),
    ThreadsLoopBody(name: "edited_reply_and_own_result_appended", reads: .nothing, change: { runner, _, _ in
        try await runner.appendMessages(json: EDITED_TOOL_USE, FOGGY)
    }, conversation: [THREADS_WEATHER_QUESTION, EDITED_TOOL_USE, FOGGY], toolRuns: 1),
    ThreadsLoopBody(name: "history_rewritten_then_text_appended", reads: .nothing, change: { runner, _, _ in
        try await runner.setMessagesParams { params in
            var p = params
            p["messages"] = [thUser("Start over: Oakland?")]
            return p
        }
        try await runner.appendMessages(json: thUser("Also Berkeley."))
    }, conversation: [thUser("Start over: Oakland?"), thUser("Also Berkeley.")], toolRuns: 1),
    ThreadsLoopBody(name: "text_set", reads: .nothing, change: thSetMessages(thUser("In one word.")),
                    conversation: [THREADS_WEATHER_QUESTION, thUser("In one word."), thToolUse("toolu_a"), thToolResult("toolu_a")], toolRuns: 1),
    ThreadsLoopBody(name: "reply_and_text_set", reads: .nothing, change: thSetMessages(thToolUse("toolu_a"), thUser("In one word.")),
                    conversation: [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thUser("In one word."), thToolUse("toolu_a"), thToolResult("toolu_a")],
                    toolRuns: 1),
    ThreadsLoopBody(name: "same_history_set", reads: .nothing, change: thSetMessages(),
                    conversation: [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")], toolRuns: 1),
]

private func thTwoToolUsesResponse(_ id: String) -> ThreadsReply {
    var reply = thMessageBody(id, toolUseID: "toolu_a").objectValue!
    reply["content"] = .array((reply["content"]?.arrayValue ?? []) + (thMessageBody(id, toolUseID: "toolu_b")["content"]?.arrayValue ?? []))
    return .json(.object(reply), status: 200, headers: [:])
}

@Suite struct ThreadsRunnerThreadingTests {
    @Test func runnerThreadsByDefault() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))

        let final = try await thMakeRunner(mock).untilDone()

        let created = mock.bodies[0], continued = mock.bodies[1]
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["messages"] == [THREADS_WEATHER_QUESTION])
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["messages"] == [thToolResult("toolu_a")])
        #expect(continued["tools"] == nil)
        #expect(mock.betas == [[THREADS_BETA], [THREADS_BETA]])
        #expect(mock.helperTags == ["BetaToolRunner, message-thread", "BetaToolRunner, message-thread"])
        #expect(final.id == "msg_b")
    }

    @Test func runnerAddsAndRemovesToolsOnTheThread() async throws {
        let mock = ThreadsMock(replies: thToolChangeReplies())
        let added = thLookupTool()
        let runner = try thMakeRunner(mock, fields: ["betas": [.string(THREADS_INLINE_TOOLS_BETA)]])

        _ = try await runner.next()
        try await runner.addTools(added)
        _ = try await runner.next()
        try await runner.removeTools("get_weather")
        let final = try await expectWarning("Tool 'get_weather' not found in tool runner") { try await runner.untilDone() }

        let turns = thToolChangeTurns(try added.toToolParam())
        #expect(final.id == "msg_d")
        let bodies = mock.bodies
        #expect(bodies.map { $0["thread"] } == [THREADS_CREATE, thContinueFrom("msg_a"), thContinueFrom("msg_b"), thContinueFrom("msg_c")])
        #expect(bodies.map { $0["messages"] } == [[THREADS_WEATHER_QUESTION]] + turns.map { .array($0) })
        #expect(bodies.map { $0["tools"] } == [[try thWeatherTool().toToolParam()], nil, nil, nil])
    }

    @Test func runnerWithACallerAnthropicBetaHeaderStillSendsTheThreadsBeta() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))

        try await thMakeRunner(mock, extraHeaders: ["anthropic-beta": .value(THREADS_CONTEXT_MANAGEMENT_BETA)]).untilDone()

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
        #expect(mock.betas == Array(repeating: [THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA], count: 2))
    }

    @Test func runnerResumesAPausedTurnOnTheThread() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thMessageResponse("msg_b"))

        let final = try await thMakeRunner(mock).untilDone()

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [])
        #expect(final.id == "msg_b")
    }

    @Test func nonStreamingRunnerDoesNotAddTheStructuredOutputsBeta() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        try await thMakeRunner(mock).untilDone()
        #expect(mock.betas == [[THREADS_BETA]])
    }

    @Test func runnerContinuesWithoutAThreadAfterAnUnsupportedRequest() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b", toolUseID: "toolu_b"),
                               thMessageResponse("msg_c", "Sunny."))

        let final = try await thMakeRunner(mock).untilDone()

        #expect(mock.threads == [THREADS_CREATE, nil, nil])
        #expect(mock.helperTags == Array(repeating: "BetaToolRunner, message-thread", count: 3))
        #expect(mock.bodies[2]["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_b"), thToolResult("toolu_b")])
        #expect(final.id == "msg_c")
    }

    @Test func runnerContinuesWithoutAThreadWhenTheThreadIsLostAgainRightAfterAReplay() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c", toolUseID: "toolu_c"),
                               THREADS_NOT_FOUND, thMessageResponse("msg_e", toolUseID: "toolu_e"), thMessageResponse("msg_f", "Sunny."))

        let final = try await thMakeRunner(mock).untilDone()

        let history = [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a"), thToolUse("toolu_c"), thToolResult("toolu_c")]
        #expect(final.id == "msg_f")
        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), nil, nil])
        #expect(mock.bodies.dropFirst(4).map { $0["messages"] } == [.array(history), .array(history + [thToolUse("toolu_e"), thToolResult("toolu_e")])])
    }

    @Test func runnerGoesOnUnderANewThreadAfterAReplyFromAFallbackModel() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", iterations: THREADS_FALLBACK_ITERATIONS),
                               thMessageResponse("msg_b", toolUseID: "toolu_b"), thMessageResponse("msg_c", "Sunny."))

        let final = try await thMakeRunner(mock, fields: ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]]).untilDone()

        let bodies = mock.bodies
        #expect(final.id == "msg_c")
        for body in bodies {
            #expect(body["model"] == .string(THREADS_MODEL))
            #expect(body["fallbacks"] == THREADS_FALLBACKS)
        }
        #expect(bodies.map { $0["thread"] } == [THREADS_CREATE, THREADS_CREATE, thContinueFrom("msg_b")])
        #expect(bodies[1]["tools"] == bodies[0]["tools"])
        #expect(bodies[1]["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")])
        #expect(bodies[2]["messages"] == [thToolResult("toolu_b")])
    }

    @Test func runnerWithThreadFalseChangesNothingAfterAReplyFromAFallbackModel() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", iterations: THREADS_FALLBACK_ITERATIONS),
                               thMessageResponse("msg_b", "Sunny."))

        try await thMakeRunner(mock, fields: ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]], thread: false).untilDone()

        #expect(mock.bodies[1]["model"] == .string(THREADS_MODEL))
        #expect(mock.bodies[1]["fallbacks"] == THREADS_FALLBACKS)
    }

    @Test func runnerWithThreadFalseSendsTheFullHistoryWithoutAThread() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))

        try await thMakeRunner(mock, thread: false).untilDone()

        #expect(mock.threads == [nil, nil])
        #expect(mock.betas == [[], []])
        #expect(mock.helperTags == ["BetaToolRunner", "BetaToolRunner"])
        #expect(mock.bodies[1]["messages"] == [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")])
    }

    @Test func runnerWithThreadFalseRecordsARefusedTurn() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "I can't help with that.", stopReason: "refusal"))
        let runner = try thMakeRunner(mock, thread: false)
        let history = ToolsBox<[JSONValue]>([])

        let final = try await runner.untilDone()
        try await runner.setMessagesParams { params in
            history.value = params["messages"]?.arrayValue ?? []
            return params
        }

        #expect(final.id == "msg_b")
        #expect(thRoles(history.value) == ["user", "assistant", "user", "assistant"])
    }

    @Test func runnerWithThreadFalseSendsEveryCacheMarkerAsGiven() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))

        try await thMakeRunner(mock, messages: [thMarked("What is the weather in SF?")], thread: false).untilDone()

        #expect(mock.bodies[1]["messages"] == [thMarked("What is the weather in SF?"), thToolUse("toolu_a"), thToolResult("toolu_a")])
    }

    @Test func runnerWithThreadFalseReusesTheContainer() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", container: "container_a"), thMessageResponse("msg_b", "Sunny."))
        try await thMakeRunner(mock, thread: false).untilDone()
        #expect(mock.bodies[1]["container"] == "container_a")
    }

    @Test func runnerKeepsContainerSkillsWhenAdoptingAContainer() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a", container: "container_a"), thMessageResponse("msg_b", "Sunny."))
        let skills: JSONValue = [["type": "anthropic", "skill_id": "xlsx", "version": "latest"]]

        try await thMakeRunner(mock, fields: ["container": ["skills": skills]]).untilDone()

        #expect(mock.bodies[0]["container"] == ["skills": skills])
        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["container"] == ["skills": skills, "id": "container_a"])
    }

    @Test(arguments: THREADS_LOOP_BODIES, [true, false])
    func runnerSendsTheHistoryTheLoopBodyLeaves(body: ThreadsLoopBody, threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let calls = ToolsBox(0)
        let runner = try thMakeRunner(mock, tools: [thWeatherTool(calls: calls)], thread: threaded ? nil : false)

        let reply = try #require(try await runner.next())
        let toolResponse = body.reads == .toolResponse ? try await runner.generateToolCallResponseJSON() : nil
        try await body.change(runner, reply, toolResponse)
        let final = try await runner.untilDone()

        let requests = mock.bodies
        #expect(requests.count == 2)
        thExpectSendsConversation(requests[1], threaded: threaded, body.conversation)
        #expect(calls.value == body.toolRuns)
        #expect(final.id == "msg_b")
    }

    @Test(arguments: [true, false])
    func runnerLeavesARawToolCallToTheResultTheCallerAppends(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Foggy."))
        let runner = try thMakeRunner(mock, tools: [try thWeatherTool().toToolParam()], thread: threaded ? nil : false)

        let item = try #require(try await runner.next())
        try await runner.appendMessages(item)
        try await runner.appendMessages(json: FOGGY)
        try await expectWarning("Tool 'get_weather' not found in tool runner") { try await runner.untilDone() }

        #expect(mock.bodies.count == 2)
        thExpectSendsConversation(mock.bodies[1], threaded: threaded, [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), FOGGY])
    }

    @Test(arguments: [true, false])
    func runnerAddsNoResultForACallTheCallerLeavesUnanswered(threaded: Bool) async throws {
        let mock = ThreadsMock(thTwoToolUsesResponse("msg_a"), thMessageResponse("msg_b"))
        let runner = try thMakeRunner(mock, thread: threaded ? nil : false)

        let reply = try #require(try await runner.next())
        try await runner.appendMessages(reply)
        try await runner.appendMessages(json: FOGGY)
        try await runner.untilDone()

        let sent = mock.bodies[1]["messages"]?.arrayValue ?? []
        #expect(sent.last == FOGGY)
        #expect(thRoles(sent) == (threaded ? ["user"] : ["user", "assistant", "user"]))
    }

    @Test(arguments: [true, false])
    func runnerGivesSetMessagesParamsTheHistoryWithoutTheReply(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", toolUseID: "toolu_b"),
                               thMessageResponse("msg_c", "Sunny."))
        let runner = try thMakeRunner(mock, thread: threaded ? nil : false)

        _ = try await runner.next()
        _ = try await runner.next()
        try await runner.setMessagesParams { params in
            var p = params
            p["messages"] = .array(Array((params["messages"]?.arrayValue ?? []).suffix(2)))
            return p
        }
        try await runner.untilDone()

        thExpectSendsConversation(mock.bodies[2], threaded: threaded,
                                  [thToolUse("toolu_a"), thToolResult("toolu_a"), thToolUse("toolu_b"), thToolResult("toolu_b")])
    }

    @Test(arguments: [true, false])
    func runnerStillRunsAToolThatSetMessagesParamsGivesAsADefinition(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let tool = thWeatherTool()
        let runner = try thMakeRunner(mock, tools: [tool], thread: threaded ? nil : false)

        _ = try await runner.next()
        let definition = try tool.toToolParam()
        try await runner.setMessagesParams { params in
            var p = params
            p["tools"] = [definition]
            return p
        }
        try await runner.untilDone()

        thExpectSendsConversation(mock.bodies[1], threaded: threaded, [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")])
    }

    @Test(arguments: [true, false])
    func runnerRunsNeitherAToolSetMessagesParamsTakesOutOfToolsNorOneItAdds(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", toolUseID: "toolu_b", toolName: "lookup"),
                               thMessageResponse("msg_c"))
        let calls = ToolsBox(0)
        let runner = try thMakeRunner(mock, tools: [thWeatherTool(calls: calls)], thread: threaded ? nil : false)

        // On a thread the definitions sent can change only before the first request.
        let lookup = try thLookupTool().toToolParam()
        try await runner.setMessagesParams { params in
            var p = params
            p["tools"] = [lookup]
            return p
        }
        try await expectWarning("not found in tool runner") { try await runner.untilDone() }

        let bodies = mock.bodies
        #expect(calls.value == 0)
        #expect(bodies[0]["tools"]?.arrayValue?.map { $0["name"] } == ["lookup"])
        for (request, id, name) in [(bodies[1], "toolu_a", "get_weather"), (bodies[2], "toolu_b", "lookup")] {
            #expect(request["messages"]?.arrayValue?.last?["content"] == [[
                "type": "tool_result", "tool_use_id": .string(id), "content": .string("Error: Tool '\(name)' not found"), "is_error": true,
            ]])
        }
    }

    @Test(arguments: [true, false])
    func runnerKeepsTheFirstTurnAfterAppendMessagesBeforeTheLoop(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let calls = ToolsBox(0)
        let runner = try thMakeRunner(mock, tools: [thWeatherTool(calls: calls)], thread: threaded ? nil : false)

        try await runner.appendMessages(json: thUser("Be concise."))
        try await runner.untilDone()

        let first = mock.bodies[0], second = mock.bodies[1]
        let turn = [thToolUse("toolu_a"), thToolResult("toolu_a")]
        #expect(first["messages"] == [THREADS_WEATHER_QUESTION, thUser("Be concise.")])
        #expect(second["thread"] == (threaded ? (thContinueFrom("msg_a") as JSONValue?) : nil))
        #expect(second["messages"] == (threaded ? .array(Array(turn.dropFirst())) : .array((first["messages"]?.arrayValue ?? []) + turn)))
        #expect(calls.value == 1)
    }

    @Test(arguments: ["without_the_reply", "rewritten_history"], [true, false])
    func runnerTakesANewSystemWithAnotherHistoryOnlyWhenItSendsTheWholeHistory(change: String, threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b"))
        let calls = ToolsBox(0)
        let runner = try thMakeRunner(mock, fields: ["system": "Be brief."], tools: [thWeatherTool(calls: calls)], thread: threaded ? nil : false)

        _ = try await runner.next()
        if change == "without_the_reply" {
            try await runner.appendMessages(json: thUser("Never mind."))
            try await runner.setMessagesParams { params in
                var p = params
                p["system"] = "Be very brief."
                return p
            }
        } else {
            try await runner.setMessagesParams { params in
                var p = params
                p["system"] = "Be very brief."
                p["messages"] = [thUser("Start over.")]
                return p
            }
        }
        if threaded {
            do {
                try await runner.untilDone()
                Issue.record("expected the turn to be refused")
            } catch let error as AnthropicError {
                #expect(error.message.contains("Cannot change `system`"))
            }
        } else {
            try await runner.untilDone()
        }

        let sent: [JSONValue?] = threaded ? ["Be brief."] : ["Be brief.", "Be very brief."]
        #expect(mock.bodies.map { $0["system"] } == sent)
        #expect(calls.value == sent.count - 1)
    }

    @Test(arguments: [true, false])
    func runnerStillRunsAToolFromAddToolsAfterSetMessagesParams(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", toolUseID: "toolu_b", toolName: "lookup"),
                               thMessageResponse("msg_c"))
        let runner = try thMakeRunner(mock, fields: ["betas": [.string(THREADS_INLINE_TOOLS_BETA)]], thread: threaded ? nil : false)

        _ = try await runner.next()
        try await runner.addTools(thLookupTool())
        try await runner.setMessagesParams { params in
            var p = params
            p["max_tokens"] = 5
            return p
        }
        try await runner.untilDone()

        #expect(mock.bodies[2]["messages"]?.arrayValue?.last == thToolResult("toolu_b", "800,000 people live in San Francisco"))
    }

    @Test(arguments: [true, false])
    func runnerGivesSetMessagesParamsTheToolsAsDefinitions(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let tool = thWeatherTool()
        let runner = try thMakeRunner(mock, tools: [tool], thread: threaded ? nil : false)
        let seen = ToolsBox<[JSONValue]>([])

        _ = try await runner.next()
        try await runner.setMessagesParams { params in
            seen.value = params["tools"]?.arrayValue ?? []
            return params
        }
        try await runner.untilDone()

        #expect(seen.value == [try tool.toToolParam()])
        thExpectSendsConversation(mock.bodies[1], threaded: threaded, [THREADS_WEATHER_QUESTION, thToolUse("toolu_a"), thToolResult("toolu_a")])
    }

    @Test func runnerSendsTheToolDefinitionsASetMessagesParamsCallbackMarks() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b"))
        let runner = try thMakeRunner(mock, thread: false)

        _ = try await runner.next()
        try await runner.setMessagesParams { params in
            var p = params
            p["tools"] = .array((params["tools"]?.arrayValue ?? []).map { tool in
                var t = tool.objectValue!
                t["cache_control"] = ["type": "ephemeral"]
                return .object(t)
            })
            return p
        }
        try await runner.untilDone()

        var marked = try thWeatherTool().toToolParam().objectValue!
        marked["cache_control"] = ["type": "ephemeral"]
        #expect(mock.bodies[1]["tools"] == [.object(marked)])
        #expect(mock.bodies[1]["messages"]?.arrayValue?.last == thToolResult("toolu_a"))
    }

    @Test(arguments: [true, false])
    func runnerKeepsTheHeaderParamsThatSetMessagesParamsLeavesOut(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let tool = thWeatherTool()
        let runner = try thMakeRunner(mock, fields: ["betas": [.string(THREADS_CONTEXT_MANAGEMENT_BETA)], "user_profile_id": "uprof_a",
                                                     "workspace_id": "wrkspc_a"], tools: [tool], thread: threaded ? nil : false)
        let params: BetaToolRunnerParams = ["model": .string(THREADS_MODEL), "max_tokens": 2048, "tools": [try tool.toToolParam()],
                                            "messages": [THREADS_WEATHER_QUESTION]]

        _ = try await runner.next()
        try await runner.setMessagesParams(params)
        try await runner.untilDone()

        let first = mock.requests[0], second = mock.requests[1]
        #expect(mock.bodies[1]["max_tokens"] == 2048)
        for header in ["anthropic-beta", "anthropic-user-profile-id", "anthropic-workspace-id"] {
            #expect(second.headers[header] == first.headers[header])
        }
        #expect(mock.betas[1].contains(THREADS_CONTEXT_MANAGEMENT_BETA))
        #expect(second.headers["anthropic-user-profile-id"] == "uprof_a")
        #expect(second.headers["anthropic-workspace-id"] == "wrkspc_a")
    }

    @Test(arguments: [true, false])
    func runnerSendsTheBetasThatSetMessagesParamsGives(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b"))
        let runner = try thMakeRunner(mock, fields: ["betas": [.string(THREADS_CONTEXT_MANAGEMENT_BETA)]], thread: threaded ? nil : false)

        _ = try await runner.next()
        try await runner.setMessagesParams { params in
            var p = params
            p["betas"] = [.string(THREADS_INLINE_TOOLS_BETA)]
            return p
        }
        try await runner.untilDone()

        #expect(mock.betas[1].contains(THREADS_INLINE_TOOLS_BETA))
        #expect(!mock.betas[1].contains(THREADS_CONTEXT_MANAGEMENT_BETA))
    }

    @Test(arguments: [true, false])
    func runnerStopsOnAToolUseReplyWithoutToolCallsWhateverTheCallerAppends(threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Which city?", stopReason: "tool_use"))
        let runner = try thMakeRunner(mock, thread: threaded ? nil : false)

        let item = try #require(try await runner.next())
        try await runner.appendMessages(item)
        try await runner.appendMessages(json: thUser("San Francisco"))
        let final = try await runner.untilDone()

        #expect(final.id == "msg_a")
        #expect(mock.bodies.count == 1)
    }

    @Test(arguments: [true, false], [true, false])
    func runnerResumesAPausedTurnWithTheHistoryTheCallerAppendedTo(appendsReply: Bool, threaded: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thMessageResponse("msg_b"))
        let runner = try thMakeRunner(mock, thread: threaded ? nil : false)

        let item = try #require(try await runner.next())
        if appendsReply { try await runner.appendMessages(item) }
        try await runner.appendMessages(json: thUser("Never mind."))
        try await runner.untilDone()

        let resumed = mock.bodies[1]
        if appendsReply && threaded {
            #expect(resumed["thread"] == thContinueFrom("msg_a"))
            #expect(resumed["messages"] == [thUser("Never mind.")])
        } else {
            #expect(resumed["thread"] == (threaded ? (THREADS_CREATE as JSONValue?) : nil))
            #expect(resumed["messages"] == .array([THREADS_WEATHER_QUESTION] + (appendsReply ? [thAssistant("Searching")] : []) + [thUser("Never mind.")]))
        }
    }

    @Test(arguments: [(THREADS_WEATHER_QUESTION, thContinueFrom("msg_a")), (thUser("And in Oakland?"), THREADS_CREATE)])
    func runnerRecognizesTheReplyInAHistoryBuiltFromTheParsedMessage(question: JSONValue, thread: JSONValue) async throws {
        var reply = thMessageBody("msg_a", toolUseID: "toolu_a").objectValue!
        reply["content"] = .array([["type": "text", "text": "Let me look."]] + (reply["content"]?.arrayValue ?? []))
        let mock = ThreadsMock(.json(.object(reply), status: 200, headers: [:]), thMessageResponse("msg_b"))
        let runner = try thMakeRunner(mock)
        let message = try #require(try await runner.next())
        let content = try JSONValue.from(message.content)

        try await runner.setMessagesParams { params in
            var p = params
            p["messages"] = [question, ["role": "assistant", "content": content]]
            return p
        }
        try await runner.untilDone()

        let body = mock.bodies[1]
        #expect(body["thread"] == thread)
        #expect(thRoles(body["messages"]) == (thread != THREADS_CREATE ? ["user"] : ["user", "assistant", "user"]))
    }

    @Test func bedrockRunnerNeverThreads() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let client = try AnthropicBedrock(awsSecretKey: "example-secret-key", awsAccessKey: "example-access-key", awsRegion: "us-east-1",
                                          transport: mock.transport, environment: isolatedEnv())
        let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: [try param(THREADS_WEATHER_QUESTION)],
                                                         model: "anthropic.claude-sonnet-5", tools: [thWeatherTool()])

        try await runner.untilDone()

        #expect(mock.requests.map { $0.url.host } == ["bedrock-runtime.us-east-1.amazonaws.com", "bedrock-runtime.us-east-1.amazonaws.com"])
        #expect(mock.threads == [nil, nil])
        #expect(mock.bodies.allSatisfy { !(($0["anthropic_beta"]?.arrayValue ?? []).contains(.string(THREADS_BETA))) })
        #expect(mock.helperTags == ["BetaToolRunner", "BetaToolRunner"])
    }

    @Test func bedrockMantleRunnerNeverThreads() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let client = try AnthropicBedrockMantle(awsRegion: "us-east-1", apiKey: "example-api-key", transport: mock.transport,
                                                environment: isolatedEnv())
        let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: [try param(THREADS_WEATHER_QUESTION)],
                                                         model: "claude-sonnet-5", tools: [thWeatherTool()])

        try await runner.untilDone()

        #expect(mock.threads == [nil, nil])
        #expect(mock.helperTags == ["BetaToolRunner", "BetaToolRunner"])
    }

    @Test(arguments: ["bedrock", "bedrock_mantle", "vertex"])
    func threadRaisesOnClientsWithoutMessageThreads(kind: String) throws {
        let client: BaseClient
        switch kind {
        case "bedrock":
            client = try AnthropicBedrock(awsSecretKey: "example-secret-key", awsAccessKey: "example-access-key", awsRegion: "us-east-1",
                                          environment: isolatedEnv())
        case "bedrock_mantle": client = try AnthropicBedrockMantle(awsRegion: "us-east-1", apiKey: "example-api-key", environment: isolatedEnv())
        default: client = try AnthropicVertex(region: "us-east5", projectID: "example-project", accessToken: "example-token", environment: isolatedEnv())
        }
        for build in [
            { _ = try BetaMessagesResource(client: client).thread(maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL)) },
            { _ = try thMakeThread(client) },
        ] as [() throws -> Void] {
            do {
                try build()
                Issue.record("expected an error")
            } catch let error as AnthropicError {
                #expect(error.message.contains("Message threads are not available on this client"))
            }
        }
    }

    @Test func foundryRunnerThreadsByDefault() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let client = try AnthropicFoundry(resource: "example-resource", apiKey: "example-api-key", transport: mock.transport, environment: isolatedEnv())
        let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: [try param(THREADS_WEATHER_QUESTION)],
                                                         model: "claude-sonnet-5", tools: [thWeatherTool()])

        try await runner.untilDone()

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
    }
}
