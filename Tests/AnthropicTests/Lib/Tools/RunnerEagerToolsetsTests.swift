// Port of tests/lib/tools/test_runner_eager_toolsets.py: a streaming tool runner with `runToolsEagerly` and a
// toolset. The runner runs a toolset call while the reply streams, once the model has moved on from it. Once one of
// a toolset's calls fails or is held, that toolset's later calls wait for the reply to end. Function tools and other
// toolsets don't wait.
//
// The replies and the timeline are the ones of `RunnerEagerToolsTests`. The computer and browser toolsets of the
// upstream fixtures are `StreamingRunnerTimelineToolset`s, which write their calls to the timeline.

import Foundation
import Testing
@testable import Anthropic

private typealias Setup = StreamingRunnerSetup
private func call(_ key: String) -> JSONValue { streamingRunnerCall(key) }
private func toolsetCall(_ key: String, _ name: String = "key", _ input: JSONValue? = nil, _ toolsetName: String? = "computer") -> JSONValue {
    streamingRunnerToolsetCall(key, name, input, toolsetName)
}
private func reply(_ blocks: JSONValue...) -> StreamingRunnerReply { StreamingRunnerReply(blocks: blocks, stopReason: "tool_use") }
private func done() -> StreamingRunnerReply { streamingRunnerDone() }
private func firstReply(_ timeline: [String]) -> [String] { streamingRunnerFirstReply(timeline) }

/// When each tool started, and when the caller's loop body ended.
private func starts(_ timeline: [String]) -> [String] {
    timeline.filter { $0.contains("STARTS") || $0 == "loop body ends" }
}

/// A call to a tool of the `family` toolset, and the timeline line for when that tool starts.
private func familyCall(_ family: String, _ key: String = "k") -> (JSONValue, String) {
    if family == "computer" { return (toolsetCall(key), "computer key STARTS") }
    return (toolsetCall(key, "wait", ["duration": 1], "browser"), "browser wait STARTS")
}

/// Sees each event, and defers the calls with these ids when the caller sees their blocks finish.
private func see(_ test: Setup, _ event: ParsedBetaMessageStreamEvent, deferring ids: Set<String>) async {
    test.see(event)
    if let toolUse = streamingRunnerIsToolUseStop(event), ids.contains(toolUse.id) {
        await test.runner.deferToolCall(toolUse)
    }
}

private func json(_ value: [JSONValue]) -> String {
    String(decoding: (try? JSONValue.serialize(.array(value))) ?? Data(), as: UTF8.self)
}

private struct EagerKeyInput: Decodable, Sendable { var text: String }

/// A toolset that extends nothing but the runnable-toolset contract (`EchoBrowserToolset`).
private final class EagerEchoBrowserToolset: BetaRunnableToolset, @unchecked Sendable {
    let calls = ToolsBox<[String]>([])
    override var toolsetName: String { "browser" }
    override func toDict() throws -> JSONValue { ["type": "browser_toolset_20260801"] }
    override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        calls.mutate { $0.append(name) }
        return .string("echo \(name)")
    }
}

@Suite struct RunnerEagerToolsetsTests {
    @Test func aToolsetCallDoesNotRunAFunctionToolOfTheSameName() async throws {
        let ran = ToolsBox<[String]>([])
        let keyTool = BetaFunctionTool(name: "key", description: "A function tool named like the computer toolset's `key` tool.",
                                       inputSchema: ["type": "object", "properties": ["text": ["type": "string"]]]) { (input: EagerKeyInput) in
            ran.mutate { $0.append(input.text) }
            return .string("the function tool ran")
        }
        let test = try Setup([reply(toolsetCall("k")), done()], computer: true, extraTools: [keyTool])

        for try await stream in test.runner {
            for try await _ in stream {}
        }

        let results = test.resultsSent()
        #expect(ran.value.isEmpty)
        #expect(test.computer?.calls.value == ["key"])
        #expect(results.map { $0["tool_use_id"] } == ["toolu_k"])
        #expect(!json(results).contains("the function tool ran"))
    }

