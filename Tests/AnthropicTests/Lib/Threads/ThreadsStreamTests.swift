// Port of tests/lib/threads/test_beta_threads.py (part 3: parse, streams, the thread's arguments, and the
// create-only fields `system` and `tools`).

import Foundation
import Testing
@testable import Anthropic

/// Reads the first text delta of a thread stream (`next(stream.text_stream)`), then leaves the stream.
private func thReadFirstTextDelta<O>(_ stream: BetaThreadMessageStream<O>) async throws {
    var text = stream.textStream.makeAsyncIterator()
    _ = try await text.next()
    stream.close()
}

/// The thread's tools as their request definitions.
private func thToolDefinitions(_ tools: [any BetaToolLike]?) throws -> JSONValue? {
    try tools.map { .array(try $0.map { try $0.toToolParam() }) }
}

@Suite struct ThreadsStreamTests {
    @Test func parseContinuesTheThreadAndParsesEachReply() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", #"{"forecast": "Sunny"}"#), thMessageResponse("msg_b", #"{"forecast": "Rain"}"#))
        let thread = try thMakeForecastThread(mock)

        let first = try await thread.parse(thUser("Today?"))
        let second = try await thread.parse(thUser("Tomorrow?"), params: ThreadSendParams(maxTokens: 12))

