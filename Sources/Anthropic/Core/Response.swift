import Foundation

/// A response from an API call, before (or after) its body is parsed
/// (`_response.AsyncAPIResponse`). Returned by `withRawResponse` and `withStreamingResponse`.
public struct APIResponse<T: Sendable>: Sendable {
    public let http: HTTPResponse
    public let options: FinalRequestOptions
    public let retriesTaken: Int
    let client: BaseClient
    let parser: @Sendable (APIResponse<T>) async throws -> T

    init(http: HTTPResponse, options: FinalRequestOptions, retriesTaken: Int, client: BaseClient,
         parser: @escaping @Sendable (APIResponse<T>) async throws -> T)
    {
        self.http = http
        self.options = options
        self.retriesTaken = retriesTaken
        self.client = client
        self.parser = parser
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
    public func parse() async throws -> T { try await parser(self) }

    /// Parses the body into a different type than the method's own.
    public func parse<U: Decodable & Sendable>(as type: U.Type) async throws -> U {
        try await client.decodeBody(U.self, from: http)
    }

    /// Reads the whole body.
    public func read() async throws -> Data { try await http.read() }
    public func text() async throws -> String { try await http.text() }
    public func json() async throws -> JSONValue { try JSONValue.parse(try await http.read()) }

    /// Iterates over the raw body chunks.
    public func iterBytes() -> ByteStream { http.bytes() }

    /// Iterates over the body line by line.
    public func iterLines() -> AsyncThrowingStream<String, Error> {
        let bytes = http.bytes()
        return AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = Data()
                do {
                    for try await chunk in bytes {
                        buffer.append(chunk)
                        while let nl = buffer.firstIndex(where: { $0 == 0x0A || $0 == 0x0D }) {
                            let line = buffer[buffer.startIndex..<nl]
                            var next = buffer.index(after: nl)
                            if buffer[nl] == 0x0D, next < buffer.endIndex, buffer[next] == 0x0A { next = buffer.index(after: next) }
                            continuation.yield(String(decoding: line, as: UTF8.self))
                            buffer = Data(buffer[next...])
                        }
                    }
                    if !buffer.isEmpty { continuation.yield(String(decoding: buffer, as: UTF8.self)) }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    public func close() { http.close() }
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
