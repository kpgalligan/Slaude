import Foundation

/// How `PartialJSON.parse` treats a document that ends early (jiter's `partial_mode`).
public enum PartialJSONMode: Sendable, Hashable {
    /// The input must be complete JSON (`partial_mode=False`).
    case off
    /// Incomplete input is allowed; a string cut off by the end of the input is dropped, with the
    /// key it belongs to (`partial_mode=True`).
    case on
    /// Incomplete input is allowed, and a string cut off by the end of the input is kept with the
    /// characters received so far (`partial_mode="trailing-strings"`).
    case trailingStrings
}

/// The error thrown for input that is not (a prefix of) valid JSON.
public struct PartialJSONError: Error, CustomStringConvertible, LocalizedError, Sendable, Equatable {
    public let message: String
    /// 1-based line and column of the offending byte.
    public let line: Int
    public let column: Int

    public var description: String { "\(message) at line \(line) column \(column)" }
    public var errorDescription: String? { description }
}

/// A JSON parser that accepts truncated documents, standing in for `jiter.from_json(..., partial_mode=...)`.
///
/// The streaming helpers use it to parse tool inputs while their `input_json_delta` chunks arrive.
public enum PartialJSON {
    public static func parse(_ text: String, mode: PartialJSONMode = .on) throws -> JSONValue {
        try parse(Data(text.utf8), mode: mode)
    }

    public static func parse(_ data: Data, mode: PartialJSONMode = .on) throws -> JSONValue {
        var p = Parser(bytes: [UInt8](data), mode: mode)
        p.skipWhitespace()
        guard let value = try p.parseValue() else {
            throw p.error(p.atEnd ? "EOF while parsing a value" : "expected value")
        }
        p.skipWhitespace()
        if !p.atEnd { throw p.error("trailing characters") }
        return value
    }

    private struct Parser {
        let bytes: [UInt8]
        let mode: PartialJSONMode
        var i = 0

        init(bytes: [UInt8], mode: PartialJSONMode) {
            self.bytes = bytes
            self.mode = mode
        }

        var atEnd: Bool { i >= bytes.count }
        var partial: Bool { mode != .off }

        func error(_ message: String) -> PartialJSONError {
            var line = 1
            var column = 1
            for b in bytes[..<min(i, bytes.count)] {
                if b == 0x0A { line += 1; column = 1 } else { column += 1 }
            }
            return PartialJSONError(message: message, line: line, column: column)
        }

        mutating func skipWhitespace() {
            while i < bytes.count, [0x20, 0x09, 0x0A, 0x0D].contains(bytes[i]) { i += 1 }
        }

        /// Parses a value. Returns `nil` when the input ended before the value was complete enough
        /// to keep (only in partial modes).
        mutating func parseValue() throws -> JSONValue? {
            skipWhitespace()
            guard i < bytes.count else {
                if partial { return nil }
                throw error("EOF while parsing a value")
            }
            switch bytes[i] {
            case UInt8(ascii: "{"): return try parseObject()
            case UInt8(ascii: "["): return try parseArray()
            case UInt8(ascii: "\""):
                guard let (s, complete) = try parseString() else { return nil }
                if !complete && mode != .trailingStrings { return nil }
                return .string(s)
            case UInt8(ascii: "t"): return try parseLiteral("true", .bool(true))
            case UInt8(ascii: "f"): return try parseLiteral("false", .bool(false))
            case UInt8(ascii: "n"): return try parseLiteral("null", .null)
            case UInt8(ascii: "-"), UInt8(ascii: "0")...UInt8(ascii: "9"): return try parseNumber()
            default: throw error("expected value")
            }
        }

        mutating func parseLiteral(_ word: String, _ value: JSONValue) throws -> JSONValue? {
            let w = Array(word.utf8)
            var j = 0
            while j < w.count {
                if i + j >= bytes.count {
                    if partial { i = bytes.count; return nil }
                    throw error("EOF while parsing a value")
                }
                if bytes[i + j] != w[j] {
                    i += j
                    throw error("expected ident")
                }
                j += 1
            }
            i += w.count
            return value
        }

