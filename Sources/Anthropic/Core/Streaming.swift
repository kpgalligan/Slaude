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
///
/// A stream ends normally only when its body ended, and, for a Messages stream (`StreamEndEvent`), only after its
/// `message_stop` event. Otherwise reading it throws, and every later read throws the same error:
///
/// * `CancellationError` when the reading task is cancelled before that, or when a Messages stream was closed
///   (`close()`) before `message_stop`. The response is closed at once, which cancels its request, and nothing more
///   of the body is read.
/// * `StreamEndedEarlyError` when a Messages stream's body ended, or its connection broke, before `message_stop`.
///
/// A cancel or `close()` after `message_stop` ends a Messages stream normally. A stream without an end event (a
/// Session's events) ends normally when it is closed.
public final class Stream<Element: Sendable>: AsyncSequence, @unchecked Sendable {
    public let response: HTTPResponse
    let client: BaseClient
    let state: State

    /// Makes an element of the `data` (never empty) of one event.
    typealias Decode = @Sendable (ServerSentEvent, HTTPResponse, BaseClient) throws -> Element

    init(response: HTTPResponse, client: BaseClient, decode: @escaping Decode) {
        self.response = response
        self.client = client
        self.state = State(response: response, client: client, decode: decode,
                           endEvent: (Element.self as? any StreamEndEvent.Type)?.endEventName)
    }

    /// The raw server-sent events, before JSON parsing and event-name filtering.
    public static func rawEvents(_ response: HTTPResponse) -> AsyncThrowingStream<ServerSentEvent, Error> {
        SSEDecoder.events(from: response.bytes())
    }

    /// Whether the stream had its end event (`message_stop`); false for a stream without one (`StreamEndEvent`).
    public var receivedEndEvent: Bool { state.receivedEndEvent }

    /// The iteration state shared by the stream and its iterators (`__stream__`). Dropping the last
    /// reference to it closes the response.
    final class State: @unchecked Sendable {
        /// How a stream ended: what every later read returns.
        enum Ending {
            case done
            case failed(any Error)
        }

        // Created on first use: the body is only taken when iteration starts, so it can still be
        // read raw (`stream.response.read()`) before that.
        private var events: AsyncThrowingStream<ServerSentEvent, Error>.AsyncIterator?
        let response: HTTPResponse
        let client: BaseClient
        let decode: Decode
        /// The event without which the stream is not whole (`message_stop`), if it has one.
        let endEvent: String?
        // `close()` may come from another task than the one reading, so these two are behind the lock.
        private let lock = NSLock()
        private var ending: Ending?
        private var sawEndEvent = false

        init(response: HTTPResponse, client: BaseClient, decode: @escaping Decode, endEvent: String?) {
            self.response = response
            self.client = client
            self.decode = decode
            self.endEvent = endEvent
        }

        deinit { response.close() }

        var receivedEndEvent: Bool { lock.withLock { sawEndEvent } }

        /// Whether the stream is not whole yet: it has an end event and has not had it.
        private var isIncomplete: Bool { lock.withLock { endEvent != nil && !sawEndEvent } }
        /// Whether the stream is whole: it had its end event. One without an end event never knows.
        private var isWhole: Bool { lock.withLock { endEvent != nil && sawEndEvent } }

        /// Ends the stream with `how`, unless it has ended already, and closes the response (which cancels its
        /// request). Returns the ending that holds.
        @discardableResult
        func end(_ how: Ending) -> Ending {
            let ending: Ending = lock.withLock {
                if let ending = self.ending { return ending }
                self.ending = how
                return how
            }
            response.close()
            return ending
        }

        /// The consumer closed the stream: one that is not whole yet is cancelled. A stream without an end event
        /// (a Session's events) is closed to stop it, which ends it.
        func close() {
            end(isIncomplete ? .failed(CancellationError()) : .done)
        }

        private func result(_ ending: Ending) throws -> Element? {
            switch ending {
            case .done: return nil
            case .failed(let error): throw error
            }
        }

        /// Ends the stream because its task was cancelled: only a stream that is whole ends normally.
        private func cancelled() throws -> Element? {
            if isWhole {
                response.streamObserver?.end(.read, error: nil)
                return try result(end(.done))
            }
            response.streamObserver?.end(.closed, error: nil)
            return try result(end(.failed(CancellationError())))
        }

