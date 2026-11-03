import Foundation

// The JSON text parser and writer behind `RawJSON` (and `PartialJSON`, which reads tool inputs as they stream).
// Foundation's `JSONDecoder` and `JSONSerialization` hand an object back as a dictionary, so its key order is gone
// before any caller sees it; this parser builds each object in document order instead, and keeps each number's text.

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

/// The error thrown for input that is not (a prefix of) valid JSON, by `PartialJSON.parse` and `RawJSON.parse`.
public struct PartialJSONError: Error, CustomStringConvertible, LocalizedError, Sendable, Equatable {
    public let message: String
    /// 1-based line and column of the offending byte.
    public let line: Int
    public let column: Int

    public var description: String { "\(message) at line \(line) column \(column)" }
    public var errorDescription: String? { description }
}

/// A recursive-descent JSON parser over UTF-8 bytes that builds `RawJSON`, optionally accepting a truncated
/// document (jiter's partial modes).
struct JSONTextParser {
    /// How deep arrays and objects may nest. The parser recurses once per level, and a task runs on a thread with a
    /// 512 KiB stack: unoptimised, a level of objects takes about 3.5 KiB of it, so 64 levels stay well inside it with
    /// room for the caller and for the recursive work done on the value afterwards (`serialized()`, `jsonValue`). The
    /// API's JSON nests a handful of levels, and a tool input is parsed on its own.
    static let maxDepth = 64

    let bytes: [UInt8]
    let mode: PartialJSONMode
    var i = 0
    var depth = 0

    static func parse(_ data: Data, mode: PartialJSONMode) throws -> RawJSON {
        var p = JSONTextParser(bytes: [UInt8](data), mode: mode)
        p.skipWhitespace()
        guard let value = try p.parseValue() else {
            throw p.error(p.atEnd ? "EOF while parsing a value" : "expected value")
        }
        p.skipWhitespace()
        if !p.atEnd { throw p.error("trailing characters") }
        return value
    }

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
        while i < bytes.count, bytes[i] == 0x20 || bytes[i] == 0x09 || bytes[i] == 0x0A || bytes[i] == 0x0D { i += 1 }
    }

    /// Parses a value. Returns `nil` when the input ended before the value was complete enough
    /// to keep (only in partial modes).
    mutating func parseValue() throws -> RawJSON? {
        skipWhitespace()
        guard i < bytes.count else {
            if partial { return nil }
            throw error("EOF while parsing a value")
        }
        switch bytes[i] {
        case UInt8(ascii: "{"), UInt8(ascii: "["):
            if depth >= JSONTextParser.maxDepth { throw error("recursion limit exceeded") }
            depth += 1
            defer { depth -= 1 }
            return bytes[i] == UInt8(ascii: "{") ? try parseObject() : try parseArray()
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

    mutating func parseLiteral(_ word: String, _ value: RawJSON) throws -> RawJSON? {
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

    /// Parses a number, keeping its text. Only the JSON grammar is accepted (`-?(0|[1-9][0-9]*)(.[0-9]+)?([eE][+-]?[0-9]+)?`),
    /// so the text can be written back as it is.
    mutating func parseNumber() throws -> RawJSON? {
        let start = i
        if bytes[i] == UInt8(ascii: "-") { i += 1 }
        func digits(_ p: inout JSONTextParser) -> Int {
            let s = p.i
            while p.i < p.bytes.count, (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(p.bytes[p.i]) { p.i += 1 }
            return p.i - s
        }
        let intStart = i
        let intDigits = digits(&self)
        if intDigits == 0 {
            if atEnd && partial { return nil }
            throw error("invalid number")
        }
        if intDigits > 1 && bytes[intStart] == UInt8(ascii: "0") {
            i = intStart + 1
            throw error("invalid number")
        }
        if i < bytes.count, bytes[i] == UInt8(ascii: ".") {
            i += 1
            if digits(&self) == 0 {
                if atEnd && partial { return nil }
                throw error("invalid number")
            }
        }
        if i < bytes.count, bytes[i] == UInt8(ascii: "e") || bytes[i] == UInt8(ascii: "E") {
            i += 1
            if i < bytes.count, bytes[i] == UInt8(ascii: "+") || bytes[i] == UInt8(ascii: "-") { i += 1 }
            if digits(&self) == 0 {
                if atEnd && partial { return nil }
                throw error("invalid number")
            }
        }
        return .number(RawJSON.Number(unchecked: String(decoding: bytes[start..<i], as: UTF8.self)))
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
    /// number of bytes consumed, or `nil` when the input ends inside the escape. A lone surrogate, which a Swift
    /// string cannot hold, becomes U+FFFD.
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

    mutating func parseArray() throws -> RawJSON? {
        i += 1
        var items: [RawJSON] = []
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

    /// Parses an object in document order. A key given twice keeps its first place and takes its last value, as
    /// JavaScript's `JSON.parse` does.
    mutating func parseObject() throws -> RawJSON? {
        i += 1
        var obj = RawJSONObject()
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

/// Writes `RawJSON` as compact JSON text: keys in their stored order, numbers as their stored text, strings as
/// UTF-8 with only `"`, `\` and the control characters escaped (what JavaScript's `JSON.stringify` writes).
enum JSONTextWriter {
    static func write(_ value: RawJSON) -> Data {
        var out: [UInt8] = []
        out.reserveCapacity(256)
        write(value, into: &out)
        return Data(out)
    }

    static func write(_ value: RawJSON, into out: inout [UInt8]) {
        switch value {
        case .null: out.append(contentsOf: [0x6E, 0x75, 0x6C, 0x6C])
        case .bool(let b): out.append(contentsOf: b ? Array("true".utf8) : Array("false".utf8))
        case .number(let n): out.append(contentsOf: n.text.utf8)
        case .string(let s): writeString(s, into: &out)
        case .array(let a):
            out.append(UInt8(ascii: "["))
            for (k, element) in a.enumerated() {
                if k > 0 { out.append(UInt8(ascii: ",")) }
                write(element, into: &out)
            }
            out.append(UInt8(ascii: "]"))
        case .object(let o):
            out.append(UInt8(ascii: "{"))
            for (k, entry) in o.enumerated() {
                if k > 0 { out.append(UInt8(ascii: ",")) }
                writeString(entry.key, into: &out)
                out.append(UInt8(ascii: ":"))
                write(entry.value, into: &out)
            }
            out.append(UInt8(ascii: "}"))
        }
    }

    static func writeString(_ s: String, into out: inout [UInt8]) {
        let hex = Array("0123456789abcdef".utf8)
        out.append(0x22)
        for b in s.utf8 {
            switch b {
            case 0x22: out.append(contentsOf: [0x5C, 0x22])
            case 0x5C: out.append(contentsOf: [0x5C, 0x5C])
            case 0x08: out.append(contentsOf: [0x5C, UInt8(ascii: "b")])
            case 0x0C: out.append(contentsOf: [0x5C, UInt8(ascii: "f")])
            case 0x0A: out.append(contentsOf: [0x5C, UInt8(ascii: "n")])
            case 0x0D: out.append(contentsOf: [0x5C, UInt8(ascii: "r")])
            case 0x09: out.append(contentsOf: [0x5C, UInt8(ascii: "t")])
            case 0x00..<0x20:
                out.append(contentsOf: [0x5C, UInt8(ascii: "u"), UInt8(ascii: "0"), UInt8(ascii: "0"), hex[Int(b >> 4)], hex[Int(b & 0x0F)]])
            default: out.append(b)
            }
        }
        out.append(0x22)
    }
}
