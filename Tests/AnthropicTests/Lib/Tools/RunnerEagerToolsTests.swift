// Port of tests/lib/tools/test_runner_eager_tools.py: how a streaming tool runner with `runToolsEagerly` runs tool
// calls. The timeline is described in `StreamingRunnerSupport.swift`. The upstream tests run on the sync and the
// async runner; Swift has the one runner.

import Foundation
import Testing
@testable import Anthropic

private typealias Setup = StreamingRunnerSetup
private func call(_ key: String, _ jsonInput: String? = nil) -> JSONValue { streamingRunnerCall(key, jsonInput) }
private func text(_ value: String) -> JSONValue { streamingRunnerText(value) }
private func done() -> StreamingRunnerReply { streamingRunnerDone() }
private func firstReply(_ timeline: [String]) -> [String] { streamingRunnerFirstReply(timeline) }
private func ids(_ toolUses: [BetaToolUseBlock]) -> [String] { streamingRunnerIDs(toolUses) }
private func reply(_ blocks: JSONValue...) -> StreamingRunnerReply { StreamingRunnerReply(blocks: blocks, stopReason: "tool_use") }
private func replyEnding(_ stopReason: String, _ blocks: JSONValue...) -> StreamingRunnerReply {
    StreamingRunnerReply(blocks: blocks, stopReason: stopReason)
}

