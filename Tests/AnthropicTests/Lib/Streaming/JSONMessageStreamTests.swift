import Foundation
import Testing
@testable import Anthropic

// `messages.createStreaming(body:)` / `beta.messages.createStreaming(body:)`, `JSONMessageStream` and
// `JSONMessageAccumulator`; lenient stream decoding and typed `error` events. No upstream test covers these: the
// Python SDK's models keep unknown fields, so it needs no JSON-keeping path.

/// An SSE body from `(event, data)` pairs.
private func sse(_ events: [(String, String)]) -> String {
    events.map { "event: \($0.0)\ndata: \($0.1)\n\n" }.joined()
}

/// `data` in chunks cut inside every multi-byte UTF-8 character (after its first byte), as a network may deliver it.
private func splitInsideCharacters(_ data: Data) -> [Data] {
    let bytes = [UInt8](data)
    var chunks: [Data] = []
    var start = 0
    for i in bytes.indices where i > start && bytes[i] & 0xC0 == 0x80 && bytes[i - 1] >= 0xC0 {
        chunks.append(Data(bytes[start..<i]))
        start = i
    }
    chunks.append(Data(bytes[start...]))
    return chunks
}

private func sseReply(_ events: [(String, String)], splitCharacters: Bool = false) -> MockReply {
    let data = Data(sse(events).utf8)
    let chunks = splitCharacters ? splitInsideCharacters(data) : [data]
    return .handler { request in
        HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream", "request-id": "req_1"],
                     stream: ByteStream { c in
                         for chunk in chunks { c.yield(chunk) }
                         c.finish()
                     }, request: request)
    }
}

private func text(_ data: Data?) -> String { String(decoding: data ?? Data(), as: UTF8.self) }

