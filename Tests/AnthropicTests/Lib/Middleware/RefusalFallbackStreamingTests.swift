import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/test_refusal_fallback_streaming.py. The sync and async classes test the same
// behaviour; both run here as Swift async tests (deduplicated where they were twins).

let fableFallbackModel = "claude-opus-4-8"
let fableSecondModel = "claude-sonnet-4-6"
let fableFallbacks = [fallback(fableFallbackModel)]
let fableTwoFallbacks = [fallback(fableFallbackModel), fallback(fableSecondModel)]
let fableUserText = "Hey claudius! Can you tell me what a solar eclipse is?"
let fableParamsMessages: JSONValue = [["role": "user", "content": .string(fableUserText)]]

var streamA: String { fixture("stream-a-refusal.sse") }
var streamB: String { fixture("stream-b-fallback.sse") }
var streamAToolFixture: String { fixture("stream-a-toolrefusal.sse") }

/// Serializes one event payload as an SSE frame (its `type` is the event name).
func ev(_ data: JSONValue) -> String { "event: \(data["type"]?.stringValue ?? "")\ndata: \(jsonDumps(data))\n\n" }

func fableMessageStart() -> String {
    ev(["type": "message_start", "message": [
        "id": "msg_a", "type": "message", "role": "assistant", "model": "claude-fable-5", "content": [], "stop_reason": nil,
        "stop_sequence": nil, "usage": ["input_tokens": 12, "output_tokens": 1],
    ]])
}

func refusalDelta(_ token: String? = "tok_abc", _ hasPrefillClaim: Bool = true) -> String {
    ev(["type": "message_delta",
        "delta": ["stop_reason": "refusal", "stop_sequence": nil,
                  "stop_details": ["type": "refusal", "category": nil, "explanation": nil, "fallback_credit_token": token.map { .string($0) } ?? .null,
                                   "fallback_has_prefill_claim": token == nil ? .null : .bool(hasPrefillClaim)]],
        "usage": ["output_tokens": 20]])
}

func redeemedToken(_ token: String) -> JSONValue { ["token": .string(token), "mode": "best_effort"] }

