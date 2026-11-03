// Port of the streaming cases of tests/lib/tools/test_runners.py (`tool_runner(stream=True)`): the recorded streaming
// run, tool changes and `compact_before_next_turn()` on a streaming runner. The runner-from-params cases are in
// `RunnerCompactionTests.swift` (`RunnerFromParamsTests`).

import Foundation
import Testing
@testable import Anthropic

@Suite struct StreamingRunnersTests {
    @Test func streamingCall() async throws {
        let mock = try snapshotMock("771c64ff-a0af-4cd9-8080-a5a539da7cb9")
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
            tools: [toolsWeatherTool()])
        let message = try await runner.untilDone()

        #expect(message.id == "msg_0158JyopQTFaomteeJoDpS5q")
        #expect(message.stopReason == .endTurn)
        #expect(message.content.count == 1)
        if case .text(let block)? = message.content.first {
            #expect(block.text == "The weather in San Francisco, CA is currently **68°F and Sunny**. It's a nice day!")
        } else {
            Issue.record("expected a text block, got \(message.content)")
        }
        #expect(message.usage.inputTokens == 770)
        #expect(message.usage.outputTokens == 27)
        #expect(mock.bodies.map { $0["stream"] } == [true, true])
        #expect(mock.requests.map { $0.headers["x-stainless-helper-method"] } == ["stream", "stream"])
    }

    /// `test_streaming_call_sync_events`, over the streamed recording (the upstream test's own recording holds
    /// non-streamed replies).
    @Test func streamingCallEvents() async throws {
        let mock = try snapshotMock("771c64ff-a0af-4cd9-8080-a5a539da7cb9")
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
            tools: [toolsWeatherTool()])
        var events = Set<String>()
        for try await stream in runner {
            for try await event in stream { events.insert(event.type) }
        }
        #expect(events == [
            "content_block_delta", "content_block_start", "content_block_stop", "input_json", "message_delta", "message_start",
            "message_stop", "text",
        ])
    }

    @Test func toolChangesWhenStreaming() async throws {
        let mock = MessagesMock(replies: [
            runnerSSEMessage(["type": "tool_use", "id": "toolu_time", "name": "get_time", "input": [:]], "tool_use",
                             ["type": "input_json_delta", "partial_json": "{}"]),
            runnerSSEMessage(["type": "text", "text": ""], "end_turn", ["type": "text_delta", "text": "Done."]),
        ])
        let calls = ToolsBox<[String]>([])
        let getTime = recordingTool("get_time", calls)
        let getWeather = recordingTool("get_weather", calls)
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What time is it, and what is the weather in SF?")],
            model: "claude-haiku-4-5", tools: [getTime], thread: false)
        for try await stream in runner {
            // Every streamed message has this id, so the final turn adds the tool again; that change is never sent.
            if try await stream.getFinalMessage().id == "msg_streamed" { try await runner.addTools(getWeather) }
        }

        #expect(calls.value == ["get_time"])
        let requests = mock.bodies
        #expect(requests.map { $0["stream"] } == [true, true])
        #expect(Array(requests[1]["messages"]?.arrayValue?.suffix(2) ?? []) == [
            ranResult("toolu_time", "get_time"), toolChangesMessage(addition(try getWeather.toToolParam())),
        ])
    }

    @Test func compactBeforeNextTurnWhenStreaming() async throws {
        let mock = MessagesMock(replies: [
            runnerSSEMessage(["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": [:]], "tool_use",
                             ["type": "input_json_delta", "partial_json": #"{"location": "SF", "units": "f"}"#]),
            // A compaction block arrives whole on the start event; there is no delta for it.
            runnerSSEMessage(["type": "compaction", "content": "Summary so far.", "signature": "sig_01"], "compaction"),
            runnerSSEMessage(["type": "text", "text": ""], "end_turn", ["type": "text_delta", "text": "Done."]),
        ])
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
            tools: [toolsWeatherTool()])
        var stopReasons: [BetaStopReason?] = []
        for try await stream in runner {
            stopReasons.append(try await stream.getFinalMessage().stopReason)
            if stopReasons.last == .toolUse { try await runner.compactBeforeNextTurn() }
        }

        #expect(stopReasons == [.toolUse, .compaction, .endTurn])
        let requests = mock.bodies
        #expect(requests.count == 3)
        #expect(requests[1]["compaction"] == ["type": "summarize"])
        #expect(requests[1]["stream"] == true)
        #expect(requests[2]["messages"] == .array(compactionBlockAlone))
    }

    /// A streaming runner with an output format parses each reply's text, as `stream(outputFormat:)` does.
    @Test func streamingRunnerParsesTheRepliesOfItsOutputFormat() async throws {
        let mock = MessagesMock(replies: [
            runnerSSEMessage(["type": "text", "text": ""], "end_turn", ["type": "text_delta", "text": #"{"summary": "Sunny"}"#]),
        ])
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("What is the weather in SF?")], model: "claude-haiku-4-5",
            tools: [toolsWeatherTool()], outputFormat: RunnerForecast.self)
        var parsed: [RunnerForecast?] = []
        for try await stream in runner { parsed.append(try await stream.getFinalMessage().parsedOutput) }

        #expect(parsed == [RunnerForecast(summary: "Sunny")])
        #expect(try await runner.untilDone().parsedOutput == RunnerForecast(summary: "Sunny"))
        #expect(mock.bodies.first?["output_config"]?["format"] == [
            "type": "json_schema", "schema": .object(try jsonOutputFormat(RunnerForecast.self)),
        ])
    }

    /// Closing a streaming runner closes the stream it handed out, and the thread's turn ends with what arrived.
    @Test func closingTheRunnerClosesTheStreamItHandedOut() async throws {
        let mock = MessagesMock(replies: [
            runnerSSEMessage(["type": "text", "text": ""], "end_turn", ["type": "text_delta", "text": "Done."]),
        ])
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("Hi")], model: "claude-haiku-4-5", tools: [toolsWeatherTool()])
        var streams = 0
        for try await stream in runner {
            streams += 1
            await runner.close()
            #expect(stream.response.isClosed)
        }
        #expect(streams == 1)
        #expect(try await runner.next() == nil)
        #expect(mock.calls == 1)
    }

    /// `toolsets/test_runner.py::test_a_streamed_member_call_is_routed_to_the_toolset`: the streaming runner
    /// accumulates the `tool_use` from events; `toolset_name` must survive that and route the block to the toolset,
    /// and a same-named plain tool in the same turn still goes to the function tool.
    @Test func aStreamedMemberCallIsRoutedToTheToolset() async throws {
        let turn = messageResponse(id: "msg_tool_use", content: [
            ["type": "tool_use", "id": "toolu_member", "name": "navigate", "input": ["url": "u"], "toolset_name": "browser"],
            ["type": "tool_use", "id": "toolu_custom", "name": "navigate", "input": ["url": "v"]],
        ], stopReason: "tool_use")
        let mock = MessagesMock(replies: [streamingRunnerSSE(of: turn), streamingRunnerSSE(of: endTurnResponse())])
        let toolset = ToolsetEchoBrowser()
        let navigate = BetaFunctionTool(name: "navigate", description: "Custom tool that shares a browser member's name.",
                                        inputSchema: ["type": "object", "properties": ["url": ["type": "string"]]]) { input in
            .string("custom:\(input["url"]?.stringValue ?? "")")
        }
        let runner = try mock.client().beta.messages.streamingToolRunner(
            maxTokens: 1024, messages: [toolsUserMessage("Open example.com")], model: "claude-haiku-4-5", tools: [toolset, navigate])

        var results: [JSONValue] = []
        for try await stream in runner {
            try await stream.untilDone()
            if let response = try await runner.generateToolCallResponseJSON() { results += response["content"]?.arrayValue ?? [] }
        }

        #expect(toolset.calls.map(\.0) == ["navigate"] && toolset.calls.first?.1 == ["url": "u"])
        // Typed lets: as one `#expect` expression this outran the Swift 6.2 type checker.
        let rows: [[JSONValue]] = results.map { result -> [JSONValue] in
            [result["tool_use_id"] ?? .null, result["toolset_name"] ?? .null, result["content"] ?? .null]
        }
        let expected: [[JSONValue]] = [
            ["toolu_member", "browser", #"navigate:{"url": "u"}"#],
            ["toolu_custom", nil, "custom:v"],
        ]
        #expect(rows == expected)
    }
}

