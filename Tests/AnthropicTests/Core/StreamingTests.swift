// Port of tests/test_streaming.py (async variants).

import Foundation
import Testing
@testable import Anthropic

private func byteStream(_ chunks: [Data]) -> ByteStream {
    ByteStream { c in
        for chunk in chunks { c.yield(chunk) }
        c.finish()
    }
}

private func bytes(_ chunks: [String]) -> ByteStream { byteStream(chunks.map { Data($0.utf8) }) }

/// `make_event_iterator`: the SSE events of a body.
private func events(_ chunks: [Data]) -> AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator {
    SSEDecoder.events(from: byteStream(chunks)).makeAsyncIterator()
}

private func events(_ chunks: [String]) -> AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator {
    events(chunks.map { Data($0.utf8) })
}

private func assertEmpty(_ it: inout AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator, sourceLocation: SourceLocation = #_sourceLocation) async throws {
    #expect(try await it.next() == nil, sourceLocation: sourceLocation)
}

@Suite("SSE decoding (test_streaming.py)")
struct SSEDecodingTests {
    @Test func basic() async throws {
        var it = events(["event: completion\n", #"data: {"foo":true}"# + "\n", "\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "completion")
        #expect(try sse.json() == ["foo": true])
        try await assertEmpty(&it)
    }

    @Test func dataMissingEvent() async throws {
        var it = events([#"data: {"foo":true}"# + "\n", "\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == nil)
        #expect(try sse.json() == ["foo": true])
        try await assertEmpty(&it)
    }

    @Test func eventMissingData() async throws {
        var it = events(["event: ping\n", "\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(sse.data == "")
        try await assertEmpty(&it)
    }

    @Test func multipleEvents() async throws {
        var it = events(["event: ping\n", "\n", "event: completion\n", "\n"])
        var sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(sse.data == "")
        sse = try #require(try await it.next())
        #expect(sse.event == "completion")
        #expect(sse.data == "")
        try await assertEmpty(&it)
    }

    @Test func multipleEventsWithData() async throws {
        var it = events(["event: ping\n", #"data: {"foo":true}"# + "\n", "\n", "event: completion\n", #"data: {"bar":false}"# + "\n", "\n"])
        var sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(try sse.json() == ["foo": true])
        sse = try #require(try await it.next())
        #expect(sse.event == "completion")
        #expect(try sse.json() == ["bar": false])
        try await assertEmpty(&it)
    }

    @Test func multipleDataLinesWithEmptyLine() async throws {
        var it = events(["event: ping\n", "data: {\n", #"data: "foo":"# + "\n", "data: \n", "data:\n", "data: true}\n", "\n\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(try sse.json() == ["foo": true])
        #expect(sse.data == "{\n\"foo\":\n\n\ntrue}")
        try await assertEmpty(&it)
    }

    @Test func dataJSONEscapedDoubleNewLine() async throws {
        var it = events(["event: ping\n", #"data: {"foo": "my long\n\ncontent"}"#, "\n\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(try sse.json() == ["foo": "my long\n\ncontent"])
        try await assertEmpty(&it)
    }

    @Test func multipleDataLines() async throws {
        var it = events(["event: ping\n", "data: {\n", #"data: "foo":"# + "\n", "data: true}\n", "\n\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(try sse.json() == ["foo": true])
        try await assertEmpty(&it)
    }

    @Test func specialNewLineCharacter() async throws {
        var it = events([
            Data((#"data: {"content":" culpa"}"# + "\n").utf8), Data("\n".utf8),
            Data(#"data: {"content":" "#.utf8) + Data([0xE2, 0x80, 0xA8]) + Data("\"}\n".utf8), Data("\n".utf8),
            Data((#"data: {"content":"foo"}"# + "\n").utf8), Data("\n".utf8),
        ])
        var sse = try #require(try await it.next())
        #expect(sse.event == nil)
        #expect(try sse.json() == ["content": " culpa"])
        sse = try #require(try await it.next())
        #expect(try sse.json() == ["content": " \u{2028}"])
        sse = try #require(try await it.next())
        #expect(try sse.json() == ["content": "foo"])
        try await assertEmpty(&it)
    }

    @Test func multiByteCharacterMultipleChunks() async throws {
        // bytes taken from the string 'известни' and arbitrarily split so that some multi-byte
        // characters span multiple chunks
        var it = events([
            Data(#"data: {"content":""#.utf8), Data([0xD0]), Data([0xB8, 0xD0, 0xB7, 0xD0]),
            Data([0xB2, 0xD0, 0xB5, 0xD1, 0x81, 0xD1, 0x82, 0xD0, 0xBD, 0xD0, 0xB8]), Data("\"}\n".utf8), Data("\n".utf8),
        ])
        let sse = try #require(try await it.next())
        #expect(sse.event == nil)
        #expect(try sse.json() == ["content": "известни"])
    }

    @Test func crlfSplitAcrossChunks() async throws {
        var it = events(["event: ping\r", "\ndata: {}\r\n", "\r", "\n"])
        let sse = try #require(try await it.next())
        #expect(sse.event == "ping")
        #expect(sse.data == "{}")
        try await assertEmpty(&it)
    }
}

@Suite("Stream (test_streaming.py)")
struct StreamTests {
    private func makeStream(_ chunks: [String], body: CountingBody? = nil) throws -> SSEStream<JSONValue> {
        let client = try makeTestClient()
        let body = body ?? CountingBody(strings: chunks)
        return SSEStream<JSONValue>(response: body.response(for: dummyRequest), client: client)
    }

    @Test func errorType() async throws {
        let stream = try makeStream(["event: error\n", #"data: {"type": "error", "error": {"type": "overloaded_error", "message": "Overloaded"}}"# + "\n\n"])
        var it = stream.makeAsyncIterator()
        do {
            _ = try await it.next()
            Issue.record("expected an APIStatusError")
        } catch let e as APIStatusError {
            #expect(e.type == .overloadedError)
            #expect("\(e)".contains("Overloaded"))
        }
    }

    @Test func pingAndUnnamedEventsAreSkipped() async throws {
        let stream = try makeStream(["event: ping\ndata: {}\n\n", "data: {\"a\": 1}\n\n", "event: completion\ndata: {\"b\": 2}\n\n", "event: x\n\n"])
        var values: [JSONValue] = []
        for try await v in stream { values.append(v) }
        #expect(values == [["b": 2]])
        #expect(stream.response.isClosed)
    }

    @Test func iteratingAgainContinuesWhereItStopped() async throws {
        let stream = try makeStream(["event: a\ndata: 1\n\n", "event: a\ndata: 2\n\n", "event: a\ndata: 3\n\n"])
        var it = stream.makeAsyncIterator()
        #expect(try await it.next() == 1)
        var rest: [JSONValue] = []
        for try await v in stream { rest.append(v) }
        #expect(rest == [2, 3])
    }

    /// `TestAsync.test_dropped_response_is_closed_at_once` for a stream that is dropped mid-iteration.
    @Test func droppedResponseIsClosedAtOnce() async throws {
        let body = CountingBody(strings: Array(repeating: "event: completion\ndata: {}\n\n", count: 100))
        do {
            let stream = try makeStream([], body: body)
            var it = stream.makeAsyncIterator()
            _ = try await it.next()
            withExtendedLifetime(it) { #expect(body.closeCount == 0) }
        }
        #expect(body.closeCount == 1)
    }

    /// The `raw_response` variants: the stream parsed from a raw response.
    @Test func droppedRawResponseStreamIsClosedAtOnce() async throws {
        let body = CountingBody(strings: Array(repeating: "event: completion\ndata: {}\n\n", count: 100))
        let client = try makeTestClient(MockServer { req, _ in body.response(for: req) })
        do {
            let response = try await client.requestStreamResponse(JSONValue.self, FinalRequestOptions(method: "get", url: "/stream"))
            var it = try await response.parse().makeAsyncIterator()
            _ = try await it.next()
            withExtendedLifetime(it) { #expect(body.closeCount == 0) }
        }
        #expect(body.closeCount == 1)
    }

    /// `TestAsync.test_held_response_stays_open`.
    @Test func heldResponseStaysOpen() async throws {
        let body = CountingBody(strings: Array(repeating: "event: completion\ndata: {}\n\n", count: 100))
        var kept: SSEStream<JSONValue>? = try makeStream([], body: body)
        #expect(body.closeCount == 0)
        var it: SSEStream<JSONValue>.AsyncIterator? = kept!.makeAsyncIterator()
        kept = nil
        _ = try await it!.next()
        #expect(body.closeCount == 0)
        _ = try await it!.next()
        #expect(body.closeCount == 0)
        it = nil
        #expect(body.closeCount == 1)
    }

    @Test func bodyIsReadLazily() async throws {
        let pulled = Locked(0)
        let source = AsyncThrowingStream<Data, Error>(unfolding: {
            let n = pulled.withValue { v -> Int in
                v += 1
                return v
            }
            return n <= 100 ? Data("event: completion\ndata: \(n)\n\n".utf8) : nil
        })
        let client = try makeTestClient()
        let stream = SSEStream<JSONValue>(response: HTTPResponse(statusCode: 200, stream: source, request: dummyRequest), client: client)
        var it = stream.makeAsyncIterator()
        #expect(try await it.next() == 1)
        #expect(try await it.next() == 2)
        #expect(pulled.value <= 3)
        stream.close()
        #expect(try await it.next() == nil)
    }

    @Test func parseTwiceGivesTheSameStream() async throws {
        let client = try makeTestClient(MockServer { req, _ in CountingBody(strings: ["event: a\ndata: 1\n\n"]).response(for: req) })
        let response = try await client.requestStreamResponse(JSONValue.self, FinalRequestOptions(method: "get", url: "/stream"))
        let a = try await response.parse()
        let b = try await response.parse()
        #expect(a === b)
    }
}