/// A fallback hop that contributes one text block, then refuses with a fresh token.
func hopRefusal(_ token: String? = "tok_b", _ hasPrefillClaim: Bool = true) -> String {
    [
        fableMessageStart(),
        ev(["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]]),
        ev(["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": "Partial from B. "]]),
        ev(["type": "content_block_stop", "index": 0]),
        refusalDelta(token, hasPrefillClaim),
        ev(["type": "message_stop"]),
    ].joined()
}

func servingStream(_ model: String = fableFallbackModel, messageID: String = "msg_b") -> String {
    [
        ev(["type": "message_start", "message": [
            "id": .string(messageID), "type": "message", "role": "assistant", "model": .string(model), "content": [], "stop_reason": nil,
            "stop_sequence": nil, "usage": ["input_tokens": 12, "output_tokens": 1],
        ]]),
        ev(["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]]),
        ev(["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": "Happy to help."]]),
        ev(["type": "content_block_stop", "index": 0]),
        ev(["type": "message_delta", "delta": ["stop_reason": "end_turn", "stop_sequence": nil], "usage": ["output_tokens": 9]]),
        ev(["type": "message_stop"]),
    ].joined()
}

let transforms: JSONValue = [["type": "thinking_dropped", "path": "messages.1.content.0", "reason": "model_binding_mismatch"]]

func transformingStream(deltaTransformations: JSONValue? = nil, terminal: String? = nil) -> String {
    var delta: JSONValue = ["type": "message_delta", "delta": ["stop_reason": "end_turn", "stop_sequence": nil], "usage": ["output_tokens": 9]]
    if let deltaTransformations { delta["input_transformations"] = deltaTransformations }
    return [
        ev(["type": "message_start", "message": [
            "id": "msg_b", "type": "message", "role": "assistant", "model": .string(fableFallbackModel), "content": [], "stop_reason": nil,
            "stop_sequence": nil, "input_transformations": transforms, "usage": ["input_tokens": 12, "output_tokens": 1],
        ]]),
        ev(["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]]),
        ev(["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": "Happy to help."]]),
        ev(["type": "content_block_stop", "index": 0]),
        terminal ?? ev(delta),
        ev(["type": "message_stop"]),
    ].joined()
}

func errorResponse(_ message: String, _ status: Int) -> MockReply {
    .json(["type": "error", "error": ["type": "invalid_request_error", "message": .string(message)]], status: status)
}

func overloaded() -> MockReply { .json(["type": "error", "error": ["type": "overloaded_error", "message": "later"]], status: 529) }

func createStream(_ client: Anthropic, betas: [AnthropicBetaParam]? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
                  messages: [BetaMessageParam]? = nil, thinking: JSONValue? = nil, fallbacks: BetaFallbacksParam?? = nil) async throws
    -> SSEStream<BetaRawMessageStreamEvent>
{
    try await client.beta.messages.createStreaming(maxTokens: 1024, messages: messages ?? [betaUserMessage(.string(fableUserText))],
                                                   model: "claude-fable-5", fallbacks: fallbacks, speed: speed,
                                                   thinking: try thinking?.decode(), betas: betas)
}

func collectStream(_ client: Anthropic, betas: [AnthropicBetaParam]? = nil, speed: BetaMessageCreateParamsBase.Speed?? = nil,
                   thinking: JSONValue? = nil) async throws -> [BetaRawMessageStreamEvent]
{
    try await collect(try await createStream(client, betas: betas, speed: speed, thinking: thinking))
}

func blockType(_ block: BetaRawContentBlockStartEvent.ContentBlock) -> String {
    (try? JSONValue.from(block))?["type"]?.stringValue ?? "?"
}

func blockStarts(_ events: [BetaRawMessageStreamEvent]) -> [String] {
    events.compactMap { e in
        if case .contentBlockStart(let s) = e { return "\(s.index) \(blockType(s.contentBlock))" }
        return nil
    }
}

func seams(_ events: [BetaRawMessageStreamEvent]) -> [String] {
    events.compactMap { e in
        if case .contentBlockStart(let s) = e, case .fallback(let b) = s.contentBlock { return "\(b.from?.model.rawValue ?? "")->\(b.to.model.rawValue)" }
        return nil
    }
}

func eventType(_ e: BetaRawMessageStreamEvent) -> String { betaRawEventType(e) }

func messageDeltas(_ events: [BetaRawMessageStreamEvent]) -> [BetaRawMessageDeltaEvent] {
    events.compactMap { e in if case .messageDelta(let d) = e { return d } else { return nil } }
}

func firstDelta(_ events: [BetaRawMessageStreamEvent]) throws -> BetaRawMessageDeltaEvent { try #require(messageDeltas(events).first) }

func iterations(_ delta: BetaRawMessageDeltaEvent) -> [String] {
    (delta.usage.iterations ?? []).map { item in
        let j = try? JSONValue.from(item)
        return "\(j?["type"]?.stringValue ?? ""):\(j?["model"]?.stringValue ?? "None")"
    }
}

/// `skeleton(events)`: a compact structural rendering of a spliced stream.
func skeleton(_ events: [BetaRawMessageStreamEvent]) -> [String] {
    events.map { e in
        switch e {
        case .contentBlockStart(let s):
            if case .fallback(let b) = s.contentBlock { return "start[\(s.index)] fallback{\(b.from?.model.rawValue ?? "")->\(b.to.model.rawValue)}" }
            return "start[\(s.index)] \(blockType(s.contentBlock))"
        case .contentBlockDelta(let d): return "delta[\(d.index)] \((try? JSONValue.from(d.delta))?["type"]?.stringValue ?? "")"
        case .contentBlockStop(let s): return "stop[\(s.index)]"
        case .messageDelta(let d):
            return "message_delta \(d.delta.stopReason?.rawValue ?? "None") iter=[\(iterations(d).joined(separator: ","))]"
        default: return eventType(e)
        }
    }
}

func withoutSpeed(_ body: JSONValue) -> JSONValue {
    var b = body
    b["speed"] = nil
    return b
}

/// A response body that counts how often it is closed (`tests/utils.Body`).
final class ClosingBody: @unchecked Sendable {
    private let lock = NSLock()
    private var _closes = 0
    var closes: Int { lock.withLock { _closes } }

    func reply(_ status: Int) -> MockReply {
        .handler { [self] request in
            HTTPResponse(statusCode: status, headers: ["content-type": "text/event-stream"],
                         stream: chunked(Data(String(repeating: "event: unhandled\ndata: {}\n\n", count: 100).utf8)), request: request,
                         onClose: { self.lock.withLock { self._closes += 1 } })
        }
    }
}

@Suite struct ShapeBContinuationTests {
    @Test func splicesTheFallbackOntoTheRefusedStream() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        // A's thinking + text, a fallback boundary at the next monotonic index, then B's blocks
        #expect(blockStarts(events) == ["0 thinking", "1 text", "2 fallback", "3 text"])
        #expect(seams(events) == ["claude-fable-5->\(fableFallbackModel)"])
        // exactly one message_start (A's), one message_delta and one message_stop reach the client
        #expect(events.filter { eventType($0) == "message_start" }.count == 1)
        #expect(events.filter { eventType($0) == "message_stop" }.count == 1)
        #expect(messageDeltas(events).count == 1)
        // B's message_start (not re-emitted) has no `input_transformations`, so the delta gains none
        #expect(try JSONValue.from(try firstDelta(events))["input_transformations"] == nil)
    }

    @Test func theStreamHelperGetsTheFallback() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let client = try server.client(middleware: [fbMiddleware(fableFallbacks)])
        let stream = try await client.beta.messages.stream(maxTokens: 1024, messages: [betaUserMessage(.string(fableUserText))], model: "claude-fable-5")
        try await stream.untilDone()
        #expect(server.bodies.map { $0["model"] } == ["claude-fable-5", .string(fableFallbackModel)])
    }

    @Test func usageIterationsIsTheTwoEntryServerShape() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let delta = try firstDelta(try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)])))
        #expect(delta.delta.stopReason?.rawValue == "end_turn")
        // the 2-entry server shape, with no spurious `message: None` entry
        #expect(iterations(delta) == ["message:claude-fable-5", "fallback_message:\(fableFallbackModel)"])
    }

    @Test func buildsRequestBAsAShapeBContinuation() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        let bodies = server.bodies
        #expect(bodies.count == 2)
        let b = bodies[1]
        #expect(b["model"] == .string(fableFallbackModel))
        #expect(b["fallback_credit_token"]?["mode"] == "best_effort")
        let token: String? = b["fallback_credit_token"]?["token"]?.stringValue
        #expect(token?.isEmpty == false)
        // mutually exclusive with server-side fallback — both spellings absent
        #expect(b["fallback"] == nil)
        #expect(b["fallbacks"] == nil)
        #expect(b["max_tokens"] == 1024)
        // original turn preserved; one assistant turn appended carrying the partial output as-is
        #expect(b["messages"]?.arrayValue?.count == 2)
        #expect(b["messages"]?[0] == fableParamsMessages[0])
        let appended = b["messages"]?[1]
        #expect(appended?["role"] == "assistant")
        #expect(appended?["content"]?.arrayValue?.map { $0["type"] } == ["thinking", "text"])
        #expect(appended?["content"]?[0]?["signature"] != nil)
    }

    @Test func betweenToolsThinkingDegradesToDisabledOnTheHop() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]), thinking: ["type": "between_tools"])
        #expect(server.bodies[0]["thinking"] == ["type": "between_tools"])
        #expect(server.bodies[1]["thinking"] == ["type": "disabled"])
    }

    @Test func appendsTheFallbackCreditBetaToBothTheOriginalAndHopRequests() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]), betas: ["interleaved-thinking-2025-05-14"])
        #expect(server.header("anthropic-beta") == [
            "interleaved-thinking-2025-05-14,fallback-credit-2026-07-01", "interleaved-thinking-2025-05-14,fallback-credit-2026-07-01",
        ])
    }

    @Test func theBetasOptionReplacesTheDefaultOnEveryRequest() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, betas: ["fallback-credit-2027-01-01"])]),
                                    betas: ["fallback-credit-2026-06-01"])
        #expect(server.header("anthropic-beta") == [
            "fallback-credit-2026-06-01,fallback-credit-2027-01-01", "fallback-credit-2026-06-01,fallback-credit-2027-01-01",
        ])
    }

    @Test func theSplicedStreamIsAlsoServedByTheStateTask() async throws {
        // TestAsyncSplicing::test_splices_the_fallback_onto_the_refused_stream, run inside a state.
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let client = try server.client(middleware: [fbMiddleware(fableFallbacks)])
        let state = BetaFallbackState()
        let events = try await state.run { try await collectStream(client) }
        #expect(blockStarts(events) == ["0 thinking", "1 text", "2 fallback", "3 text"])
        #expect(iterations(try firstDelta(events)) == ["message:claude-fable-5", "fallback_message:\(fableFallbackModel)"])
        #expect(state.index == 0)
    }
}