/// A `Message` response body as the stream events the API sends for it (`_sse`): each block starts empty and a
/// `tool_use` block's input arrives as one `input_json_delta`.
func streamingRunnerSSE(of message: JSONValue) -> MessagesMock.Reply {
    var start = message
    start["content"] = []
    start["stop_reason"] = nil
    var events: [JSONValue] = [["type": "message_start", "message": start]]
    for (index, block) in (message["content"]?.arrayValue ?? []).enumerated() {
        var empty = block
        var delta: JSONValue?
        if block["type"] == "tool_use" {
            empty["input"] = [:]
            let partial = String(decoding: (try? JSONValue.serialize(block["input"] ?? [:])) ?? Data(), as: UTF8.self)
            delta = ["type": "input_json_delta", "partial_json": .string(partial)]
        } else if block["type"] == "text" {
            empty["text"] = ""
            delta = ["type": "text_delta", "text": block["text"] ?? ""]
        }
        events.append(["type": "content_block_start", "index": .int(index), "content_block": empty])
        if let delta { events.append(["type": "content_block_delta", "index": .int(index), "delta": delta]) }
        events.append(["type": "content_block_stop", "index": .int(index)])
    }
    events.append(["type": "message_delta", "delta": ["stop_reason": message["stop_reason"] ?? .null, "stop_sequence": nil],
                   "usage": ["output_tokens": 1]])
    events.append(["type": "message_stop"])
    return .sse(events.map(streamingRunnerSSE).joined())
}
