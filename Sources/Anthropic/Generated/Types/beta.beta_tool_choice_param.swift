// Transformed from `anthropic.types.beta.beta_tool_choice_param` (beta_tool_choice_param.py).

import Foundation

public indirect enum BetaToolChoiceParam: Codable, Hashable, Sendable {
    case auto(BetaToolChoiceAutoParam)
    case any(BetaToolChoiceAnyParam)
    case tool(BetaToolChoiceToolParam)
    case none(BetaToolChoiceNoneParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "auto": self = .auto(try BetaToolChoiceAutoParam(from: decoder))
        case "any": self = .any(try BetaToolChoiceAnyParam(from: decoder))
        case "tool": self = .tool(try BetaToolChoiceToolParam(from: decoder))
        case "none": self = .none(try BetaToolChoiceNoneParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .auto(let v): try v.encode(to: encoder)
        case .any(let v): try v.encode(to: encoder)
        case .tool(let v): try v.encode(to: encoder)
        case .none(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
