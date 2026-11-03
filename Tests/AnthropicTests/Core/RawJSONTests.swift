import Foundation
import Testing
@testable import Anthropic

// `RawJSON` (order- and field-preserving JSON) and the deterministic request body. These have no upstream test:
// Python's dicts keep insertion order, so its bodies are deterministic without any of this.

private func text(_ data: Data?) -> String { String(decoding: data ?? Data(), as: UTF8.self) }

@Suite struct RawJSONTests {
    @Test func parseKeepsDocumentOrderEveryFieldNullsAndNumberText() throws {
        let source = #"{"zeta":{"b":1.50,"a":[2e3,-0,0.1,12345678901234567890]},"type":"text","unknown_field":null,"text":"é ✓\n\"q\""}"#
        let value = try RawJSON.parse(source)
        #expect(value.serializedString == source)
        #expect(value.objectValue?.keys == ["zeta", "type", "unknown_field", "text"])
        #expect(value["unknown_field"] == .null)
        #expect(value["zeta"]?["b"]?.numberValue?.text == "1.50")
        #expect(value["zeta"]?["b"]?.doubleValue == 1.5)
        #expect(value["zeta"]?["a"]?[0]?.intValue == 2000)
        // Whitespace is not kept; everything else is.
        let spaced = try RawJSON.parse(" {\n  \"b\" : [ 1 , true ] ,\t\"a\" : null } ")
        #expect(spaced.serializedString == #"{"b":[1,true],"a":null}"#)
    }

    @Test func aRepeatedKeyKeepsItsFirstPlaceAndItsLastValue() throws {
        // As JavaScript's `JSON.parse` does.
        #expect(try RawJSON.parse(#"{"a":1,"b":2,"a":3}"#).serializedString == #"{"a":3,"b":2}"#)
    }

    @Test func buildingKeepsInsertionOrder() {
        var value: RawJSON = ["zeta": 1, "alpha": ["y": true, "x": nil], "mid": "m"]
        #expect(value.serializedString == #"{"zeta":1,"alpha":{"y":true,"x":null},"mid":"m"}"#)
        value["alpha"] = "replaced in place"
        value["new"] = 2.5
        value["zeta"] = nil
        #expect(value.serializedString == #"{"alpha":"replaced in place","mid":"m","new":2.5}"#)
        var object = RawJSONObject()
        object["b"] = 1
        object["a"] = 2
        object.modifyValue(forKey: "b") { $0 = [$0, 3] }
        #expect(RawJSON.object(object).serializedString == #"{"b":[1,3],"a":2}"#)
        #expect(object.map(\.key) == ["b", "a"])
        let removed = object.removeValue(forKey: "b")
        #expect(removed == [1, 3])
        #expect(object.keys == ["a"] && object.index(forKey: "a") == 0)
    }

    @Test func aJSONValueConvertsWithSortedKeys() throws {
        var dict: [String: JSONValue] = [:]
        for key in ["m", "b", "z", "a", "k"] { dict[key] = .int(key.count) }
        let value = RawJSON(JSONValue.object(["outer": .object(dict), "list": [1.5, nil, "s"]]))
        #expect(value.serializedString == #"{"list":[1.5,null,"s"],"outer":{"a":1,"b":1,"k":1,"m":1,"z":1}}"#)
        #expect(value.jsonValue == ["outer": .object(dict), "list": [1.5, nil, "s"]])
        #expect(RawJSON(JSONValue.double(.nan)) == .null)
        #expect(RawJSON(JSONValue.double(1.0)).serializedString == "1")
    }

    @Test func numbersAreValidatedJSONText() throws {
        #expect(RawJSON.Number(text: "-12.5e+3")?.doubleValue == -12500)
        for bad in ["01", "1.", ".5", "abc", " 1", "1 ", "+1", "-", "1e", "NaN"] {
            #expect(RawJSON.Number(text: bad) == nil, "\(bad)")
        }
        for bad in ["[01]", "{\"a\":1.}", "[1] x", "{\"a\" 1}", "[\"\u{01}\"]", "{'a': 1}", ""] {
            #expect(throws: PartialJSONError.self, "\(bad)") { try RawJSON.parse(bad) }
        }
        #expect(RawJSON.Number(Double.infinity) == nil)
        #expect(RawJSON.Number(0.1)?.text == "0.1")
    }

