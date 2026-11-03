import Foundation

/// A JSON value that keeps what `JSONValue` cannot: each object's key order and each number's text.
///
/// `JSONValue` holds an object as a `Dictionary`, whose order differs from one instance to the next, and the typed
/// models keep only the fields this SDK knows. `RawJSON` is for JSON that is received from the API and sent back
/// later as it was (a conversation's history, replayed on every request) and for JSON whose bytes must not change from
/// one request to the next (tool definitions, which a prompt cache reads first):
///
/// * `parse(_:)` keeps each object's keys in document order, every field (including ones this SDK does not model),
///   explicit `null`s, and each number's text. A key given twice keeps its first place and its last value, as
///   JavaScript's `JSON.parse` does.
/// * Building one keeps insertion order: a dictionary literal keeps its order, and assigning a key that is not there
///   appends it.
/// * `serialized()` writes the stored order and number text, with no re-sorting.
/// * Converting a `JSONValue` (`init(_:)`, `init(encoding:)`) sorts each object's keys, so that the result is the same
///   in every process.
/// * An object's keys are told apart by their UTF-8 bytes, as JSON does (Swift's `String` equality would make a
///   precomposed and a decomposed `"é"` one key).
///
/// Two values are equal when they hold the same keys in the same order and numbers with the same text (`1` and `1.0`
/// differ); compare `jsonValue`s to ignore both.
///
/// It is deliberately not `Codable`: a `Decoder` hands an object's keys over unordered, and an `Encoder` writes a
/// number from its value, so either would lose what this type keeps. Store a value as its text (`serialized()`,
/// `serializedString`) and read it back with `parse(_:)`, which gives the same value.
public enum RawJSON: Sendable, Hashable {
    case null
    case bool(Bool)
    case number(Number)
    case string(String)
    case array([RawJSON])
    case object(RawJSONObject)

    /// A JSON number, kept as its text so that it is written back as it was received.
    public struct Number: Sendable, Hashable, CustomStringConvertible {
        /// The number's JSON text.
        public let text: String

        /// A number with this JSON text, or `nil` when `text` is not a JSON number.
        public init?(text: String) {
            guard (try? JSONTextParser.parse(Data(text.utf8), mode: .off))?.numberValue?.text == text else { return nil }
            self.text = text
        }

        init(unchecked text: String) { self.text = text }

        public init(_ value: Int) { text = String(value) }

        /// The number, written as `JSONEncoder` writes a `Double`; `nil` for a non-finite value, which JSON cannot hold.
        public init?(_ value: Double) {
            guard value.isFinite else { return nil }
            var s = value.description
            if s.hasSuffix(".0") { s.removeLast(2) }
            text = s
        }

        /// Whether the text has a fraction or an exponent.
        var isFloat: Bool { text.utf8.contains { $0 == UInt8(ascii: ".") || $0 == UInt8(ascii: "e") || $0 == UInt8(ascii: "E") } }

        /// The value as a `JSONValue`: `.int` for an integer that fits, `.double` otherwise.
        public var jsonValue: JSONValue {
            if !isFloat, let i = Int(text) { return .int(i) }
            return .double(Double(text) ?? 0)
        }

        public var intValue: Int? { jsonValue.intValue }
        public var doubleValue: Double? { jsonValue.doubleValue }
        public var description: String { text }
    }
}

extension RawJSON {
    public var isNull: Bool { if case .null = self { return true } else { return false } }
    public var boolValue: Bool? { if case .bool(let b) = self { return b } else { return nil } }
    public var stringValue: String? { if case .string(let s) = self { return s } else { return nil } }
    public var numberValue: Number? { if case .number(let n) = self { return n } else { return nil } }
    public var intValue: Int? { numberValue?.intValue }
    public var doubleValue: Double? { numberValue?.doubleValue }
    public var arrayValue: [RawJSON]? { if case .array(let a) = self { return a } else { return nil } }
    public var objectValue: RawJSONObject? { if case .object(let o) = self { return o } else { return nil } }

    /// An object's value for `key`. Assigning replaces the value in place, or appends a new key; assigning `nil`
    /// removes the key. Assigning to a value that is not an object does nothing.
    public subscript(key: String) -> RawJSON? {
        get { objectValue?[key] }
        set {
            guard case .object(var o) = self else { return }
            self = .null
            o[key] = newValue
            self = .object(o)
        }
    }

