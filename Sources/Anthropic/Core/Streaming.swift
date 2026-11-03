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
///
/// Reading is lenient where the element type allows it (`LenientStreamEvent`, which the Messages and Sessions event
/// unions adopt): an event that does not decode (a field that drifted from the schema) is handed out as the type's
/// `unknown` case holding its JSON, and the stream goes on, as the Python and TypeScript SDKs do. An `error` event
/// ends the stream with the typed error for its `error.type` (`BaseClient.makeStreamError`).
public final class Stream<Element: Sendable>: AsyncSequence, @unchecked Sendable {
    public let response: HTTPResponse
    let client: BaseClient
    let state: State

    /// Makes an element of the `data` (never empty) of one event.
    typealias Decode = @Sendable (ServerSentEvent, HTTPResponse, BaseClient) throws -> Element

    init(response: HTTPResponse, client: BaseClient, decode: @escaping Decode) {
        self.response = response
        self.client = client
        self.state = State(response: response, client: client, decode: decode)
    }

    /// The raw server-sent events, before JSON parsing and event-name filtering.
    public static func rawEvents(_ response: HTTPResponse) -> AsyncThrowingStream<ServerSentEvent, Error> {
        SSEDecoder.events(from: response.bytes())
    }

    /// The iteration state shared by the stream and its iterators (`__stream__`). Dropping the last
    /// reference to it closes the response.
    final class State: @unchecked Sendable {
        // Created on first use: the body is only taken when iteration starts, so it can still be
        // read raw (`stream.response.read()`) before that.
        private var events: AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator?
        let response: HTTPResponse
        let client: BaseClient
        let decode: Decode
        private var finished = false

        init(response: HTTPResponse, client: BaseClient, decode: @escaping Decode) {
            self.response = response
            self.client = client
            self.decode = decode
        }

        deinit { response.close() }

        func finish() {
            finished = true
            response.close()
        }

        func next() async throws -> Element? {
            if finished { return nil }
            if events == nil {
                // A stream of a traced call tells the call's span how the application reads it.
                response.streamObserver?.begin()
                events = client.makeSSEEvents(response.bytes()).makeAsyncIterator()
            }
            do {
                while let sse = try await events!.next() {
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
                        throw client.makeStreamError(message, body: body, response: response)
                    }
                    if sse.data.isEmpty { continue }
                    let item = try decode(sse, response, client)
                    response.streamObserver?.item((item as? any ObservedStreamItem)?.observedItem ?? item)
                    return item
                }
                response.streamObserver?.end(.read, error: nil)
                finish()
                return nil
            } catch {
                if !finished { response.streamObserver?.end(.failed, error: error) }
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
    public func close() {
        response.streamObserver?.end(.closed, error: nil)
        state.finish()
    }
}

extension Stream: TracedEventStream {}

extension Stream where Element: Decodable {
    /// A stream that decodes each event's `data` into `Element`, leniently when `Element` is a `LenientStreamEvent`.
    convenience init(response: HTTPResponse, client: BaseClient) {
        self.init(response: response, client: client) { sse, response, client in
            try client.decodeStreamEvent(Element.self, Data(sse.data.utf8), response: response)
        }
    }
}

/// An event union whose undecodable events a stream hands out instead of failing: the Messages and Sessions event
/// unions, whose `unknown` case holds an event's JSON.
///
/// An event of a type this SDK version does not know already decodes as `unknown`; this also covers an event of a
/// known type that does not decode because a field drifted from the schema (a `null` where a number was expected, a
/// required key left out), which the Python SDK's `construct_type` and the TypeScript SDK's casts let through too.
public protocol LenientStreamEvent: Decodable, Sendable {
    /// The value for an event that does not decode: the `unknown` case holding its JSON.
    static func undecodable(_ json: JSONValue) -> Self
}

extension RawMessageStreamEvent: LenientStreamEvent {
    public static func undecodable(_ json: JSONValue) -> RawMessageStreamEvent { .unknown(json) }
}

extension BetaRawMessageStreamEvent: LenientStreamEvent {
    public static func undecodable(_ json: JSONValue) -> BetaRawMessageStreamEvent { .unknown(json) }
}

extension BetaManagedAgentsStreamSessionEvents: LenientStreamEvent {
    public static func undecodable(_ json: JSONValue) -> BetaManagedAgentsStreamSessionEvents { .unknown(json) }
}

extension BetaManagedAgentsStreamSessionThreadEvents: LenientStreamEvent {
    public static func undecodable(_ json: JSONValue) -> BetaManagedAgentsStreamSessionThreadEvents { .unknown(json) }
}

/// A stream element that tells a call's span which value to observe (a `JSONStreamEvent`: its typed event).
protocol ObservedStreamItem {
    var observedItem: Any { get }
}

extension BaseClient {
    /// Decodes one event of a stream. A `LenientStreamEvent` that is JSON but does not decode becomes the type's
    /// `unknown` case; anything else that does not decode throws `APIResponseValidationError`, as a response does.
    func decodeStreamEvent<T: Decodable>(_ type: T.Type, _ data: Data, response: HTTPResponse) throws -> T {
        do {
            return try decodeData(T.self, data, response: response)
        } catch let error as APIResponseValidationError {
            guard let lenient = T.self as? any LenientStreamEvent.Type, let json = error.body,
                  let value = lenient.undecodable(json) as? T
            else { throw error }
            return value
        }
    }
}