        mutating func parseNumber() throws -> JSONValue? {
            let start = i
            if bytes[i] == UInt8(ascii: "-") { i += 1 }
            func digits(_ p: inout Parser) -> Int {
                let s = p.i
                while p.i < p.bytes.count, (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(p.bytes[p.i]) { p.i += 1 }
                return p.i - s
            }
            var isFloat = false
            if digits(&self) == 0 {
                if atEnd && partial { return nil }
                throw error("invalid number")
            }
            if i < bytes.count, bytes[i] == UInt8(ascii: ".") {
                isFloat = true
                i += 1
                if digits(&self) == 0 {
                    if atEnd && partial { return nil }
                    throw error("invalid number")
                }
            }
            if i < bytes.count, bytes[i] == UInt8(ascii: "e") || bytes[i] == UInt8(ascii: "E") {
                isFloat = true
                i += 1
                if i < bytes.count, bytes[i] == UInt8(ascii: "+") || bytes[i] == UInt8(ascii: "-") { i += 1 }
                if digits(&self) == 0 {
                    if atEnd && partial { return nil }
                    throw error("invalid number")
                }
            }
            let text = String(decoding: bytes[start..<i], as: UTF8.self)
            if !isFloat, let v = Int(text) { return .int(v) }
            guard let d = Double(text) else { throw error("invalid number") }
            return .double(d)
        }

        /// Parses a string starting at the opening quote. Returns the decoded characters and whether
        /// the closing quote was seen; `nil` when not even the opening quote could be consumed.
        mutating func parseString() throws -> (String, Bool)? {
            i += 1  // opening quote
            var out = [UInt8]()
            while i < bytes.count {
                let b = bytes[i]
                if b == UInt8(ascii: "\"") {
                    i += 1
                    return (String(decoding: out, as: UTF8.self), true)
                }
                if b == UInt8(ascii: "\\") {
                    guard i + 1 < bytes.count else {
                        i = bytes.count
                        if partial { return (String(decoding: out, as: UTF8.self), false) }
                        throw error("EOF while parsing a string")
                    }
                    let e = bytes[i + 1]
                    switch e {
                    case UInt8(ascii: "\""): out.append(0x22)
                    case UInt8(ascii: "\\"): out.append(0x5C)
                    case UInt8(ascii: "/"): out.append(0x2F)
                    case UInt8(ascii: "b"): out.append(0x08)
                    case UInt8(ascii: "f"): out.append(0x0C)
                    case UInt8(ascii: "n"): out.append(0x0A)
                    case UInt8(ascii: "r"): out.append(0x0D)
                    case UInt8(ascii: "t"): out.append(0x09)
                    case UInt8(ascii: "u"):
                        guard let (scalar, consumed) = try parseUnicodeEscape(at: i) else {
                            i = bytes.count
                            if partial { return (String(decoding: out, as: UTF8.self), false) }
                            throw error("EOF while parsing a string")
                        }
                        out.append(contentsOf: Array(String(Character(scalar)).utf8))
                        i += consumed
                        continue
                    default:
                        i += 1
                        throw error("invalid escape")
                    }
                    i += 2
                    continue
                }
                if b < 0x20 { throw error("control character (\\u0000-\\u001F) found while parsing a string") }
                out.append(b)
                i += 1
            }
            if partial { return (String(decoding: out, as: UTF8.self), false) }
            throw error("EOF while parsing a string")
        }

        /// Parses `\uXXXX` (and a following low surrogate) at `pos`. Returns the scalar and the
        /// number of bytes consumed, or `nil` when the input ends inside the escape.
        func parseUnicodeEscape(at pos: Int) throws -> (Unicode.Scalar, Int)? {
            func hex(_ at: Int) throws -> UInt32? {
                guard at + 4 <= bytes.count else { return nil }
                guard let v = UInt32(String(decoding: bytes[at..<(at + 4)], as: UTF8.self), radix: 16) else {
                    throw error("invalid escape")
                }
                return v
            }
            guard let hi = try hex(pos + 2) else { return nil }
            if (0xD800...0xDBFF).contains(hi) {
                guard pos + 12 <= bytes.count else { return nil }
                if bytes[pos + 6] == UInt8(ascii: "\\"), bytes[pos + 7] == UInt8(ascii: "u"), let lo = try hex(pos + 8),
                   (0xDC00...0xDFFF).contains(lo)
                {
                    let v = 0x10000 + ((hi - 0xD800) << 10) + (lo - 0xDC00)
                    return (Unicode.Scalar(v) ?? "\u{FFFD}", 12)
                }
                return ("\u{FFFD}", 6)
            }
            return (Unicode.Scalar(hi) ?? "\u{FFFD}", 6)
        }

        mutating func parseArray() throws -> JSONValue? {
            i += 1
            var items: [JSONValue] = []
            skipWhitespace()
            if i < bytes.count, bytes[i] == UInt8(ascii: "]") {
                i += 1
                return .array(items)
            }
            while true {
                skipWhitespace()
                if atEnd {
                    if partial { return .array(items) }
                    throw error("EOF while parsing a list")
                }
                let v = try parseValue()
                if let v { items.append(v) }
                if atEnd {
                    if partial { return .array(items) }
                    throw error("EOF while parsing a list")
                }
                skipWhitespace()
                if atEnd {
                    if partial { return .array(items) }
                    throw error("EOF while parsing a list")
                }
                if bytes[i] == UInt8(ascii: ",") {
                    i += 1
                    continue
                }
                if bytes[i] == UInt8(ascii: "]") {
                    i += 1
                    return .array(items)
                }
                throw error("expected `,` or `]`")
            }
        }

        mutating func parseObject() throws -> JSONValue? {
            i += 1
            var obj: [String: JSONValue] = [:]
            skipWhitespace()
            if i < bytes.count, bytes[i] == UInt8(ascii: "}") {
                i += 1
                return .object(obj)
            }
            while true {
                skipWhitespace()
                if atEnd {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing an object")
                }
                guard bytes[i] == UInt8(ascii: "\"") else { throw error("key must be a string") }
                guard let (key, complete) = try parseString(), complete else {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing an object")
                }
                skipWhitespace()
                if atEnd {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing an object")
                }
                guard bytes[i] == UInt8(ascii: ":") else { throw error("expected `:`") }
                i += 1
                skipWhitespace()
                if atEnd {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing a value")
                }
                let v = try parseValue()
                if let v { obj[key] = v }
                if atEnd {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing an object")
                }
                skipWhitespace()
                if atEnd {
                    if partial { return .object(obj) }
                    throw error("EOF while parsing an object")
                }
                if bytes[i] == UInt8(ascii: ",") {
                    i += 1
                    continue
                }
                if bytes[i] == UInt8(ascii: "}") {
                    i += 1
                    return .object(obj)
                }
                throw error("expected `,` or `}`")
            }
        }
    }
}
