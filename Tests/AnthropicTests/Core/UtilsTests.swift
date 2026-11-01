// Ports of tests/test_qs.py, tests/test_utils/test_path.py, tests/test_utils/test_datetime_parse.py,
// tests/test_utils/test_json.py and tests/decoders/test_jsonl.py.

import Foundation
import Testing
@testable import Anthropic

private func unquote(_ s: String) -> String { s.removingPercentEncoding ?? s }

// MARK: - test_qs.py

@Suite("Querystring (test_qs.py)")
struct QuerystringTests {
    let qs = Querystring()

    @Test func empty() {
        #expect(qs.stringify([String: JSONValue]()) == "")
        #expect(qs.stringify(["a": [:]]) == "")
        #expect(qs.stringify(["a": ["b": ["c": [:]]]]) == "")
    }

    @Test func basic() {
        #expect(qs.stringify(["a": 1]) == "a=1")
        #expect(qs.stringify(["a": "b"]) == "a=b")
        #expect(qs.stringify(["a": true]) == "a=true")
        #expect(qs.stringify(["a": false]) == "a=false")
        #expect(qs.stringify(["a": 1.23456]) == "a=1.23456")
        #expect(qs.stringify(["a": nil]) == "")
        #expect(qs.stringify(["a": ""]) == "a=")
    }

    @Test func datetime() throws {
        // Swift dates are instants: they are sent as UTC ISO 8601, keeping microseconds.
        let d = try JSONValue.from(Date(timeIntervalSince1970: 1_704_164_645.000_6))
        #expect(unquote(qs.stringify(["a": ["gte": d]])) == "a[gte]=2024-01-02T03:04:05.0006Z")
        #expect(unquote(qs.stringify(["a": try JSONValue.from(ISODate(year: 2024, month: 1, day: 2))])) == "a=2024-01-02")
    }

    @Test(arguments: [true, false])
    func nestedDotted(useInstance: Bool) {
        func serialise(_ v: [String: JSONValue]) -> String {
            useInstance ? Querystring(nestedFormat: .dots).stringify(v) : Querystring().stringify(v, nestedFormat: .dots)
        }
        #expect(unquote(serialise(["a": ["b": "c"]])) == "a.b=c")
        #expect(unquote(serialise(["a": ["b": "c", "d": "e", "f": "g"]])) == "a.b=c&a.d=e&a.f=g")
        #expect(unquote(serialise(["a": ["b": ["c": ["d": "e"]]]])) == "a.b.c.d=e")
        #expect(unquote(serialise(["a": ["b": true]])) == "a.b=true")
    }

    @Test func nestedBrackets() {
        #expect(unquote(qs.stringify(["a": ["b": "c"]])) == "a[b]=c")
        #expect(unquote(qs.stringify(["a": ["b": "c", "d": "e", "f": "g"]])) == "a[b]=c&a[d]=e&a[f]=g")
        #expect(unquote(qs.stringify(["a": ["b": ["c": ["d": "e"]]]])) == "a[b][c][d]=e")
        #expect(unquote(qs.stringify(["a": ["b": true]])) == "a[b]=true")
    }

    @Test(arguments: [true, false])
    func arrayComma(useInstance: Bool) {
        func serialise(_ v: [String: JSONValue]) -> String {
            useInstance ? Querystring(arrayFormat: .comma).stringify(v) : Querystring().stringify(v, arrayFormat: .comma)
        }
        #expect(unquote(serialise(["in": ["foo", "bar"]])) == "in=foo,bar")
        #expect(unquote(serialise(["a": ["b": [true, false]]])) == "a[b]=true,false")
        #expect(unquote(serialise(["a": ["b": [true, false, nil, true]]])) == "a[b]=true,false,true")
    }

    @Test func arrayRepeat() {
        #expect(unquote(qs.stringify(["in": ["foo", "bar"]])) == "in=foo&in=bar")
        #expect(unquote(qs.stringify(["a": ["b": [true, false]]])) == "a[b]=true&a[b]=false")
        #expect(unquote(qs.stringify(["a": ["b": [true, false, nil, true]]])) == "a[b]=true&a[b]=false&a[b]=true")
        #expect(unquote(qs.stringify(["in": ["foo", ["b": ["c": ["d", "e"]]]]])) == "in=foo&in[b][c]=d&in[b][c]=e")
    }