        /// Ends the stream with `error`. Every later read throws it again while the stream is not whole, so that
        /// nothing reads a partial Message as the whole one; otherwise later reads end, as Python's do.
        private func failed(_ error: any Error) throws -> Element? {
            response.streamObserver?.end(.failed, error: error)
            if case .failed(let held) = end(isIncomplete ? .failed(error) : .done) { throw held }
            throw error
        }

        /// Ends the stream with an error of reading its body: a cancel, or a broken connection.
        private func failedReading(_ error: any Error) throws -> Element? {
            if Task.isCancelled || isCancellation(error) { return try cancelled() }
            guard let endEvent, isIncomplete, !(error is AnthropicError) else { return try failed(error) }
            return try failed(StreamEndedEarlyError(response: response, endEvent: endEvent, underlying: error))
        }

        func next() async throws -> Element? {
            if let ending = lock.withLock({ self.ending }) { return try result(ending) }
            // A cancelled task reads nothing more. (An `AsyncThrowingStream` ends without an error when its task is
            // cancelled, so the body's end alone would look like a normal one.)
            if Task.isCancelled { return try cancelled() }
            if events == nil {
                // A stream of a traced call tells the call's span how the application reads it.
                response.streamObserver?.begin()
                events = client.makeSSEEvents(response.bytes()).makeAsyncIterator()
            }
            while true {
                let next: ServerSentEvent?
                do {
                    next = try await events!.next()
                } catch {
                    if let ending = lock.withLock({ self.ending }) { return try result(ending) }
                    return try failedReading(error)
                }
                // Closed by another task while this one waited.
                if let ending = lock.withLock({ self.ending }) { return try result(ending) }
                guard let sse = next else { break }
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
                    return try failed(client.makeStreamError(message, body: body, response: response))
                }
                if name == endEvent { lock.withLock { sawEndEvent = true } }
                if sse.data.isEmpty { continue }
                let item: Element
                do {
                    item = try decode(sse, response, client)
                } catch {
                    return try failed(error)
                }
                response.streamObserver?.item((item as? any ObservedStreamItem)?.observedItem ?? item)
                return item
            }
            // The body ended: because the task was cancelled, or before the end event, or whole.
            if Task.isCancelled { return try cancelled() }
            if let endEvent, isIncomplete {
                return try failed(StreamEndedEarlyError(response: response, endEvent: endEvent))
            }
            response.streamObserver?.end(.read, error: nil)
            return try result(end(.done))
        }
    }

    public struct AsyncIterator: AsyncIteratorProtocol {
        let state: State
        public mutating func next() async throws -> Element? { try await state.next() }
    }

    public func makeAsyncIterator() -> AsyncIterator { AsyncIterator(state: state) }

    /// Closes the response and releases the connection. Called automatically when the stream is
    /// read to completion. A read of a stream closed before its end throws `CancellationError`.
    public func close() {
        response.streamObserver?.end(.closed, error: nil)
        state.close()
    }

    /// Ends the stream with `error`, which every later read throws, and closes the response: for a reader of the
    /// events that cannot go on (a tool input that does not parse).
    func fail(_ error: any Error) {
        response.streamObserver?.end(.failed, error: error)
        state.end(.failed(error))
    }
}

/// Whether `error` is a cancel: Swift's, or a transport's (`URLError.cancelled`).
func isCancellation(_ error: any Error) -> Bool {
    if error is CancellationError { return true }
    if let e = error as? URLError, e.code == .cancelled { return true }
    return false
}

/// An event union whose stream is whole only once its end event arrived: the Messages events, which end with
/// `message_stop`. A `Stream` of one that ends before that event throws `StreamEndedEarlyError`, or
/// `CancellationError` when it was cancelled.
public protocol StreamEndEvent {
    /// The SSE event name that ends the stream.
    static var endEventName: String { get }
}

extension RawMessageStreamEvent: StreamEndEvent {
    public static var endEventName: String { "message_stop" }
}

extension BetaRawMessageStreamEvent: StreamEndEvent {
    public static var endEventName: String { "message_stop" }
}

extension JSONStreamEvent: StreamEndEvent where Event: StreamEndEvent {
    public static var endEventName: String { Event.endEventName }
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

