import Foundation

/// One Server-Sent Event (`_streaming.ServerSentEvent`).
public struct ServerSentEvent: Sendable, Hashable, CustomStringConvertible {
    public let event: String?
    public let data: String
    public let id: String?
    public let retry: Int?
    /// The original wire lines this event was decoded from.
    public let raw: [String]

    public init(event: String? = nil, data: String? = nil, id: String? = nil, retry: Int? = nil, raw: [String] = []) {
        self.event = (event?.isEmpty ?? true) ? nil : event
        self.data = data ?? ""
        self.id = id
        self.retry = retry
        self.raw = raw
    }

    public func json() throws -> JSONValue { try JSONValue.parse(data) }

    public var description: String {
        "ServerSentEvent(event=\(event ?? "None"), data=\(data), id=\(id ?? "None"), retry=\(retry.map(String.init) ?? "None"))"
    }
}

/// Decodes a byte stream into Server-Sent Events (`_streaming.SSEDecoder`).
public struct SSEDecoder: Sendable {
    private var event: String? = nil
    private var dataLines: [String] = []
    private var lastEventID: String? = nil
    private var retry: Int? = nil
    private var rawLines: [String] = []

    public init() {}

    /// Feeds one line (without its terminator). Returns an event when the line completes one.
    public mutating func decode(_ line: String) -> ServerSentEvent? {
        if line.isEmpty {
            if (event ?? "").isEmpty && dataLines.isEmpty && (lastEventID ?? "").isEmpty && retry == nil {
                rawLines = []
                return nil
            }
            let sse = ServerSentEvent(event: event, data: dataLines.joined(separator: "\n"), id: lastEventID, retry: retry, raw: rawLines)
            // Per the SSE spec, the last event id is not reset.
            event = nil
            dataLines = []
            retry = nil
            rawLines = []
            return sse
        }
        rawLines.append(line)
        if line.hasPrefix(":") { return nil }
        let fieldname: String
        var value: String
        if let colon = line.firstIndex(of: ":") {
            fieldname = String(line[..<colon])
            value = String(line[line.index(after: colon)...])
        } else {
            fieldname = line
            value = ""
        }
        if value.hasPrefix(" ") { value.removeFirst() }
        switch fieldname {
        case "event": event = value
        case "data": dataLines.append(value)
        case "id": if !value.contains("\0") { lastEventID = value }
        case "retry": if let r = Int(value) { retry = r }
        default: break
        }
        return nil
    }

    /// Splits raw bytes into SSE chunks the way `_iter_chunks` does, then decodes each line. The
    /// body is read only as events are requested.
    public static func events(from bytes: ByteStream) -> AsyncThrowingStream<ServerSentEvent, Error> {
        let state = SSEEventIterator(bytes)
        return AsyncThrowingStream(unfolding: { try await state.next() })
    }

    /// Decodes all events in a complete byte buffer.
    public static func events(in data: Data) -> [ServerSentEvent] {
        var decoder = SSEDecoder()
        var out: [ServerSentEvent] = []
        var pending = Data()
        func emit(_ chunk: Data) {
            for line in splitLines(chunk) { if let sse = decoder.decode(line) { out.append(sse) } }
        }
        for line in splitLinesKeepEnds(data) {
            pending.append(line)
            if pending.hasSuffix([0x0D, 0x0D]) || pending.hasSuffix([0x0A, 0x0A]) || pending.hasSuffix([0x0D, 0x0A, 0x0D, 0x0A]) {
                emit(pending)
                pending = Data()
            }
        }
        if !pending.isEmpty { emit(pending) }
        return out
    }
}

extension Data {
    func hasSuffix(_ bytes: [UInt8]) -> Bool {
        guard count >= bytes.count else { return false }
        return Array(suffix(bytes.count)) == bytes
    }
}

/// `bytes.splitlines(keepends=True)` for `\r`, `\n` and `\r\n` terminators.
func splitLinesKeepEnds(_ data: Data) -> [Data] {
    var out: [Data] = []
    let bytes = [UInt8](data)
    var start = 0
    var i = 0
    while i < bytes.count {
        if bytes[i] == 0x0A {
            out.append(Data(bytes[start...i]))
            start = i + 1
        } else if bytes[i] == 0x0D {
            if i + 1 < bytes.count, bytes[i + 1] == 0x0A {
                out.append(Data(bytes[start...(i + 1)]))
                i += 1
            } else {
                out.append(Data(bytes[start...i]))
            }
            start = i + 1
        }
        i += 1
    }
    if start < bytes.count { out.append(Data(bytes[start...])) }
    return out
}

