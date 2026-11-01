import Foundation

/// A response from an API call, before (or after) its body is parsed
/// (`_response.AsyncAPIResponse`). Returned by `withRawResponse` and `withStreamingResponse`.
///
/// Parsed values are cached: `parse()` twice gives the same value (and, for a stream, the same
/// `Stream` object), and a value middleware already parsed is handed back as is.
public struct APIResponse<T: Sendable>: Sendable {
    public let http: HTTPResponse
    public let options: FinalRequestOptions
    public let retriesTaken: Int
    let client: BaseClient
    let parser: @Sendable (APIResponse<T>) async throws -> T
    let cache: ParseCache

    init(http: HTTPResponse, options: FinalRequestOptions, retriesTaken: Int, client: BaseClient, cache: ParseCache = ParseCache(),
         parser: @escaping @Sendable (APIResponse<T>) async throws -> T)
    {
        self.http = http
        self.options = options
        self.retriesTaken = retriesTaken
        self.client = client
        self.cache = cache
        self.parser = parser
    }

    init(_ raw: RawAPIResponse, client: BaseClient, parser: @escaping @Sendable (APIResponse<T>) async throws -> T) {
        self.init(http: raw.http, options: raw.options, retriesTaken: raw.retriesTaken, client: raw.client ?? client,
                  cache: raw.cache, parser: parser)
    }

    public var headers: HTTPHeaders { http.headers }
    public var statusCode: Int { http.statusCode }
    public var httpRequest: HTTPRequest { http.request }
    public var url: URL { http.request.url }
    public var method: String { http.request.method }
    public var isClosed: Bool { http.isClosed }
    public var elapsed: TimeInterval { http.elapsed }
    /// The `request-id` header the API attaches to every response.
    public var requestID: String? { http.headers["request-id"] }

    /// Parses the body into the method's return type.
    public func parse() async throws -> T {
        try await cache.value(T.self) { try await parser(self) }
    }

    /// Parses the body into a different type than the method's own.
    public func parse<U: Decodable & Sendable>(as type: U.Type) async throws -> U {
        try await cache.value(U.self) { try await client.decodeBody(U.self, from: http) }
    }

    /// Parses the body as a stream of server-sent events of `E` (Python's `parse(to=AsyncStream[E])`).
    public func parse<E: Decodable & Sendable>(as type: Stream<E>.Type) async throws -> Stream<E> {
        try await cache.value(Stream<E>.self) { Stream<E>(response: http, client: client) }
    }

    /// Parses the body as JSON Lines of `E` (Python's `parse(to=AsyncJSONLDecoder[E])`).
    public func parse<E: Decodable & Sendable>(as type: JSONLDecoder<E>.Type) async throws -> JSONLDecoder<E> {
        try await cache.value(JSONLDecoder<E>.self) { JSONLDecoder<E>(response: http, client: client) }
    }

    /// Reads the whole body.
    public func read() async throws -> Data { try await http.read() }
    public func text() async throws -> String { try await http.text() }
    public func json() async throws -> JSONValue { try JSONValue.parse(try await http.read()) }

    /// Iterates over the raw body chunks.
    public func iterBytes() -> ByteStream { http.bytes() }

    /// Iterates over the body line by line (`\n`, `\r` and `\r\n` end a line), reading the body
    /// only as lines are requested.
    public func iterLines() -> AsyncThrowingStream<String, Error> {
        let state = LineIterator(http.bytes())
        return AsyncThrowingStream(unfolding: { try await state.next() })
    }

    public func close() { http.close() }
}

/// Pull-based line splitting over a byte stream (httpx's `aiter_lines`).
final class LineIterator: @unchecked Sendable {
    private var bytes: ByteStream.AsyncIterator
    private var buffer = Data()
    private var done = false

    init(_ bytes: ByteStream) { self.bytes = bytes.makeAsyncIterator() }

    func next() async throws -> String? {
        while true {
            if let nl = buffer.firstIndex(where: { $0 == 0x0A || $0 == 0x0D }) {
                var next = buffer.index(after: nl)
                if buffer[nl] == 0x0D {
                    // A `\r` at the end of the buffer may be the first half of `\r\n`.
                    if next == buffer.endIndex && !done {
                        if try await fill() { continue }
                    }
                    if next < buffer.endIndex, buffer[next] == 0x0A { next = buffer.index(after: next) }
                }
                let line = String(decoding: buffer[buffer.startIndex..<nl], as: UTF8.self)
                buffer = Data(buffer[next...])
                return line
            }
            if done {
                if buffer.isEmpty { return nil }
                let line = String(decoding: buffer, as: UTF8.self)
                buffer = Data()
                return line
            }
            _ = try await fill()
        }
    }

    /// Reads one more chunk; returns whether there was one.
    private func fill() async throws -> Bool {
        if let chunk = try await bytes.next() {
            buffer.append(chunk)
            return true
        }
        done = true
        return false
    }
}

/// The body of an endpoint that returns raw bytes (Python's `BinaryAPIResponse`).
public struct BinaryResponse: Sendable {
    public let response: HTTPResponse

    public var headers: HTTPHeaders { response.headers }
    public func read() async throws -> Data { try await response.read() }
    public func text() async throws -> String { try await response.text() }
    public func iterBytes() -> ByteStream { response.bytes() }

    /// Writes the body to a file.
    public func write(to url: URL) async throws {
        try await read().write(to: url)
    }
}

/// Marker for endpoints whose response body is ignored (`cast_to=NoneType`).
public struct EmptyResponse: Codable, Sendable, Hashable {
    public init() {}
    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {}
}
