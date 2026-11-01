// Transformed from `anthropic.types.beta.beta_fallbacks_param` (beta_fallbacks_param.py).

import Foundation

public indirect enum BetaFallbacksParam: Codable, Hashable, Sendable, ExpressibleByArrayLiteral {
    case betaFallbackParams([BetaFallbackParam])
    case `default`(String)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(arrayLiteral elements: BetaFallbackParam...) { self = .betaFallbackParams(elements) }

    public init(from decoder: Decoder) throws {
        if let v = try? [BetaFallbackParam](from: decoder) { self = .betaFallbackParams(v); return }
        if let v = try? String(from: decoder) { self = .default(v); return }
        self = .unknown(try _Coding.raw(decoder))
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .betaFallbackParams(let v): try v.encode(to: encoder)
        case .default(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