@Suite struct RefusalFallbackStreamingEdgeCaseTests {
    @Test func aRefusalWithoutAPrefillClaimFallsBackToShapeA() async throws {
        let noClaim = [
            fableMessageStart(),
            ev(["type": "content_block_start", "index": 0, "content_block": ["type": "thinking", "thinking": "", "signature": ""]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "thinking_delta", "thinking": "considering the request"]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "signature_delta", "signature": "sig=="]]),
            ev(["type": "content_block_stop", "index": 0]),
            refusalDelta("tok_abc", false),
            ev(["type": "message_stop"]),
        ].joined()
        let server = MockServer([.sse(noClaim), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(server.bodies[1]["fallback_credit_token"] == redeemedToken("tok_abc"))
        // no appended assistant turn — identical body (shape-A)
        #expect(server.bodies[1]["messages"] == fableParamsMessages)
    }

    @Test func refusalWithNoCreditTokenPassesAThroughAndLogsAnError() async throws {
        let noToken = streamA.replacingOccurrences(of: #""fallback_credit_token":"[^"]*""#, with: #""fallback_credit_token":null"#,
                                                   options: .regularExpression)
        let server = MockServer([.sse(noToken)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(server.callCount == 1)
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("no fallback_credit_token") == true)
        #expect(seams(events).isEmpty)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "refusal")
    }

    @Test func a400OnThePrefillFormRetriesTheSameHopWithoutThePartial() async throws {
        let server = MockServer([.sse(streamA), errorResponse("bad prefill", 400), .sse(streamB)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        let bodies = server.bodies
        #expect(bodies.count == 3)
        #expect(bodies[1]["messages"]?.arrayValue?.count == 2)
        #expect(bodies[2]["model"] == .string(fableFallbackModel))
        #expect(bodies[2]["fallback_credit_token"] == bodies[1]["fallback_credit_token"])
        #expect(bodies[2]["messages"] == fableParamsMessages)
        // the recovered hop is not a failure: one boundary, a normal completion
        #expect(logs.errors.isEmpty)
        #expect(seams(events).count == 1)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test func aFailedFallbackRequestReplaysTheRefusalAndLogsAnError() async throws {
        let server = MockServer([.sse(streamA), errorResponse("nope", 400), errorResponse("nope", 400)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(server.callCount == 3)
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("HTTP 400") == true)
        #expect(logs.errors.first?.contains(fableFallbackModel) == true)
        // the failed hop leaves no seam; A's suppressed refusal is replayed, token intact, no recommendation
        #expect(seams(events).isEmpty)
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "refusal")
        #expect(delta.delta.stopDetails?.fallbackCreditToken != nil)
        #expect(delta.delta.stopDetails?.recommendedModel == nil)
        #expect(iterations(delta) == ["message:claude-fable-5"])
        #expect(events.last.map(eventType) == "message_stop")
    }

    @Test func aCapacityFailedFallbackRequestStampsTheRecommendedModel() async throws {
        let server = MockServer([.sse(streamA), overloaded()])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("HTTP 529") == true)
        #expect(try firstDelta(events).delta.stopDetails?.recommendedModel == fableFallbackModel)
    }

    @Test func aFallbackRequestThatRaisesReplaysTheRefusal() async throws {
        let server = MockServer([.sse(streamA), .fail(URLError(.networkConnectionLost))])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(logs.errors.count == 1)
        // the raised error reaches the log as the SDK's connection error
        #expect(logs.errors.first?.contains("Connection error.") == true)
        #expect(logs.errors.first?.contains(fableFallbackModel) == true)
        // the stream still closes cleanly: A's refusal is replayed and message_stop follows
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "refusal")
        #expect(events.last.map(eventType) == "message_stop")
    }

    @Test func passThroughPreservesSSEFieldsBeyondEventAndData() async throws {
        let wire = "retry: 1500\nevent: message_start\ndata: "
            + jsonDumps(["type": "message_start", "message": [
                "id": "msg_a", "type": "message", "role": "assistant", "model": "claude-fable-5", "content": [], "stop_reason": nil,
                "stop_sequence": nil, "usage": ["input_tokens": 10, "output_tokens": 1],
            ]])
            + "\n\n" + ": keep-alive\nid: 42\nevent: message_delta\ndata: "
            + jsonDumps(["type": "message_delta", "delta": ["stop_reason": "end_turn", "stop_sequence": nil], "usage": ["output_tokens": 3]])
            + "\n\n" + "event: message_stop\ndata: " + jsonDumps(["type": "message_stop"]) + "\n\n"
        let server = MockServer([.sse(wire)])
        let stream = try await createStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        let raw = try await stream.response.read()
        #expect(String(decoding: raw, as: UTF8.self) == wire)
    }

    @Test func aNonRefusalStreamIsPassedThroughUntouched() async throws {
        let normal = [
            fableMessageStart(),
            ev(["type": "content_block_start", "index": 0, "content_block": ["type": "text", "text": ""]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "text_delta", "text": "Sure!"]]),
            ev(["type": "content_block_stop", "index": 0]),
            ev(["type": "message_delta", "delta": ["stop_reason": "end_turn", "stop_sequence": nil], "usage": ["output_tokens": 3]]),
            ev(["type": "message_stop"]),
        ].joined()
        let server = MockServer([.sse(normal)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(server.callCount == 1)
        #expect(logs.errors.isEmpty)
        #expect(skeleton(events) == [
            "message_start", "start[0] text", "delta[0] text_delta", "stop[0]", "message_delta end_turn iter=[]", "message_stop",
        ])
    }

    @Test func serverSideFallbacksRaiseAnError() async throws {
        let server = MockServer([.sse(streamA)])
        do {
            _ = try await createStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]),
                                       fallbacks: try JSONValue.array([["model": "server-fallback"]]).decode(as: BetaFallbacksParam.self))
            Issue.record("expected an error")
        } catch let e as AnthropicError {
            #expect(e.message.hasPrefix("Sending the `fallbacks:` request param is not supported when using the `BetaRefusalFallbackMiddleware`."))
        }
        #expect(server.callCount == 0)
    }
}