    @Test(arguments: [true, false])
    func arrayBrackets(useInstance: Bool) {
        func serialise(_ v: [String: JSONValue]) -> String {
            useInstance ? Querystring(arrayFormat: .brackets).stringify(v) : Querystring().stringify(v, arrayFormat: .brackets)
        }
        #expect(unquote(serialise(["in": ["foo", "bar"]])) == "in[]=foo&in[]=bar")
        #expect(unquote(serialise(["a": ["b": [true, false]]])) == "a[b][]=true&a[b][]=false")
        #expect(unquote(serialise(["a": ["b": [true, false, nil, true]]])) == "a[b][]=true&a[b][]=false&a[b][]=true")
        #expect(unquote(serialise(["in": ["", "foo"]])) == "in[]=&in[]=foo")
    }

    @Test func arrayIndices() {
        #expect(unquote(Querystring(arrayFormat: .indices).stringify(["in": ["foo", "bar"]])) == "in[0]=foo&in[1]=bar")
    }

    @Test func quotePlusEncoding() {
        #expect(qs.stringify(["a b": "c&d=e/f"]) == "a+b=c%26d%3De%2Ff")
    }
}

// MARK: - test_utils/test_path.py

@Suite("Path template (test_utils/test_path.py)")
struct PathTemplateTests {
    @Test(arguments: [
        ("/v1/{id}", ["id": "abc"], "/v1/abc"),
        ("/v1/{a}/{b}", ["a": "x", "b": "y"], "/v1/x/y"),
        ("/v1/{a}{b}/path/{c}?val={d}#{e}", ["a": "x", "b": "y", "c": "z", "d": "u", "e": "v"], "/v1/xy/path/z?val=u#v"),
        ("/{w}/{w}", ["w": "echo"], "/echo/echo"),
        ("/v1/static", [:], "/v1/static"),
        ("", [:], ""),
        ("/v1/?q={n}&count=10", ["n": "42"], "/v1/?q=42&count=10"),
        ("/v1/{v}", ["v": ".hidden"], "/v1/.hidden"),
        ("/v1/{v}", ["v": "file.txt"], "/v1/file.txt"),
        ("/v1/{v}", ["v": "..."], "/v1/..."),
        ("/v1/{a}{b}", ["a": ".", "b": "txt"], "/v1/.txt"),
        ("/items?q={v}#{f}", ["v": ".", "f": ".."], "/items?q=.#.."),
        ("/v1/{a}?query={b}", ["a": "../../other/endpoint", "b": "a&bad=true"], "/v1/..%2F..%2Fother%2Fendpoint?query=a%26bad%3Dtrue"),
        ("/v1/{val}", ["val": "a/b/c"], "/v1/a%2Fb%2Fc"),
        ("/v1/{val}", ["val": "a/b/c?query=value"], "/v1/a%2Fb%2Fc%3Fquery=value"),
        ("/v1/{val}", ["val": "a/b/c?query=value&bad=true"], "/v1/a%2Fb%2Fc%3Fquery=value&bad=true"),
        ("/v1/{val}", ["val": "%20"], "/v1/%2520"),
        ("/items?q={v}", ["v": "a/b"], "/items?q=a/b"),
        ("/items?q={v}", ["v": "a?b"], "/items?q=a?b"),
        ("/items?q={v}", ["v": "a#b"], "/items?q=a%23b"),
        ("/items?q={v}", ["v": "a b"], "/items?q=a%20b"),
        ("/docs#{v}", ["v": "a/b"], "/docs#a/b"),
        ("/docs#{v}", ["v": "a?b"], "/docs#a?b"),
        ("/v1/{v}", ["v": "a/b"], "/v1/a%2Fb"),
        ("/v1/{v}", ["v": "a?b"], "/v1/a%3Fb"),
        ("/v1/{v}", ["v": "a#b"], "/v1/a%23b"),
        ("/v1/{v}?q={v}#{v}", ["v": "a/b?c#d"], "/v1/a%2Fb%3Fc%23d?q=a/b?c%23d#a/b?c%23d"),
        ("/v1/{val}", ["val": "x?admin=true"], "/v1/x%3Fadmin=true"),
        ("/v1/{val}", ["val": "x#admin"], "/v1/x%23admin"),
    ] as [(String, [String: String], String)])
    func interpolation(template: String, values: [String: String], expected: String) throws {
        #expect(try pathTemplate(template, values) == expected)
    }