/// `bytes.splitlines()` decoded as UTF-8.
func splitLines(_ data: Data) -> [String] {
    splitLinesKeepEnds(data).map { line in
        var l = [UInt8](line)
        while let last = l.last, last == 0x0A || last == 0x0D { l.removeLast() }
        return String(decoding: l, as: UTF8.self)
    }
}

/// Pull-based SSE decoding over a byte stream (`SSEDecoder.aiter_bytes`): reads a chunk of the
/// body only when the next event is requested.
final class SSEEventIterator: @unchecked Sendable {
    private var bytes: ByteStream.AsyncIterator
    private var decoder = SSEDecoder()
    private var ready: [ServerSentEvent] = []
    private var pending = Data()
    private var done = false

    init(_ bytes: ByteStream) { self.bytes = bytes.makeAsyncIterator() }

    private func emit(_ chunk: Data) {
        for line in splitLines(chunk) {
            if let sse = decoder.decode(line) { ready.append(sse) }
        }
    }

    func next() async throws -> ServerSentEvent? {
        while true {
            if !ready.isEmpty { return ready.removeFirst() }
            if done { return nil }
            guard let chunk = try await bytes.next() else {
                done = true
                if !pending.isEmpty {
                    emit(pending)
                    pending = Data()
                }
                continue
            }
            for line in splitLinesKeepEnds(chunk) {
                pending.append(line)
                if pending.hasSuffix([0x0D, 0x0D]) || pending.hasSuffix([0x0A, 0x0A]) || pending.hasSuffix([0x0D, 0x0A, 0x0D, 0x0A]) {
                    emit(pending)
                    pending = Data()
                }
            }
        }
    }
}

/// An asynchronous stream of decoded server-sent events (`_streaming.AsyncStream`).
///
/// Iterate it with `for try await event in stream`. The body is read only as events are requested.
/// The underlying response is closed when iteration finishes or fails, when `close()` is called,
/// or as soon as the stream and every iterator over it have been dropped.
///
/// Like Python's, a stream has a single position: iterating it again continues where the previous
/// iteration stopped. Don't iterate one stream from several tasks at once.
public final class Stream<Element: Decodable & Sendable>: AsyncSequence, @unchecked Sendable {
    public let response: HTTPResponse
    let client: BaseClient
    let state: State

    init(response: HTTPResponse, client: BaseClient) {
        self.response = response
        self.client = client
        self.state = State(events: client.makeSSEEvents(response.bytes()), response: response, client: client)
    }

    /// The raw server-sent events, before JSON parsing and event-name filtering.
    public static func rawEvents(_ response: HTTPResponse) -> AsyncThrowingStream<ServerSentEvent, Error> {
        SSEDecoder.events(from: response.bytes())
    }

    /// The iteration state shared by the stream and its iterators (`__stream__`). Dropping the last
    /// reference to it closes the response.
    final class State: @unchecked Sendable {
        private var events: AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator
        let response: HTTPResponse
        let client: BaseClient
        private var finished = false

        init(events: AsyncThrowingStream<ServerSentEvent, Error>, response: HTTPResponse, client: BaseClient) {
            self.events = events.makeAsyncIterator()
            self.response = response
            self.client = client
        }

        deinit { response.close() }

        func finish() {
            finished = true
            response.close()
        }

        func next() async throws -> Element? {
            if finished { return nil }
            do {
                while let sse = try await events.next() {
                    if sse.event == "ping" { continue }
                    guard let name = sse.event else { continue }
                    if name == "error" {
                        var body: JSONValue = .string(sse.data)
                        let message: String
                        if let parsed = try? sse.json() {
                            body = parsed
                            message = pythonRepr(parsed)
                        } else {
                            message = sse.data.isEmpty ? "Error code: \(response.statusCode)" : sse.data
                        }
                        throw client.makeStatusError(message, body: body, response: response)
                    }
                    if sse.data.isEmpty { continue }
                    return try client.decodeData(Element.self, Data(sse.data.utf8), response: response)
                }
                finish()
                return nil
            } catch {
                finish()
                throw error
            }
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let state: State
        public mutating func next() async throws -> Element? { try await state.next() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(state: state) }

    /// Closes the response and releases the connection. Called automatically when the stream is
    /// read to completion.
    public func close() { state.finish() }
}

