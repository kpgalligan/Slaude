// The parts of tests/test_models.py and tests/test_prepare.py that have a Swift meaning: decoding and
// encoding semantics of the generated types (unknown fields, aliases, open enums, unions, dates,
// nullable vs omitted), and how request data is prepared.

import Foundation
import Testing
@testable import Anthropic

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try AnthropicJSON.decoder().decode(T.self, from: Data(json.utf8))
}

private func encode<T: Encodable>(_ value: T) throws -> JSONValue { try JSONValue.from(value) }

@Suite("Models (test_models.py)")
struct ModelsTests {
    @Test func basic() throws {
        let usage = try decode(Usage.self, #"{"input_tokens": 1, "output_tokens": 2}"#)
        #expect(usage.inputTokens == 1)
        #expect(usage.outputTokens == 2)
    }

    @Test func directlyNestedModel() throws {
        let message = try messageBody().decode(as: Message.self)
        #expect(message.usage.inputTokens == 10)
        guard case .text(let block) = message.content.first else {
            Issue.record("expected a text block")
            return
        }
        #expect(block.text == "Hello!")
    }

    @Test func unknownFields() throws {
        // fields the SDK doesn't know are ignored (Python keeps them as extra attributes)
        let usage = try decode(Usage.self, #"{"input_tokens": 1, "output_tokens": 2, "unknown_field": {"foo": "bar"}}"#)
        #expect(usage.inputTokens == 1)
    }

    @Test func aliases() throws {
        // snake_case wire names map to camelCase properties both ways
        let usage = try decode(Usage.self, #"{"input_tokens": 1, "output_tokens": 2, "cache_read_input_tokens": 3}"#)
        #expect(usage.cacheReadInputTokens == 3)
        #expect(try encode(usage)["cache_read_input_tokens"] == 3)
    }

    @Test func optionalFieldsNullAndOmitted() throws {
        let a = try decode(Usage.self, #"{"input_tokens": 1, "output_tokens": 2, "cache_read_input_tokens": null}"#)
        let b = try decode(Usage.self, #"{"input_tokens": 1, "output_tokens": 2}"#)
        #expect(a.cacheReadInputTokens == nil)
        #expect(b.cacheReadInputTokens == nil)
        #expect(try encode(b) == ["input_tokens": 1, "output_tokens": 2])
    }

    @Test func listMismatchedTypeFails() throws {
        // Python's `construct` keeps mismatched values; Swift decoding is typed and reports them
        #expect(throws: DecodingError.self) { try decode(Usage.self, #"{"input_tokens": "one", "output_tokens": 2}"#) }
    }

    @Test func doesNotCoerceIntToString() throws {
        #expect(throws: DecodingError.self) { try decode(TextBlock.self, #"{"type": "text", "text": 1, "citations": null}"#) }
    }

    @Test func intToFloatSafeConversion() throws {
        struct Model: Codable { var value: Double; var count: Int }
        let m = try decode(Model.self, #"{"value": 1, "count": 2.0}"#)
        #expect(m.value == 1.0)
        #expect(m.count == 2)
    }

    @Test func iso8601Datetime() throws {
        let file = try decode(BetaFileMetadata.self,
                              #"{"id": "f", "created_at": "2019-12-27T18:11:19.117Z", "filename": "a", "mime_type": "text/plain", "size_bytes": 1, "type": "file"}"#)
        #expect(file.createdAt == Date(timeIntervalSince1970: 1_577_470_279.117))
        #expect(try encode(file)["created_at"] == "2019-12-27T18:11:19.117Z")
    }

    @Test func unknownEnumValuesRoundTrip() throws {
        var body = messageBody()
        body["stop_reason"] = "a_new_stop_reason"
        let message = try body.decode(as: Message.self)
        #expect(message.stopReason == .unknown("a_new_stop_reason"))
        #expect(message.stopReason?.rawValue == "a_new_stop_reason")
        #expect(try encode(message)["stop_reason"] == "a_new_stop_reason")
        #expect(StopReason(rawValue: "end_turn") == .endTurn)
    }

    @Test func discriminatedUnionCase() throws {
        let block = try decode(ContentBlock.self, #"{"type": "tool_use", "id": "t", "name": "get_weather", "input": {"city": "Paris"}}"#)
        guard case .toolUse(let tool) = block else {
            Issue.record("expected a tool_use block, got \(block)")
            return
        }
        #expect(tool.name == "get_weather")
    }

    @Test func discriminatedUnionsUnknownVariant() throws {
        // a variant this SDK version doesn't know is kept as raw JSON and round-trips
        let json: JSONValue = ["type": "a_new_block", "payload": [1, 2]]
        let block: ContentBlock = try json.decode()
        #expect(block == .unknown(json))
        #expect(try encode(block) == json)
    }

    @Test func discriminatedUnionsInvalidData() throws {
        // a known discriminator with invalid data is an error
        #expect(throws: DecodingError.self) { try decode(ContentBlock.self, #"{"type": "text", "text": 1}"#) }
    }

    @Test func listOfUnions() throws {
        let blocks = try decode([ContentBlock].self, #"[{"type": "text", "text": "a", "citations": null}, {"type": "thinking", "thinking": "b", "signature": "s"}]"#)
        #expect(blocks.count == 2)
        if case .thinking(let t) = blocks[1] { #expect(t.thinking == "b") } else { Issue.record("expected thinking") }
    }

    @Test func unionWithAStringVariant() throws {
        // `MessageParam.content` is `str | list[block]`: both decode, and a string literal builds one
        let messages: [MessageParam] = try JSONValue.array([
            ["role": "user", "content": "hi"],
            ["role": "user", "content": [["type": "text", "text": "hello"]]],
        ]).decode()
        #expect(try encode(messages) == [
            ["role": "user", "content": "hi"],
            ["role": "user", "content": [["type": "text", "text": "hello"]]],
        ])
    }

    @Test func toDictAndToJSON() throws {
        let message = try messageBody().decode(as: Message.self)
        let json = try encode(message)
        #expect(json["id"] == "msg_013Zva2CMHLNnXjNJJKqJ2EF")
        #expect(json["usage"] == ["input_tokens": 10, "output_tokens": 5])
        // `stop_sequence: null` decodes to nil, which isn't sent back
        #expect(json["stop_sequence"] == nil)
    }
}

@Suite("Request params (test_prepare.py)")
struct PrepareTests {
    @Test func nullableVersusOmitted() throws {
        // not-required + nullable params are `X??`: nil omits the key, `.some(nil)` sends `null`
        let omitted = TextBlockParam(text: "hi")
        let null = TextBlockParam(text: "hi", cacheControl: .some(nil))
        #expect(try encode(omitted) == ["text": "hi", "type": "text"])
        #expect(try encode(null) == ["text": "hi", "type": "text", "cache_control": nil])
    }

    @Test func nullableVersusOmittedRoundTrips() throws {
        let null: TextBlockParam = try JSONValue.object(["text": "hi", "type": "text", "cache_control": nil]).decode()
        #expect(null.cacheControl == .some(nil))
        let omitted: TextBlockParam = try JSONValue.object(["text": "hi", "type": "text"]).decode()
        #expect(omitted.cacheControl == nil)
        let set: TextBlockParam = try JSONValue.object(["text": "hi", "type": "text", "cache_control": ["type": "ephemeral"]]).decode()
        #expect(set.cacheControl??.type == "ephemeral")
        #expect(try encode(null) == ["text": "hi", "type": "text", "cache_control": nil])
    }

    @Test func stripsOmitAndKeepsNone() throws {
        var body = ParamsBuilder()
        try body.set("a", Optional<String>.none)
        try body.set("b", Optional<String?>.some(nil))
        try body.set("c", "x")
        #expect(body.object == ["b": nil, "c": "x"])
    }

    @Test func extraBodyIsMergedIn() async throws {
        let server = MockServer(json: messageBody())
        let client = try makeTestClient(server)
        _ = try await client.messages.create(maxTokens: 1, messages: helloMessages(), model: "m", extraBody: ["max_tokens": 5, "extra": true])
        #expect(server.lastRequest?.jsonBody?["max_tokens"] == 5)
        #expect(server.lastRequest?.jsonBody?["extra"] == true)
    }

    @Test func queryParams() async throws {
        let server = MockServer(json: ["data": [], "has_more": false, "first_id": nil, "last_id": nil])
        let client = try makeTestClient(server)
        _ = try await client.models.list(afterID: "a b", limit: 5, extraQuery: ["extra": ["x": 1]])
        let request = try #require(server.lastRequest)
        #expect(request.query("after_id") == "a b")
        #expect(request.query("limit") == "5")
        #expect(request.query("extra[x]") == "1")
        #expect(request.query("before_id") == nil)
    }

    @Test func emptyQueryParamsAreLeftUnset() async throws {
        let server = MockServer(json: ["data": [], "has_more": false, "first_id": nil, "last_id": nil])
        let client = try makeTestClient(server)
        _ = try await client.models.list()
        #expect(server.lastRequest?.url.query == nil)
    }

    @Test func base64FileInput() throws {
        let source = Base64FileInput(data: Data("abc".utf8))
        #expect(try encode(["data": source]) == ["data": "YWJj"])
    }

    @Test func getDoesNotSendABody() throws {
        let client = try makeTestClient()
        let request = try buildRequest(client, FinalRequestOptions(method: "get", url: "/foo", jsonData: ["a": 1], extraJSON: ["b": 2]))
        #expect(request.body == nil)
        #expect(request.headers["Content-Type"] == nil)
    }
}