        let created = mock.bodies[0], continued = mock.bodies[1]
        #expect(first.parsedOutput == ThreadsForecast(forecast: "Sunny"))
        #expect(second.parsedOutput == ThreadsForecast(forecast: "Rain"))
        #expect(created["thread"] == THREADS_CREATE)
        #expect(created["output_config"]?["format"]?["type"] == "json_schema")
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["messages"] == [thUser("Tomorrow?")])
        #expect(continued["max_tokens"] == 12)
        #expect(thread.previousMessageID == second.id)
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
    }

    @Test func parseWithoutOutputFormatReturnsNoParsedOutput() async throws {
        let text = #"{"forecast": "Sunny"}"#
        let mock = ThreadsMock(thMessageResponse("msg_a", text))
        let thread = try thMakeThread(mock)

        let message = try await thread.parse(thUser("Today?"))

        #expect(message.parsedOutput == nil)
        #expect(thText(message.message) == [text])
        #expect(mock.bodies[0]["output_config"] == nil)
        #expect(thread.previousMessageID == "msg_a")
    }

    @Test func parseOfAReplyThatDoesNotFitTheOutputFormatKeepsTheTurn() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Sunny"))
        let thread = try thMakeForecastThread(mock)

        await #expect(throws: (any Error).self) { try await thread.parse(thUser("Today?")) }

        #expect(thRoles(thread.messagesJSON) == ["user", "assistant"])
        #expect(thread.previousMessageID == "msg_a")
    }

    @Test func sendWhileStreamingRaisesAndStagesNothing() async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        let stream = try await thread.stream(thUser("Hello"))
        do {
            try await thread.send(thUser("Interrupting"))
            Issue.record("expected the send to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("already in progress"))
        }
        try await stream.untilDone()
        stream.close()
        try await thread.send(thUser("Now"))

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
        #expect(mock.bodies[1]["messages"] == [thUser("Now")])
        #expect(thread.previousMessageID == "msg_b")
    }

    @Test func sendWhileAnotherSendIsInFlightRaisesAndStagesNothing() async throws {
        // test_async_beta_threads.py: a second `send()` while the first one waits for its reply.
        let release = EnvEvent()
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let firstRequest = EnvEvent()
        mock.onRequest = { _ in
            if !firstRequest.value {
                firstRequest.set()
                await release.wait()
            }
        }
        let thread = try thMakeThread(mock)

        let first = Task { try await thread.send(thUser("Hello")) }
        await firstRequest.wait()
        do {
            try await thread.send(thUser("Interrupting"))
            Issue.record("expected the send to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("already in progress"))
        }
        release.set()
        _ = try await first.value
        try await thread.send(thUser("Now"))

        #expect(mock.bodies.map { $0["messages"] } == [[thUser("Hello")], [thUser("Now")]])
        #expect(thread.previousMessageID == "msg_b")
    }

    @Test func aCancelledSendTakesTheTurnBack() async throws {
        // test_async_beta_threads.py
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        let hang = ToolsBox(true)
        let sent = EnvEvent()
        mock.onRequest = { _ in
            guard hang.value else { return }
            hang.value = false
            sent.set()
            try await Task.sleep(nanoseconds: 30_000_000_000)
            Issue.record("not cancelled")
        }

        let inFlight = Task { try await thread.send(thUser("A long story")) }
        await sent.wait()
        inFlight.cancel()
        if case .success = await inFlight.result { Issue.record("expected the send to be cancelled") }
        try await thread.send(thUser("One word"))

        #expect(mock.bodies.last?["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies.last?["messages"] == [thUser("One word")])
    }

    @Test func failedSendLetsTheNextSendRun() async throws {
        let mock = ThreadsMock(thServerError(), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Hello")) }

        let reply = try await thread.send(thUser("Hello"))

        #expect(reply.id == "msg_b")
    }

    @Test func streamRecordsTheReplyOnceItReachesMessageStop() async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a"))
        let thread = try thMakeThread(mock)

        let stream = try await thread.stream(thUser("Hello"))
        try await stream.untilDone()
        stream.close()

        #expect(mock.bodies[0]["stream"] == true)
        #expect(mock.bodies[0]["thread"] == THREADS_CREATE)
        #expect(try await stream.getFinalMessage().id == "msg_a")
        #expect(thread.previousMessageID == "msg_a")
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant"])
        #expect(mock.requests[0].headers["x-stainless-helper-method"] == "stream")
        #expect(mock.requests[0].headers["x-stainless-stream-helper"] == "beta.messages")
    }

    @Test func streamThatFindsTheThreadGoneReplaysInsideTheSameStream() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), THREADS_NOT_FOUND, thStreamResponse("msg_c", "one two"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let stream = try await thread.stream(thUser("Count"))
        var text = ""
        for try await delta in stream.textStream { text += delta }
        stream.close()

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a"), THREADS_CREATE])
        #expect(text == "one two")
        #expect(try await stream.getFinalMessage().id == "msg_c")
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func streamErrorTakesTheTurnBack() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thServerError())
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: InternalServerError.self) { try await thread.stream(thUser("Count")) }

        #expect(thread.previousMessageID == "msg_a")
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant"])
    }

    @Test(arguments: ["leave", "close", "error_event"])
    func aStreamThatEndsBeforeMessageStartTakesTheTurnBack(how: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), how == "error_event" ? thStreamErrorResponse() : thStreamResponse("msg_b"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        do {
            let stream = try await thread.stream(thUser("Count"))
            switch how {
            case "close": stream.close()
            case "error_event":
                await #expect(throws: APIError.self) { try await stream.untilDone() }
            default: break
            }
        }
        try await thread.send(thUser("Count"))

        #expect(mock.bodies[2]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[2]["messages"] == [thUser("Count")])
    }

    @Test func messagesAppendedDuringATurnAreStagedOnceItFinishes() async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        let stream = try await thread.stream(thUser("Hello"))
        try thread.append(thUser("While you were out"))
        let messagesDuringTheTurn = thread.messagesJSON
        try await stream.untilDone()
        stream.close()
        try await thread.send()

        #expect(messagesDuringTheTurn == [thUser("Hello"), thUser("While you were out")])
        #expect(mock.bodies[1]["messages"] == [thUser("While you were out")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
    }

    @Test(arguments: ["break", "close"])
    func aStreamThatEndsEarlyRecordsThePartialReplyAndStartsANewThread(how: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two three"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let (_, capture) = try await ToolDiagnostics.capture {
            let stream = try await thread.stream(thUser("Count"))
            var text = stream.textStream.makeAsyncIterator()
            _ = try await text.next()
            if how == "close" { stream.close() }
            // "break": the stream is released without being closed, which ends the turn as well.
        }
        let previousMessageIDAfterStream = thread.previousMessageID
        let historyAfterStream = thread.messagesJSON
        try await thread.send(thUser("Just the total"))

        let later = mock.bodies[2]
        #expect(previousMessageIDAfterStream == nil)
        #expect(thRoles(historyAfterStream) == ["user", "assistant", "user", "assistant"])
        #expect(historyAfterStream.last?["content"]?[0]?["text"] == "one")
        #expect(thThreadLogs(capture).contains(
            "Replaying the full message history under a new thread: reason=stream_ended_before_message_stop previous_message_id=msg_a"))
        #expect(later["thread"] == THREADS_CREATE)
        #expect(thRoles(later["messages"]) == ["user", "assistant", "user", "assistant", "user"])
        #expect(later["messages"]?[3] == thAssistant("one"))
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func anErrorWhileTheStreamIsReadRecordsThePartialReply() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        await #expect(throws: EnvBugError.self) {
            let stream = try await thread.stream(thUser("Count"))
            defer { stream.close() }
            var text = stream.textStream.makeAsyncIterator()
            _ = try await text.next()
            throw EnvBugError(message: "boom")
        }

        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thread.previousMessageID == nil)
    }

    @Test func sendWithNoMessagesAfterAPartialReplySendsTheTurnAgainWithoutIt() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two three"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        try await thReadFirstTextDelta(try await thread.stream(thUser("Count")))

        let reply = try await thread.send()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Count")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thread.previousMessageID == reply.id)
        #expect(reply.id == "msg_c")
    }

    @Test func sendWithNoMessagesStillSendsAPartialTurnAgainAfterACallThatFailed() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two three"), thServerError(), thMessageResponse("msg_d"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        try await thReadFirstTextDelta(try await thread.stream(thUser("Count")))
        let messagesAfterTheStream = thread.messagesJSON

        await #expect(throws: InternalServerError.self) { try await thread.send(thUser("Just the total")) }
        let messagesAfterTheError = thread.messagesJSON
        try await thread.send()

        #expect(mock.bodies[3]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[3]["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Count")])
        #expect(messagesAfterTheError == messagesAfterTheStream)
    }

    @Test func aStreamThatEndsAfterMessageDeltaIsStillAPartialTurn() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", toolUseID: "toolu_b", messageStop: false),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        let stream = try await thread.stream(thUser("Weather?"))
        try await stream.untilDone()
        stream.close()
        let afterStream = (thRoles(thread.messagesJSON), thread.previousMessageID)

        try await thread.send()

        #expect(afterStream.0 == ["user", "assistant", "user", "assistant"])
        #expect(afterStream.1 == nil)
        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Weather?")])
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func resumeStreamThatEndsMidTextKeepsThePausedReplyResumable() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", "Searching", stopReason: "pause_turn"), thStreamResponse("msg_b", "found it"),
                               thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))
        try await thReadFirstTextDelta(try await thread.stream())

        try await thread.send()

        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Searching")])
        #expect(thread.previousMessageID == "msg_c")
    }

    @Test func aPartialReplyKeepsFinishedBlocksAndDropsAnUnfinishedToolCall() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thPartialToolUseStreamResponse("msg_b", "Let me check.", toolUseID: "toolu_b"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let stream = try await thread.stream(thUser("What's the weather in SF?"))
        for try await event in stream {
            if case .contentBlockDelta(let e) = event, case .inputJsonDelta = e.delta { break }
        }
        stream.close()

        let last = thread.messagesJSON.last
        #expect(last?["content"]?.arrayValue?.map { $0["type"] } == ["text"])
        #expect(last?["content"]?[0]?["text"] == "Let me check.")
        #expect(thread.previousMessageID == nil)
    }

    @Test(arguments: [true, false])
    func aStreamWhoseEventsFailOrRunOutEarlyFreesTheThreadAtOnce(fails: Bool) async throws {
        let mock = ThreadsMock(thInterruptedStreamResponse("msg_a", "one", error: fails), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        let stream = try await thread.stream(thUser("Count"))
        if fails {
            await #expect(throws: (any Error).self) { try await stream.untilDone() }
        } else {
            try await stream.untilDone()
        }
        try await thread.send(thUser("Just the total"))
        stream.close()

        #expect(mock.bodies[1]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[1]["messages"] == [thUser("Count"), thAssistant("one"), thUser("Just the total")])
        #expect(thRoles(thread.messagesJSON) == ["user", "assistant", "user", "assistant"])
        #expect(thread.previousMessageID == "msg_b")
    }

    @Test func aStreamReadToMessageStopFreesTheThreadAtOnce() async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)

        let stream = try await thread.stream(thUser("Hello"))
        try await stream.untilDone()
        let previousMessageIDInsideTheBlock = thread.previousMessageID
        try await thread.send(thUser("Again"))
        stream.close()

        #expect(previousMessageIDInsideTheBlock == "msg_a")
        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
        #expect(mock.bodies[1]["messages"] == [thUser("Again")])
        #expect(thread.previousMessageID == "msg_b")
    }

    @Test func aStreamThatEndsBeforeAnyContentStoresTheTurnAndSendRepeatsIt() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thStreamResponse("msg_b", "one two"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock)
        try await thread.send(thUser("Hello"))

        let stream = try await thread.stream(thUser("Count"))
        var iterator = stream.makeAsyncIterator()
        if case .messageStart? = try await iterator.next() {} else { Issue.record("expected message_start") }
        stream.close()
        let afterStream = (thRoles(thread.messagesJSON), thread.previousMessageID)
        try await thread.send()

        #expect(afterStream.0 == ["user", "assistant", "user"])
        #expect(afterStream.1 == nil)
        #expect(mock.bodies[2]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[2]["messages"] == [thUser("Hello"), thAssistant("Hi!"), thUser("Count")])
    }

    @Test func aThreadValueFromTheCallerIsRefused() throws {
        let client = try mockClient()
        let thread = try client.beta.messages.thread(maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL))
        var params = thread.params
        params["thread"] = THREADS_CREATE
        #expect(throws: ArgumentTypeError.self) { try client.beta.messages.thread(params: params) }
    }

    @Test func aFieldLeftNilIsLeftOut() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try mock.client().beta.messages.thread(
            maxTokens: THREADS_MAX_TOKENS, model: ModelParam(rawValue: THREADS_MODEL),
            params: ThreadCreateParams(metadata: BetaMetadataParam(userID: .some("thread")), system: nil))

        try await thread.send(thUser("Hello"), params: ThreadSendParams(metadata: nil, stopSequences: nil))

        let body = mock.bodies[0]
        #expect(body["system"] == nil && body["stop_sequences"] == nil)
        #expect(body["metadata"] == ["user_id": "thread"])
    }

    @Test func constructorStartsTheSameThreadAsTheFactory() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try BetaMessageThread(client: try mock.client(), params: ThreadParams(
            fields: ["model": .string(THREADS_MODEL), "max_tokens": 64, "system": "Be brief."], messages: [thUser("Hello")]))

        try await thread.send()
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[0]["thread"] == THREADS_CREATE)
        #expect(mock.bodies[0]["system"] == "Be brief.")
        #expect(mock.bodies[0]["messages"] == [thUser("Hello")])
        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thUser("Again")])
    }

    @Test func threadWithoutMessagesStartsEmpty() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"))
        let thread = try thMakeThread(mock)

        try await thread.send(thUser("Hello"))

        #expect(thread.messagesJSON[0] == thUser("Hello"))
        #expect(mock.bodies[0]["messages"] == [thUser("Hello")])
    }

    @Test func aChangedPinnedFieldIsSentOnContinueForTheServerToReject() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["tool_choice": ["type": "auto"]])
        try await thread.send(thUser("Hello"))

        try await thSend(thread, thUser("Again"), fields: ["tool_choice": ["type": "none"]])

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["tool_choice"] == ["type": "none"])
    }

    @Test(arguments: ["system", "tools"])
    func changingSystemOrToolsIsRefusedAndAThreadFromTheParamsTakesTheChange(field: String) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["system": "Be brief."])
        try await thread.send(thUser("Hello"))

        if field == "system" { try thUpdate(thread, ["system": "Be very brief."]) } else { try thUpdate(thread, tools: [THREADS_NOOP_TOOL]) }
        do {
            try await thread.send(thUser("Again"))
            Issue.record("expected the turn to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("Cannot change"))
            #expect(error.message.contains("send `tool_addition` or `tool_removal` blocks") == (field == "tools"))
            #expect(error.message.hasSuffix("blocks in a `system` message.") == (field == "tools"))
        }
        #expect(mock.calls == 1)
        try await mock.client().beta.messages.thread(params: thread.params).send(thUser("Again"))

        let recreated = mock.bodies[1]
        #expect(recreated["thread"] == THREADS_CREATE)
        #expect(thRoles(recreated["messages"]) == ["user", "assistant", "user"])
        #expect(recreated[field] == (field == "system" ? "Be very brief." : [THREADS_NOOP_TOOL]))
    }

    @Test func anEqualCopyOfSystemAndToolsContinuesTheThread() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["system": [["type": "text", "text": "Be brief."]], "tools": [THREADS_NOOP_TOOL]])
        try await thread.send(thUser("Hello"))

        try await thSend(thread, thUser("Again"), fields: ["system": [["type": "text", "text": "Be brief."]], "tools": [THREADS_NOOP_TOOL]])

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
    }

    @Test func aToolRemovalAppendedByHandIsSentOnTheContinueAsGiven() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["tools": [THREADS_NOOP_TOOL], "betas": [.string(THREADS_INLINE_TOOLS_BETA)]])
        try await thread.send(thUser("Hello"))

        try thread.append(thToolRemoval("noop"))
        try await thread.send(thUser("Again"))

        let continued = mock.bodies[1]
        #expect(continued["thread"] == thContinueFrom("msg_a"))
        #expect(continued["tools"] == nil)
        #expect(continued["messages"] == [thToolRemoval("noop"), thUser("Again")])
    }

    @Test(arguments: ThreadsTurnMethod.allCases, ["system", "tools"])
    func aOneTurnSystemOrToolsOnTheTurnThatCreatesTheThreadStaysWithTheThread(method: ThreadsTurnMethod, field: String) async throws {
        let mock = ThreadsMock(thRespond(method, "msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock)
        let value: JSONValue = field == "system" ? "Be brief." : [THREADS_NOOP_TOOL]

        try await thRunTurn(thread, method, thUser("Hello"), fields: [field: value])
        try await thread.send(thUser("Again"))

        #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
        if field == "system" {
            #expect(thread.params["system"] == value)
        } else {
            #expect(try thToolDefinitions(thread.params.tools) == value)
        }
    }

    @Test(arguments: ThreadsTurnMethod.allCases, ["system", "tools"])
    func aOneTurnSystemOrToolsOnAFirstTurnThatFailsDoesNotStayWithTheThread(method: ThreadsTurnMethod, field: String) async throws {
        let mock = ThreadsMock(thServerError(), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["system": "Be kind."])
        let paramsBefore = thread.params
        let value: JSONValue = field == "system" ? "Be brief." : [["name": "noop", "input_schema": ["type": "object", "properties": [:]]]]

        await #expect(throws: InternalServerError.self) { try await thRunTurn(thread, method, thUser("Hello"), fields: [field: value]) }
        let paramsAfterTheError = thread.params
        try await thread.send(thUser("Hello"))

        let failed = mock.bodies[0], later = mock.bodies[1]
        #expect(failed[field] == value)
        #expect(later["thread"] == THREADS_CREATE)
        #expect(later["messages"] == [thUser("Hello")])
        #expect(later["system"] == "Be kind.")
        #expect(later["tools"] == nil)
        #expect(paramsAfterTheError.fields == paramsBefore.fields)
        #expect(paramsAfterTheError.messages == paramsBefore.messages)
        #expect(paramsAfterTheError.tools == nil)
    }

    @Test(arguments: ["system", "tools"], [[JSONValue](), [thUser("Just the total")]])
    func aOneTurnSystemOrToolsOnAFirstTurnWhoseStreamEndsEarlyDoesNotStayWithTheThread(field: String, nextTurn: [JSONValue]) async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a", "one two three"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["system": "Be kind."])
        let value: JSONValue = field == "system" ? "Be brief." : [["name": "noop", "input_schema": ["type": "object", "properties": [:]]]]

        try await thReadFirstTextDelta(try await thread.stream(try thMessages([thUser("Count")]), overrides: thOverrides([field: value])))
        try await thread.send(try thMessages(nextTurn), overrides: thOverrides())

        let later = mock.bodies[1]
        #expect(later["thread"] == THREADS_CREATE)
        #expect(later["system"] == "Be kind.")
        #expect(later["tools"] == nil)
    }

    @Test(arguments: ["update_system", "update_tools", "set_messages_params"])
    func aChangeDuringTheTurnThatCreatesTheThreadOfWhatThatTurnGaveIsRefusedOnTheNextTurn(change: String) async throws {
        let mock = ThreadsMock(thStreamResponse("msg_a"))
        let thread = try thMakeThread(mock)
        let override: [String: JSONValue] = change == "update_tools" ? ["tools": [["name": "noop", "input_schema": ["type": "object"]]]]
            : ["system": "Be brief."]

        let stream = try await thread.stream(try thMessages([thUser("Hello")]), overrides: thOverrides(override))
        switch change {
        case "update_system": try thread.update(params: ThreadSendParams(system: "Be verbose."))
        case "update_tools": try thread.update(tools: [])
        default:
            try await thread.toolRunner().setMessagesParams { params in
                var p = params
                p["system"] = "Be verbose."
                return p
            }
        }
        try await stream.untilDone()
        stream.close()
        do {
            try await thread.send(thUser("Again"))
            Issue.record("expected the turn to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("Cannot change `\(override.keys.first!)`"))
        }

        #expect(mock.calls == 1)
        #expect(thread.previousMessageID == "msg_a")
    }

    @Test(arguments: [false, true], ["system", "tools"])
    func aChangeOfAnotherFieldDuringTheTurnThatCreatesTheThreadKeepsWhatThatTurnGave(ownFields: Bool, field: String) async throws {
        for viaRunner in [false, true] {
            let mock = ThreadsMock(thStreamResponse("msg_a"), thMessageResponse("msg_b"))
            let own: [String: JSONValue] = ownFields
                ? ["system": "Be kind.", "tools": [["name": "other", "input_schema": ["type": "object", "properties": [:]]]]] : [:]
            let thread = try thMakeThread(mock, own)
            let value: JSONValue = field == "system" ? "Be brief." : [["name": "noop", "input_schema": ["type": "object", "properties": [:]]]]

            let stream = try await thread.stream(try thMessages([thUser("Hello")]), overrides: thOverrides([field: value]))
            if viaRunner {
                try await thread.toolRunner().setMessagesParams { params in
                    var p = params
                    p["max_tokens"] = 12
                    return p
                }
            } else {
                try thread.update(params: ThreadSendParams(maxTokens: 12))
            }
            try await stream.untilDone()
            stream.close()
            try await thread.send(thUser("Again"))

            #expect(mock.threads == [THREADS_CREATE, thContinueFrom("msg_a")])
            #expect(mock.bodies[1]["max_tokens"] == 12)
            if field == "system" {
                #expect(thread.params["system"] == value)
            } else {
                #expect(try thToolDefinitions(thread.params.tools) == value)
            }
        }
    }

    @Test func aOneTurnSystemOnAFirstTurnThatGoesWithoutAThreadIsForThatTurnOnly() async throws {
        let mock = ThreadsMock(thUnsupportedResponse("inference_hooks"), thMessageResponse("msg_b"), thMessageResponse("msg_c"))
        let thread = try thMakeThread(mock, behavior: .continueUnthreaded)

        try await thSend(thread, thUser("Hello"), fields: ["system": "Be brief."])
        try await thread.send(thUser("Again"))

        #expect(mock.threads == [THREADS_CREATE, nil, nil])
        #expect(mock.bodies.map { $0["system"] } == ["Be brief.", "Be brief.", nil])
    }

    @Test(arguments: ThreadsTurnMethod.allCases)
    func aOneTurnSystemOverrideIsRefusedAndTakesTheTurnBack(method: ThreadsTurnMethod) async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a"), thMessageResponse("msg_b"))
        let thread = try thMakeThread(mock, ["system": "Be brief."])
        try await thread.send(thUser("Hello"))

        do {
            try await thRunTurn(thread, method, thUser("Again"), fields: ["system": "Be verbose."])
            Issue.record("expected the turn to be refused")
        } catch let error as AnthropicError {
            #expect(error.message.contains("Cannot change `system`"))
        }
        try await thread.send(thUser("Again"))

        #expect(mock.bodies[1]["thread"] == thContinueFrom("msg_a"))
        #expect(mock.bodies[1]["messages"] == [thUser("Again")])
    }

    @Test func updateToolsReplacesTheRunnableTools() async throws {
        let mock = ThreadsMock(thMessageResponse("msg_a", toolUseID: "toolu_a"), thMessageResponse("msg_b", "Sunny."))
        let thread = try thMakeThread(mock)

        try thread.update(tools: [thWeatherTool()])
        try thread.append(THREADS_WEATHER_QUESTION)
        let final = try await thread.toolRunner().untilDone()

        let first = mock.bodies[0], second = mock.bodies[1]
        #expect(first["tools"]?.arrayValue?.map { $0["name"] } == ["get_weather"])
        #expect(second["messages"]?[0]?["content"]?[0]?["type"] == "tool_result")
        #expect(final.id == "msg_b")
    }
}