    @Test func stringsAreEscapedAsJavaScriptDoes() throws {
        let value: RawJSON = ["s": "quote\" back\\ nl\n tab\t ctl\u{01} del\u{7F} é / \u{2028}"]
        #expect(value.serializedString == "{\"s\":\"quote\\\" back\\\\ nl\\n tab\\t ctl\\u0001 del\u{7F} é / \u{2028}\"}")
        #expect(try RawJSON.parse(value.serializedString) == value)
        // Escapes are decoded, surrogate pairs included.
        #expect(try RawJSON.parse(#""é😀\/""#) == "é😀/")
    }

    @Test func nestingIsBoundedOnATaskStack() async throws {
        // The parser keeps its own stack; what recurses once per level is the work done on the value afterwards. Here
        // it runs on a cooperative thread, unoptimised in a debug build, on a value twice as deep as the limit.
        func nested(_ depth: Int) -> String { String(repeating: #"{"a":["#, count: depth / 2) + "1" + String(repeating: "]}", count: depth / 2) }
        let limit = JSONTextParser.maxDepth
        let deepest = try RawJSON.parse(nested(limit))
        #expect(deepest.serialized().count == nested(limit).utf8.count)
        // The SDK's typed route, through `JSONEncoder` and `JSONDecoder`, at the limit.
        #expect(try JSONValue.parse(JSONValue.serialize(deepest.jsonValue)) == deepest.jsonValue)
        let twice = try JSONTextParser.parse(Data(nested(2 * limit).utf8), mode: .off, maxDepth: 2 * limit)
        #expect(twice.serializedString == nested(2 * limit))
        let view = twice.jsonValue
        #expect(RawJSON(view) == twice)
        #expect(twice.reconciled(with: view) == twice)
        #expect(Set([twice, deepest]).count == 2)

        // A tool input as deep as the streams take one can be put into a history and read back with it.
        let input = try RawJSON.parse(nested(JSONTextParser.toolInputMaxDepth))
        let history: RawJSON = [["role": "assistant", "content": [["type": "tool_use", "id": "t", "name": "n", "input": input]]]]
        #expect(try RawJSON.parse(RawJSON.object(["history": history]).serializedString)["history"] == history)

        for deeper in [nested(limit + 2), String(repeating: "[", count: 100_000)] {
            do {
                _ = try RawJSON.parse(deeper)
                Issue.record("expected the nesting limit")
            } catch let error as PartialJSONError {
                #expect(error.exceedsNestingLimit)
                #expect(error.message == "arrays and objects nested deeper than 128 levels")
            }
        }
        #expect(throws: PartialJSONError.self) { try PartialJSON.parse(String(repeating: "[", count: 100_000)) }
    }

    @Test func aToolInputNestedDeeperThanTheLimitSaysSo() throws {
        func nested(_ depth: Int) -> String { String(repeating: #"{"a":"#, count: depth) + "1" + String(repeating: "}", count: depth) }
        var bufs: [Int: String] = [:]
        #expect(try accumulateToolInput(&bufs, index: 0, partialJSON: nested(JSONTextParser.toolInputMaxDepth), mode: .on) != nil)
        bufs = [:]
        do {
            _ = try accumulateToolInput(&bufs, index: 0, partialJSON: nested(JSONTextParser.toolInputMaxDepth + 1), mode: .on)
            Issue.record("expected a ValueError")
        } catch let error as ValueError {
            #expect(error.message.hasPrefix("The tool input nests arrays and objects deeper than the 120 levels this SDK parses."))
        }
    }

    @Test func aLoneHighSurrogateAtTheEndOfADocumentIsReplaced() throws {
        // Complete documents: the surrogate is lone, whatever is left of the input after it.
        #expect(try RawJSON.parse(#"{"a":"\ud83d"}"#) == ["a": "\u{FFFD}"])
        #expect(try RawJSON.parse(#""\ud83dx""#) == "\u{FFFD}x")
        #expect(try RawJSON.parse(#""\ud83d\n""#) == "\u{FFFD}\n")
        #expect(try PartialJSON.parse(#"{"a":"\ud83d"}"#, mode: .on) == ["a": "\u{FFFD}"])
        #expect(try PartialJSON.parse(#"{"a":"\ud83d"}"#, mode: .trailingStrings) == ["a": "\u{FFFD}"])
        // A pair, and a high surrogate whose low one has not arrived yet.
        #expect(try RawJSON.parse(#""😀""#) == "😀")
        #expect(try PartialJSON.parse(#"{"a":"x\ud83d"#, mode: .trailingStrings) == ["a": "x"])
        #expect(try PartialJSON.parse(#"{"a":"x\ud83d\u"#, mode: .trailingStrings) == ["a": "x"])
        #expect(try PartialJSON.parse(#"{"a":"x\ud83d\ude"#, mode: .trailingStrings) == ["a": "x"])
        #expect(throws: PartialJSONError.self) { try RawJSON.parse(#""\ud83d"#) }
    }

    @Test func keysAreToldApartByTheirBytes() throws {
        // "é" precomposed (U+00E9) and decomposed (e + U+0301): equal as Swift strings, two keys in JSON.
        let source = "{\"\u{E9}\":1,\"e\u{301}\":2}"
        let value = try RawJSON.parse(source)
        #expect(value.objectValue?.count == 2)
        #expect(value.serializedString == source)
        #expect(value["\u{E9}"] == 1)
        #expect(value["e\u{301}"] == 2)
        #expect(value != (try RawJSON.parse("{\"e\u{301}\":1,\"\u{E9}\":2}")))
        var object = RawJSONObject()
        object["e\u{301}"] = 1
        object["\u{E9}"] = 2
        object.removeValue(forKey: "e\u{301}")
        #expect(RawJSON.object(object).serializedString == "{\"\u{E9}\":2}")
    }

    @Test func decodingGoesThroughTheSDKsDecoderAndThereIsNoLossyCodable() throws {
        let value = try RawJSON.parse(#"{"type":"text","text":"hi","citations":null}"#)
        let block: BetaTextBlock = try value.decode()
        #expect(block.text == "hi")
        #expect(try RawJSON(encoding: block)["text"] == "hi")
        // A `Codable` round trip would sort keys and rewrite numbers; the text is what keeps them.
        #expect(!((value as Any) is any Encodable) && !((value as Any) is any Decodable))
        let received = try RawJSON.parse(#"[{"role":"user","content":[{"b":1.50,"a":1}]}]"#)
        let reloaded = try RawJSON.parse(received.serialized())
        #expect(reloaded == received)
        #expect(reloaded.serializedString == #"[{"role":"user","content":[{"b":1.50,"a":1}]}]"#)
    }

    @Test func reconcilingKeepsWhatAViewLeftAlone() throws {
        let raw = try RawJSON.parse(#"{"model":"m","messages":[{"role":"user","content":[{"z":1,"a":1.50}]}],"max_tokens":5}"#)
        var view = raw.jsonValue
        #expect(raw.reconciled(with: view) == raw)
        view["max_tokens"] = 6
        view["metadata"] = ["user_id": "u"]
        view["anthropic_version"] = "v"
        view["model"] = nil
        #expect(raw.reconciled(with: view).serializedString
            == #"{"messages":[{"role":"user","content":[{"z":1,"a":1.50}]}],"max_tokens":6,"anthropic_version":"v","metadata":{"user_id":"u"}}"#)
    }

    @Test func partialToolInputKeepsTheModelsOrder() throws {
        #expect(try PartialJSON.parseRaw(#"{"zip": "94103", "city": "San Fr"#, mode: .trailingStrings).serializedString
            == #"{"zip":"94103","city":"San Fr"}"#)
        #expect(try PartialJSON.parseRaw(#"{"zip": "94103", "city": "San Fr"#).serializedString == #"{"zip":"94103"}"#)
    }
}

/// R1: the same request, built from dictionaries filled in different orders and with different capacities (so that
/// they iterate in different orders), is sent as the same bytes. Each body is compared with a literal, so the bytes are
/// also the same in every process.
@Suite struct RequestBodyDeterminismTests {
    /// The same input schema, built two ways.
    func schema(_ variant: Int) -> JSONValue {
        let keys = ["type", "properties", "required", "additionalProperties", "description"]
        let values: [String: JSONValue] = [
            "type": "object", "required": ["city"], "additionalProperties": false, "description": "Where",
            "properties": .object(variant == 0
                ? ["city": ["type": "string"], "units": ["type": "string", "enum": ["c", "f"]], "days": ["type": "integer"]]
                : ["days": ["type": "integer"], "units": ["enum": ["c", "f"], "type": "string"], "city": ["type": "string"]]),
        ]
        var out = [String: JSONValue](minimumCapacity: variant == 0 ? 5 : 64)
        for key in variant == 0 ? keys : keys.reversed() { out[key] = values[key] }
        return .object(out)
    }

    func toolInput(_ variant: Int) -> JSONValue {
        var out = [String: JSONValue](minimumCapacity: variant == 0 ? 3 : 48)
        let pairs: [(String, JSONValue)] = [("zip", "94103"), ("city", "San Francisco"), ("days", 3)]
        for (k, v) in variant == 0 ? pairs : pairs.reversed() { out[k] = v }
        return .object(out)
    }

    static let expectedSchema = #"{"additionalProperties":false,"description":"Where","properties":{"city":{"type":"string"},"days":{"type":"integer"},"units":{"enum":["c","f"],"type":"string"}},"required":["city"],"type":"object"}"#

    @Test func aTypedRequestIsTheSameBytesWhateverItsDictionariesOrder() async throws {
        let server = LibMockServer([.json(try JSONValue.parse(ReadmeExamplesTests.messageJSON))], repeatLast: true)
        let client = try server.client()
        for variant in [0, 1] {
            let tool = try JSONValue.object(["name": "get_weather", "description": "Weather", "input_schema": schema(variant)])
                .decode(as: ToolUnionParam.self)
            let history: [MessageParam] = [
                userMessage("Weather?"),
                try JSONValue.object(["role": "assistant", "content": [.object([
                    "type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": toolInput(variant)])]]).decode(),
            ]
            _ = try await client.messages.create(maxTokens: 64, messages: history, model: "claude-opus-5-5", tools: [tool])
        }
        let bodies = server.requests.map { text($0.body) }
        #expect(bodies[0] == bodies[1])
        // (The typed `ToolParam.InputSchema` keeps only `type`, `properties` and `required`.)
        #expect(bodies[0] == #"{"max_tokens":64,"messages":[{"content":"Weather?","role":"user"},{"content":[{"id":"toolu_1","input":{"city":"San Francisco","days":3,"zip":"94103"},"name":"get_weather","type":"tool_use"}],"role":"assistant"}],"model":"claude-opus-5-5","tools":[{"description":"Weather","input_schema":{"properties":{"city":{"type":"string"},"days":{"type":"integer"},"units":{"enum":["c","f"],"type":"string"}},"required":["city"],"type":"object"},"name":"get_weather"}]}"#)
    }

    @Test func aJSONValueBodyIsTheSameBytesWhateverItsDictionariesOrder() async throws {
        let server = LibMockServer([.json(["ok": true])], repeatLast: true)
        let client = try server.client()
        for variant in [0, 1] {
            let _: JSONValue = try await client.post("/v1/things", body: ["schema": schema(variant), "input": toolInput(variant)])
        }
        let bodies = server.requests.map { text($0.body) }
        #expect(bodies[0] == bodies[1])
        #expect(bodies[0] == #"{"input":{"city":"San Francisco","days":3,"zip":"94103"},"schema":"# + Self.expectedSchema + "}")
    }

    @Test func aToolRunnerSendsTheSameToolBytesOnEveryRequest() async throws {
        let toolUse: JSONValue = [
            "id": "msg_1", "type": "message", "role": "assistant", "model": "claude-opus-5-5", "stop_reason": "tool_use",
            "content": [["type": "tool_use", "id": "toolu_1", "name": "get_weather", "input": ["city": "SF"]]],
            "usage": ["input_tokens": 1, "output_tokens": 1],
        ]
        let server = LibMockServer([.json(toolUse), .json(try JSONValue.parse(ReadmeExamplesTests.messageJSON))])
        let weather = BetaFunctionTool(name: "get_weather", description: "Weather", inputSchema: schema(1).objectValue ?? [:]) {
            (_: BetaToolInput) in .string("Sunny")
        }
        let runner = try server.client().beta.messages.toolRunner(
            maxTokens: 64, messages: [betaUserMessage("Weather?")], model: "claude-opus-5-5", tools: [weather], thread: false)
        _ = try await runner.untilDone()
        // Each request rebuilds the tool definitions from the tool.
        let tools = try server.requests.map { try RawJSON.parse($0.body ?? Data())["tools"]?.serializedString }
        #expect(tools.count == 2 && tools[0] == tools[1])
        #expect(tools[0] == #"[{"description":"Weather","input_schema":"# + Self.expectedSchema + #","name":"get_weather"}]"#)
    }
}
