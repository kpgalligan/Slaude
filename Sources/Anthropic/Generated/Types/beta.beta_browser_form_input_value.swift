// Transformed from `anthropic.types.beta.beta_browser_form_input_value` (beta_browser_form_input_value.py).

import Foundation

public indirect enum BetaBrowserFormInputValue: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    case string(String)
    case double(Double)
    case bool(Bool)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if let v = try? Double(from: decoder) { self = .double(v); return }
        if let v = try? Bool(from: decoder) { self = .bool(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .double(let v): try v.encode(to: encoder)
        case .bool(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
