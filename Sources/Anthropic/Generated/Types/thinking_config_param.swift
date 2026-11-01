// Transformed from `anthropic.types.thinking_config_param` (thinking_config_param.py).

import Foundation

public indirect enum ThinkingConfigParam: Codable, Hashable, Sendable {
    case enabled(ThinkingConfigEnabledParam)
    case disabled(ThinkingConfigDisabledParam)
    case betweenTools(ThinkingConfigBetweenToolsParam)
    case adaptive(ThinkingConfigAdaptiveParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try ThinkingConfigEnabledParam(from: decoder))
        case "disabled": self = .disabled(try ThinkingConfigDisabledParam(from: decoder))
        case "between_tools": self = .betweenTools(try ThinkingConfigBetweenToolsParam(from: decoder))
        case "adaptive": self = .adaptive(try ThinkingConfigAdaptiveParam(from: decoder))
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
