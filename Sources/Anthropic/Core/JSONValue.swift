import Foundation

/// An arbitrary JSON value.
///
/// This is the Swift counterpart of the Python SDK's `object` / `Dict[str, object]`
/// annotations: anything the API returns or accepts without a fixed schema.
public enum JSONValue: Sendable, Hashable {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public var isNull: Bool { if case .null = self { return true } else { return false } }

    public var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }
    public var boolValue: Bool? { if case .bool(let b) = self { return b } else { return nil } }
    public var intValue: Int? {
        switch self {
        case .int(let i): return i
        case .double(let d) where d.rounded() == d && abs(d) < 9.2e18: return Int(d)
        default: return nil
        }
    }
    public var doubleValue: Double? {
        switch self {
        case .int(let i): return Double(i)
        case .double(let d): return d
        default: return nil
        }
    }
    public var arrayValue: [JSONValue]? { if case .array(let a) = self { return a } else { return nil } }
    public var objectValue: [String: JSONValue]? { if case .object(let o) = self { return o } else { return nil } }

    public subscript(key: String) -> JSONValue? {
        get { objectValue?[key] }
        set {
            guard case .object(var o) = self else { return }
            o[key] = newValue
            self = .object(o)
        }
    }

    public subscript(index: Int) -> JSONValue? {
        guard case .array(let a) = self, a.indices.contains(index) else { return nil }
        return a[index]
    }
}

extension JSONValue: Codable {
    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() {
            self = .null
        } else if let b = try? c.decode(Bool.self) {
            self = .bool(b)
        } else if let i = try? c.decode(Int.self) {
            self = .int(i)
        } else if let d = try? c.decode(Double.self) {
            self = .double(d)
        } else if let s = try? c.decode(String.self) {
            self = .string(s)
        } else if let a = try? c.decode([JSONValue].self) {
            self = .array(a)
        } else if let o = try? c.decode([String: JSONValue].self) {
            self = .object(o)
        } else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Value is not valid JSON")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let b): try c.encode(b)
        case .int(let i): try c.encode(i)
        case .double(let d): try c.encode(d)
        case .string(let s): try c.encode(s)
        case .array(let a): try c.encode(a)
        case .object(let o): try c.encode(o)
        }
    }
}

extension JSONValue: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral,
    ExpressibleByDictionaryLiteral
{
    public init(nilLiteral: ()) { self = .null }
    public init(booleanLiteral value: Bool) { self = .bool(value) }
    public init(integerLiteral value: Int) { self = .int(value) }
    public init(floatLiteral value: Double) { self = .double(value) }
    public init(stringLiteral value: String) { self = .string(value) }
    public init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        var o: [String: JSONValue] = [:]
        for (k, v) in elements { o[k] = v }
        self = .object(o)
    }
}

extension JSONValue: CustomStringConvertible {
    /// A compact JSON rendering (keys sorted), mainly for error messages and debugging.
    public var description: String {
        (try? JSONValue.serialize(self, sortedKeys: true)).flatMap { String(data: $0, encoding: .utf8) } ?? "<invalid json>"
    }
}

extension JSONValue {
    /// Parses JSON data into a `JSONValue`.
    public static func parse(_ data: Data) throws -> JSONValue {
        try JSONDecoder().decode(JSONValue.self, from: data)
    }

    /// Parses a JSON string into a `JSONValue`.
    public static func parse(_ string: String) throws -> JSONValue {
        try parse(Data(string.utf8))
    }

    /// Serializes a `JSONValue` to JSON data. Without `sortedKeys` the key order is a `Dictionary`'s, which differs from
    /// one instance (and process) to the next; a request body is written by `BaseClient.serializeBody`, which is the same
    /// for equal bodies, and `RawJSON` keeps an order of its own.
    public static func serialize(_ value: JSONValue, sortedKeys: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        var formatting: JSONEncoder.OutputFormatting = [.withoutEscapingSlashes]
        if sortedKeys { formatting.insert(.sortedKeys) }
        encoder.outputFormatting = formatting
        return try encoder.encode(value)
    }

    /// Converts any `Encodable` value to a `JSONValue` using the SDK's encoding conventions.
    public static func from<T: Encodable>(_ value: T) throws -> JSONValue {
        if let v = value as? JSONValue { return v }
        let data = try AnthropicJSON.encoder().encode(value)
        return try AnthropicJSON.decoder().decode(JSONValue.self, from: data)
    }

    /// Decodes this JSON value into a `Decodable` type using the SDK's decoding conventions.
    public func decode<T: Decodable>(as type: T.Type = T.self) throws -> T {
        if let v = self as? T { return v }
        let data = try JSONValue.serialize(self)
        return try AnthropicJSON.decoder().decode(T.self, from: data)
    }
}
