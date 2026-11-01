import Foundation

/// Port of `anthropic/lib/credentials/_secrets.py`, plus the Python value coercions the
/// credentials code relies on (`int(x)`, `float(x)`, truthiness, `type(x).__name__`).
///
/// Python wraps secret fields in `pydantic.SecretStr` so that traceback frame locals captured by
/// crash reporters never hold raw tokens. Swift has no such frame capture; what remains is that a
/// parsed credentials payload never *renders* its secrets: `SecretPayload`'s `description` and
/// reflection mirror mask every string value whose key is not plumbing.

/// Top-level keys that are plumbing, not secrets, in the credentials file and in token-endpoint
/// responses. Every other string value is secret by default.
let PLAIN_KEYS: Set<String> = [
    "type", "version", "expires_at",
    "token_type", "expires_in", "scope", "error", "error_description", "error_uri",
]

/// A parsed JSON object holding credential material (`_wrap_secret_fields`). Values read back raw;
/// renderings mask them.
struct SecretPayload: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var values: [String: JSONValue]

    init(_ values: [String: JSONValue] = [:]) { self.values = values }

    /// Parses `data` as a JSON object. A payload that is not an object throws
    /// `NonObjectPayloadError`, which carries only the payload's type name.
    static func parse(_ data: Data) throws -> SecretPayload {
        let value = try parseJSONFragment(data)
        guard case .object(let o) = value else { throw NonObjectPayloadError(typeName: pythonTypeName(value)) }
        return SecretPayload(o)
    }

    subscript(key: String) -> JSONValue? {
        get { values[key] }
        set { values[key] = newValue }
    }

    var redacted: [String: JSONValue] {
        values.mapValues { $0 }.reduce(into: [:]) { out, kv in
            if !PLAIN_KEYS.contains(kv.key), case .string = kv.value { out[kv.key] = .string("**********") } else { out[kv.key] = kv.value }
        }
    }

    var description: String { "SecretPayload(\(pythonRepr(.object(redacted))))" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["values": redacted], displayStyle: .struct) }

    /// Serializes the payload with its real values (`_json_dumps_secrets`).
    func serialized(pretty: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = pretty ? [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes] : [.withoutEscapingSlashes]
        return try encoder.encode(JSONValue.object(values))
    }
}

/// A JSON payload that is not an object (`_NonObjectPayloadError`).
struct NonObjectPayloadError: Error {
    let typeName: String
}

/// Parses JSON the way Python's `json.loads` does: a top-level scalar is allowed, a number too
/// large for a `Double` becomes ±infinity (rather than failing the whole document), and the
/// `NaN` / `Infinity` / `-Infinity` literals are accepted. Token-endpoint and credentials-file
/// payloads go through this, so a malformed field fails that field's check — never the parse,
/// whose error message would echo the raw (secret-bearing) body.
func parseJSONFragment(_ data: Data) throws -> JSONValue {
    var parser = PythonJSONParser(bytes: Array(data))
    parser.skipWhitespace()
    let value = try parser.parseValue(depth: 0)
    parser.skipWhitespace()
    guard parser.atEnd else { throw parser.error("Extra data") }
    return value
}

/// A JSON decoding failure; the message carries only a position, never the document.
struct JSONParseError: Error, CustomStringConvertible {
    let message: String
    let offset: Int
    var description: String { "\(message): char \(offset)" }
}

struct PythonJSONParser {
    let bytes: [UInt8]
    var i = 0

    var atEnd: Bool { i >= bytes.count }

    func error(_ message: String) -> JSONParseError { JSONParseError(message: message, offset: i) }

    mutating func skipWhitespace() {
        while i < bytes.count, [0x20, 0x09, 0x0A, 0x0D].contains(bytes[i]) { i += 1 }
    }

    mutating func consume(_ literal: String) -> Bool {
        let l = Array(literal.utf8)
        guard i + l.count <= bytes.count, Array(bytes[i..<(i + l.count)]) == l else { return false }
        i += l.count
        return true
    }

