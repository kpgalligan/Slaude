// Transformed from `anthropic.types.beta.beta_context_management_config_param` (beta_context_management_config_param.py).

import Foundation

public struct BetaContextManagementConfigParam: Codable, Hashable, Sendable {
    /// List of context management edits to apply
    public var edits: [BetaContextManagementConfigParam.Edit]?

    public init(edits: [BetaContextManagementConfigParam.Edit]? = nil) {
        self.edits = edits
    }

    enum CodingKeys: String, CodingKey {
        case edits
    }
}

extension BetaContextManagementConfigParam {

    public indirect enum Edit: Codable, Hashable, Sendable {
        case clearToolUses20250919(BetaClearToolUses20250919EditParam)
        case clearThinking20251015(BetaClearThinking20251015EditParam)
        case compact20260112(BetaCompact20260112EditParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "clear_tool_uses_20250919": self = .clearToolUses20250919(try BetaClearToolUses20250919EditParam(from: decoder))
            case "clear_thinking_20251015": self = .clearThinking20251015(try BetaClearThinking20251015EditParam(from: decoder))
            case "compact_20260112": self = .compact20260112(try BetaCompact20260112EditParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .clearToolUses20250919(let v): try v.encode(to: encoder)
            case .clearThinking20251015(let v): try v.encode(to: encoder)
            case .compact20260112(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
