// Port of tests/lib/threads/test_beta_threads.py (part 1: creating and continuing a thread, betas and helper tags,
// paused turns, replays, unsupported requests, failed turns).
//
// Upstream runs these on the sync thread and repeats the async-specific ones in test_async_beta_threads.py; the
// Swift thread is async only, so each test is ported once.

import Foundation
import Testing
@testable import Anthropic

@Suite struct ThreadsSendTests {
    @Test func firstSendCreatesAThreadWithTheSeedAndTheNewMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, messages: [thUser("Seed"), thAssistant("Seeded")])

        let reply = try await thread.send(thUser("Hello"))

        let body = mock.bodies[0]
        #expect(body["thread"] == THREADS_CREATE)
        #expect(body["messages"] == [thUser("Seed"), thAssistant("Seeded"), thUser("Hello")])
        #expect(thread.previousMessageID == reply.id)
        #expect(reply.id == "msg_a")
    }

    @Test func nextSendContinuesTheThreadWithOnlyTheNewMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        try await thread.send(thUser("Hello"))
        let second = try await thread.send(thUser("Again"))

        let body = mock.bodies[1]
        #expect(body["thread"] == thContinueFrom("msg_a"))
        #expect(body["messages"] == [thUser("Again")])
        #expect(thread.previousMessageID == second.id)
        #expect(second.id == "msg_b")
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
    }

    @Test func continueOmitsTheSystemAndToolsTheServerHolds() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["model": "claude-sonnet-5", "system": "You are terse.", "tools": [THREADS_NOOP_TOOL]])

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        let created = mock.bodies[0], continued = mock.bodies[1]
        #expect(created["system"] == "You are terse.")
        #expect(created["tools"] == [THREADS_NOOP_TOOL])
        #expect(continued["model"] == "claude-sonnet-5")
        #expect(continued["system"] == nil && continued["tools"] == nil)
    }

    @Test func replayAfterAContinueSendsSystemAndToolsAgain() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, ["system": "You are terse.", "tools": [THREADS_NOOP_TOOL]])
        try await thread.send(thUser("Hello"))

        try await thread.send(thUser("Again"))

        let replayed = mock.bodies[2]
        #expect(replayed["thread"] == THREADS_CREATE)
        #expect(replayed["system"] == "You are terse.")
        #expect(replayed["tools"] == [THREADS_NOOP_TOOL])
    }

    @Test func sendOverridesApplyToThatTurnOnly() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["max_tokens": 1024])

        try await thSend(thread, thUser("Hello"), fields: ["max_tokens": 12, "speed": "fast"])
        try await thread.send(thUser("Again"))

        let overridden = mock.bodies[0], later = mock.bodies[1]
        #expect(overridden["max_tokens"] == 12)
        #expect(overridden["speed"] == "fast")
        #expect(later["max_tokens"] == 1024)
        #expect(later["speed"] == nil)
    }

    @Test func sendTakesTypedOverrides() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        try await thread.send(thUser("Hello"), params: ThreadSendParams(maxTokens: 12, speed: .some(.fast)))
        try await thread.send(BetaMessageParam.user(BetaUserMessageParam(content: .string("Again"))))

        #expect(mock.bodies[0]["max_tokens"] == 12)
        #expect(mock.bodies[0]["speed"] == "fast")
        #expect(mock.bodies[1]["max_tokens"] == 1024)
        #expect(mock.bodies[1]["messages"] == [thUser("Again")])
    }

    @Test(arguments: [
        ([String](), [THREADS_BETA]),
        ([THREADS_CONTEXT_MANAGEMENT_BETA], [THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA]),
        ([THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA], [THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA]),
    ])
    func everyTurnSendsTheThreadsBetaOnceAfterTheCallersBetas(betas: [String], expected: [String]) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["betas": .array(betas.map { .string($0) })])

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        #expect(mock.betas == [expected, expected])
    }

    @Test(arguments: [THREADS_CONTEXT_MANAGEMENT_BETA, "\(THREADS_CONTEXT_MANAGEMENT_BETA), \(THREADS_BETA)"])
    func callerAnthropicBetaHeaderGainsTheThreadsBetaOnce(header: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, extraHeaders: ["Anthropic-Beta": .value(header)])

        try await thread.send(thUser("Hello"))
        try await thSend(thread, thUser("Again"), extraHeaders: ["anthropic-beta": .value(header)])

        let expected = [THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA]
        #expect(mock.betas == [expected, expected])
    }

    @Test func callerAnthropicBetaHeaderIsLeftAloneOnceUnthreaded() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded,
                                      extraHeaders: ["anthropic-beta": .value(THREADS_CONTEXT_MANAGEMENT_BETA)])

        try await thread.send(thUser("Hello"))

        #expect(mock.betas == [[THREADS_CONTEXT_MANAGEMENT_BETA, THREADS_BETA], [THREADS_CONTEXT_MANAGEMENT_BETA]])
    }

    @Test(arguments: ThreadsTurnMethod.allCases)
    func everyRequestNamesTheThreadInTheHelperTelemetryHeader(method: ThreadsTurnMethod) async throws {
        let mock = ThreadsMock(thRespond(method, "msg_a"), THREADS_NOT_FOUND, thRespond(method, "msg_c"),
                               thUnsupportedResponse("inference_hooks"), thRespond(method, "msg_e"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        for text in ["One", "Two", "Three"] { try await thRunTurn(thread, method, thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), nil])
        #expect(mock.helperTags == Array(repeating: "message-thread", count: 5))
    }

    @Test func noRequestOptionDropsOrRepeatsTheHelperTag() async throws {
        let mock = ThreadsMock(replies: ["msg_a", "msg_b", "msg_c", "msg_d"].map { thMessageResponse($0) })
        let thread = try thMakeThread(mock, extraHeaders: ["X-Stainless-Helper": "mine"])

        try await thread.send(thUser("One"))
        try await thSend(thread, thUser("Two"), extraHeaders: [:])
        try await thSend(thread, thUser("Three"), extraHeaders: ["x-stainless-helper": "message-thread, mine"])
        try thread.update(extraHeaders: ["x-stainless-helper": .omit])
        try await thread.send(thUser("Four"))

        #expect(mock.helperTags == ["mine, message-thread", "message-thread", "message-thread, mine", "message-thread"])
    }

    @Test func consecutiveUserMessagesAreSentAsTheyWereAppended() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock)

        try thread.append(thUser("part one"))
        try thread.append(["role": "user", "content": [["type": "text", "text": "part two"]]] as JSONValue)
        try await thread.send()

        #expect(mock.bodies[0]["messages"] == [thUser("part one"), ["role": "user", "content": [["type": "text", "text": "part two"]]]])
    }

    @Test func sendWithNothingStagedGoesOut() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try await thread.send()

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [])
    }

    @Test func sendAfterAPausedReplyContinuesFromItWithNoMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let resumed = try await thread.send()

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [])
        #expect(thread.previousMessageID == resumed.id)
        #expect(resumed.id == "msg_b")
    }

    @Test func aTurnThatPausesTwiceContinuesFromTheSecondPauseWithNoMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"),
                               thMessageResponse("msg_b", "Still searching", stopReason: "pause_turn"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        try await thread.send()

        try await thread.send()

        #expect(mock.bodies[2]["thread"] == thContinueFrom("msg_b"))
        #expect(mock.bodies[2]["messages"] == [])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "assistant", "assistant"])
    }

    @Test func sendAfterAResumedTurnFinishesContinuesFromItsLastReply() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thMessageResponse("msg_b"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        try await thread.send()

        try await thread.send(thUser("Again"))

        #expect(mock.bodies[2]["thread"] == thContinueFrom("msg_b"))
        #expect(mock.bodies[2]["messages"] == [thUser("Again")])
    }

    @Test func userMessageAfterAPausedReplyIsSentAloneAndThe400IsRaised() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"),
                               thAPIErrorResponse(400, "invalid_request_error", "messages.0: `server_tool_use` was not executed"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: BadRequestError.self) { try await thread.send(thUser("Never mind")) }

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thUser("Never mind")])
    }

    @Test func resumeStreamThatEndsBeforeAnyContentKeepsThePausedReplyResumable() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thStreamResponse("msg_b", "found it"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let stream = try await thread.stream()
        var iterator = stream.makeAsyncIterator()
        let first = try await iterator.next()
        if case .messageStart? = first {} else { Issue.record("expected message_start, got \(String(describing: first))") }
        stream.close()
        try await thread.send()

        let retried = mock.bodies[2]
        #expect(retried["thread"] == THREADS_CREATE)
        #expect(retried["messages"] == [thUser("Hello"), thAssistant("Searching")])
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func resumeThatFindsTheThreadGoneReplaysTheHistoryEndingInThePausedReply() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), THREADS_NOT_FOUND, thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try await thread.send()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Searching")])
    }

    @Test(arguments: [(THREADS_NOT_FOUND, "thread_not_found"), (THREADS_ALREADY_CONTINUED, "thread_already_continued"),
                      (THREADS_CONTINUE_IN_FLIGHT, "thread_continue_in_flight")])
    func rejectedPreviousMessageIDReplaysTheFullHistoryUnderANewThread(rejection: ThreadsReply, reason: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), rejection, thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)

        let (second, capture) = try await ToolDiagnostics.capture {
            try await thread.send(thUser("Hello"))
            return try await thread.send(thUser("Again"))
        }

        let rejected = mock.bodies[1], replayed = mock.bodies[2]
        #expect(rejected["thread"] == thContinueFrom("msg_a"))
        #expect(rejected["messages"] == [thUser("Again")])
        #expect(replayed["thread"] == THREADS_CREATE)
        #expect(replayed["messages"] == [thUser("Hello"), thAssistant(), thUser("Again")])
        #expect(thread.previousMessageID == second.id)
        #expect(second.id == "msg_c")
        #expect(thThreadLogs(capture).contains(
            "Replaying the full message history under a new thread: reason=\(reason) previous_message_id=msg_a"))
    }

    @Test(arguments: [THREADS_FINGERPRINT_MISMATCH, thAPIErrorResponse(400, "invalid_request_error", THREADS_ALREADY_CONTINUED_MESSAGE)])
    func otherThreadRejectionsRaiseAndKeepPreviousMessageID(rejection: ThreadsReply) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), rejection)
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: BadRequestError.self) { try await thread.send(thUser("Again")) }

        #expect(mock.calls == 2)
        #expect(thread.previousMessageID == "msg_a")
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant"])
    }

    @Test func unsupportedRequestRaisesByDefaultAndKeepsPreviousMessageID() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thUnsupportedResponse("fallbacks"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: BadRequestError.self) { try await thSend(thread, thUser("Again"), fields: ["fallbacks": THREADS_FALLBACKS]) }
        try await thread.send(thUser("Again"))

        let retried = mock.bodies[2]
        #expect(mock.calls == 3)
        #expect(retried["thread"] == thContinueFrom("msg_a"))
        #expect(retried["messages"] == [thUser("Again")])
        #expect(retried["fallbacks"] == nil)
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func continueUnthreadedStopsThreadingAfterAnUnsupportedRequestThatListsNoFeature() async throws {
        let mock = ThreadsMock(thAPIErrorResponse(400, "invalid_request_error", "Cannot be used with `thread`.",
                                                  errorCode: "thread_unsupported_request"), thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        try await thread.send(thUser("Hello"))

        #expect(mock.threads == [THREADS_CREATE, nil])
    }

    @Test(arguments: [["fallbacks"], ["inference_hooks"], ["fallbacks", "thinking"], ["something_new"]])
    func continueUnthreadedStopsThreadingForGoodAfterAnUnsupportedRequest(unsupported: [String]) async throws {
        let rejection = thAPIErrorResponse(400, "invalid_request_error", "This request cannot be used with `thread`.",
                                           errorCode: "thread_unsupported_request", details: ["unsupported": .array(unsupported.map { .string($0) })])
        let mock = ThreadsMock(thMessageResponse("msg_a"), rejection, thMessageResponse("msg_c"), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)
        try await thread.send(thUser("Hello"))

        let (_, capture) = try await ToolDiagnostics.capture {
            try await thread.send(thUser("Again"))
            try await thread.send(thUser("Once more"))
        }

        let rejected = mock.bodies[1], unthreaded = mock.bodies[2], later = mock.bodies[3]
        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), nil, nil])
        #expect(Array(mock.betas[2...]) == [[], []])
        #expect(rejected["messages"] == [thUser("Again")])
        #expect(unthreaded["messages"] == [thUser("Hello"), thAssistant(), thUser("Again")])
        #expect(thRoles(later["messages"]) == ["user", "assistant", "user", "assistant", "user"])
        #expect(thread.previousMessageID == nil)
        #expect(thThreadLogs(capture).contains(
            "The server cannot thread this request; continuing without a thread: unsupported=\(unsupported.joined(separator: ","))"))
    }

    @Test func continueUnthreadedReplayThatIsUnsupportedGoesWithoutAThread() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thUnsupportedResponse("fallbacks"), thMessageResponse("msg_d"),
                               thMessageResponse("msg_e"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)
        try await thread.send(thUser("Hello"))

        try await thSend(thread, thUser("Again"), fields: ["fallbacks": THREADS_FALLBACKS])
        try await thread.send(thUser("Once more"))

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, nil, nil])
        #expect(thRoles(mock.bodies[3]["messages"]) == ["user", "assistant", "user"])
        #expect(thRoles(mock.bodies[4]["messages"]) == ["user", "assistant", "user", "assistant", "user"])
        #expect(thread.previousMessageID == nil)
    }

    @Test(arguments: ThreadsTurnMethod.allCases)
    func continueUnthreadedStopsThreadingWhenTheThreadIsLostAgainRightAfterAReplay(method: ThreadsTurnMethod) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"), THREADS_NOT_FOUND,
                               thRespond(method, "msg_e", "Hi!"), thMessageResponse("msg_f"))
        let thread = try thMakeThread(mock, ["system": "You are terse."], behavior: .continueUnthreaded)
        try await thread.send(thUser("One"))
        try await thread.send(thUser("Two"))

        let (_, capture) = try await ToolDiagnostics.capture {
            try await thRunTurn(thread, method, thUser("Three"))
            try await thread.send(thUser("Four"))
        }

        let unthreaded = mock.bodies[4], later = mock.bodies[5]
        let history = [thUser("One"), thAssistant(), thUser("Two"), thAssistant(), thUser("Three")]
        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), nil, nil])
        #expect(unthreaded["messages"] == .array(history))
        #expect(unthreaded["system"] == "You are terse.")
        #expect(later["messages"] == .array(history + [thAssistant(), thUser("Four")]))
        #expect(Array(mock.betas[4...]) == [[], []])
        #expect(thread.previousMessageID == nil)
        #expect(thThreadLogs(capture).contains(
            "The server lost the thread again right after a replay; continuing without a thread: previous_message_id=msg_c"))
    }

    @Test func continueUnthreadedCountsTheCreateAfterAReplayThatFailedAsTheReplay() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thServerError(), thMessageResponse("msg_d"), THREADS_NOT_FOUND,
                               thMessageResponse("msg_f"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)
        try await thread.send(thUser("One"))
        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Two")) }

        try await thread.send(thUser("Two"))
        try await thread.send(thUser("Three"))

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, THREADS_CREATE, thContinueFrom("msg_d"), nil])
    }

    @Test func aThreadLostAgainRightAfterAReplayIsReplayedAgainByDefault() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"), THREADS_NOT_FOUND,
                               thMessageResponse("msg_e"), thMessageResponse("msg_f"))
        let thread = try thMakeThread(mock)

        for text in ["One", "Two", "Three", "Four"] { try await thread.send(thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), THREADS_CREATE,
                                 thContinueFrom("msg_e")])
    }

    @Test func continueUnthreadedReplaysAThreadThatIsLostAfterAContinueThatSucceeded() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"), thMessageResponse("msg_d"),
                               THREADS_NOT_FOUND, thMessageResponse("msg_f"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        for text in ["One", "Two", "Three", "Four"] { try await thread.send(thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), thContinueFrom("msg_d"),
                                 THREADS_CREATE])
    }

    @Test(arguments: [(THREADS_ALREADY_CONTINUED, THREADS_NOT_FOUND), (THREADS_NOT_FOUND, THREADS_ALREADY_CONTINUED),
                      (THREADS_NOT_FOUND, THREADS_CONTINUE_IN_FLIGHT)])
    func continueUnthreadedKeepsThreadingUnlessBothRejectionsAreThreadNotFound(first: ThreadsReply, second: ThreadsReply) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), first, thMessageResponse("msg_c"), second, thMessageResponse("msg_e"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        for text in ["One", "Two", "Three"] { try await thread.send(thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE, thContinueFrom("msg_c"), THREADS_CREATE])
    }

    @Test func continueUnthreadedStreamStopsThreadingForGoodAfterAnUnsupportedRequest() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thUnsupportedResponse("fallbacks"), thStreamResponse("msg_c", "Fallback"),
                               thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)
        try await thread.send(thUser("Hello"))

        let stream = try await thread.stream(try thMessages([thUser("Again")]), overrides: thOverrides(["fallbacks": THREADS_FALLBACKS]))
        let streamed = try await stream.getFinalMessage()
        stream.close()
        try await thread.send(thUser("Once more"))

        let unthreaded = mock.bodies[2], later = mock.bodies[3]
        #expect(streamed.id == "msg_c")
        #expect(unthreaded["stream"] == true)
        #expect(unthreaded["thread"] == nil)
        #expect(later["thread"] == nil)
        #expect(thRoles(later["messages"]) == ["user", "assistant", "user", "assistant", "user"])
        #expect(thread.previousMessageID == nil)
    }

    @Test(arguments: ThreadsTurnMethod.allCases, 0..<THREADS_FAILURES_BEFORE_A_REPLY.count)
    func unrelatedErrorsRaiseAndTheSameCallAgainSendsTheTurnOnce(method: ThreadsTurnMethod, failure: Int) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_FAILURES_BEFORE_A_REPLY[failure], thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        let messagesBefore = thread.messagesJSON

        await #expect(throws: (any Error).self) { try await thRunTurn(thread, method, thUser("Again")) }
        let afterTheError = (thread.messagesJSON, thread.previousMessageID)
        try await thread.send(thUser("Again"))

        let retried = mock.bodies[2]
        #expect(retried["thread"] == thContinueFrom("msg_a"))
        #expect(retried["messages"] == [thUser("Again")])
        #expect(afterTheError.0 == messagesBefore)
        #expect(afterTheError.1 == "msg_a")
    }

    @Test func turnThatFailedIsNotSentWithTheNextTurn() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thServerError(), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Again")) }

        try await thread.send(thUser("Never mind"))

        #expect(mock.bodies[2]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[2]["messages"] == [thUser("Never mind")])
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func messagesAppendedBeforeACallThatFailsStayStaged() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thServerError(), thServerError(), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try thread.append(thUser("Appended"))
        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Again")) }
        await #expect(throws: InternalServerError.self) { try await thread.send() }
        try await thread.send()

        #expect(mock.bodies.dropFirst().map { $0["messages"] } == [[thUser("Appended"), thUser("Again")], [thUser("Appended")], [thUser("Appended")]])
    }

    @Test func failedReplayClearsPreviousMessageID() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thServerError())
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Again")) }

        #expect(mock.calls == 3)
        #expect(thread.previousMessageID == nil)
    }

    @Test func turnAfterAFailedReplayCreatesAThreadWithTheFullHistory() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thServerError(), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Again")) }

        try await thread.send(thUser("Again"))

        #expect(mock.bodies[3]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[3]["messages"] == [thUser("Hello"), thAssistant(), thUser("Again")])
        #expect(thread.previousMessageID == "msg_d")
    }
}