    @Test(arguments: ["computer", "browser"])
    func startsAToolsetCallOnceTheModelHasMovedOnFromIt(family: String) async throws {
        let (toolCall, started) = familyCall(family)
        let test = try Setup([reply(call("a"), toolCall, call("b")), done()], computer: family == "computer", browser: family == "browser")

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
            "k: content_block_start",  // the model has moved on from a
            "lookup(a) STARTS",
            "k: content_block_delta",
            "input_json",
            "k: content_block_stop",
            "b: content_block_start",  // the model has moved on from the toolset call
            started,
            "b: content_block_delta",
            "input_json",
            "b: content_block_stop",
            "message_delta (tool_use)",  // the model has moved on from b
            "lookup(b) STARTS",
            "message_stop",
            "loop body ends",
        ])
        // The results go back in the model's order, and the toolset call ran once.
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_a", "toolu_k", "toolu_b"])
        #expect(results[1]["is_error"] == nil)
    }

    @Test func aToolsetCallThatTheCallerDefersHoldsItsToolsetsLaterCallsAndNoOtherCall() async throws {
        let wait = toolsetCall("w", "wait", ["duration": 1], "browser")
        let test = try Setup([reply(call("a"), toolsetCall("k1"), call("f"), wait, toolsetCall("k2")), done()], computer: true, browser: true)

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_k1"]) }
            test.append("loop body ends")
        }

        #expect(starts(firstReply(test.lines)) == [
            "lookup(a) STARTS",
            "lookup(f) STARTS",  // a function tool doesn't wait for the held call
            "browser wait STARTS",  // nor does another toolset
            "loop body ends",
            "computer key STARTS",  // k1
            "computer key STARTS",  // k2 waited behind it
        ])
        #expect(test.resultsSent().map { $0["tool_use_id"] } == ["toolu_a", "toolu_k1", "toolu_f", "toolu_w", "toolu_k2"])
    }

    @Test func aFunctionCallThatTheCallerDefersHoldsNoOtherCall() async throws {
        let test = try Setup([reply(call("a"), toolsetCall("k"), call("b")), done()], computer: true)

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_a"]) }
            test.append("loop body ends")
        }

        #expect(starts(firstReply(test.lines)) == ["computer key STARTS", "lookup(b) STARTS", "loop body ends", "lookup(a) STARTS"])
    }

    @Test func listsOnlyTheCallThatTheCallerDefersAndNotItsToolsetsLaterCalls() async throws {
        let test = try Setup([reply(toolsetCall("k1"), toolsetCall("k2")), done()], computer: true)
        var listed: [[String]] = []

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_k1"]) }
            listed.append(streamingRunnerIDs(await test.runner.deferredToolCalls))
            break
        }

        #expect(listed == [["toolu_k1"]])
    }

    @Test func theHoldEndsWithTheReply() async throws {
        let test = try Setup([reply(toolsetCall("k1"), toolsetCall("k2")), reply(toolsetCall("k3")), done()], computer: true)

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_k1"]) }
            test.append("loop body ends")
        }

        let secondReply = streamingRunnerBetween(test.lines, "request 2", "request 3")
        #expect(starts(secondReply) == [
            "computer key STARTS",  // the next reply's calls run early again
            "loop body ends",
        ])
    }

    @Test func doesNotRunACallThatHasNotStartedWhenTheCallerLeavesTheLoop() async throws {
        let test = try Setup([reply(toolsetCall("k1"), toolsetCall("k2")), done()], computer: true)

        outer: for try await stream in test.runner {
            for try await event in stream {
                test.see(event)
                // The model has moved on from k1, so k1 has run. k2 has not.
                if streamingRunnerIsToolUseStop(event)?.id == "toolu_k2" { break outer }
            }
            break
        }

        #expect(starts(test.lines) == ["computer key STARTS"])
    }

    @Test func doesNotRunAHeldCallOnceOneOfItsToolsetsCallsHasFailed() async throws {
        let test = try Setup([reply(toolsetCall("k1"), toolsetCall("k2")), done()], computer: true)
        test.computer?.fail.mutate { $0["key"] = ToolError("no such key") }

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_k2"]) }
            test.append("loop body ends")
        }

        #expect(starts(firstReply(test.lines)) == ["computer key STARTS", "loop body ends"])
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_k1", "toolu_k2"])
        #expect(json([results[1]]).contains("Not executed"))
    }

    @Test func aCallNamedLikeAToolsetWithNoToolsetNameHoldsThatToolsetsLaterCalls() async throws {
        // The runner answers such a call as a malformed toolset call when it builds the tool response. That answers
        // the toolset's later calls with `Not executed`, so none of them may have run.
        let malformed = toolsetCall("m", "computer", ["action": "key"], nil)
        let test = try Setup([reply(call("a"), malformed, toolsetCall("k"), call("b")), done()], computer: true)

        for try await stream in test.runner {
            for try await event in stream { test.see(event) }
            test.append("loop body ends")
        }

        #expect(starts(firstReply(test.lines)) == ["lookup(a) STARTS", "lookup(b) STARTS", "loop body ends"])
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_a", "toolu_m", "toolu_k", "toolu_b"])
        #expect(results[1]["is_error"] == true && results[2]["is_error"] == true && results[3]["is_error"] == nil)
        #expect(json([results[2]]).contains("Not executed"))
    }

    @Test func aHeldCallNamedLikeAToolsetWithNoToolsetNameHoldsThatToolsetsLaterCalls() async throws {
        // The caller holds the malformed call. It is still answered as malformed when the tool response is built,
        // and that answers the toolset's later calls with `Not executed`, so none of them may have run.
        let malformed = toolsetCall("m", "computer", ["action": "key"], nil)
        let test = try Setup([reply(malformed, toolsetCall("k"), call("b")), done()], computer: true)

        for try await stream in test.runner {
            for try await event in stream { await see(test, event, deferring: ["toolu_m"]) }
            test.append("loop body ends")
        }

        #expect(starts(firstReply(test.lines)) == ["lookup(b) STARTS", "loop body ends"])
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_m", "toolu_k", "toolu_b"])
        #expect(json([results[1]]).contains("Not executed"))
    }

    @Test func aCallToAToolsetTheRunnerDoesNotHaveIsAnsweredAsNotFound() async throws {
        let test = try Setup([reply(call("a"), toolsetCall("k"), call("b")), done()])

        try await expectWarning("not found in tool runner") {
            for try await stream in test.runner {
                for try await event in stream { test.see(event) }
                test.append("loop body ends")
            }
        }

        #expect(starts(firstReply(test.lines)) == ["lookup(a) STARTS", "lookup(b) STARTS", "loop body ends"])
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_a", "toolu_k", "toolu_b"])
        #expect(results[1]["is_error"] == true && json([results[1]]).contains("not found"))
    }

    @Test func runsNoLaterCallOfAToolsetOnceOneOfItsCallsHasFailed() async throws {
        let test = try Setup([reply(toolsetCall("k1"), toolsetCall("k2"), call("c")), done()], computer: true)
        test.computer?.fail.mutate { $0["key"] = ToolError("no such key") }

        for try await stream in test.runner {
            for try await event in stream { test.see(event) }
            test.append("loop body ends")
        }

        // k2 doesn't start after k1 failed. It is answered with `Not executed`, and c, which is not a toolset call, runs.
        #expect(starts(firstReply(test.lines)) == ["computer key STARTS", "lookup(c) STARTS", "loop body ends"])
        let results = test.resultsSent()
        #expect(results.map { $0["tool_use_id"] } == ["toolu_k1", "toolu_k2", "toolu_c"])
        #expect(results[0]["is_error"] == true && results[1]["is_error"] == true && results[2]["is_error"] == nil)
        #expect(json([results[1]]).contains("Not executed"))
    }

    @Test func aToolsetThatDoesNotExtendTheSDKsClassesStartsItsCallsEarlyToo() async throws {
        let echo = EagerEchoBrowserToolset()
        let test = try Setup([reply(call("a"), toolsetCall("w", "wait", ["duration": 1], "browser"), call("b")), done()],
                             extraTools: [echo])
        var ranWhileStreaming: [String] = []

        for try await stream in test.runner {
            for try await event in stream { test.see(event) }
            ranWhileStreaming += echo.calls.value
            test.append("loop body ends")
        }

        #expect(Array(ranWhileStreaming.prefix(1)) == ["wait"])
        #expect(echo.calls.value == ["wait"])  // it ran once
    }
}