@Suite struct RunnerEagerToolsTests {
    @Test func runsEachToolOnceTheModelHasMovedOnFromItsCall() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await stream in test.runner {
            for try await event in stream { test.see(event) }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == [
            "message_start",
            "a: content_block_start",
            "a: content_block_delta",
            "input_json",
            "a: content_block_stop",
            "b: content_block_start",  // the model has moved on from a
            "lookup(a) STARTS",
            "b: content_block_delta",
            "input_json",
            "b: content_block_stop",
            "message_delta (tool_use)",  // the model has moved on from b
            "lookup(b) STARTS",
            "message_stop",
            "loop body ends",
        ])
    }

    @Test func runsEveryToolAfterTheLoopBodyWhenNotStreamingAsBefore() async throws {
        let timeline = ToolsBox<[String]>([])
        let server = StreamingRunnerServer([reply(call("a"), call("b")), done()], timeline: timeline, stream: false)
        let runner = try server.client().beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("Look these up.")], model: "claude-haiku-4-5",
            tools: [streamingRunnerLookupTool(timeline)])

        for try await _ in runner { timeline.mutate { $0.append("loop body ends") } }

        #expect(firstReply(timeline.value) == ["loop body ends", "lookup(a) STARTS", "lookup(b) STARTS"])
    }

    @Test func holdsACallThatTheCallerDefersUntilTheLoopBodyEnds() async throws {
        let test = try Setup([reply(call("a"), call("b"), call("c")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                test.see(event)
                if let toolUse = streamingRunnerIsToolUseStop(event), toolUse.id == "toolu_b" {
                    await test.runner.deferToolCall(toolUse)
                }
            }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == [
            "message_start",
            "a: content_block_start",
            "a: content_block_delta",
            "input_json",
            "a: content_block_stop",
            "b: content_block_start",
            "lookup(a) STARTS",
            "b: content_block_delta",
            "input_json",
            "b: content_block_stop",  // the caller defers b here
            "c: content_block_start",  // b would have run after this event
            "c: content_block_delta",
            "input_json",
            "c: content_block_stop",
            "message_delta (tool_use)",
            "lookup(c) STARTS",
            "message_stop",
            "loop body ends",
            "lookup(b) STARTS",
        ])
        // The results go back in the model's order, whatever order the calls ran in.
        #expect(test.resultsSent() == [
            ["type": "tool_result", "tool_use_id": "toolu_a", "content": "value of a"],
            ["type": "tool_result", "tool_use_id": "toolu_b", "content": "value of b"],
            ["type": "tool_result", "tool_use_id": "toolu_c", "content": "value of c"],
        ])
    }

    @Test func listsTheCallsThatAreBeingHeldSoThatTheCallerCanDecideAboutThem() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                if let toolUse = streamingRunnerIsToolUseStart(event), toolUse.id == "toolu_b" {
                    await test.runner.deferToolCall(toolUse)
                }
            }
            let held = await test.runner.deferredToolCalls
            #expect(try held.map { try JSONValue.from($0) } == [["type": "tool_use", "id": "toolu_b", "name": "lookup", "input": ["key": "b"]]])
            break  // the caller decides against b
        }

        #expect(test.lines == ["lookup(a) STARTS"])
    }

    @Test func runsEachCallOnce() async throws {
        let test = try Setup([reply(call("a"), call("b"))])

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            let message = try await stream.getFinalMessage()

            let response = try await test.runner.generateToolCallResponseJSON()
            // appendMessages() drops the cached response, so the second call answers the reply again.
            try await test.runner.appendMessages(message)
            try await test.runner.appendMessages(json: try #require(response))
            #expect(try await test.runner.generateToolCallResponseJSON() == response)
            break
        }

        #expect(test.lines == ["lookup(b) STARTS", "lookup(a) STARTS"])
    }

    // MARK: - without `runToolsEagerly`

    @Test func withoutTheOptionEveryToolRunsAfterTheLoopBodyAsBefore() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()], runToolsEagerly: false)

        for try await stream in test.runner {
            for try await event in stream { test.see(event) }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == [
            "message_start",
            "a: content_block_start",
            "a: content_block_delta",
            "input_json",
            "a: content_block_stop",
            "b: content_block_start",
            "b: content_block_delta",
            "input_json",
            "b: content_block_stop",
            "message_delta (tool_use)",
            "message_stop",
            "loop body ends",
            "lookup(a) STARTS",
            "lookup(b) STARTS",
        ])
    }

    @Test func withoutTheOptionThereIsNothingToDefer() async throws {
        let test = try Setup([reply(call("a")), done()], runToolsEagerly: false)

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            _ = try await stream.getFinalMessage()
            #expect(await test.runner.deferredToolCalls.isEmpty)
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["loop body ends", "lookup(a) STARTS"])
    }

    @Test func withoutTheOptionTheToolsRunAgainAfterAppendMessagesAsBefore() async throws {
        let test = try Setup([reply(call("a"))], runToolsEagerly: false)

        for try await _ in test.runner {
            _ = try await test.runner.generateToolCallResponse()
            try await test.runner.appendMessages(toolsUserMessage("Go on."))
            _ = try await test.runner.generateToolCallResponse()
            break
        }

        #expect(test.lines == ["lookup(a) STARTS", "lookup(a) STARTS"])
    }

    // MARK: - the `runToolsEagerly` option

    @Test func theOptionIsNotSentToTheAPI() async throws {
        let test = try Setup([replyEnding("compaction", streamingRunnerCompaction()), reply(call("a")), done()])

        try await test.runner.compactBeforeNextTurn()
        _ = try await test.runner.untilDone()

        #expect(test.requests.map { $0["compaction"] != nil } == [true, false, false])
        #expect(test.requests.map { $0["run_tools_eagerly"] != nil } == [false, false, false])
    }

    @Test func yieldsTheStreamThatMessagesStreamReturns() async throws {
        let test = try Setup([done()])

        for try await stream in test.runner {
            #expect(type(of: stream) == BetaMessageStream<Never>.self)
            #expect(try await stream.getFinalMessage().stopReason == .endTurn)
        }

        #expect(test.requests[0]["stream"] == true)
    }

    // MARK: - when a tool call runs

    @Test(arguments: ["events", "text_stream", "get_final_message", "until_done"])
    func runsTheCallsWhileTheCallerReadsTheStreamHoweverItReadsIt(read: String) async throws {
        let test = try Setup([reply(call("a"), text("Found a."), call("b")), done()])

        for try await stream in test.runner {
            switch read {
            case "events": for try await _ in stream {}
            case "text_stream": for try await _ in stream.textStream {}
            case "get_final_message": _ = try await stream.getFinalMessage()
            default: try await stream.untilDone()
            }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "lookup(b) STARTS", "loop body ends"])
    }

    @Test func runsTheCallsAfterTheLoopBodyWhenTheCallerDoesNotReadTheStream() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await _ in test.runner { test.append("loop body ends") }

        #expect(firstReply(test.lines) == ["loop body ends", "lookup(a) STARTS", "lookup(b) STARTS"])
    }

    @Test func runsTheRemainingCallsAfterTheLoopBodyWhenTheCallerStopsReadingEarly() async throws {
        let test = try Setup([reply(call("a"), call("b"), call("c")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                test.see(event)
                if case .contentBlockDelta(let delta) = event, delta.index == 1 { break }
            }
            test.append("loop body ends")
        }

        #expect(Array(firstReply(test.lines).suffix(5)) == [
            "lookup(a) STARTS",
            "b: content_block_delta",
            "loop body ends",
            "lookup(b) STARTS",
            "lookup(c) STARTS",
        ])
        #expect(test.resultsSent().map { $0["tool_use_id"] } == ["toolu_a", "toolu_b", "toolu_c"])
    }

    @Test func doesNotWaitForTheReplyToEnd() async throws {
        let test = try Setup([streamingRunnerEventByEvent(reply(call("a"), text("Found a."), call("b"))), done()])

        _ = try await test.runner.untilDone()

        #expect(firstReply(test.lines) == [
            "server sends message_start",
            "server sends a: content_block_start",
            "server sends a: content_block_delta",
            "server sends a: content_block_stop",
            "server sends text: content_block_start",  // the model has moved on from a
            "server sends text: content_block_delta",
            "lookup(a) STARTS",
            "server sends text: content_block_stop",
            "server sends b: content_block_start",
            "server sends b: content_block_delta",
            "server sends b: content_block_stop",
            "server sends message_delta (tool_use)",  // the model has moved on from b
            "server sends message_stop",
            "lookup(b) STARTS",
        ])
    }

    @Test func runsNoCallOnceReadingTheReplyHasFailed() async throws {
        let test = try Setup([streamingRunnerEventByEvent(reply(call("a"), call("b")), failsBefore: "b: content_block_delta")])

        await #expect(throws: (any Error).self) {
            for try await stream in test.runner {
                for try await event in stream { test.see(event) }
            }
        }

        // The model had moved on from a, and the caller was done with the event that showed it.
        #expect(Array(test.lines.suffix(3)) == ["server sends b: content_block_start", "b: content_block_start", "server fails"])
    }

    @Test func runsTheCallsOneAtATime() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()], logReturns: true)

        _ = try await test.runner.untilDone()

        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "lookup(a) returns", "lookup(b) STARTS", "lookup(b) returns"])
    }

    @Test func sendsTheErrorResultOfACallThatFailedWhileTheReplyStreamed() async throws {
        let test = try Setup([reply(call("a"), text("Looking.")), done()], lookup: { key in throw ToolError("No value for \(key).") })

        for try await stream in test.runner {
            _ = try await stream.getFinalMessage()
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "loop body ends"])
        #expect(test.resultsSent() == [["type": "tool_result", "tool_use_id": "toolu_a", "content": "No value for a.", "is_error": true]])
    }

    // MARK: - deferToolCall()

    @Test(arguments: ["the block", "the id"])
    func deferToolCallTakes(argument: String) async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                if let block = streamingRunnerIsToolUseStop(event), block.id == "toolu_a" {
                    if argument == "the block" {
                        await test.runner.deferToolCall(block)
                    } else {
                        await test.runner.deferToolCall(id: block.id)
                    }
                }
            }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(b) STARTS", "loop body ends", "lookup(a) STARTS"])
    }

    @Test(arguments: [
        "a: content_block_start",  // when the call starts streaming
        "a: content_block_stop",  // when the call has streamed
        "b: content_block_start",  // when the model moves on from the call
    ])
    func holdsACallThatIsDeferred(at: String) async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await stream in test.runner {
            for try await event in stream where test.label(event) == at {
                await test.runner.deferToolCall(id: "toolu_a")
            }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(b) STARTS", "loop body ends", "lookup(a) STARTS"])
    }

    @Test func givesTheTimingFromBeforeWhenTheCallerDefersEveryCall() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                test.see(event)
                if let toolUse = streamingRunnerIsToolUseStart(event) { await test.runner.deferToolCall(toolUse) }
            }
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == [
            "message_start",
            "a: content_block_start",
            "a: content_block_delta",
            "input_json",
            "a: content_block_stop",
            "b: content_block_start",
            "b: content_block_delta",
            "input_json",
            "b: content_block_stop",
            "message_delta (tool_use)",
            "message_stop",
            "loop body ends",
            "lookup(a) STARTS",
            "lookup(b) STARTS",
        ])
    }

    @Test func listsOnlyTheCallThatTheCallerDefersAndNotTheCallsAfterIt() async throws {
        let test = try Setup([reply(call("a"), call("b"), call("c"))])

        for try await stream in test.runner {
            for try await event in stream {
                if let toolUse = streamingRunnerIsToolUseStop(event), toolUse.id == "toolu_b" {
                    await test.runner.deferToolCall(toolUse)
                }
            }
            #expect(ids(await test.runner.deferredToolCalls) == ["toolu_b"])
            break
        }
    }

    @Test func defersTheCallsOfOneReplyOnly() async throws {
        let test = try Setup([reply(call("a"), call("b")), reply(call("c"), call("d")), done()])

        for try await stream in test.runner {
            for try await event in stream {
                test.see(event)
                if let toolUse = streamingRunnerIsToolUseStop(event), toolUse.id == "toolu_a" {
                    await test.runner.deferToolCall(toolUse)
                }
            }
            test.append("loop body ends")
        }

        let secondReply = streamingRunnerBetween(test.lines, "request 2", "request 3")
        let starts = secondReply.filter { $0.contains("STARTS") || $0 == "loop body ends" }
        #expect(starts == ["lookup(c) STARTS", "lookup(d) STARTS", "loop body ends"])  // the next reply starts early again
    }

    @Test func deferToolCallDoesNothingBeforeTheLoopStartsBecauseThereIsNoReplyYet() async throws {
        let test = try Setup([reply(call("a")), done()])

        await test.runner.deferToolCall(id: "toolu_a")
        #expect(await test.runner.deferredToolCalls.isEmpty)

        for try await stream in test.runner {
            _ = try await stream.getFinalMessage()
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "loop body ends"])
        #expect(await test.runner.deferredToolCalls.isEmpty)
    }

    @Test func deferToolCallChangesNothingForACallThatHasRun() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        var held: [[String]] = []
        for try await stream in test.runner {
            for try await event in stream where test.label(event) == "b: content_block_delta" {
                test.append("defer_tool_call(a)")
                await test.runner.deferToolCall(id: "toolu_a")
                await test.runner.deferToolCall(id: "toolu_b")
            }
            held.append(ids(await test.runner.deferredToolCalls))
            test.append("loop body ends")
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "defer_tool_call(a)", "loop body ends", "lookup(b) STARTS"])
        #expect(held[0] == ["toolu_b"])
        #expect(test.resultsSent().map { $0["tool_use_id"] } == ["toolu_a", "toolu_b"])
    }

    @Test func deferToolCallLastsForOneReply() async throws {
        // The second reply reuses the id of the call that was held in the first.
        let test = try Setup([reply(call("a")), reply(call("a")), done()])

        var held: [[String]] = []
        for try await stream in test.runner {
            if held.isEmpty { await test.runner.deferToolCall(id: "toolu_a") }
            _ = try await stream.getFinalMessage()
            held.append(ids(await test.runner.deferredToolCalls))
            test.append("loop body ends")
        }

        #expect(test.lines == [
            "loop body ends",
            "lookup(a) STARTS",  // held in the first reply
            "request 2",
            "lookup(a) STARTS",  // not held in the second
            "loop body ends",
            "request 3",
            "loop body ends",
        ])
        #expect(held == [["toolu_a"], [], []])
    }

    @Test func letsTheCallerRefuseAHeldCallByRemovingItsTool() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        try await expectWarning("Tool 'lookup' not found in tool runner") {
            for try await stream in test.runner {
                for try await event in stream where test.label(event) == "b: content_block_start" {
                    await test.runner.deferToolCall(try #require(streamingRunnerToolUse(event)))
                }
                try await test.runner.removeTools("lookup")
            }
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS"])
        #expect(test.resultsSent() == [
            ["type": "tool_result", "tool_use_id": "toolu_a", "content": "value of a"], streamingRunnerNotFound("toolu_b"),
        ])
    }

    @Test func runsAHeldCallWhenTheCallerAsksForTheToolResponse() async throws {
        let test = try Setup([reply(call("a"), call("b"))])

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            _ = try await stream.getFinalMessage()
            test.append("generate_tool_call_response()")
            let response = try await test.runner.generateToolCallResponseJSON()

            #expect(streamingRunnerToolResults(response).map { $0["tool_use_id"] } == ["toolu_a", "toolu_b"])
            break
        }

        #expect(test.lines == ["lookup(b) STARTS", "generate_tool_call_response()", "lookup(a) STARTS"])
    }

    // MARK: - deferredToolCalls

    @Test func deferredToolCallsListsTheHeldCallsInTheModelsOrderWithTheirWholeInput() async throws {
        let test = try Setup([reply(call("a"), call("b"), call("c"))])

        for try await stream in test.runner {
            // c is deferred by id before its block has streamed, and before b.
            await test.runner.deferToolCall(id: "toolu_c")
            for try await event in stream where test.label(event) == "b: content_block_stop" {
                await test.runner.deferToolCall(id: "toolu_b")
            }

            #expect(try await test.runner.deferredToolCalls.map { try JSONValue.from($0) } == [
                ["type": "tool_use", "id": "toolu_b", "name": "lookup", "input": ["key": "b"]],
                ["type": "tool_use", "id": "toolu_c", "name": "lookup", "input": ["key": "c"]],
            ])
            break
        }
    }

    @Test func deferredToolCallsListsAHeldCallFromWhenItsBlockHasFinishedStreaming() async throws {
        let test = try Setup([reply(call("a"), call("b"))])
        var held: [String] = []

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            await test.runner.deferToolCall(id: "toolu_b")
            for try await event in stream {
                held.append("\(test.label(event)) -> \(pythonList(ids(await test.runner.deferredToolCalls)))")
            }
            break
        }

        #expect(held == [
            "message_start -> []",
            "a: content_block_start -> []",
            "a: content_block_delta -> []",
            "input_json -> []",
            "a: content_block_stop -> ['toolu_a']",
            "b: content_block_start -> ['toolu_a']",
            "b: content_block_delta -> ['toolu_a']",
            "input_json -> ['toolu_a']",
            "b: content_block_stop -> ['toolu_a', 'toolu_b']",
            "message_delta (tool_use) -> ['toolu_a', 'toolu_b']",
            "message_stop -> ['toolu_a', 'toolu_b']",
        ])
    }

    @Test func deferredToolCallsIsEmptyOnceGenerateToolCallResponseHasRunTheHeldCalls() async throws {
        let test = try Setup([reply(call("a"))])

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            _ = try await stream.getFinalMessage()
            #expect(ids(await test.runner.deferredToolCalls) == ["toolu_a"])

            _ = try await test.runner.generateToolCallResponse()

            #expect(await test.runner.deferredToolCalls.isEmpty)
            break
        }
    }

    @Test func deferredToolCallsListsTheHeldCallsOfAReplyThatIsCutOff() async throws {
        // The runner runs no tools for such a reply, but generateToolCallResponse() does.
        let test = try Setup([replyEnding("max_tokens", call("a"), call("b"))])

        for try await stream in test.runner {
            await test.runner.deferToolCall(id: "toolu_a")
            await test.runner.deferToolCall(id: "toolu_b")
            _ = try await stream.getFinalMessage()

            #expect(ids(await test.runner.deferredToolCalls) == ["toolu_a", "toolu_b"])
            #expect(test.lines.isEmpty)

            _ = try await test.runner.generateToolCallResponse()
            break
        }

        #expect(test.lines == ["lookup(a) STARTS", "lookup(b) STARTS"])
    }

    // MARK: - a reply that is cut off

    @Test(arguments: [
        ("a refusal", replyEnding("refusal", call("a"), call("b", #"{"key": "b""#))),
        ("a refusal that hands the reply to a fallback model",
         replyEnding("end_turn", call("a"), call("b", #"{"key": "b""#), streamingRunnerFallback(), text("Here it is."))),
        // What arrived of the input is enough to call the tool with.
        ("max_tokens", replyEnding("max_tokens", call("a"), call("b", #"{"key": "b", "note": "unfinis"#))),
    ])
    func neverRunsTheCallThatWasCutOffBy(id: String, cutOffReply: StreamingRunnerReply) async throws {
        let test = try Setup([cutOffReply])

        _ = try await test.runner.untilDone()

        #expect(test.lines == ["lookup(a) STARTS"])
        #expect(test.requests.count == 1)
    }

    @Test func runsTheCallsAfterAFallbackBlockOnceTheLoopBodyEndsInOrder() async throws {
        let test = try Setup([reply(call("a"), call("b"), streamingRunnerFallback(), call("c")), done()])

        for try await stream in test.runner {
            _ = try await stream.getFinalMessage()
            test.append("loop body ends")
        }

        // The fallback block started while b was still waiting for the model to move on.
        #expect(firstReply(test.lines) == ["lookup(a) STARTS", "loop body ends", "lookup(b) STARTS", "lookup(c) STARTS"])
        #expect(test.resultsSent().map { $0["tool_use_id"] } == ["toolu_a", "toolu_b", "toolu_c"])
    }

    @Test func runsNoLaterCallOnceTheCallerLeavesTheLoop() async throws {
        let test = try Setup([reply(call("a"), call("b"))])

        for try await stream in test.runner {
            for try await event in stream where test.label(event) == "b: content_block_delta" { break }
            break
        }

        #expect(test.lines == ["lookup(a) STARTS"])
        #expect(test.requests.count == 1)
    }

    // MARK: - a call that has run

    @Test func aCallThatHasRunKeepsItsResultAfterRemoveToolsWhichRefusesACallThatHasNot() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])

        try await expectWarning("Tool 'lookup' not found in tool runner") {
            for try await stream in test.runner {
                for try await event in stream where test.label(event) == "b: content_block_delta" {
                    try await test.runner.removeTools("lookup")
                }
            }
        }

        #expect(firstReply(test.lines) == ["lookup(a) STARTS"])
        #expect(test.resultsSent() == [
            ["type": "tool_result", "tool_use_id": "toolu_a", "content": "value of a"], streamingRunnerNotFound("toolu_b"),
        ])
    }

    @Test func aCallThatHasRunKeepsItsResultAfterAddToolsReplacesItsTool() async throws {
        let test = try Setup([reply(call("a"), call("b")), done()])
        let replacement = streamingRunnerLookupTool(ToolsBox([]), lookup: { key in "new value of \(key)" })

        for try await stream in test.runner {
            for try await event in stream where test.label(event) == "b: content_block_delta" {
                try await test.runner.addTools(replacement)
            }
        }

        #expect(test.resultsSent() == [
            ["type": "tool_result", "tool_use_id": "toolu_a", "content": "value of a"],
            ["type": "tool_result", "tool_use_id": "toolu_b", "content": "new value of b"],
        ])
    }

    @Test func aCallToAToolRemovedEarlierInTheConversationGetsANotFoundResult() async throws {
        let test = try Setup([reply(call("a"), text("Looking.")), done()], messages: [
            ["role": "user", "content": "Look this up."],
            ["role": "system", "content": [["type": "tool_removal", "tool": ["type": "tool_reference", "name": "lookup"]]]],
        ])

        try await expectWarning("Tool 'lookup' not found in tool runner") {
            _ = try await test.runner.untilDone()
        }

        #expect(firstReply(test.lines).isEmpty)
        #expect(test.resultsSent() == [streamingRunnerNotFound("toolu_a")])
    }

    @Test func aCallThatHasRunDoesNotAnswerALaterReplyThatReusesItsID() async throws {
        // The second reply's call comes after a fallback block, so it runs after the loop body.
        let test = try Setup([reply(call("a")), reply(streamingRunnerFallback(), call("a", #"{"key": "again"}"#)), done()])

        _ = try await test.runner.untilDone()

        #expect(streamingRunnerToolResults(test.requests[2]["messages"]?.arrayValue?.last).map { $0["content"] } == ["value of again"])
    }
}
