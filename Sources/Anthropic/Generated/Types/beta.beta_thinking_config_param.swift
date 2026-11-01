// Transformed from `anthropic.types.beta.beta_thinking_config_param` (beta_thinking_config_param.py).

import Foundation

public indirect enum BetaThinkingConfigParam: Codable, Hashable, Sendable {
    case enabled(BetaThinkingConfigEnabledParam)
    case disabled(BetaThinkingConfigDisabledParam)
    case betweenTools(BetaThinkingConfigBetweenToolsParam)
    case adaptive(BetaThinkingConfigAdaptiveParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaThinkingConfigEnabledParam(from: decoder))
        case "disabled": self = .disabled(try BetaThinkingConfigDisabledParam(from: decoder))
        case "between_tools": self = .betweenTools(try BetaThinkingConfigBetweenToolsParam(from: decoder))
        case "adaptive": self = .adaptive(try BetaThinkingConfigAdaptiveParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .enabled(let v): try v.encode(to: encoder)
        case .disabled(let v): try v.encode(to: encoder)
        case .betweenTools(let v): try v.encode(to: encoder)
        case .adaptive(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