    @Test func missingKwargRaises() {
        #expect {
            try pathTemplate("/v1/{org_id}", [:])
        } throws: { error in
            "\(error)".contains("org_id")
        }
    }

    @Test(arguments: [
        ("{a}/path", ["a": "."]), ("{a}/path", ["a": ".."]), ("/v1/{a}", ["a": "."]), ("/v1/{a}", ["a": ".."]),
        ("/v1/{a}/path", ["a": "."]), ("/v1/{a}/path", ["a": ".."]), ("/v1/{a}{b}", ["a": ".", "b": "."]),
        ("/v1/{a}.", ["a": "."]), ("/v1/{a}{b}", ["a": "", "b": "."]), ("/v1/%2e/{x}", ["x": "ok"]),
        ("/v1/%2e./{x}", ["x": "ok"]), ("/v1/.%2E/{x}", ["x": "ok"]), ("/v1/{v}?q=1", ["v": ".."]), ("/v1/{v}#frag", ["v": ".."]),
    ] as [(String, [String: String])])
    func dotSegmentRejected(template: String, values: [String: String]) {
        #expect {
            try pathTemplate(template, values)
        } throws: { error in
            (error as? ValueError)?.message.contains("dot-segment") ?? false
        }
    }
}

// MARK: - test_utils/test_datetime_parse.py

private func utc(_ y: Int, _ mo: Int, _ d: Int, _ h: Int = 0, _ mi: Int = 0, _ s: Int = 0, _ us: Int = 0, offsetMinutes: Int = 0) -> Date {
    DatetimeParse.makeDate(y, mo, d, h, mi, s, us, offsetSeconds: offsetMinutes * 60)!
}

@Suite("Datetime parsing (test_utils/test_datetime_parse.py)")
struct DatetimeParseTests {
    enum Input: Sendable, CustomTestStringConvertible {
        case string(String), number(Double)
        var testDescription: String {
            switch self {
            case .string(let s): return "'\(s)'"
            case .number(let n): return "\(n)"
            }
        }
    }

    @Test(arguments: [
        (Input.string("1494012444.883309"), "2017-05-05"), (.number(1_494_012_444.883_309), "2017-05-05"),
        (.string("1494012444"), "2017-05-05"), (.number(1_494_012_444), "2017-05-05"), (.number(0), "1970-01-01"),
        (.string("2012-04-23"), "2012-04-23"), (.string("2012-4-9"), "2012-04-09"),
        (.number(19_999_999_999), "2603-10-11"), (.number(20_000_000_001), "1970-08-20"),
        (.number(1_549_316_052), "2019-02-04"), (.number(1_549_316_052_104), "2019-02-04"),
        (.number(1_549_316_052_104_324), "2019-02-04"), (.number(1_549_316_052_104_324_096), "2019-02-04"),
        (.string("infinity"), "9999-12-31"), (.string("inf"), "9999-12-31"), (.number(.infinity), "9999-12-31"),
        (.string("infinity "), "9999-12-31"), (.number(1e100), "9999-12-31"), (.string("-infinity"), "0001-01-01"),
        (.string("-inf"), "0001-01-01"),
    ])
    func dateParsing(value: Input, expected: String) throws {
        let parsed: ISODate
        switch value {
        case .string(let s): parsed = try DatetimeParse.parseDate(s)
        case .number(let n): parsed = try DatetimeParse.parseDate(n)
        }
        #expect(parsed.description == expected)
    }