@Suite struct RefusalFallbackStreamingStateTests {
    @Test func pinsTheStateToTheHopThatServed() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let client = try server.client(middleware: [fbMiddleware(fableFallbacks)])
        let state = BetaFallbackState()
        _ = try await state.run { try await collectStream(client) }
        #expect(state.index == 0)
    }

    @Test func aPinnedStateStartsOnThePinnedEntryAndChainsPastIt() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        let client = try server.client(middleware: [fbMiddleware(fableTwoFallbacks)])
        let state = BetaFallbackState()
        state.index = 0
        _ = try await state.run { try await collectStream(client) }
        #expect(server.bodies.count == 2)
        #expect(server.bodies[0]["model"] == .string(fableFallbackModel))
        #expect(server.bodies[1]["model"] == .string(fableSecondModel))
        #expect(state.index == 1)
    }

    @Test func warnsOnceWhenFallingBackWithoutAState() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB), .sse(streamA), .sse(streamB)])
        let logs = LogRecorder()
        let client = try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)])
        _ = try await collectStream(client)
        _ = try await collectStream(client)
        #expect(logs.all.count == 1)
        #expect(logs.all.first?.contains("BetaFallbackState") == true)
    }
}

@Suite struct RefusalFallbackChainTests {
    @Test func aRefusedHopSplicesItsPartialAndChainsToTheNextEntry() async throws {
        let server = MockServer([.sse(streamA), .sse(hopRefusal()), .sse(streamB)])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks)]))
        let bodies = server.bodies
        #expect(bodies.count == 3)
        // hop 1 redeems A's token; hop 2 the fresh token from hop 1's refusal, with hop 1's partial appended
        #expect(bodies[1]["model"] == .string(fableFallbackModel))
        #expect(bodies[2]["model"] == .string(fableSecondModel))
        #expect(bodies[2]["fallback_credit_token"] == redeemedToken("tok_b"))
        #expect(bodies[2]["fallback_credit_token"] != bodies[1]["fallback_credit_token"])
        #expect(bodies[2]["messages"]?[1]?["content"] == .array((bodies[1]["messages"]?[1]?["content"]?.arrayValue ?? []) + [
            ["type": "text", "text": "Partial from B. "],
        ]))
        // one continuous message with monotonic indices across all three streams
        #expect(blockStarts(events) == ["0 thinking", "1 text", "2 fallback", "3 text", "4 fallback", "5 text"])
        #expect(seams(events) == ["claude-fable-5->\(fableFallbackModel)", "\(fableFallbackModel)->\(fableSecondModel)"])
        // hop 1's refusal delta is suppressed; the terminal delta carries every hop
        let deltas = messageDeltas(events)
        #expect(deltas.count == 1)
        #expect(deltas.first?.delta.stopReason?.rawValue == "end_turn")
        #expect(deltas.first.map(iterations) == [
            "message:claude-fable-5", "message:\(fableFallbackModel)", "fallback_message:\(fableSecondModel)",
        ])
        #expect(events.filter { eventType($0) == "message_stop" }.count == 1)
    }

    @Test func aRefusedHopWithoutAPrefillClaimDropsItsPartialFromTheNextRequest() async throws {
        let server = MockServer([.sse(streamA), .sse(hopRefusal("tok_b", false)), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks)]))
        let bodies = server.bodies
        #expect(bodies.count == 3)
        #expect(bodies[2]["fallback_credit_token"] == redeemedToken("tok_b"))
        #expect(bodies[2]["messages"] == bodies[1]["messages"])
    }

    @Test func anHTTPFailedHopIsSkippedAndTheUnredeemedTokenCarriesToTheNextEntry() async throws {
        let server = MockServer([.sse(streamA), overloaded(), .sse(streamB)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks, logs: logs)]))
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("HTTP 529") == true)
        #expect(logs.errors.first?.contains(fableFallbackModel) == true)
        #expect(server.callCount == 3)
        let bodies = server.bodies
        #expect(bodies[2]["model"] == .string(fableSecondModel))
        #expect(bodies[2]["fallback_credit_token"] == bodies[1]["fallback_credit_token"])
        #expect(bodies[2]["messages"] == bodies[1]["messages"])
        // the failed hop was never reached: one boundary, straight to the entry that served
        #expect(seams(events) == ["claude-fable-5->\(fableSecondModel)"])
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "end_turn")
        #expect(iterations(delta) == ["message:claude-fable-5", "fallback_message:\(fableSecondModel)"])
    }

    @Test func aTerminalRefusalWithNoEntriesLeftIsEmittedWithTheFullIterationChain() async throws {
        let server = MockServer([.sse(streamA), .sse(hopRefusal())])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(server.callCount == 2)
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("no fallback entries remain") == true)
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "refusal")
        // the fresh token reaches the client for a manual retry
        #expect(delta.delta.stopDetails?.fallbackCreditToken == "tok_b")
        #expect(iterations(delta) == ["message:claude-fable-5", "fallback_message:\(fableFallbackModel)"])
    }

    @Test func aTokenLessRefusalOnTheFinalHopIsStillLogged() async throws {
        let server = MockServer([.sse(streamA), .sse(hopRefusal(nil))])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("no fallback_credit_token") == true)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "refusal")
    }

    @Test func anEmptyChainPassesTheStreamThroughUntouched() async throws {
        let logs = LogRecorder()
        let middleware = fbMiddleware([], logs: logs)
        let client = try MockServer([]).client()
        var options = FinalRequestOptions(method: "post", url: "/v1/messages?beta=true",
                                          jsonData: ["model": "claude-fable-5", "max_tokens": 1024, "messages": fableParamsMessages])
        options.qualifiers = ["beta": "true"]
        let request = APIRequest(options: options, stream: true, retriesTaken: 0)
        let http = HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(streamA.utf8)),
                                request: HTTPRequest(method: "POST", url: URL(string: testBaseURL)!))
        let response = RawAPIResponse(http: http, options: options, retriesTaken: 0, client: client)
        let calls = WarningBox()
        let out = try await middleware.handle(request) { _ in
            calls.append("call")
            return response
        }
        // with nothing to hop to, the response isn't even wrapped
        #expect(out.http === http)
        #expect(calls.messages.count == 1)
        #expect(logs.errors.isEmpty)
    }

    @Test func aHopWhoseRequestRaisesIsSkippedAndTheUnredeemedTokenCarries() async throws {
        let server = MockServer([.sse(streamA), .fail(URLError(.networkConnectionLost)), .sse(streamB)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks, logs: logs)]))
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("Connection error.") == true)
        #expect(logs.errors.first?.contains(fableFallbackModel) == true)
        #expect(server.callCount == 3)
        let bodies = server.bodies
        #expect(bodies[2]["model"] == .string(fableSecondModel))
        #expect(bodies[2]["fallback_credit_token"] == bodies[1]["fallback_credit_token"])
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "end_turn")
        #expect(iterations(delta) == ["message:claude-fable-5", "fallback_message:\(fableSecondModel)"])
    }
}