    public subscript(index: Int) -> RawJSON? {
        guard case .array(let a) = self, a.indices.contains(index) else { return nil }
        return a[index]
    }
}

// MARK: - Conversions

extension RawJSON {
    /// `value` with each object's keys sorted, so that equal values give equal bytes in any process.
    /// A non-finite `Double` becomes `null`, as in JavaScript's `JSON.stringify`.
    public init(_ value: JSONValue) {
        switch value {
        case .null: self = .null
        case .bool(let b): self = .bool(b)
        case .int(let i): self = .number(Number(i))
        case .double(let d): self = Number(d).map { .number($0) } ?? .null
        case .string(let s): self = .string(s)
        case .array(let a): self = .array(a.map(RawJSON.init))
        case .object(let o):
            var out = RawJSONObject(minimumCapacity: o.count)
            for key in o.keys.sorted() { out.append(key, RawJSON(o[key] ?? .null)) }
            self = .object(out)
        }
    }

    /// An encodable value (a typed model or params type) as ordered JSON, with each object's keys sorted. `RawJSON`
    /// values are combined with `.array(_:)` and `.object(_:)` (or a literal), which keep their order.
    public init<T: Encodable>(encoding value: T) throws {
        self.init(try JSONValue.from(value))
    }

    /// The value as a `JSONValue`, for the typed parts of the SDK (the key order is lost).
    public var jsonValue: JSONValue {
        switch self {
        case .null: return .null
        case .bool(let b): return .bool(b)
        case .number(let n): return n.jsonValue
        case .string(let s): return .string(s)
        case .array(let a): return .array(a.map(\.jsonValue))
        case .object(let o):
            var out: [String: JSONValue] = [:]
            out.reserveCapacity(o.count)
            for (k, v) in o { out[k] = v.jsonValue }
            return .object(out)
        }
    }

    /// Decodes this value into a `Decodable` type using the SDK's decoding conventions.
    public func decode<T: Decodable>(as type: T.Type = T.self) throws -> T {
        try AnthropicJSON.decoder().decode(T.self, from: serialized())
    }

    /// This value with `view`'s content: where `view` agrees with this value (`jsonValue == view`), this value is
    /// kept, with its key order and number text; what `view` changed is taken from it. A key that `view` adds comes
    /// after the kept ones, new keys in sorted order; a key it drops is dropped.
    ///
    /// The request pipeline uses it to write an ordered body that middleware, a platform client or `extraBody`
    /// changed through its `JSONValue` view (`FinalRequestOptions.rawJSONBody`).
    public func reconciled(with view: JSONValue) -> RawJSON {
        switch (self, view) {
        case (.object(let mine), .object(let theirs)):
            var out = RawJSONObject(minimumCapacity: theirs.count)
            for (k, v) in mine {
                if let t = theirs[k] { out.append(k, v.reconciled(with: t)) }
            }
            for k in theirs.keys.sorted() where mine[k] == nil {
                out.append(k, RawJSON(theirs[k] ?? .null))
            }
            return .object(out)
        case (.array(let mine), .array(let theirs)):
            return .array(theirs.indices.map { i in i < mine.count ? mine[i].reconciled(with: theirs[i]) : RawJSON(theirs[i]) })
        default:
            return jsonValue == view ? self : RawJSON(view)
        }
    }
}

// MARK: - Text

extension RawJSON {
    /// Parses JSON text, keeping each object's key order and each number's text (see the type's documentation).
    /// Throws `PartialJSONError` for text that is not JSON.
    public static func parse(_ data: Data) throws -> RawJSON {
        try JSONTextParser.parse(data, mode: .off)
    }

    public static func parse(_ string: String) throws -> RawJSON {
        try parse(Data(string.utf8))
    }

    /// The value as compact JSON text, keys in their stored order and numbers as their stored text.
    public func serialized() -> Data { JSONTextWriter.write(self) }

    /// `serialized()` as a string.
    public var serializedString: String { String(decoding: serialized(), as: UTF8.self) }
}

extension RawJSON: CustomStringConvertible {
    public var description: String { serializedString }
}

extension RawJSON: ExpressibleByNilLiteral, ExpressibleByBooleanLiteral, ExpressibleByIntegerLiteral,
    ExpressibleByFloatLiteral, ExpressibleByStringLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral
{
    public init(nilLiteral: ()) { self = .null }
    public init(booleanLiteral value: Bool) { self = .bool(value) }
    public init(integerLiteral value: Int) { self = .number(Number(value)) }
    public init(floatLiteral value: Double) { self = Number(value).map { .number($0) } ?? .null }
    public init(stringLiteral value: String) { self = .string(value) }
    public init(arrayLiteral elements: RawJSON...) { self = .array(elements) }
    public init(dictionaryLiteral elements: (String, RawJSON)...) { self = .object(RawJSONObject(elements)) }
}

