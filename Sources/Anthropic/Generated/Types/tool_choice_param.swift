// Transformed from `anthropic.types.tool_choice_param` (tool_choice_param.py).

import Foundation

public indirect enum ToolChoiceParam: Codable, Hashable, Sendable {
    case auto(ToolChoiceAutoParam)
    case any(ToolChoiceAnyParam)
    case tool(ToolChoiceToolParam)
    case none(ToolChoiceNoneParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "auto": self = .auto(try ToolChoiceAutoParam(from: decoder))
        case "any": self = .any(try ToolChoiceAnyParam(from: decoder))
        case "tool": self = .tool(try ToolChoiceToolParam(from: decoder))
        case "none": self = .none(try ToolChoiceNoneParam(from: decoder))
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
