import Foundation

/// The JSON encoder/decoder configuration the SDK uses on the wire.
///
/// Mirrors `_utils/_json.py` (`openapi_dumps`) and `_models.py` (`construct_type`) in the
/// Python SDK: datetimes are ISO 8601, and keys are mapped explicitly by each model's `CodingKeys`.
public enum AnthropicJSON {
    public static func encoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.outputFormatting = [.withoutEscapingSlashes]
        e.dateEncodingStrategy = .custom { date, encoder in
            var c = encoder.singleValueContainer()
            try c.encode(formatISO8601(date))
        }
        return e
    }

    public static func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()
            // `_utils/_datetime_parse.py`: ISO 8601 variants, or unix timestamps (s, ms, us or ns).
            do {
                if let s = try? c.decode(String.self) {
                    if let date = try? DatetimeParse.parseDatetime(s) { return date }
                    if let date = parseISO8601(s) { return date }
                    return try DatetimeParse.parseDatetime(s)
                }
                return try DatetimeParse.parseDatetime(try c.decode(Double.self))
            } catch let e as ValueError {
                throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid datetime: \(e.message)")
            }
        }
        return d
    }

    /// Formats a date as an ISO 8601 UTC datetime (`2024-01-02T03:04:05Z`), keeping microseconds
    /// like Python's `datetime.isoformat()` does (trailing zeros of the fraction are dropped).
    public static func formatISO8601(_ date: Date) -> String {
        let f = ISO8601DateFormatter()
        f.timeZone = TimeZone(identifier: "UTC")
        f.formatOptions = [.withInternetDateTime]
        let t = date.timeIntervalSince1970
        var whole = t.rounded(.down)
        var micros = Int(((t - whole) * 1_000_000).rounded())
        if micros >= 1_000_000 {
            whole += 1
            micros -= 1_000_000
        }
        let base = f.string(from: Date(timeIntervalSince1970: whole))
        if micros == 0 { return base }
        var frac = String(micros)
        frac = String(repeating: "0", count: 6 - frac.count) + frac
        while frac.hasSuffix("0") { frac.removeLast() }
        return String(base.dropLast()) + "." + frac + "Z"
    }

    /// Parses the ISO 8601 variants accepted by `_utils/_datetime_parse.py`.
    public static func parseISO8601(_ raw: String) -> Date? {
        var s = raw.trimmingCharacters(in: .whitespaces)
        if s.isEmpty { return nil }
        // Allow a space separator, as Python's `fromisoformat` does.
        if s.count > 10, s[s.index(s.startIndex, offsetBy: 10)] == " " {
            s.replaceSubrange(s.index(s.startIndex, offsetBy: 10)...s.index(s.startIndex, offsetBy: 10), with: "T")
        }
        if s.count == 10 {
            s += "T00:00:00Z"
        }
        // No timezone -> UTC.
        let tzPattern = #"(Z|[+-]\d{2}:?\d{2})$"#
        if s.range(of: tzPattern, options: .regularExpression) == nil { s += "Z" }
        // Normalise fractional seconds to at most 3 digits (Foundation's limit) and drop extras.
        if let dot = s.firstIndex(of: "."), let end = s[dot...].firstIndex(where: { !$0.isNumber && $0 != "." }) {
            var frac = String(s[s.index(after: dot)..<end])
            if frac.count > 3 { frac = String(frac.prefix(3)) }
            s = String(s[..<dot]) + (frac.isEmpty ? "" : "." + frac) + String(s[end...])
        }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }
}