    @Test(arguments: [Input.string("x20120423"), .string("2012-04-56"), .string("nan")])
    func dateParsingErrors(value: Input) {
        #expect(throws: ValueError.self) {
            switch value {
            case .string(let s): _ = try DatetimeParse.parseDate(s)
            case .number(let n): _ = try DatetimeParse.parseDate(n)
            }
        }
    }

    @Test(arguments: [
        (Input.string("1494012444.883309"), utc(2017, 5, 5, 19, 27, 24, 883_309)),
        (.number(1_494_012_444.883_309), utc(2017, 5, 5, 19, 27, 24, 883_309)),
        (.string("1494012444"), utc(2017, 5, 5, 19, 27, 24)),
        (.number(1_494_012_444), utc(2017, 5, 5, 19, 27, 24)),
        (.string("1494012444000.883309"), utc(2017, 5, 5, 19, 27, 24, 883)),
        (.string("-1494012444000.883309"), utc(1922, 8, 29, 4, 32, 35, 999_117)),
        (.number(1_494_012_444_000), utc(2017, 5, 5, 19, 27, 24)),
        (.string("2012-04-23T09:15:00"), utc(2012, 4, 23, 9, 15)),
        (.string("2012-4-9 4:8:16"), utc(2012, 4, 9, 4, 8, 16)),
        (.string("2012-04-23T09:15:00Z"), utc(2012, 4, 23, 9, 15)),
        (.string("2012-4-9 4:8:16-0320"), utc(2012, 4, 9, 4, 8, 16, offsetMinutes: -200)),
        (.string("2012-04-23T10:20:30.400+02:30"), utc(2012, 4, 23, 10, 20, 30, 400_000, offsetMinutes: 150)),
        (.string("2012-04-23T10:20:30.400+02"), utc(2012, 4, 23, 10, 20, 30, 400_000, offsetMinutes: 120)),
        (.string("2012-04-23T10:20:30.400-02"), utc(2012, 4, 23, 10, 20, 30, 400_000, offsetMinutes: -120)),
        (.number(0), utc(1970, 1, 1)),
        (.number(19_999_999_999), utc(2603, 10, 11, 11, 33, 19)),
        (.number(20_000_000_001), utc(1970, 8, 20, 11, 33, 20, 1000)),
        (.number(1_549_316_052), utc(2019, 2, 4, 21, 34, 12)),
        (.number(1_549_316_052_104), utc(2019, 2, 4, 21, 34, 12, 104_000)),
        (.number(1_549_316_052_104_324), utc(2019, 2, 4, 21, 34, 12, 104_324)),
        (.number(1_549_316_052_104_324_096), utc(2019, 2, 4, 21, 34, 12, 104_324)),
        (.string("infinity"), DatetimeParse.maxDate), (.string("inf"), DatetimeParse.maxDate), (.string("inf "), DatetimeParse.maxDate),
        (.number(1e50), DatetimeParse.maxDate), (.number(.infinity), DatetimeParse.maxDate),
        (.string("-infinity"), DatetimeParse.minDate), (.string("-inf"), DatetimeParse.minDate),
    ])
    func datetimeParsing(value: Input, expected: Date) throws {
        let parsed: Date
        switch value {
        case .string(let s): parsed = try DatetimeParse.parseDatetime(s)
        case .number(let n): parsed = try DatetimeParse.parseDatetime(n)
        }
        #expect(abs(parsed.timeIntervalSince(expected)) < 2e-6, "\(parsed) != \(expected)")
    }

    @Test(arguments: ["x20120423091500", "2012-04-56T09:15:90", "2012-04-23T11:05:00-25:00", "nan"])
    func datetimeParsingErrors(value: String) {
        #expect(throws: ValueError.self) { _ = try DatetimeParse.parseDatetime(value) }
    }

    /// The parser is what decodes `Date` fields of responses.
    @Test func decodesResponseDates() throws {
        struct Model: Codable { var at: Date }
        func decode(_ json: String) throws -> Date {
            try AnthropicJSON.decoder().decode(Model.self, from: Data(json.utf8)).at
        }
        #expect(try decode(#"{"at": "2019-12-27T18:11:19.117Z"}"#) == utc(2019, 12, 27, 18, 11, 19, 117_000))
        #expect(abs(try decode(#"{"at": "2024-01-02T03:04:05.000600+00:00"}"#).timeIntervalSince(utc(2024, 1, 2, 3, 4, 5, 600))) < 1e-6)
        #expect(try decode(#"{"at": 1494012444}"#) == utc(2017, 5, 5, 19, 27, 24))
        #expect(try decode(#"{"at": 1549316052104}"#) == utc(2019, 2, 4, 21, 34, 12, 104_000))
        #expect(try decode(#"{"at": "2024-01-01"}"#) == utc(2024, 1, 1))
        #expect(throws: DecodingError.self) { _ = try decode(#"{"at": "x2012"}"#) }
    }
}

// MARK: - test_utils/test_json.py

@Suite("JSON encoding (test_utils/test_json.py)")
struct OpenapiDumpsTests {
    private func dumps<T: Encodable>(_ value: T) throws -> String {
        let e = AnthropicJSON.encoder()
        e.outputFormatting.insert(.sortedKeys)
        return String(decoding: try e.encode(value), as: UTF8.self)
    }

    @Test func basic() throws {
        let data: JSONValue = ["key": "value", "number": 42]
        #expect(String(decoding: try JSONValue.serialize(data, sortedKeys: true), as: UTF8.self) == #"{"key":"value","number":42}"#)
    }

    @Test func strVariant() throws {
        struct Payload: Encodable { var key: String; var when: ISODate }
        #expect(try dumps(Payload(key: "välue", when: ISODate(year: 2023, month: 1, day: 1))) == #"{"key":"välue","when":"2023-01-01"}"#)
    }

