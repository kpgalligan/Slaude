// Port of tests/lib/threads/test_beta_threads.py (part 2: refused turns, cache markers on replays, replies from a
// fallback model, containers, update, params, fork and output formats).

import Foundation
import Testing
@testable import Anthropic

private let XLSX_SKILL: JSONValue = ["type": "anthropic", "skill_id": "xlsx", "version": "latest"]

@Suite struct ThreadsHistoryTests {
    @Test(arguments: ThreadsTurnMethod.allCases)
    func aRefusedTurnIsNotRecordedAndTheNextTurnStartsANewThread(method: ThreadsTurnMethod) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thRespond(method, "msg_b", "I can't help with that.", stopReason: "refusal"),
                               thMessageResponse("msg_c"), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, ["system": "You are terse.", "tools": [THREADS_NOOP_TOOL]])
        try await thread.send(thUser("Hello"))
        let messagesBefore = thread.messagesJSON

        try await thRunTurn(thread, method, thUser("Refused"))
        let afterTheRefusal = (thread.messagesJSON, thread.previousMessageID)
        try await thread.send(thUser("Rephrased"))
        try await thread.send(thUser("Again"))

        let refused = mock.bodies[1], created = mock.bodies[2], continued = mock.bodies[3]
        #expect(refused["thread"] == thContinueFrom("msg_a"))
        #expect(refused["messages"] == [thUser("Refused")])
        #expect(afterTheRefusal.0 == messagesBefore)
        #expect(afterTheRefusal.1 == nil)
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["system"] == "You are terse.")
        #expect(created["tools"] == [THREADS_NOOP_TOOL])
        #expect(created["messages"] == [thUser("Hello"), thAssistant(), thUser("Rephrased")])
        #expect(continued["thread"] == thContinueFrom("msg_c"))
        #expect(continued["messages"] == [thUser("Again")])
    }

    @Test func aStreamLeftOnceItHasShownTheRefusalIsNotRecorded() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "I can't help with that.", stopReason: "refusal"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, ["system": "You are terse."])
        try await thread.send(thUser("Hello"))
        let messagesBefore = thread.messagesJSON

        try thread.append(thUser("Appended"))
        let stream = try await thread.stream(thUser("Refused"))
        for try await event in stream {
            if case .messageDelta = event { break }
        }
        stream.close()
        let afterTheRefusal = (thread.messagesJSON, thread.previousMessageID)
        try await thread.send(thUser("Rephrased"))

        let created = mock.bodies[2]
        #expect(afterTheRefusal.0 == messagesBefore + [thUser("Appended")])
        #expect(afterTheRefusal.1 == nil)
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["system"] == "You are terse.")
        #expect(created["messages"] == [thUser("Hello"), thAssistant(), thUser("Appended"), thUser("Rephrased")])
    }

    @Test func aRefusedReplyReachesTheCallerAsItCame() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "I can't help with that.", stopReason: "refusal"),
                               thStreamResponse("msg_b", "I can't help with that.", stopReason: "refusal"))
        let thread = try thMakeThread(mock)

        let sent = try await thread.send(thUser("Refused"))
        let stream = try await thread.stream(thUser("Refused"))
        var events: [String] = []
        for try await event in stream { events.append((try? JSONValue.from(event))?["type"]?.stringValue ?? "") }
        let streamed = try await stream.getFinalMessage().message

        for (reply, id) in [(sent, "msg_a"), (streamed, "msg_b")] {
            #expect(reply.id == id)
            #expect(reply.stopReason == .refusal)
            #expect(thText(reply) == ["I can't help with that."])
        }
        #expect(events.last == "message_stop")
    }

    @Test func aRefusedFirstTurnKeepsTheSeedAndNothingTheTurnWasGiven() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", stopReason: "refusal"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, messages: [thUser("Seed"), thAssistant("Seeded")])

        try await thSend(thread, thUser("Refused"), fields: ["system": "Be brief.", "tools": [THREADS_NOOP_TOOL]])
        try await thread.send(thUser("Rephrased"))

        let created = mock.bodies[1]
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["messages"] == [thUser("Seed"), thAssistant("Seeded"), thUser("Rephrased")])
        #expect(created["system"] == nil && created["tools"] == nil)
    }

    @Test func messagesAppendedBeforeARefusedTurnStayStaged() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b", stopReason: "refusal"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try thread.append(thUser("Appended"))
        try await thread.send(thUser("Refused"))
        try await thread.send(thUser("Rephrased"))

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant(), thUser("Appended"), thUser("Rephrased")])
    }

    @Test func aRefusedTurnIsNotRecordedOnceUnthreadedEither() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("fallbacks"), thMessageResponse("msg_a"), thMessageResponse("msg_b", stopReason: "refusal"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)
        try await thread.send(thUser("Hello"))

        try await thread.send(thUser("Refused"))
        try await thread.send(thUser("Rephrased"))

        #expect(mock.threads == [THREADS_CREATE, nil, nil, nil])
        #expect(mock.bodies[3]["messages"] == [thUser("Hello"), thAssistant(), thUser("Rephrased")])
    }

    @Test func aReplayDropsTheCacheMarkersOfTheRecordedMessages() async throws {
        let mock = ThreadsMock(replies: (0..<5).map { thMessageResponse("msg_\($0)") } + [THREADS_NOT_FOUND, thMessageResponse("msg_5")])
        let given = (0..<6).map { thMarked("Turn \($0)") }
        let thread = try thMakeThread(mock)
        for message in given.prefix(5) { try await thread.send(message) }

        try await thread.send(given[5])

        let bodies = mock.bodies
        #expect(bodies.prefix(6).map { $0["messages"] } == (0..<6).map { .array([thMarked("Turn \($0)")]) })
        #expect(bodies[6]["thread"] == THREADS_CREATE)
        #expect(bodies[6]["messages"] == .array((0..<5).flatMap { [thUnmarked("Turn \($0)"), thAssistant()] } + [thMarked("Turn 5")]))
        #expect(thread.messagesJSON.filter { $0["role"] == "user" } == given)
        #expect(thread.params.messages.filter { $0["role"] == "user" } == given)
    }

    @Test func theFirstTurnSendsTheCacheMarkersOfTheSeedAsGiven() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, messages: [thMarked("Seed"), thAssistant("Seeded")])
        try thread.append(thMarked("Appended"))

        try await thread.send(thMarked("Hello"))

        #expect(mock.bodies[0]["messages"] == [thMarked("Seed"), thAssistant("Seeded"), thMarked("Appended"), thMarked("Hello")])
    }

    @Test(arguments: [[JSONValue](), [thMarked("Once more")]])
    func aTurnThatNoReplyAnsweredKeepsItsCacheMarkers(newMessages: [JSONValue]) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thInterruptedStreamResponse("msg_b", ""), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thMarked("Hello"))
        let stream = try await thread.stream(thMarkedTwice("Again"))
        await #expect(throws: StreamEndedEarlyError.self) { try await stream.untilDone() }
        stream.close()

        try await thread.send(try thMessages(newMessages), overrides: thOverrides())

        let created = mock.bodies[2]
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["messages"] == .array([thUnmarked("Hello"), thAssistant(), thMarkedTwice("Again")] + newMessages))
    }

    @Test func aReplayDropsNestedCacheMarkersAndLeavesFreeFormDataAlone() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"))
        let marker: [String: JSONValue] = ["cache_control": ["type": "ephemeral"]]
        let given = thHistoryWithNestedBlocks(marker)
        let thread = try thMakeThread(mock, ["betas": [.string(THREADS_INLINE_TOOLS_BETA)]], messages: given)
        try await thread.send()

        try await thread.send(thUser("Again"))

        #expect(mock.bodies[0]["messages"] == .array(thHistoryWithNestedBlocks(marker)))
        #expect(mock.bodies[2]["messages"] == .array(thHistoryWithNestedBlocks([:]) + [thAssistant(), thUser("Again")]))
        #expect(Array(thread.messagesJSON.prefix(given.count)) == given)
    }

    @Test func aReplayKeepsTheCacheMarkersOutsideTheMessages() async throws {
        let marker: JSONValue = ["type": "ephemeral"]
        var tool = THREADS_NOOP_TOOL.objectValue!
        tool["cache_control"] = marker
        let fields: [String: JSONValue] = [
            "system": [["type": "text", "text": "You are terse.", "cache_control": marker]], "tools": [.object(tool)], "cache_control": marker,
        ]
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, fields)
        try await thread.send(thUser("Hello"))

        try await thread.send(thUser("Again"))

        let replayed = mock.bodies[2]
        for (field, value) in fields { #expect(replayed[field] == value, "\(field)") }
    }

    @Test func everyTurnDropsTheCacheMarkersOfTheRecordedMessagesOnceUnthreaded() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("fallbacks"), thMessageResponse("msg_a"), thMessageResponse("msg_b"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        for text in ["One", "Two", "Three"] { try await thread.send(thMarked(text)) }

        #expect(mock.bodies.dropFirst().map { $0["messages"] } == [
            [thMarked("One")],
            [thUnmarked("One"), thAssistant(), thMarked("Two")],
            [thUnmarked("One"), thAssistant(), thUnmarked("Two"), thAssistant(), thMarked("Three")],
        ])
    }

    @Test func theFirstTurnOfAForkDropsTheCacheMarkersOfTheRecordedMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thMarked("Hello"))
        try thread.append(thMarked("Appended"))

        try await thread.fork().send(thMarked("Again"))

        #expect(mock.bodies[1]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[1]["messages"] == [thUnmarked("Hello"), thAssistant(), thMarked("Appended"), thMarked("Again")])
    }

    @Test func theTurnAfterARefusedOneDropsTheCacheMarkersOfTheRecordedMessages() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b", stopReason: "refusal"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thMarked("Hello"))
        try await thread.send(thMarked("Refused"))

        try await thread.send(thMarked("Rephrased"))

        #expect(mock.bodies[2]["messages"] == [thUnmarked("Hello"), thAssistant(), thMarked("Rephrased")])
    }

    @Test func aReplyFromAFallbackModelOnlyStartsANewThread() async throws {
        let mock = ThreadsMock(thFallbackResponse("msg_a"), thFallbackResponse("msg_b"), thMessageResponse("msg_c"), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, ["system": "You are terse.", "fallbacks": THREADS_FALLBACKS,
                                             "betas": [.string(THREADS_FALLBACK_BETA)]])

        try await thread.send(thUser("Hello"))
        let paramsAfterTheReply = thread.params
        try await thread.send(thUser("Again"))
        try await thread.send(thUser("Once more"))
        try await thread.send(thUser("One last time"))

        let bodies = mock.bodies
        let history = [thUser("Hello"), thFallbackReply(), thUser("Again")]
        #expect(paramsAfterTheReply["model"] == .string(THREADS_MODEL))
        #expect(paramsAfterTheReply["fallbacks"] == THREADS_FALLBACKS)
        for body in bodies {
            #expect(body["model"] == .string(THREADS_MODEL))
            #expect(body["fallbacks"] == THREADS_FALLBACKS)
        }
        #expect(bodies.map { $0["thread"] } == [THREADS_CREATE, THREADS_CREATE, THREADS_CREATE, thContinueFrom("msg_c")])
        #expect(bodies.map { $0["system"] } == ["You are terse.", "You are terse.", "You are terse.", nil])
        #expect(bodies.dropFirst().map { $0["messages"] } == [
            .array(history), .array(history + [thFallbackReply(), thUser("Once more")]), [thUser("One last time")],
        ])
        #expect(mock.betas == Array(repeating: [THREADS_FALLBACK_BETA, THREADS_BETA], count: 4))
    }

    @Test(arguments: ThreadsTurnMethod.allCases)
    func aReplyFromAFallbackModelOnAContinueStartsANewThread(method: ThreadsTurnMethod) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thRespond(method, "msg_b", "Hi!", iterations: THREADS_FALLBACK_ITERATIONS),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, ["fallbacks": "default", "betas": [.string(THREADS_FALLBACK_BETA)]])
        try await thread.send(thUser("Hello"))

        try await thRunTurn(thread, method, thUser("Again"))
        try await thread.send(thUser("Once more"))

        let continued = mock.bodies[1], created = mock.bodies[2]
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["model"] == .string(THREADS_MODEL))
        #expect(continued["fallbacks"] == "default")
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["fallbacks"] == "default")
        #expect(created["messages"] == [thUser("Hello"), thAssistant(), thUser("Again"), thAssistant(), thUser("Once more")])
    }

    @Test func aThreadStartedAfterAReplyFromAFallbackModelReplacesNoLostThread() async throws {
        let mock = ThreadsMock(thFallbackResponse("msg_a"), thMessageResponse("msg_b"), THREADS_NOT_FOUND, thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock, ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]],
                                      behavior: .continueUnthreaded)

        for text in ["Hello", "Again", "Once more"] { try await thread.send(thUser(text)) }

        #expect(mock.threads == [THREADS_CREATE, THREADS_CREATE, thContinueFrom("msg_b"), THREADS_CREATE])
    }

    @Test func aRefusedReplyFromAFallbackModelIsNotRecorded() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", stopReason: "refusal", iterations: THREADS_FALLBACK_ITERATIONS), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]])

        try await thread.send(thUser("Refused"))
        try await thread.send(thUser("Rephrased"))

        let created = mock.bodies[1]
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["fallbacks"] == THREADS_FALLBACKS)
        #expect(created["messages"] == [thUser("Rephrased")])
    }

    @Test func aReplyFromTheRequestedModelIsContinued() async throws {
        let iterations: JSONValue = .array(Array(THREADS_FALLBACK_ITERATIONS.arrayValue!.prefix(1)))
        let mock = ThreadsMock(thMessageResponse("msg_a", iterations: iterations), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]])

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["fallbacks"] == THREADS_FALLBACKS)
    }

    @Test func aReplyFromAFallbackModelChangesNothingOnceUnthreaded() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("fallbacks"), thMessageResponse("msg_a", iterations: THREADS_FALLBACK_ITERATIONS),
                               thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["fallbacks": THREADS_FALLBACKS, "betas": [.string(THREADS_FALLBACK_BETA)]],
                                      behavior: .continueUnthreaded)

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        let later = mock.bodies[2]
        #expect(later["thread"] == nil)
        #expect(later["model"] == .string(THREADS_MODEL))
        #expect(later["fallbacks"] == THREADS_FALLBACKS)
        #expect(thread.params["model"] == .string(THREADS_MODEL))
    }

    @Test func aStopReasonThisVersionDoesNotKnowIsRecorded() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", stopReason: "something_new"), thMessageResponse("msg_b"))
        let thread = try mock.client().beta.messages.thread(maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL))

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
    }

    @Test(arguments: [
        ([String: JSONValue](), JSONValue.string("container_a")),
        (["container": ["skills": [XLSX_SKILL]]] as [String: JSONValue], ["skills": [XLSX_SKILL], "id": "container_a"] as JSONValue),
        (["container": "container_mine"] as [String: JSONValue], "container_mine" as JSONValue),
    ] as [([String: JSONValue], JSONValue)])
    func laterTurnsRunInTheContainerOfTheLastReply(fields: [String: JSONValue], expected: JSONValue) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", container: "container_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, fields)

        try await thread.send(thUser("Hello"))
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[1]["container"] == expected)
    }

    @Test func updateChangesTheFieldsOfLaterTurnsWithoutARequest() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try thread.update(params: ThreadSendParams(maxTokens: 77, stopSequences: ["END"]))
        let requestsAfterUpdate = mock.calls
        try await thread.send(thUser("Again"))

        let body = mock.bodies[1]
        #expect(requestsAfterUpdate == 1)
        #expect(body["max_tokens"] == 77)
        #expect(body["stop_sequences"] == ["END"])
        #expect(body["thread"] == thContinueFrom("msg_a"))
        #expect(body["messages"] == [thUser("Again")])
    }

    @Test func sendOverridesTakePrecedenceOverUpdate() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try thread.update(params: ThreadSendParams(maxTokens: 77))

        try await thread.send(thUser("Hello"), params: ThreadSendParams(maxTokens: 12))
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[0]["max_tokens"] == 12)
        #expect(mock.bodies[1]["max_tokens"] == 77)
    }

    @Test func updateRequestOptionsApplyToLaterTurns() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try thread.update(extraHeaders: ["X-Trace": "abc"], extraBody: ["top_k": 5])
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[0]["top_k"] == nil)
        #expect(mock.bodies[1]["top_k"] == 5)
        #expect(mock.requests[1].headers["X-Trace"] == "abc")
    }

    @Test func updateReplacesEachRequestOptionItIsGivenAsAWhole() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, extraHeaders: ["X-Thread": "thread"], extraQuery: ["thread": "1"], extraBody: ["top_k": 5],
                                      timeout: 12)

        try thread.update(extraHeaders: ["X-Update": "update"], extraQuery: ["update": "1"])
        try await thread.send(thUser("Hello"))

        let request = mock.requests[0]
        #expect(request.headers["X-Thread"] == nil)
        #expect(request.headers["X-Update"] == "update")
        #expect(request.queryItems.first { $0.name == "thread" } == nil)
        #expect(request.queryItems.first { $0.name == "update" }?.value == "1")
        #expect(mock.bodies[0]["top_k"] == 5)
        #expect(request.timeout.read == 12)
    }

    @Test func sendRequestOptionsReplaceTheThreadsForThatTurnOnly() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, extraHeaders: ["X-Thread": "thread"], extraQuery: ["thread": "1"], extraBody: ["top_k": 5])

        try await thread.send(thUser("Hello"), extraHeaders: ["X-Turn": "turn"], extraQuery: ["turn": "1"])
        try await thread.send(thUser("Again"))

        let requests = mock.requests
        #expect(requests.map { [$0.headers["X-Thread"], $0.headers["X-Turn"]] } == [[nil, "turn"], ["thread", nil]])
        #expect(requests.map { r in ["thread", "turn"].map { n in r.queryItems.first { $0.name == n }?.value } } == [[nil, "1"], ["1", nil]])
        #expect(mock.bodies.map { $0["top_k"] } == [5, 5])
    }

    @Test func anEmptyRequestOptionClearsTheThreads() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, extraHeaders: ["X-Thread": "thread"], extraQuery: ["thread": "1"], extraBody: ["top_k": 5])

        try await thread.send(thUser("Hello"), extraHeaders: [:], extraQuery: [:], extraBody: [:])

        let request = mock.requests[0]
        #expect(request.headers["X-Thread"] == nil)
        #expect(request.queryItems.first { $0.name == "thread" } == nil)
        #expect(mock.bodies[0]["top_k"] == nil)
    }

    @Test func paramsIsTheWholeConversationAsThreadArguments() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock, ["system": "Be brief.", "betas": ["context-management-2025-06-27"]])
        try await thread.send(thUser("Hello"))
        try thread.update(params: ThreadSendParams(maxTokens: 2048))
        try thread.append(thUser("Again"))

        let params = thread.params

        #expect(params["model"] == .string(THREADS_MODEL))
        #expect(params["max_tokens"] == 2048)
        #expect(params["system"] == "Be brief.")
        #expect(params["betas"] == ["context-management-2025-06-27"])
        #expect(thRoles(params.messages) == ["user", "assistant", "user"])
        #expect(!params.hasOutputFormat)
        #expect(params["thread"] == nil)
        #expect(params.unsupportedRequestBehavior == .error)
    }

    @Test func aThreadBuiltFromParamsReplaysTheConversation() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let client = try mock.client()
        let thread = try client.beta.messages.thread(maxTokens: 1024, model: ModelParam(rawValue: THREADS_MODEL),
                                                     params: ThreadCreateParams(system: "Be brief."))
        try await thread.send(thUser("Hello"))

        var params = thread.params
        params.messages = Array(params.messages.prefix(1))
        let rewound = try client.beta.messages.thread(params: params)
        try await rewound.send()

        let body = mock.bodies[1]
        #expect(body["thread"] == THREADS_CREATE)
        #expect(body["system"] == "Be brief.")
        #expect(body["messages"] == [thUser("Hello")])
    }

    @Test func aThreadBuiltFromParamsKeepsTheUnsupportedRequestBehavior() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b"), thUnsupportedResponse("inference_hooks"))
        let client = try mock.client()
        let unthreaded = try thMakeThread(client, behavior: .continueUnthreaded)

        try await client.beta.messages.thread(params: unthreaded.params).send(thUser("Hello"))
        await #expect(throws: BadRequestError.self) {
            try await client.beta.messages.thread(params: try thMakeThread(client).params).send(thUser("Hello"))
        }

        #expect(mock.threads == [THREADS_CREATE, nil, THREADS_CREATE])
        #expect(!mock.bodies.contains { $0["unsupported_request_behavior"] != nil })
    }

    @Test func paramsIncludesTheOutputFormat() throws {
        let thread = try thMakeForecastThread(ThreadsMock())
        let params = thread.params
        #expect(params.hasOutputFormat)
        // `thread(params:)` keeps the output type as the thread's type parameter.
        let rebuilt: BetaMessageThread<ThreadsForecast> = try mockClient().beta.messages.thread(params: params)
        #expect(rebuilt.params.hasOutputFormat)
    }

    @Test func forkReturnsAThreadWithNoPreviousMessageIDWithoutARequest() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let fork = thread.fork()

        #expect(fork.previousMessageID == nil)
        #expect(fork.messagesJSON == thread.messagesJSON)
        #expect(fork.messages == thread.messages)
        #expect(mock.calls == 1)
    }

    @Test func forkCreatesAThreadWithTheFullHistoryAndTheSameFields() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["max_tokens": 1024, "system": "You are terse."], extraHeaders: ["X-Trace": "abc"])
        try await thread.send(thUser("Hello"))

        try await thread.fork().send(thUser("Fork"))

        let body = mock.bodies[1]
        #expect(body["thread"] == THREADS_CREATE)
        #expect(body["messages"] == [thUser("Hello"), thAssistant(), thUser("Fork")])
        #expect(body["system"] == "You are terse.")
        #expect(body["max_tokens"] == 1024)
        #expect(mock.requests[1].headers["X-Trace"] == "abc")
        #expect(mock.betas[1] == [THREADS_BETA])
    }

    @Test func forkKeepsTheUnsupportedRequestBehavior() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        let fork = thread.fork()
        try await fork.send(thUser("Hello"))

        #expect(mock.threads == [THREADS_CREATE, nil])
        #expect(fork.previousMessageID == nil)
    }

    @Test func forkAndOriginalContinueIndependently() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        let fork = thread.fork()

        try await fork.send(thUser("Fork"))
        try await thread.send(thUser("Original"))

        #expect(mock.bodies[2]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[2]["messages"] == [thUser("Original")])
        #expect(thread.previousMessageID == "msg_c")
        #expect(fork.previousMessageID == "msg_b")
        #expect(thread.messagesJSON[2] == thUser("Original"))
        #expect(fork.messagesJSON[2] == thUser("Fork"))
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thRoles(fork.messagesJSON) == ["user", "assistant", "user", "assistant"])
    }

    @Test(arguments: ThreadsTurnMethod.allCases, [1, 2])
    func forkOfAThreadThatEndsInAPartialReplySendsTheTurnAgainWithoutIt(method: ThreadsTurnMethod, forks: Int) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two three"),
                               method == .stream ? thStreamResponse("msg_c") : thMessageResponse("msg_c"), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        let stream = try await thread.stream(thUser("Count"))
        var text = stream.textStream.makeAsyncIterator()
        _ = try await text.next()
        stream.close()
        let messagesAfterTheStream = thread.messagesJSON

        var fork = thread
        for _ in 0..<forks { fork = fork.fork() }
        let messagesOfTheFork = fork.messagesJSON
        try await thRunTurn(fork, method)
        let messagesAfterTheTurnOfTheFork = thread.messagesJSON
        try await thread.send()

        let forked = mock.bodies[2], original = mock.bodies[3]
        #expect(forked["thread"] == THREADS_CREATE)
        #expect(forked["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Count")])
        #expect(original["thread"] == forked["thread"])
        #expect(original["messages"] == forked["messages"])
        #expect(messagesOfTheFork == messagesAfterTheStream)
        #expect(messagesAfterTheTurnOfTheFork == messagesAfterTheStream)
        #expect(thRoles(fork.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(fork.previousMessageID == "msg_c")
    }

    @Test func forkOfAThreadThatEndsInAPartialReplySendsItAheadOfANewMessage() async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a", "one two three"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        let stream = try await thread.stream(thUser("Count"))
        var text = stream.textStream.makeAsyncIterator()
        _ = try await text.next()
        stream.close()

        try await thread.fork().send(thUser("Just the total"))

        #expect(mock.bodies[1]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[1]["messages"] == [thUser("Count"), thAssistant("one"), thUser("Just the total")])
    }

    @Test func forkOfAThreadThatEndsInAWholeReplySendsTheFullHistoryWithNoNewMessage() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        try await thread.fork().send()

        #expect(mock.bodies[1]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[1]["messages"] == [thUser("Hello"), thAssistant()])
    }

    @Test func outputFormatAddsNoBetaBeyondTheThreadsBeta() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        try await thMakeForecastThread(mock).send(thUser("Hello"))
        try await thMakeThread(mock, ["output_config": ["format": ["type": "json_schema", "schema": ["type": "object"]]]]).send(thUser("Hello"))
        #expect(mock.betas == [[THREADS_BETA], [THREADS_BETA]])
    }

    @Test(arguments: [true, false])
    func everyTurnAndAThreadBuiltFromParamsSendTheOutputConfigGivenAtCreation(outputFormat: Bool) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"), thMessageResponse("msg_c"))
        if outputFormat {
            let thread = try thMakeForecastThread(mock, outputConfig: BetaOutputConfigParam(effort: .some(.low)))
            try await thread.send(thUser("Hello"))
            try await thread.send(thUser("Again"))
            try await mock.client().beta.messages.thread(params: thread.params).send(thUser("Once more"))
        } else {
            let thread = try thMakeThread(mock, ["output_config": ["format": ["type": "json_schema", "schema": ["type": "object"]]]])
            try await thread.send(thUser("Hello"))
            try await thread.send(thUser("Again"))
            try await mock.client().beta.messages.thread(params: thread.params).send(thUser("Once more"))
        }

        let created = mock.bodies[0], continued = mock.bodies[1], rebuilt = mock.bodies[2]
        #expect(created["output_config"]?["format"]?["type"] == "json_schema")
        if outputFormat { #expect(created["output_config"]?["effort"] == "low") }
        #expect(created["output_config"] == continued["output_config"])
        #expect(created["output_config"] == rebuilt["output_config"])
    }

    @Test func threadRejectsBothOutputFormatAndOutputConfigFormat() throws {
        let config = BetaOutputConfigParam(format: .some(BetaJSONOutputFormatParam(schema: ["type": "object"], type: "json_schema")))
        #expect(throws: AnthropicError.self) { try thMakeForecastThread(ThreadsMock(), outputConfig: config) }
        do {
            _ = try thMakeForecastThread(ThreadsMock(), outputConfig: config)
        } catch let error as AnthropicError {
            #expect(error.message.contains("output_config.format"))
        }
    }
}
