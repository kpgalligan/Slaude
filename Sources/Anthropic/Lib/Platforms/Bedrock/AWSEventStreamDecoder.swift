import Foundation

/// One frame of the AWS event-stream binary protocol (`botocore.eventstream.EventStreamMessage`).
public struct AWSEventStreamMessage: Sendable, Hashable {
    public enum HeaderValue: Sendable, Hashable {
        case bool(Bool)
        case int(Int64)
        case bytes(Data)
        case string(String)
        case timestamp(Int64)
        case uuid(Data)

        public var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }
    }

    public var headers: [String: HeaderValue]
    public var payload: Data

    public init(headers: [String: HeaderValue], payload: Data) {
        self.headers = headers
        self.payload = payload
    }

    /// The status code botocore assigns the frame (`to_response_dict`): 400 for `error` /
    /// `exception` frames, 200 otherwise.
    public var statusCode: Int {
        let type = headers[":message-type"]?.stringValue
        return type == "error" || type == "exception" ? 400 : 200
    }

    /// Encodes the frame (used by tests and mocks).
    public func encoded() -> Data {
        var h = Data()
        for (name, value) in headers.sorted(by: { $0.key < $1.key }) {
            h.append(UInt8(name.utf8.count))
            h.append(contentsOf: Array(name.utf8))
            switch value {
            case .bool(let b): h.append(b ? 0 : 1)
            case .int(let v):
                h.append(5)
                h.append(contentsOf: bigEndianBytes(UInt64(bitPattern: v), count: 8))
            case .bytes(let d):
                h.append(6)
                h.append(contentsOf: bigEndianBytes(UInt64(d.count), count: 2))
                h.append(d)
            case .string(let s):
                h.append(7)
                h.append(contentsOf: bigEndianBytes(UInt64(s.utf8.count), count: 2))
                h.append(contentsOf: Array(s.utf8))
            case .timestamp(let t):
                h.append(8)
                h.append(contentsOf: bigEndianBytes(UInt64(bitPattern: t), count: 8))
            case .uuid(let d):
                h.append(9)
                h.append(d)
            }
        }
        var prelude = Data(bigEndianBytes(UInt64(12 + h.count + payload.count + 4), count: 4))
        prelude.append(contentsOf: bigEndianBytes(UInt64(h.count), count: 4))
        prelude.append(contentsOf: bigEndianBytes(UInt64(CRC32.checksum(prelude)), count: 4))
        var message = prelude + h + payload
        message.append(contentsOf: bigEndianBytes(UInt64(CRC32.checksum(message)), count: 4))
        return message
    }
}

func bigEndianBytes(_ value: UInt64, count: Int) -> [UInt8] {
    (0..<count).map { UInt8(truncatingIfNeeded: value >> (UInt64(count - 1 - $0) * 8)) }
}

/// A malformed or corrupted event-stream frame.
public struct AWSEventStreamError: Error, CustomStringConvertible, Sendable {
    public let description: String
}

/// Incremental frame parser (`botocore.eventstream.EventStreamBuffer`).
public struct AWSEventStreamBuffer: Sendable {
    private var data = Data()

    public init() {}

    public mutating func add(_ chunk: Data) { data.append(chunk) }