    mutating func parseValue(depth: Int) throws -> JSONValue {
        guard depth < 512 else { throw error("Nesting too deep") }
        guard !atEnd else { throw error("Expecting value") }
        switch bytes[i] {
        case UInt8(ascii: "{"):
            i += 1
            var object: [String: JSONValue] = [:]
            skipWhitespace()
            if consume("}") { return .object(object) }
            while true {
                skipWhitespace()
                guard !atEnd, bytes[i] == UInt8(ascii: "\"") else { throw error("Expecting property name enclosed in double quotes") }
                let key = try parseString()
                skipWhitespace()
                guard consume(":") else { throw error("Expecting ':' delimiter") }
                skipWhitespace()
                object[key] = try parseValue(depth: depth + 1)
                skipWhitespace()
                if consume("}") { return .object(object) }
                guard consume(",") else { throw error("Expecting ',' delimiter") }
            }
        case UInt8(ascii: "["):
            i += 1
            var array: [JSONValue] = []
            skipWhitespace()
            if consume("]") { return .array(array) }
            while true {
                skipWhitespace()
                array.append(try parseValue(depth: depth + 1))
                skipWhitespace()
                if consume("]") { return .array(array) }
                guard consume(",") else { throw error("Expecting ',' delimiter") }
            }
        case UInt8(ascii: "\""):
            return .string(try parseString())
        default:
            if consume("true") { return .bool(true) }
            if consume("false") { return .bool(false) }
            if consume("null") { return .null }
            if consume("NaN") { return .double(.nan) }
            if consume("Infinity") { return .double(.infinity) }
            if consume("-Infinity") { return .double(-.infinity) }
            return try parseNumber()
        }
    }

