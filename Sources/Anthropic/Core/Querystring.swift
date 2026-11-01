import Foundation

/// How arrays are rendered in a query string (`_types.ArrayFormat`).
public enum ArrayFormat: String, Sendable {
    case comma, repeat_ = "repeat", indices, brackets
}

/// How nested objects are rendered in a query string (`_types.NestedFormat`).
public enum NestedFormat: String, Sendable {
    case dots, brackets
}

/// Port of `_qs.Querystring`.
public struct Querystring: Sendable {
    public var arrayFormat: ArrayFormat
    public var nestedFormat: NestedFormat

    public init(arrayFormat: ArrayFormat = .repeat_, nestedFormat: NestedFormat = .brackets) {
        self.arrayFormat = arrayFormat
        self.nestedFormat = nestedFormat
    }

    /// Parses a query string into a mapping of key to every value given for it (`urllib.parse.parse_qs`).
    public func parse(_ query: String) -> [String: [String]] {
        var out: [String: [String]] = [:]
        for part in query.split(separator: "&") {
            let kv = part.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            guard kv.count == 2, !kv[1].isEmpty else { continue }
            let k = Querystring.unquote(String(kv[0]))
            let v = Querystring.unquote(String(kv[1]))
            out[k, default: []].append(v)
        }
        return out
    }

    public func stringify(_ params: [(String, JSONValue)], arrayFormat: ArrayFormat? = nil, nestedFormat: NestedFormat? = nil) -> String {
        Querystring.urlencode(stringifyItems(params, arrayFormat: arrayFormat, nestedFormat: nestedFormat))
    }

    public func stringify(_ params: [String: JSONValue], arrayFormat: ArrayFormat? = nil, nestedFormat: NestedFormat? = nil) -> String {
        stringify(params.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }, arrayFormat: arrayFormat, nestedFormat: nestedFormat)
    }

    public func stringifyItems(_ params: [(String, JSONValue)], arrayFormat: ArrayFormat? = nil, nestedFormat: NestedFormat? = nil) -> [(String, String)] {
        let af = arrayFormat ?? self.arrayFormat
        let nf = nestedFormat ?? self.nestedFormat
        return params.flatMap { stringifyItem($0.0, $0.1, af, nf) }
    }

    public func stringifyItems(_ params: [String: JSONValue], arrayFormat: ArrayFormat? = nil, nestedFormat: NestedFormat? = nil) -> [(String, String)] {
        stringifyItems(params.sorted(by: { $0.key < $1.key }).map { ($0.key, $0.value) }, arrayFormat: arrayFormat, nestedFormat: nestedFormat)
    }

    private func stringifyItem(_ key: String, _ value: JSONValue, _ af: ArrayFormat, _ nf: NestedFormat) -> [(String, String)] {
        switch value {
        case .object(let o):
            var items: [(String, String)] = []
            for (subkey, subvalue) in o.sorted(by: { $0.key < $1.key }) {
                items += stringifyItem(nf == .dots ? "\(key).\(subkey)" : "\(key)[\(subkey)]", subvalue, af, nf)
            }
            return items
        case .array(let a):
            switch af {
            case .comma:
                return [(key, a.filter { !$0.isNull }.map(primitiveToString).joined(separator: ","))]
            case .repeat_:
                return a.flatMap { stringifyItem(key, $0, af, nf) }
            case .indices:
                return a.enumerated().flatMap { stringifyItem("\(key)[\($0.offset)]", $0.element, af, nf) }
            case .brackets:
                return a.flatMap { stringifyItem(key + "[]", $0, af, nf) }
            }
        case .null:
            return []
        default:
            return [(key, primitiveToString(value))]
        }
    }

    private func primitiveToString(_ value: JSONValue) -> String {
        switch value {
        case .bool(let b): return b ? "true" : "false"
        case .null: return ""
        case .int(let i): return String(i)
        case .double(let d): return pythonFloatString(d)
        case .string(let s): return s
        default: return value.description
        }
    }

    /// `urllib.parse.urlencode` with `quote_plus`.
    public static func urlencode(_ items: [(String, String)]) -> String {
        items.map { "\(quotePlus($0.0))=\(quotePlus($0.1))" }.joined(separator: "&")
    }

    static let unreserved: Set<Character> = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.-~")

    public static func quotePlus(_ s: String) -> String {
        var out = ""
        for byte in Array(s.utf8) {
            let ch = Character(UnicodeScalar(byte))
            if byte < 128 && unreserved.contains(ch) {
                out.append(ch)
            } else if byte == 0x20 {
                out.append("+")
            } else {
                out += String(format: "%%%02X", byte)
            }
        }
        return out
    }

    static func unquote(_ s: String) -> String {
        let plus = s.replacingOccurrences(of: "+", with: " ")
        return plus.removingPercentEncoding ?? plus
    }
}
