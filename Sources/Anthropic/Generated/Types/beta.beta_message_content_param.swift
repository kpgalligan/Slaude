// Transformed from `anthropic.types.beta.beta_message_content_param` (beta_message_content_param.py).

import Foundation

public indirect enum BetaMessageContentParam: Codable, Hashable, Sendable, ExpressibleByStringLiteral, ExpressibleByArrayLiteral {
    case string(String)
    case betaContentBlockParams([BetaContentBlockParam])
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(stringLiteral value: String) { self = .string(value) }

    public init(arrayLiteral elements: BetaContentBlockParam...) { self = .betaContentBlockParams(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? String(from: decoder) { self = .string(v); return }
        if let v = try? [BetaContentBlockParam](from: decoder) { self = .betaContentBlockParams(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .string(let v): try v.encode(to: encoder)
        case .betaContentBlockParams(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