    mutating func parseNumber() throws -> JSONValue {
        let start = i
        if i < bytes.count, bytes[i] == UInt8(ascii: "-") { i += 1 }
        func digits() -> Int {
            let s = i
            while i < bytes.count, (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(bytes[i]) { i += 1 }
            return i - s
        }
        guard digits() > 0 else {
            i = start
            throw error("Expecting value")
        }
        var isInteger = true
        if i < bytes.count, bytes[i] == UInt8(ascii: ".") {
            i += 1
            isInteger = false
            guard digits() > 0 else { throw error("Expecting value") }
        }
        if i < bytes.count, bytes[i] == UInt8(ascii: "e") || bytes[i] == UInt8(ascii: "E") {
            i += 1
            isInteger = false
            if i < bytes.count, bytes[i] == UInt8(ascii: "+") || bytes[i] == UInt8(ascii: "-") { i += 1 }
            guard digits() > 0 else { throw error("Expecting value") }
        }
        let text = String(decoding: bytes[start..<i], as: UTF8.self)
        if isInteger, let n = Int(text) { return .int(n) }
        // strtod semantics: an out-of-range literal is ±infinity (Python's `float`).
        return .double(Double(text) ?? (text.hasPrefix("-") ? -.infinity : .infinity))
    }

    mutating func parseString() throws -> String {
        i += 1  // opening quote
        var scalars = String.UnicodeScalarView()
        var raw: [UInt8] = []
        func flushRaw() throws {
            guard !raw.isEmpty else { return }
            guard let s = String(bytes: raw, encoding: .utf8) else { throw error("Invalid UTF-8") }
            scalars.append(contentsOf: s.unicodeScalars)
            raw = []
        }
        while true {
            guard !atEnd else { throw error("Unterminated string") }
            let b = bytes[i]
            if b == UInt8(ascii: "\"") {
                i += 1
                try flushRaw()
                return String(scalars)
            }
            if b < 0x20 { throw error("Invalid control character") }
            if b != UInt8(ascii: "\\") {
                raw.append(b)
                i += 1
                continue
            }
            try flushRaw()
            i += 1
            guard !atEnd else { throw error("Unterminated string") }
            let e = bytes[i]
            i += 1
            switch e {
            case UInt8(ascii: "\""): scalars.append("\"")
            case UInt8(ascii: "\\"): scalars.append("\\")
            case UInt8(ascii: "/"): scalars.append("/")
            case UInt8(ascii: "b"): scalars.append("\u{08}")
            case UInt8(ascii: "f"): scalars.append("\u{0C}")
            case UInt8(ascii: "n"): scalars.append("\n")
            case UInt8(ascii: "r"): scalars.append("\r")
            case UInt8(ascii: "t"): scalars.append("\t")
            case UInt8(ascii: "u"):
                var code = try hex4()
                if (0xD800..<0xDC00).contains(code), consume("\\u") {
                    let low = try hex4()
                    if (0xDC00..<0xE000).contains(low) {
                        code = 0x10000 + ((code - 0xD800) << 10) + (low - 0xDC00)
                    } else {
                        scalars.append("\u{FFFD}")
                        code = low
                    }
                }
                scalars.append(Unicode.Scalar(code) ?? "\u{FFFD}")
            default: throw error("Invalid \\escape")
            }
        }
    }

    mutating func hex4() throws -> UInt32 {
        guard i + 4 <= bytes.count, let v = UInt32(String(decoding: bytes[i..<(i + 4)], as: UTF8.self), radix: 16) else {
            throw error("Invalid \\uXXXX escape")
        }
        i += 4
        return v
    }
}

/// Max characters of response body kept on `WorkloadIdentityError.body` and in messages.
let MAX_ERROR_BODY_CHARS = 256

/// Truncates a token-endpoint error body for safe inclusion in an exception (`_redact_body`).
/// Objects keep only the RFC 6749 §5.2 error fields; other non-string shapes are dropped.
func redactBody(_ body: JSONValue?) -> JSONValue? {
    guard let body else { return nil }
    switch body {
    case .null: return nil
    case .string(let s):
        let scalars = s.unicodeScalars
        if scalars.count <= MAX_ERROR_BODY_CHARS { return .string(s) }
        let head = String(String.UnicodeScalarView(scalars.prefix(MAX_ERROR_BODY_CHARS)))
        return .string(head + "... <\(scalars.count - MAX_ERROR_BODY_CHARS) more chars>")
    case .object(let o):
        var kept: [String: JSONValue] = [:]
        for key in ["error", "error_description", "error_uri"] { if let v = o[key] { kept[key] = v } }
        return .object(kept)
    default: return nil
    }
}

/// Python's `str(x)` of a redacted body: strings render raw, `None` as `None`.
func pythonStr(_ value: JSONValue?) -> String {
    guard let value else { return "None" }
    if case .string(let s) = value { return s }
    return pythonRepr(value)
}

/// `type(x).__name__` of a decoded JSON value.
func pythonTypeName(_ value: JSONValue) -> String {
    switch value {
    case .null: return "NoneType"
    case .bool: return "bool"
    case .int: return "int"
    case .double: return "float"
    case .string: return "str"
    case .array: return "list"
    case .object: return "dict"
    }
}

/// Python's `int(x)` for a decoded JSON value, or `nil` where Python raises
/// (`TypeError` / `ValueError` / `OverflowError`).
func pythonInt(_ value: JSONValue?) -> Int? {
    guard let value else { return nil }
    switch value {
    case .int(let i): return i
    case .bool(let b): return b ? 1 : 0
    case .double(let d):
        guard d.isFinite, d > -9.2e18, d < 9.2e18 else { return nil }
        return Int(d.rounded(.towardZero))
    case .string(let s):
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "_", with: "")
        return Int(t)
    default: return nil
    }
}

/// Python's `float(x)` for a decoded JSON value, or `nil` where Python raises.
func pythonFloat(_ value: JSONValue?) -> Double? {
    guard let value else { return nil }
    switch value {
    case .int(let i): return Double(i)
    case .bool(let b): return b ? 1 : 0
    case .double(let d): return d
    case .string(let s):
        let t = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if ["nan", "+nan", "-nan"].contains(t) { return .nan }
        if ["inf", "+inf", "infinity", "+infinity"].contains(t) { return .infinity }
        if ["-inf", "-infinity"].contains(t) { return -.infinity }
        return Double(t)
    default: return nil
    }
}

/// Python truthiness of an optional JSON value.
func isTruthy(_ value: JSONValue?) -> Bool {
    guard let value else { return false }
    switch value {
    case .null: return false
    case .bool(let b): return b
    case .int(let i): return i != 0
    case .double(let d): return d != 0
    case .string(let s): return !s.isEmpty
    case .array(let a): return !a.isEmpty
    case .object(let o): return !o.isEmpty
    }
}

/// Python's `str(x)` of a config value.
func pythonStringValue(_ value: JSONValue) -> String {
    if case .string(let s) = value { return s }
    if case .bool(let b) = value { return b ? "True" : "False" }
    return pythonRepr(value)
}