    @Test func datetimeSerialization() throws {
        struct Payload: Encodable { var datetime: Date }
        #expect(try dumps(Payload(datetime: utc(2023, 1, 1, 12))) == #"{"datetime":"2023-01-01T12:00:00Z"}"#)
        #expect(try dumps(Payload(datetime: utc(2023, 1, 1, 12, 0, 0, 600))) == #"{"datetime":"2023-01-01T12:00:00.0006Z"}"#)
    }

    @Test func dateSerialization() throws {
        struct Payload: Encodable { var date: ISODate; var list: [ISODate] }
        #expect(try dumps(Payload(date: "2023-01-01", list: ["2023-01-02"])) == #"{"date":"2023-01-01","list":["2023-01-02"]}"#)
    }

    @Test func modelSerializationUsesWireNames() throws {
        let usage = Usage(inputTokens: 10, outputTokens: 5)
        #expect(try dumps(usage) == #"{"input_tokens":10,"output_tokens":5}"#)
    }

    @Test func nonASCIIAndSlashesAreNotEscaped() throws {
        #expect(String(decoding: try JSONValue.serialize(["a": "x/y é"]), as: UTF8.self) == #"{"a":"x/y é"}"#)
    }
}

// MARK: - decoders/test_jsonl.py

@Suite("JSONL decoder (decoders/test_jsonl.py)")
struct JSONLDecoderTests {
    private func decoder(_ chunks: [Data], response: HTTPResponse? = nil) throws -> JSONLDecoder<JSONValue> {
        let stream = ByteStream { c in
            for chunk in chunks { c.yield(chunk) }
            c.finish()
        }
        return JSONLDecoder<JSONValue>(bytes: stream, response: response ?? .empty(200, for: dummyRequest), client: try makeTestClient())
    }

    private func decoder(_ chunks: [String]) throws -> JSONLDecoder<JSONValue> { try decoder(chunks.map { Data($0.utf8) }) }

    @Test func basic() async throws {
        var it = try decoder([#"{"foo":true}"# + "\n", #"{"bar":false}"# + "\n"]).makeAsyncIterator()
        #expect(try await it.next() == ["foo": true])
        #expect(try await it.next() == ["bar": false])
        #expect(try await it.next() == nil)
    }

    @Test func newLinesInJSON() async throws {
        var it = try decoder([#"{"content":"Hello, world!\nHow are you doing?"}"#]).makeAsyncIterator()
        #expect(try await it.next() == ["content": "Hello, world!\nHow are you doing?"])
    }

    @Test func multiByteCharacterMultipleChunks() async throws {
        var it = try decoder([
            Data(#"{"content":""#.utf8), Data([0xD0]), Data([0xB8, 0xD0, 0xB7, 0xD0]),
            Data([0xB2, 0xD0, 0xB5, 0xD1, 0x81, 0xD1, 0x82, 0xD0, 0xBD, 0xD0, 0xB8]), Data("\"}\n".utf8),
        ]).makeAsyncIterator()
        #expect(try await it.next() == ["content": "известни"])
    }

    @Test func droppedDecoderLetsGoOfItsIteratorAtOnce() async throws {
        let body = CountingBody(strings: ["1\n2\n", "3\n"])
        let response = body.response(headers: ["content-type": "application/x-jsonl"], for: dummyRequest)
        do {
            let d = JSONLDecoder<JSONValue>(response: response, client: try makeTestClient())
            var it = d.makeAsyncIterator()
            #expect(try await it.next() == 1)
            #expect(try await it.next() == 2)
            withExtendedLifetime(it) { #expect(body.closeCount == 0) }
        }
        #expect(body.closeCount == 1)
    }

    @Test func blankLinesAreSkipped() async throws {
        var values: [JSONValue] = []
        for try await v in try decoder(["1\r\n", "\r\n", "2\n\n"]) { values.append(v) }
        #expect(values == [1, 2])
    }

    @Test func throughTheClient() async throws {
        let server = MockServer { req, _ in CountingBody(strings: ["{\"a\":1}\n{\"a\"", ":2}\n"]).response(headers: ["content-type": "application/x-jsonl"], for: req) }
        let client = try makeTestClient(server)
        let response = try await client.requestJSONLResponse(JSONValue.self, FinalRequestOptions(method: "get", url: "/results"))
        var values: [JSONValue] = []
        for try await v in try await response.parse() { values.append(v) }
        #expect(values == [["a": 1], ["a": 2]])
        #expect(response.http.isClosed)
    }
}