/// A beta response with an unknown field at each level, a `null`, keys out of alphabetical order, a block type and a
/// delta type and an event type this SDK does not know, multi-byte text, and a tool input in parts.
let jsonStreamScript: [(String, String)] = [
    ("message_start", #"{"type":"message_start","message":{"model":"claude-opus-5-5","id":"msg_1","type":"message","role":"assistant","content":[],"stop_reason":null,"stop_sequence":null,"usage":{"output_tokens":1,"input_tokens":10,"future_usage":{"z":1,"a":2}},"future_top":null}}"#),
    ("ping", #"{"type":"ping"}"#),
    ("content_block_start", #"{"type":"content_block_start","index":0,"content_block":{"type":"text","text":"","citations":null,"zz_unknown":{"b":1,"a":[1.50,null]}}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Héllo "}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"wörld ✓"}}"#),
    ("content_block_stop", #"{"type":"content_block_stop","index":0}"#),
    ("content_block_start", #"{"type":"content_block_start","index":1,"content_block":{"type":"future_block","data":{"q":1,"p":[]}}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":1,"delta":{"type":"future_delta","more":"x"}}"#),
    ("content_block_stop", #"{"type":"content_block_stop","index":1}"#),
    ("future_event", #"{"type":"future_event","payload":{"x":1}}"#),
    ("content_block_start", #"{"type":"content_block_start","index":2,"content_block":{"type":"tool_use","id":"toolu_1","name":"get_weather","input":{},"caller":{"type":"direct"}}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":2,"delta":{"type":"input_json_delta","partial_json":""}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":2,"delta":{"type":"input_json_delta","partial_json":"{\"zip\": \"9"}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":2,"delta":{"type":"input_json_delta","partial_json":"4103\", \"city\": \"São "}}"#),
    ("content_block_delta", #"{"type":"content_block_delta","index":2,"delta":{"type":"input_json_delta","partial_json":"Paulo\", \"units\": {\"temp\": \"c\", \"a\": 1.0}}"}}"#),
    ("content_block_stop", #"{"type":"content_block_stop","index":2}"#),
    ("message_delta", #"{"type":"message_delta","delta":{"stop_reason":"tool_use","stop_sequence":null,"future_delta_field":"x"},"usage":{"output_tokens":42,"cache_read_input_tokens":null}}"#),
    ("message_stop", #"{"type":"message_stop"}"#),
]

let jsonStreamContent = #"[{"type":"text","text":"Héllo wörld ✓","citations":null,"zz_unknown":{"b":1,"a":[1.50,null]}},{"type":"future_block","data":{"q":1,"p":[]}},{"type":"tool_use","id":"toolu_1","name":"get_weather","input":{"zip":"94103","city":"São Paulo","units":{"temp":"c","a":1.0}},"caller":{"type":"direct"}}]"#

let jsonStreamMessage = #"{"model":"claude-opus-5-5","id":"msg_1","type":"message","role":"assistant","content":"# + jsonStreamContent
    + #","stop_reason":"tool_use","stop_sequence":null,"usage":{"output_tokens":42,"input_tokens":10,"future_usage":{"z":1,"a":2}},"future_top":null,"future_delta_field":"x"}"#

@Suite struct JSONMessageStreamTests {
    @Test func theMessageIsBuiltFromTheEventsJSONAndReplaysUnchanged() async throws {
        let server = LibMockServer([sseReply(jsonStreamScript, splitCharacters: true), sseReply(jsonStreamScript)])
        let client = try server.client()
        var history: [RawJSON] = [["role": "user", "content": "Weather in São Paulo?"]]
        let stream = try await client.beta.messages.createStreaming(
            body: ["model": "claude-opus-5-5", "max_tokens": 1024, "messages": .array(history)], betas: ["fine-grained-tool-streaming-2025-05-14"])
        var events: [JSONStreamEvent<BetaRawMessageStreamEvent>] = []
        for try await event in stream { events.append(event) }

        #expect(events.map(\.name) == jsonStreamScript.map(\.0).filter { $0 != "ping" })
        // Each event's JSON is its data as received.
        #expect(events.map(\.json.serializedString) == jsonStreamScript.filter { $0.0 != "ping" }.map(\.1))
        #expect(stream.isComplete)
        #expect(stream.requestID == "req_1")
        #expect(try await stream.getFinalMessage().serializedString == jsonStreamMessage)
        #expect(stream.messageParam?.serializedString == #"{"role":"assistant","content":"# + jsonStreamContent + "}")

        // The typed events, best effort: an unknown block, delta or event type decodes as `unknown` without an error.
        guard case .contentBlockStart(let start) = events[5].event, case .unknown(let block) = start.contentBlock else {
            Issue.record("expected an unknown content block, got \(events[5].event)")
            return
        }
        #expect(block["data"] == ["q": 1, "p": []])
        guard case .contentBlockDelta(let delta) = events[6].event, case .unknown = delta.delta else {
            Issue.record("expected an unknown delta, got \(events[6].event)")
            return
        }
        guard case .unknown(let unknownEvent) = events[8].event else {
            Issue.record("expected an unknown event, got \(events[8].event)")
            return
        }
        #expect(unknownEvent["payload"] == ["x": 1])
        #expect(events.allSatisfy { $0.decodingError == nil })
        if case .contentBlockDelta(let d) = events[2].event, case .textDelta(let t) = d.delta { #expect(t.text == "Héllo ") } else {
            Issue.record("expected a text delta")
        }

        // The next request carries the reply exactly as received.
        history.append(try #require(stream.messageParam))
        history.append(["role": "user", "content": [["type": "tool_result", "tool_use_id": "toolu_1", "content": "22°C"]]])
        let next = try await client.beta.messages.createStreaming(
            body: ["model": "claude-opus-5-5", "max_tokens": 1024, "messages": .array(history)], betas: ["fine-grained-tool-streaming-2025-05-14"])
        try await next.untilDone()
        #expect(text(server.requests[0].body) == #"{"model":"claude-opus-5-5","max_tokens":1024,"messages":[{"role":"user","content":"Weather in São Paulo?"}],"stream":true}"#)
        #expect(text(server.requests[1].body)
            == #"{"model":"claude-opus-5-5","max_tokens":1024,"messages":[{"role":"user","content":"Weather in São Paulo?"},{"role":"assistant","content":"#
            + jsonStreamContent + #"},{"role":"user","content":[{"type":"tool_result","tool_use_id":"toolu_1","content":"22°C"}]}],"stream":true}"#)
        #expect(server.requests[1].headers["anthropic-beta"] == "fine-grained-tool-streaming-2025-05-14")
        #expect(server.requests[1].url.path == "/v1/messages")
    }

    @Test func theTypedStreamOfTheSameResponseAgrees() async throws {
        // The typed accumulator and the JSON one agree on what both model.
        let server = LibMockServer([sseReply(jsonStreamScript)])
        let stream = try await server.client().beta.messages.stream(
            maxTokens: 1024, messages: [betaUserMessage("Weather?")], model: "claude-opus-5-5")
        let message = try await stream.getFinalMessage().message
        #expect(message.stopReason == .toolUse)
        #expect(message.usage.outputTokens == 42)
        guard message.content.count == 3, case .text(let t) = message.content[0], case .unknown = message.content[1],
              case .toolUse(let tool) = message.content[2]
        else {
            Issue.record("unexpected content \(message.content)")
            return
        }
        #expect(t.text == "Héllo wörld ✓")
        #expect(tool.input == ["zip": "94103", "city": "São Paulo", "units": ["temp": "c", "a": 1.0]])
        #expect(try RawJSON.parse(jsonStreamMessage)["content"]?[2]?["input"]?.jsonValue == .object(tool.input))
    }

    @Test func anOrderedBodyKeepsItsOrderThroughMiddlewareAndExtraBody() async throws {
        let middleware = MiddlewareFunction { request, next in
            guard case .object(var body)? = request.json else { throw ValueError("expected an object body") }
            body["max_tokens"] = 2048
            body["metadata"] = ["user_id": "u"]
            return try await next(request.copy(body: .object(body)))
        }
        let server = LibMockServer([sseReply(jsonStreamScript)])
        let body = try RawJSON.parse(#"{"model":"m","max_tokens":1,"messages":[{"role":"user","content":[{"type":"text","text":"x","z":1.50,"a":null}]}]}"#)
        let stream = try await server.client(middleware: [middleware]).beta.messages.createStreaming(body: body, extraBody: ["service_tier": "auto"])
        try await stream.untilDone()
        #expect(text(server.requests[0].body)
            == #"{"model":"m","max_tokens":2048,"messages":[{"role":"user","content":[{"type":"text","text":"x","z":1.50,"a":null}]}],"stream":true,"metadata":{"user_id":"u"},"service_tier":"auto"}"#)
    }

    @Test func theGAMessagesAPIToo() async throws {
        let script = [
            ("message_start", #"{"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[],"stop_reason":null,"usage":{"input_tokens":1,"output_tokens":0}}}"#),
            ("content_block_start", #"{"type":"content_block_start","index":0,"content_block":{"type":"thinking","thinking":"","signature":""}}"#),
            ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"thinking_delta","thinking":"Hmm, "}}"#),
            ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"thinking_delta","thinking":"yes."}}"#),
            ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"signature_delta","signature":"sig=="}}"#),
            ("content_block_stop", #"{"type":"content_block_stop","index":0}"#),
            ("content_block_start", #"{"type":"content_block_start","index":1,"content_block":{"type":"text","text":"","citations":null}}"#),
            ("content_block_delta", #"{"type":"content_block_delta","index":1,"delta":{"type":"citations_delta","citation":{"type":"char_location","cited_text":"a","document_index":0,"document_title":null,"start_char_index":0,"end_char_index":1}}}"#),
            ("content_block_delta", #"{"type":"content_block_delta","index":1,"delta":{"type":"text_delta","text":"Yes"}}"#),
            ("content_block_stop", #"{"type":"content_block_stop","index":1}"#),
            ("message_delta", #"{"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":7}}"#),
            ("message_stop", #"{"type":"message_stop"}"#),
        ]
        let server = LibMockServer([sseReply(script)])
        let stream = try await server.client().messages.createStreaming(
            body: ["model": "claude-opus-5-5", "max_tokens": 16, "messages": [["role": "user", "content": "Hi"]]])
        var typed: [RawMessageStreamEvent] = []
        for try await event in stream { typed.append(event.event) }
        #expect(typed.count == script.count)
        if case .messageStart(let start) = typed[0] { #expect(start.message.id == "msg_1") } else { Issue.record("expected message_start") }
        #expect(stream.message?.serializedString
            == #"{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[{"type":"thinking","thinking":"Hmm, yes.","signature":"sig=="},{"type":"text","text":"Yes","citations":[{"type":"char_location","cited_text":"a","document_index":0,"document_title":null,"start_char_index":0,"end_char_index":1}]}],"stop_reason":"end_turn","usage":{"input_tokens":1,"output_tokens":7},"stop_sequence":null}"#)
        #expect(server.requests[0].headers["anthropic-beta"] == nil)
    }

    @Test func aStreamCutShortIsIncompleteWithThePartialMessage() async throws {
        let script = Array(jsonStreamScript.prefix(13))  // stops inside the tool input
        let server = LibMockServer([sseReply(script)])
        let stream = try await server.client().beta.messages.createStreaming(body: ["model": "m", "max_tokens": 1, "messages": []])
        let message = try await stream.getFinalMessage()
        #expect(!stream.isComplete)
        #expect(stream.accumulator.partialInputJSON(at: 2) == #"{"zip": "9"#)
        // A tool input still arriving is parsed as far as it goes.
        #expect(message["content"]?[2]?["input"] == [:])
        #expect(message["stop_reason"] == .null)
        #expect(message["content"]?[0]?["text"] == "Héllo wörld ✓")
    }

    @Test func aToolInputThatIsNotJSONFailsAtItsBlockStop() async throws {
        let script = Array(jsonStreamScript.prefix(11)) + [
            ("content_block_delta", #"{"type":"content_block_delta","index":2,"delta":{"type":"input_json_delta","partial_json":"{\"a\": nope}"}}"#),
            ("content_block_stop", #"{"type":"content_block_stop","index":2}"#),
        ]
        let server = LibMockServer([sseReply(script)])
        let stream = try await server.client().beta.messages.createStreaming(body: ["model": "m", "max_tokens": 1, "messages": []])
        await #expect(throws: ValueError.self) { try await stream.untilDone() }
        #expect(stream.response.isClosed)
    }

    @Test func aBodyThatIsNotAnObjectIsRefused() async throws {
        let client = try LibMockServer([]).client()
        await #expect(throws: ArgumentTypeError.self) { _ = try await client.beta.messages.createStreaming(body: []) }
    }
}

/// R4: an event whose fields drifted from the schema does not end the stream.
@Suite struct LenientStreamDecodingTests {
    static let drifted: [(String, String)] = [
        ("message_start", #"{"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[],"stop_reason":null,"usage":{"input_tokens":3,"output_tokens":1}}}"#),
        // `text` is required
        ("content_block_start", #"{"type":"content_block_start","index":0,"content_block":{"type":"text","citations":null}}"#),
        ("content_block_delta", #"{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}"#),
        ("content_block_stop", #"{"type":"content_block_stop","index":0}"#),
        // an iteration's cache counts are required numbers
        ("message_delta", #"{"type":"message_delta","delta":{"stop_reason":"end_turn","stop_sequence":null},"usage":{"output_tokens":5,"iterations":[{"type":"message","input_tokens":3,"output_tokens":5,"cache_creation_input_tokens":null,"cache_read_input_tokens":null}]}}"#),
        ("message_stop", #"{"type":"message_stop"}"#),
    ]

    @Test func theJSONStreamHandsOutDriftedEventsWithTheirJSON() async throws {
        let server = LibMockServer([sseReply(Self.drifted)])
        let stream = try await server.client().beta.messages.createStreaming(body: ["model": "m", "max_tokens": 1, "messages": []])
        var events: [JSONStreamEvent<BetaRawMessageStreamEvent>] = []
        for try await event in stream { events.append(event) }
        #expect(events.count == 6)
        for i in [1, 4] {
            guard case .unknown(let json) = events[i].event else {
                Issue.record("expected event \(i) to be unknown, got \(events[i].event)")
                continue
            }
            #expect(json == events[i].json.jsonValue)
            #expect(events[i].decodingError is DecodingError)
        }
        #expect(events[2].decodingError == nil)
        #expect(stream.isComplete)
        #expect(stream.message?.serializedString
            == #"{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[{"type":"text","citations":null,"text":"Hi"}],"stop_reason":"end_turn","usage":{"input_tokens":3,"output_tokens":5,"iterations":[{"type":"message","input_tokens":3,"output_tokens":5,"cache_creation_input_tokens":null,"cache_read_input_tokens":null}]},"stop_sequence":null}"#)
    }

    @Test func theTypedStreamHandsThemOutAsUnknown() async throws {
        let server = LibMockServer([sseReply(Self.drifted)])
        let stream = try await server.client().beta.messages.createStreaming(
            maxTokens: 1, messages: [betaUserMessage("Hi")], model: "claude-opus-5-5")
        var unknown = 0
        var count = 0
        for try await event in stream {
            count += 1
            if case .unknown = event { unknown += 1 }
        }
        #expect(count == 6 && unknown == 2)
    }

    @Test func theTypedAccumulatorKeepsTheBlockAndTheStopReason() async throws {
        let server = LibMockServer([sseReply(Self.drifted)])
        let stream = try await server.client().beta.messages.stream(maxTokens: 1, messages: [betaUserMessage("Hi")], model: "claude-opus-5-5")
        let message = try await stream.getFinalMessage().message
        #expect(message.content.count == 1)
        if case .unknown(let block) = message.content.first { #expect(block["type"] == "text") } else { Issue.record("expected a placeholder") }
        #expect(message.stopReason == .endTurn)
        #expect(message.usage.outputTokens == 5)
        #expect(stream.messageComplete)
    }

    @Test func theGATypedAccumulatorToo() async throws {
        let drifted = Self.drifted.map { ($0.0, $0.1.replacingOccurrences(of: #","iterations":[{"type":"message","input_tokens":3,"output_tokens":5,"cache_creation_input_tokens":null,"cache_read_input_tokens":null}]"#, with: #","input_tokens":"three""#)) }
        let server = LibMockServer([sseReply(drifted)])
        let stream = try await server.client().messages.stream(maxTokens: 1, messages: [userMessage("Hi")], model: "claude-opus-5-5")
        let message = try await stream.getFinalMessage().message
        if case .unknown = message.content.first {} else { Issue.record("expected a placeholder, got \(message.content)") }
        #expect(message.stopReason == .endTurn)
        #expect(message.usage.outputTokens == 5)
    }

    @Test func dataThatIsNotJSONStillFails() async throws {
        let server = LibMockServer([sseReply([("message_start", "{not json")])])
        let stream = try await server.client().beta.messages.createStreaming(body: ["model": "m", "max_tokens": 1, "messages": []])
        await #expect(throws: APIResponseValidationError.self) { try await stream.untilDone() }
        let typed = try await LibMockServer([sseReply([("message_start", "{not json")])]).client().beta.messages.createStreaming(
            maxTokens: 1, messages: [betaUserMessage("Hi")], model: "claude-opus-5-5")
        await #expect(throws: APIResponseValidationError.self) { for try await _ in typed {} }
    }
}

/// R5: an `error` event ends the stream with the typed error of its `error.type`.
@Suite struct StreamErrorEventTests {
    static func script(_ type: String, _ message: String) -> [(String, String)] {
        Array(jsonStreamScript.prefix(4)) + [("error", #"{"type":"error","error":{"type":"\#(type)","message":"\#(message)"}}"#)]
    }

    @Test func anOverloadedErrorMidStreamIsAnOverloadedError() async throws {
        let server = LibMockServer([sseReply(Self.script("overloaded_error", "Overloaded"))])
        let stream = try await server.client(maxRetries: 2).beta.messages.createStreaming(body: ["model": "m", "max_tokens": 1, "messages": []])
        do {
            try await stream.untilDone()
            Issue.record("expected an OverloadedError")
        } catch let e as OverloadedError {
            #expect(e.statusCode == 529)
            #expect(e.response.statusCode == 200)
            #expect(e.type == .overloadedError)
            #expect(e.errorMessage == "Overloaded")
            #expect(e.message.contains("Overloaded"))
            #expect(e.requestID == "req_1")
        }
        // What arrived before the error is kept, and the stream is not complete.
        #expect(!stream.isComplete)
        #expect(stream.message?["content"]?[0]?["text"] == "Héllo ")
        // A stream that failed after it began is not retried.
        #expect(server.callCount == 1)
    }

    @Test func eachErrorTypeMapsToItsClass() async throws {
        let cases: [(String, Int, (any Error) -> Bool)] = [
            ("rate_limit_error", 429, { $0 is RateLimitError }),
            ("api_error", 500, { $0 is InternalServerError }),
            ("invalid_request_error", 400, { $0 is BadRequestError }),
            ("authentication_error", 401, { $0 is AuthenticationError }),
            ("permission_error", 403, { $0 is PermissionDeniedError }),
            ("not_found_error", 404, { $0 is NotFoundError }),
            ("request_too_large", 413, { $0 is RequestTooLargeError }),
            ("timeout_error", 504, { $0 is InternalServerError }),
            ("billing_error", 402, { type(of: $0) == APIStatusError.self }),
            ("future_error", 200, { type(of: $0) == APIStatusError.self }),
        ]
        for (type, status, isExpected) in cases {
            // the typed stream, as `createStreaming` returns it
            let server = LibMockServer([sseReply(Self.script(type, "Boom"))])
            let stream = try await server.client().beta.messages.createStreaming(
                maxTokens: 1, messages: [betaUserMessage("Hi")], model: "claude-opus-5-5")
            do {
                for try await _ in stream {}
                Issue.record("expected an error for \(type)")
            } catch let e as APIStatusError {
                #expect(isExpected(e), "\(type): \(Swift.type(of: e))")
                #expect(e.statusCode == status, "\(type)")
                #expect(e.errorMessage == "Boom")
            }
        }
    }
}