    /// Returns the next complete frame, or `nil` when more bytes are needed.
    public mutating func next() throws -> AWSEventStreamMessage? {
        let bytes = [UInt8](data)
        guard bytes.count >= 12 else { return nil }
        func u32(_ i: Int) -> UInt32 { UInt32(bytes[i]) << 24 | UInt32(bytes[i + 1]) << 16 | UInt32(bytes[i + 2]) << 8 | UInt32(bytes[i + 3]) }
        let total = Int(u32(0))
        let headersLength = Int(u32(4))
        guard CRC32.checksum(bytes[0..<8]) == u32(8) else { throw AWSEventStreamError(description: "Prelude checksum mismatch") }
        guard total >= 16, headersLength <= total - 16 else { throw AWSEventStreamError(description: "Invalid event-stream frame length") }
        guard bytes.count >= total else { return nil }
        guard CRC32.checksum(bytes[0..<(total - 4)]) == u32(total - 4) else {
            throw AWSEventStreamError(description: "Message checksum mismatch")
        }
        var headers: [String: AWSEventStreamMessage.HeaderValue] = [:]
        var i = 12
        let headersEnd = 12 + headersLength
        func read(_ n: Int) throws -> ArraySlice<UInt8> {
            guard i + n <= headersEnd else { throw AWSEventStreamError(description: "Truncated event-stream header") }
            defer { i += n }
            return bytes[i..<(i + n)]
        }
        func int(_ n: Int) throws -> Int64 {
            var v: UInt64 = 0
            for b in try read(n) { v = v << 8 | UInt64(b) }
            // Sign-extend.
            let shift = UInt64(64 - n * 8)
            return Int64(bitPattern: v << shift) >> Int64(shift)
        }
        while i < headersEnd {
            let nameLength = Int(try read(1).first!)
            let name = String(decoding: try read(nameLength), as: UTF8.self)
            let type = try read(1).first!
            switch type {
            case 0: headers[name] = .bool(true)
            case 1: headers[name] = .bool(false)
            case 2: headers[name] = .int(try int(1))
            case 3: headers[name] = .int(try int(2))
            case 4: headers[name] = .int(try int(4))
            case 5: headers[name] = .int(try int(8))
            case 6: headers[name] = .bytes(Data(try read(Int(UInt16(truncatingIfNeeded: try int(2)) ))))
            case 7: headers[name] = .string(String(decoding: try read(Int(UInt16(truncatingIfNeeded: try int(2)))), as: UTF8.self))
            case 8: headers[name] = .timestamp(try int(8))
            case 9: headers[name] = .uuid(Data(try read(16)))
            default: throw AWSEventStreamError(description: "Unknown event-stream header type \(type)")
            }
        }
        let payload = Data(bytes[headersEnd..<(total - 4)])
        data = Data(bytes[total...])
        return AWSEventStreamMessage(headers: headers, payload: payload)
    }
}

/// Turns a Bedrock `invoke-with-response-stream` body into Server-Sent Events (`AWSEventStreamDecoder`).
public enum AWSEventStreamDecoder {
    /// The exception members of Bedrock Runtime's `ResponseStream` shape.
    static let responseStreamExceptions: Set<String> = [
        "internalServerException", "modelStreamErrorException", "validationException", "throttlingException",
        "modelTimeoutException", "serviceUnavailableException",
    ]

    public static func events(from bytes: ByteStream) -> AsyncThrowingStream<ServerSentEvent, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                var buffer = AWSEventStreamBuffer()
                do {
                    for try await chunk in bytes {
                        buffer.add(chunk)
                        while let message = try buffer.next() {
                            if let sse = parseMessage(message) { continuation.yield(sse) }
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    /// `_parse_message_from_event`.
    public static func parseMessage(_ message: AWSEventStreamMessage) -> ServerSentEvent? {
        if message.statusCode != 200 {
            // An `exception` / `error` frame: surface it the way a first-party stream `error` event does.
            var code = message.headers[":error-code"]?.stringValue ?? ""
            var text = message.headers[":error-message"]?.stringValue ?? ""
            if let type = message.headers[":exception-type"]?.stringValue, responseStreamExceptions.contains(type) {
                code = type
                let body = (try? JSONValue.parse(message.payload)) ?? .object([:])
                text = body["Message"]?.stringValue ?? body["message"]?.stringValue ?? ""
            }
            let data: JSONValue = ["type": "error", "error": ["type": .string(code), "message": .string(text)]]
            return ServerSentEvent(event: "error", data: (try? JSONValue.serialize(data)).map { String(decoding: $0, as: UTF8.self) })
        }
        guard message.headers[":event-type"]?.stringValue == "chunk" else { return nil }
        guard let body = try? JSONValue.parse(message.payload), let b64 = body["bytes"]?.stringValue,
              let raw = Data(base64Encoded: b64)
        else { return nil }
        return chunkBytesToSSE(raw)
    }

    /// `_chunk_bytes_to_sse`.
    public static func chunkBytesToSSE(_ raw: Data) -> ServerSentEvent? {
        let decoded = String(decoding: raw, as: UTF8.self)
        guard case .object(let payload)? = try? JSONValue.parse(raw) else {
            return ServerSentEvent(event: "completion", data: decoded)
        }
        if case .string(let type)? = payload["type"] { return ServerSentEvent(event: type, data: decoded) }
        // Neither a Messages event nor a legacy Text Completions chunk: there is no event name to
        // route it by, so skip it rather than mis-parse it downstream.
        guard payload["completion"] != nil else { return nil }
        return ServerSentEvent(event: "completion", data: decoded)
    }
}
