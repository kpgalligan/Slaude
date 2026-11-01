import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/streaming/test_partial_json.py and test_parsed_content_blocks.py.

func toolUseSnapshot() -> BetaMessage {
    BetaMessage(id: "msg_123",
                content: [.toolUse(BetaToolUseBlock(id: "tool_123", input: [:], name: "test_tool", caller: .direct(BetaDirectCaller())))],
                model: "claude-sonnet-5-5", stopReason: nil, stopSequence: nil, usage: BetaUsage(inputTokens: 10, outputTokens: 10))
}

func inputJSONDelta(_ json: String) -> BetaRawMessageStreamEvent {
    .contentBlockDelta(BetaRawContentBlockDeltaEvent(delta: .inputJsonDelta(BetaInputJSONDelta(partialJson: json)), index: 0))
}

func toolInput(_ message: BetaMessage) -> [String: JSONValue]? {
    if case .toolUse(let b) = message.content[0] { return b.input }
    return nil
}

let fineGrained: HTTPHeaders = ["anthropic-beta": "fine-grained-tool-streaming-2025-05-14"]

@Suite struct PartialJSONTests {
    @Test func trailingStringsModeHeader() throws {
        // Complete JSON: both modes agree.
        var bufs: [Int: String] = [:]
        let m1 = try accumulateBetaEvent(inputJSONDelta(#"{"key": "value"}"#), snapshot: toolUseSnapshot(), jsonBufs: &bufs,
                                         requestHeaders: ["some-header": "value"])
        bufs = [:]
        let m2 = try accumulateBetaEvent(inputJSONDelta(#"{"key": "value"}"#), snapshot: toolUseSnapshot(), jsonBufs: &bufs, requestHeaders: fineGrained)
        #expect(toolInput(m1) == ["key": "value"])
        #expect(toolInput(m2) == ["key": "value"])

        // Incomplete JSON with a trailing string: the modes differ.
        let incomplete = #"{"items": ["item1", "item2"], "unfinished_field": "incomplete value"#
        bufs = [:]
        let standard = try accumulateBetaEvent(inputJSONDelta(incomplete), snapshot: toolUseSnapshot(), jsonBufs: &bufs,
                                               requestHeaders: ["some-header": "value"])
        bufs = [:]
        let trailing = try accumulateBetaEvent(inputJSONDelta(incomplete), snapshot: toolUseSnapshot(), jsonBufs: &bufs, requestHeaders: fineGrained)
        #expect(toolInput(standard)?["items"] == ["item1", "item2"])
        #expect(toolInput(trailing)?["items"] == ["item1", "item2"])
        #expect(toolInput(standard)?["unfinished_field"] == nil)
        #expect(toolInput(trailing)?["unfinished_field"] == "incomplete value")
    }

    @Test func partialJSONWithInvalidJSON() throws {
        var bufs: [Int: String] = [:]
        do {
            _ = try accumulateBetaEvent(inputJSONDelta(#"{"key": "value", "incomplete_field": bad_value"#), snapshot: toolUseSnapshot(),
                                        jsonBufs: &bufs, requestHeaders: fineGrained)
            Issue.record("Expected ValueError for invalid JSON, but no error was raised.")
        } catch let e as ValueError {
            #expect(e.message.hasPrefix("Unable to parse tool parameter JSON from model. Please retry your request or adjust your prompt."))
        }
    }

    @Test func partialParserSemantics() throws {
        #expect(try PartialJSON.parse(#"{"a": 1, "b": "inc"#, mode: .on) == ["a": 1])
        #expect(try PartialJSON.parse(#"{"a": 1, "b": "inc"#, mode: .trailingStrings) == ["a": 1, "b": "inc"])
        #expect(try PartialJSON.parse(#"[1, 2, {"x": [tr"#, mode: .on) == [1, 2, ["x": []]])
        #expect(try PartialJSON.parse(#"{"a": 12"#, mode: .on) == ["a": 12])
        #expect(try PartialJSON.parse(#"{"a"#, mode: .trailingStrings) == [:])
        #expect(try PartialJSON.parse(#"{"s": "é\n"}"#, mode: .off) == ["s": "é\n"])
        #expect(throws: PartialJSONError.self) { try PartialJSON.parse(#"{"a": 1"#, mode: .off) }
        #expect(throws: PartialJSONError.self) { try PartialJSON.parse("[1] x", mode: .on) }
        #expect(try TextEvent(text: "", snapshot: #"{"name": "Jo"#).parsedSnapshot() == ["name": "Jo"])
    }
}

@Suite struct ParsedContentBlocksTests {
    /// `test_streamed_fallback_block_is_constructed_as_fallback_block`.
    @Test func streamedFallbackBlockIsConstructedAsFallbackBlock() throws {
        let snapshot = BetaMessage(id: "msg_123", content: [], model: "claude-sonnet-5-5", usage: BetaUsage(inputTokens: 10, outputTokens: 10))
        let event: JSONValue = [
            "type": "content_block_start", "index": 0,
            "content_block": ["type": "fallback", "from": ["model": "claude-sonnet-4-5"], "to": ["model": "claude-haiku-4-5"],
                              "trigger": ["type": "refusal", "category": nil]],
        ]
        var bufs: [Int: String] = [:]
        let message = try accumulateBetaEvent(try event.decode(), snapshot: snapshot, jsonBufs: &bufs, requestHeaders: HTTPHeaders())
        guard case .fallback(let block) = message.content[0] else {
            Issue.record("expected a fallback block, got \(message.content[0])")
            return
        }
        #expect(block.type == "fallback")
        #expect(block.from?.model.rawValue == "claude-sonnet-4-5")
        #expect(block.to.model.rawValue == "claude-haiku-4-5")
    }

    /// `test_parsed_output_is_readable_but_not_dumped`.
    @Test func parsedOutputIsReadableButNotDumped() throws {
        let message = Message(id: "m", content: [.text(TextBlock(text: "{}"))], model: "m", usage: Usage(inputTokens: 0, outputTokens: 0))
        let parsed = ParsedMessage<JSONValue>(message: message, parsedOutputs: [0: ["greeting": "hi"]])
        #expect(parsed.parsedOutput == ["greeting": "hi"])
        #expect(parsed.parsedOutput(at: 0) == ["greeting": "hi"])
        // the API rejects `parsed_output`, so the encoded message must not carry it
        let json = try JSONValue.from(parsed)
        #expect(json == (try JSONValue.from(message)))
        #expect(json["content"]?[0]?["parsed_output"] == nil)
        // copies keep the parsed value
        let copy = parsed
        #expect(copy.parsedOutput == parsed.parsedOutput)

        let beta = BetaMessage(id: "m", content: [.text(BetaTextBlock(text: "{}"))], model: "m", usage: BetaUsage(inputTokens: 0, outputTokens: 0))
        let parsedBeta = ParsedBetaMessage<JSONValue>(message: beta, parsedOutputs: [0: ["greeting": "hi"]])
        #expect(parsedBeta.parsedOutput == ["greeting": "hi"])
        #expect(try JSONValue.from(parsedBeta) == (try JSONValue.from(beta)))
    }
}