let preStreamRefusal = [fableMessageStart(), refusalDelta("tok_abc", false), ev(["type": "message_stop"])].joined()

@Suite struct PreStreamRefusalTests {
    @Test func theServingStartOpensTheWireWithThePrimaryMessageID() async throws {
        let server = MockServer([.sse(preStreamRefusal), .sse(servingStream())])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        // the refused hop's message_start never reaches the client; the serving hop's opens the wire
        let starts = events.compactMap { e -> BetaRawMessageStartEvent? in if case .messageStart(let s) = e { return s } else { return nil } }
        #expect(starts.count == 1)
        #expect(starts.first?.message.model.rawValue == fableFallbackModel)
        #expect(starts.first?.message.id == "msg_a")
        #expect(blockStarts(events) == ["0 fallback", "1 text"])
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "end_turn")
        #expect(iterations(delta) == ["message:claude-fable-5", "fallback_message:\(fableFallbackModel)"])
    }

    @Test func aTokenLessPreStreamRefusalStillRetries() async throws {
        let tokenLess = [fableMessageStart(), refusalDelta(nil), ev(["type": "message_stop"])].joined()
        let server = MockServer([.sse(tokenLess), .sse(servingStream())])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]))
        // nothing had streamed, so the retry fired despite the missing token
        #expect(logs.errors.isEmpty)
        #expect(server.bodies.count == 2)
        #expect(server.bodies[1]["model"] == .string(fableFallbackModel))
        #expect(server.bodies[1]["fallback_credit_token"] == nil)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test func aChainOfPreStreamDeclinesQueuesEverySeamInOrder() async throws {
        let server = MockServer([
            .sse(preStreamRefusal), .sse([fableMessageStart(), refusalDelta("tok_b"), ev(["type": "message_stop"])].joined()),
            .sse(servingStream(fableSecondModel)),
        ])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks)]))
        // serving start first, then both seams, then the serving content
        guard case .messageStart(let start)? = events.first else {
            Issue.record("expected message_start first")
            return
        }
        #expect(start.message.id == "msg_a")
        #expect(blockStarts(events) == ["0 fallback", "1 fallback", "2 text"])
        #expect(seams(events) == ["claude-fable-5->\(fableFallbackModel)", "\(fableFallbackModel)->\(fableSecondModel)"])
        #expect(iterations(try firstDelta(events)) == [
            "message:claude-fable-5", "message:\(fableFallbackModel)", "fallback_message:\(fableSecondModel)",
        ])
    }
}