/// A JSON object whose keys keep their order: document order when parsed, insertion order when built.
///
/// It is a collection of `(key, value)` pairs in that order, with dictionary-style lookup by key. Keys are told apart
/// by their UTF-8 bytes, as JSON does: two keys that `String` compares as equal (a precomposed and a decomposed
/// `"é"`) are two keys here, and a lookup finds only the key with the same bytes.
public struct RawJSONObject: Sendable, Hashable, RandomAccessCollection, ExpressibleByDictionaryLiteral {
    public typealias Element = (key: String, value: RawJSON)
    public typealias Index = Int

    private var _keys: [String] = []
    private var _values: [RawJSON] = []
    private var positions: [ByteKey: Int] = [:]

    public init() {}

    init(minimumCapacity: Int) {
        _keys.reserveCapacity(minimumCapacity)
        _values.reserveCapacity(minimumCapacity)
        positions.reserveCapacity(minimumCapacity)
    }

    /// The pairs in order; a key given again replaces the value in its first place.
    public init<S: Sequence>(_ pairs: S) where S.Element == (String, RawJSON) {
        for (k, v) in pairs { self[k] = v }
    }

    public init(dictionaryLiteral elements: (String, RawJSON)...) { self.init(elements) }

    public var keys: [String] { _keys }
    public var values: [RawJSON] { _values }

    public var startIndex: Int { 0 }
    public var endIndex: Int { _keys.count }
    public subscript(position: Int) -> Element { (_keys[position], _values[position]) }

    /// The position of `key`, if it is there.
    public func index(forKey key: String) -> Int? { positions[ByteKey(key)] }

    /// The value for `key`. Assigning replaces it in place, or appends a new key; assigning `nil` removes the key.
    public subscript(key: String) -> RawJSON? {
        get { positions[ByteKey(key)].map { _values[$0] } }
        set {
            if let newValue {
                if let p = positions[ByteKey(key)] { _values[p] = newValue } else { append(key, newValue) }
            } else {
                removeValue(forKey: key)
            }
        }
    }

    /// Changes the value for `key` in place (so that a string or array held there can grow without a copy); a key
    /// that is not there is appended, starting from `null`.
    public mutating func modifyValue<R>(forKey key: String, _ body: (inout RawJSON) throws -> R) rethrows -> R {
        let p: Int
        if let existing = positions[ByteKey(key)] {
            p = existing
        } else {
            p = _keys.count
            append(key, .null)
        }
        return try body(&_values[p])
    }

    /// Appends a key known not to be there.
    mutating func append(_ key: String, _ value: RawJSON) {
        let k = ByteKey(key)
        if let p = positions[k] {
            _values[p] = value
            return
        }
        positions[k] = _keys.count
        _keys.append(key)
        _values.append(value)
    }

    @discardableResult
    public mutating func removeValue(forKey key: String) -> RawJSON? {
        guard let p = positions.removeValue(forKey: ByteKey(key)) else { return nil }
        _keys.remove(at: p)
        let old = _values.remove(at: p)
        for k in _keys[p...] { positions[ByteKey(k), default: 0] -= 1 }
        return old
    }

    public static func == (a: RawJSONObject, b: RawJSONObject) -> Bool {
        a._keys.count == b._keys.count && zip(a._keys, b._keys).allSatisfy { ByteKey($0) == ByteKey($1) } && a._values == b._values
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_keys.count)
        for key in _keys { hasher.combine(ByteKey(key)) }
        hasher.combine(_values)
    }

    /// A key as JSON compares it: by its UTF-8 bytes.
    struct ByteKey: Hashable {
        let string: String

        init(_ string: String) { self.string = string }

        static func == (a: ByteKey, b: ByteKey) -> Bool { a.string.utf8.elementsEqual(b.string.utf8) }

        func hash(into hasher: inout Hasher) {
            var s = string
            s.withUTF8 { hasher.combine(bytes: UnsafeRawBufferPointer($0)) }
        }
    }
}

extension RawJSONObject: CustomStringConvertible {
    public var description: String { RawJSON.object(self).serializedString }
}