/// A calendar date without a time (Python's `datetime.date`), coded as `YYYY-MM-DD`.
public struct ISODate: Codable, Hashable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
    public var year: Int
    public var month: Int
    public var day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    public init?(_ string: String) {
        let parts = string.prefix(10).split(separator: "-")
        guard parts.count == 3, let y = Int(parts[0]), let m = Int(parts[1]), let d = Int(parts[2]) else { return nil }
        self.init(year: y, month: m, day: d)
    }

    public init(stringLiteral value: String) {
        guard let d = ISODate(value) else { preconditionFailure("Invalid ISO date literal: \(value)") }
        self = d
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let s = try c.decode(String.self)
        guard let d = ISODate(s) else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid ISO 8601 date: \(s)")
        }
        self = d
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(description)
    }

    public var description: String {
        func pad(_ v: Int, _ n: Int) -> String {
            let s = String(v)
            return String(repeating: "0", count: max(0, n - s.count)) + s
        }
        return "\(pad(year, 4))-\(pad(month, 2))-\(pad(day, 2))"
    }
}

/// A string-backed enumeration that tolerates values this SDK version doesn't know.
///
/// Python models `Literal[...]` annotations as plain strings at runtime, so a value the
/// SDK hasn't been regenerated for still round-trips. Generated Swift enums conform to this
/// protocol and carry an `unknown(String)` case for the same reason.
public protocol OpenEnum: RawRepresentable, Codable, Hashable, Sendable, ExpressibleByStringLiteral,
    CustomStringConvertible where RawValue == String
{
    init(rawValue: String)
}

extension OpenEnum {
    public init(stringLiteral value: String) { self.init(rawValue: value) }
    public init(from decoder: Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }
    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(rawValue)
    }
    public var description: String { rawValue }
}

/// A coding key built from an arbitrary string, used by generated union decoders.
public struct AnyCodingKey: CodingKey, Hashable, Sendable {
    public var stringValue: String
    public var intValue: Int?
    public init(_ string: String) { self.stringValue = string }
    public init?(stringValue: String) { self.stringValue = stringValue }
    public init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

/// Helpers used by generated code.
public enum _Coding {
    /// Reads a string discriminator (e.g. `type`) from an object without consuming it.
    public static func discriminator(_ decoder: Decoder, _ key: String) -> String? {
        guard let c = try? decoder.container(keyedBy: AnyCodingKey.self) else { return nil }
        return try? c.decodeIfPresent(String.self, forKey: AnyCodingKey(key))
    }

    /// Error thrown when no variant of a union matched.
    public static func noMatch(_ decoder: Decoder, _ typeName: String, _ errors: [Error] = []) -> DecodingError {
        DecodingError.dataCorrupted(
            .init(
                codingPath: decoder.codingPath,
                debugDescription: "Could not decode \(typeName) from any of its variants: \(errors.map { "\($0)" })"
            )
        )
    }

    /// Decodes a value as a `JSONValue` (used for `unknown` union cases).
    public static func raw(_ decoder: Decoder) throws -> JSONValue {
        try JSONValue(from: decoder)
    }

    /// Validates that a constant (single `Literal[...]` value) field holds the expected value.
    public static func expectConstant<K: CodingKey>(
        _ c: KeyedDecodingContainer<K>, _ key: K, _ expected: String
    ) throws {
        if let v = try c.decodeIfPresent(String.self, forKey: key), v != expected {
            throw DecodingError.dataCorruptedError(
                forKey: key, in: c, debugDescription: "Expected \(expected) but found \(v)")
        }
    }
}

/// A file whose contents are sent base64-encoded (Python's `Base64FileInput`: a path or file object).
public struct Base64FileInput: Codable, Hashable, Sendable {
    public enum Source: Hashable, Sendable {
        case path(URL)
        case data(Data)
    }

    public var source: Source

    public init(path: URL) { self.source = .path(path) }
    public init(path: String) { self.source = .path(URL(fileURLWithPath: path)) }
    public init(data: Data) { self.source = .data(data) }

    public func read() throws -> Data {
        switch source {
        case .path(let url): return try Data(contentsOf: url)
        case .data(let d): return d
        }
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        let s = try c.decode(String.self)
        guard let d = Data(base64Encoded: s) else {
            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Invalid base64 data")
        }
        self.source = .data(d)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(try read().base64EncodedString())
    }
}