@Suite struct SplicedInputTransformationsTests {
    @Test func theSuppressedStartsListIsForwardedOnTheTerminal() async throws {
        let server = MockServer([.sse(streamA), .sse(transformingStream())])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(events.filter { eventType($0) == "message_start" }.count == 1)
        #expect(try JSONValue.from(try firstDelta(events))["input_transformations"] == transforms)
    }

    @Test func aListAlreadyOnTheDeltaIsKept() async throws {
        let server = MockServer([.sse(streamA), .sse(transformingStream(deltaTransformations: []))])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(try JSONValue.from(try firstDelta(events))["input_transformations"] == [])
    }

    @Test func theListIsForwardedOnADegradedChainsReplayedRefusal() async throws {
        let server = MockServer([.sse(streamA), .sse(transformingStream(terminal: refusalDelta("tok_b", false))), errorResponse("down", 503)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks, logs: logs)]))
        #expect(server.callCount == 3)
        #expect(logs.errors.count == 1)
        #expect(events.filter { eventType($0) == "message_start" }.count == 1)
        let delta = try firstDelta(events)
        #expect(delta.delta.stopReason?.rawValue == "refusal")
        #expect(try JSONValue.from(delta)["input_transformations"] == transforms)
        #expect(events.last.map(eventType) == "message_stop")
    }

    @Test func anEmittedStartLeavesTheDeltaUntouched() async throws {
        let server = MockServer([.sse(preStreamRefusal), .sse(transformingStream())])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        guard case .messageStart(let start)? = events.first(where: { eventType($0) == "message_start" }) else {
            Issue.record("expected a message_start")
            return
        }
        #expect(try JSONValue.from(start.message)["input_transformations"] == transforms)
        #expect(try JSONValue.from(try firstDelta(events))["input_transformations"] == nil)
    }
}

@Suite struct HistorySeamReplayTests {
    @Test func aHistorySeamWithoutAStateDoesNotPin() async throws {
        let server = MockServer([.sse(servingStream("claude-fable-5"))])
        let messages = [
            betaUserMessage("hello"),
            betaMessageParam(["role": "assistant", "content": [
                ["type": "fallback", "from": ["model": "claude-fable-5"], "to": ["model": .string(fableFallbackModel)]],
                ["type": "text", "text": "earlier turn"],
            ]]),
            betaUserMessage("and again?"),
        ]
        _ = try await collect(try await createStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks)]), messages: messages))
        #expect(server.bodies.count == 1)
        // no state, no pin — the first request goes to the original model
        #expect(server.bodies[0]["model"] == "claude-fable-5")
        // the seam block is the middleware's own marker — filtered off the wire
        #expect(server.bodies[0]["messages"]?[1]?["content"] == [["type": "text", "text": "earlier turn"]])
        #expect(server.header("anthropic-beta") == ["fallback-credit-2026-07-01"])
    }

    @Test func aSeamOnlyAssistantTurnIsDroppedWhole() async throws {
        let server = MockServer([.sse(servingStream("claude-fable-5"))])
        let messages = [
            betaUserMessage("hello"),
            betaMessageParam(["role": "assistant", "content": [
                ["type": "fallback", "from": ["model": "claude-fable-5"], "to": ["model": .string(fableFallbackModel)]],
            ]]),
            betaUserMessage("and again?"),
        ]
        _ = try await collect(try await createStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]), messages: messages))
        #expect(server.bodies.count == 1)
        #expect(server.bodies[0]["messages"] == [["role": "user", "content": "hello"], ["role": "user", "content": "and again?"]])
        #expect(server.bodies[0]["model"] == "claude-fable-5")
        #expect(server.bodies[0]["max_tokens"] == 1024)
        #expect(server.header("anthropic-beta") == ["fallback-credit-2026-07-01"])
    }
}

@Suite struct RefusalFallbackStreamingMiscTests {
    @Test func entryOverridesApplyToTheHopRequest() async throws {
        let server = MockServer([.sse(streamA), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware([BetaFallbackParam(model: ModelParam(rawValue: fableFallbackModel), maxTokens: 32)])]))
        #expect(server.bodies[0]["max_tokens"] == 1024)
        #expect(server.bodies[1]["max_tokens"] == 32)
        #expect(server.bodies[1]["model"] == .string(fableFallbackModel))
    }

    @Test func closingTheStreamMidPassthroughTearsDownWithoutAFallbackRequest() async throws {
        let server = MockServer([.sse(streamA)])
        let stream = try await createStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        var seen = 0
        for try await _ in stream {
            seen += 1
            if seen == 2 { break }
        }
        stream.close()
        // the splice never reached A's refusal, so no hop request was issued
        #expect(server.callCount == 1)
        #expect(stream.response.isClosed)
    }
}

let toolUseID = "srvtoolu_01"

