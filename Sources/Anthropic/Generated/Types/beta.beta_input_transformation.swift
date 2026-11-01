// Transformed from `anthropic.types.beta.beta_input_transformation` (beta_input_transformation.py).

import Foundation

public indirect enum BetaInputTransformation: Codable, Hashable, Sendable {
    case thinkingDropped(BetaThinkingDroppedInputTransformation)
    case thinkingMismatchAllowed(BetaThinkingMismatchAllowedInputTransformation)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "thinking_dropped": self = .thinkingDropped(try BetaThinkingDroppedInputTransformation(from: decoder))
        case "thinking_mismatch_allowed": self = .thinkingMismatchAllowed(try BetaThinkingMismatchAllowedInputTransformation(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .thinkingDropped(let v): try v.encode(to: encoder)
        case .thinkingMismatchAllowed(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