@Suite struct ToolUseRefusalTests {
    @Test func refusalAfterACompletedServerTool() async throws {
        let a = [
            fableMessageStart(),
            ev(["type": "content_block_start", "index": 0, "content_block": ["type": "thinking", "thinking": "", "signature": ""]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "thinking_delta", "thinking": "let me look this up"]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "signature_delta", "signature": "sig=="]]),
            ev(["type": "content_block_stop", "index": 0]),
            ev(["type": "content_block_start", "index": 1,
                "content_block": ["type": "server_tool_use", "id": .string(toolUseID), "name": "web_search", "input": [:]]]),
            ev(["type": "content_block_delta", "index": 1, "delta": ["type": "input_json_delta", "partial_json": #"{"query":"solar eclipse"}"#]]),
            ev(["type": "content_block_stop", "index": 1]),
            ev(["type": "content_block_start", "index": 2, "content_block": [
                "type": "web_search_tool_result", "tool_use_id": .string(toolUseID),
                "content": [["type": "web_search_result", "url": "https://example.com", "title": "x", "encrypted_content": "e", "page_age": nil]],
            ]]),
            ev(["type": "content_block_stop", "index": 2]),
            ev(["type": "content_block_start", "index": 3, "content_block": ["type": "text", "text": ""]]),
            ev(["type": "content_block_delta", "index": 3, "delta": ["type": "text_delta", "text": "Based on that, "]]),
            ev(["type": "content_block_stop", "index": 3]),
            refusalDelta(),
            ev(["type": "message_stop"]),
        ].joined()
        let server = MockServer([.sse(a), .sse(streamB)])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(blockStarts(events) == ["0 thinking", "1 server_tool_use", "2 web_search_tool_result", "3 text", "4 fallback", "5 text"])
        let appended = server.bodies[1]["messages"]?[1]
        #expect(appended?["role"] == "assistant")
        #expect(appended?["content"]?.arrayValue?.map { $0["type"] } == ["thinking", "server_tool_use", "web_search_tool_result", "text"])
        // the tool input is the parsed input_json_delta payload, not the empty `{}` from content_block_start
        #expect(appended?["content"]?[1] == [
            "type": "server_tool_use", "id": .string(toolUseID), "name": "web_search", "input": ["query": "solar eclipse"],
        ])
        #expect(appended?["content"]?[2]?["tool_use_id"] == .string(toolUseID))
    }

    @Test func fullFixtureToolWire() async throws {
        let server = MockServer([.sse(streamAToolFixture), .sse(streamB)])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(blockStarts(events) == ["0 server_tool_use", "1 web_search_tool_result", "2 text", "3 fallback", "4 text"])
        let appended = server.bodies[1]["messages"]?[1]
        #expect(appended?["content"]?.arrayValue?.map { $0["type"] } == ["server_tool_use", "web_search_tool_result", "text"])
        #expect(appended?["content"]?[0] == [
            "type": "server_tool_use", "id": "srvtoolu_fixture_a_0001", "name": "web_search",
            "input": ["query": "solar eclipse viewing safety news 2026"],
        ])
        #expect(appended?["content"]?[1]?["tool_use_id"] == "srvtoolu_fixture_a_0001")
        #expect(appended?["content"]?[1]?["type"] == "web_search_tool_result")
    }

    @Test func midLoopRefusalEndingInThinkingStripsTheTrailingThinkingBlock() async throws {
        let a = [
            fableMessageStart(),
            ev(["type": "content_block_start", "index": 0,
                "content_block": ["type": "server_tool_use", "id": .string(toolUseID), "name": "web_search", "input": [:]]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "input_json_delta", "partial_json": #"{"query":"x"}"#]]),
            ev(["type": "content_block_stop", "index": 0]),
            ev(["type": "content_block_start", "index": 1,
                "content_block": ["type": "web_search_tool_result", "tool_use_id": .string(toolUseID), "content": []]]),
            ev(["type": "content_block_stop", "index": 1]),
            ev(["type": "content_block_start", "index": 2, "content_block": ["type": "thinking", "thinking": "", "signature": ""]]),
            ev(["type": "content_block_delta", "index": 2, "delta": ["type": "thinking_delta", "thinking": "hmm"]]),
            ev(["type": "content_block_delta", "index": 2, "delta": ["type": "signature_delta", "signature": "sig=="]]),
            ev(["type": "content_block_stop", "index": 2]),
            refusalDelta(),
            ev(["type": "message_stop"]),
        ].joined()
        let server = MockServer([.sse(a), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        let b = server.bodies[1]
        #expect(b["fallback_credit_token"] == redeemedToken("tok_abc"))
        #expect(b["messages"]?[1]?["role"] == "assistant")
        #expect(b["messages"]?[1]?["content"]?.arrayValue?.map { $0["type"] } == ["server_tool_use", "web_search_tool_result"])
    }

    @Test func aPartialOfOnlyThinkingFallsBackToTheSameBodyForm() async throws {
        let a = [
            fableMessageStart(),
            ev(["type": "content_block_start", "index": 0, "content_block": ["type": "thinking", "thinking": "", "signature": ""]]),
            ev(["type": "content_block_delta", "index": 0, "delta": ["type": "thinking_delta", "thinking": "hmm"]]),
            ev(["type": "content_block_stop", "index": 0]),
            refusalDelta(),
            ev(["type": "message_stop"]),
        ].joined()
        let server = MockServer([.sse(a), .sse(streamB)])
        _ = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]))
        #expect(server.bodies[1]["fallback_credit_token"] == redeemedToken("tok_abc"))
        #expect(server.bodies[1]["messages"] == fableParamsMessages)
    }
}

// No prefill claim, so a 400 on the hop is a plain failure rather than a rejected prefill.
let refusalWithoutAPrefillClaim = [fableMessageStart(), refusalDelta("tok_abc", false), ev(["type": "message_stop"])].joined()

let streamingFailedHopsThatAreNotResent: [(BetaFallbackParam, BetaMessageCreateParamsBase.Speed?, Int)] = [
    (BetaFallbackParam(model: ModelParam(rawValue: fableFallbackModel), speed: "fast"), .fast, 429),
    (fallback(fableFallbackModel), nil, 429),
    (fallback(fableFallbackModel), .standard, 429),
    (fallback(fableFallbackModel), .fast, 400),
    (fallback(fableFallbackModel), .fast, 500),
]

/// The statuses one entry's requests draw before it serves, with the `speed` each request carries
/// and whether it has the refused model's partial output appended.
let hopsThatAlsoDropThePartial: [([Int], [(String?, Bool)])] = [
    ([429, 400], [("fast", true), (nil, true), (nil, false)]),  // rate-limited first
    ([400, 429], [("fast", true), ("fast", false), (nil, false)]),  // partial rejected first
]

@Suite struct RefusalFallbackStreamingRateLimitedFastHopTests {
    @Test(arguments: [429, 529])
    func isResentOnceWithoutSpeed(_ status: Int) async throws {
        let rejected = ClosingBody()
        let server = MockServer([.sse(streamA), rejected.reply(status), .sse(streamB)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks, logs: logs)]), speed: .fast)
        let bodies = server.bodies
        #expect(bodies.map { [$0["model"], $0["speed"]] } == [
            ["claude-fable-5", "fast"], [.string(fableFallbackModel), "fast"], [.string(fableFallbackModel), nil],
        ])
        #expect(bodies[2]["fallback_credit_token"]?["mode"] == "best_effort")
        #expect(bodies[2] == withoutSpeed(bodies[1]))
        #expect(rejected.closes == 1)
        #expect(logs.resendWarnings.count == 1)
        // the recovered hop is not a failure: one boundary, a normal completion
        #expect(logs.errors.isEmpty)
        #expect(blockStarts(events) == ["0 thinking", "1 text", "2 fallback", "3 text"])
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test(arguments: streamingFailedHopsThatAreNotResent.indices)
    func anyOtherFailedHopIsNotResent(_ i: Int) async throws {
        let (entry, speed, status) = streamingFailedHopsThatAreNotResent[i]
        let server = MockServer([.sse(refusalWithoutAPrefillClaim), errorResponse("nope", status), .sse(servingStream())])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware([entry])]), speed: speed.map { .some($0) })
        #expect(server.callCount == 2)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "refusal")
    }

    @Test(arguments: hopsThatAlsoDropThePartial.indices)
    func theRetryWithoutThePartialDoesNotGoBackToFast(_ i: Int) async throws {
        let (statuses, hopRequests) = hopsThatAlsoDropThePartial[i]
        let server = MockServer([.sse(streamA)] + statuses.map { errorResponse("nope", $0) } + [.sse(streamB)])
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]), speed: .fast)
        let hops = Array(server.bodies.dropFirst())
        #expect(hops.map { "\($0["speed"]?.stringValue ?? "None") \($0["messages"]?.arrayValue?.count == 2)" }
            == hopRequests.map { "\($0.0 ?? "None") \($0.1)" })
        #expect(hops.map { $0["speed"] != nil } == hopRequests.map { $0.0 != nil })
        #expect(Set(hops.map { $0["model"] }) == [.string(fableFallbackModel)])
        #expect(hops.allSatisfy { $0["fallback_credit_token"] == hops[0]["fallback_credit_token"] })
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test func aResendThatIsRateLimitedTooFailsTheHop() async throws {
        let server = MockServer([.sse(streamA), errorResponse("slow down", 429), errorResponse("slow down", 429), .sse(streamB)])
        let logs = LogRecorder()
        let events = try await collectStream(try server.client(middleware: [fbMiddleware(fableTwoFallbacks, logs: logs)]), speed: .fast)
        // the failed hop is skipped as usual, and the next entry starts from the original `speed`
        let bodies = server.bodies
        #expect(bodies.map { [$0["model"], $0["speed"]] } == [
            ["claude-fable-5", "fast"], [.string(fableFallbackModel), "fast"], [.string(fableFallbackModel), nil], [.string(fableSecondModel), "fast"],
        ])
        #expect(bodies[3]["fallback_credit_token"] == bodies[1]["fallback_credit_token"])
        #expect(logs.errors.count == 1)
        #expect(logs.errors.first?.contains("HTTP 429") == true)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test func aRequestThatStartsOnThePinnedEntryIsResentWithoutSpeed() async throws {
        let rejected = ClosingBody()
        let server = MockServer([rejected.reply(429), .sse(servingStream())])
        let client = try server.client(middleware: [fbMiddleware(fableTwoFallbacks)])
        let state = BetaFallbackState()
        state.index = 0
        let events = try await state.run { try await collectStream(client, speed: .fast) }
        let bodies = server.bodies
        #expect(bodies.map { [$0["model"], $0["speed"]] } == [[.string(fableFallbackModel), "fast"], [.string(fableFallbackModel), nil]])
        #expect(bodies[1] == withoutSpeed(bodies[0]))
        #expect(rejected.closes == 1)
        #expect(state.index == 0)
        #expect(try firstDelta(events).delta.stopReason?.rawValue == "end_turn")
    }

    @Test func theOriginalRequestIsNotResent() async throws {
        let server = MockServer([errorResponse("slow down", 429), .sse(servingStream())])
        await #expect(throws: APIStatusError.self) {
            _ = try await createStream(try server.client(middleware: [fbMiddleware(fableFallbacks)]), speed: .fast)
        }
        #expect(server.callCount == 1)
    }
}
