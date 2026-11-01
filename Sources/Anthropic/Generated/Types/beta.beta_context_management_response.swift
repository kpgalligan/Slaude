// Transformed from `anthropic.types.beta.beta_context_management_response` (beta_context_management_response.py).

import Foundation

public struct BetaContextManagementResponse: Codable, Hashable, Sendable {
    /// List of context management edits that were applied.
    public var appliedEdits: [BetaContextManagementResponse.AppliedEdit]

    public init(appliedEdits: [BetaContextManagementResponse.AppliedEdit]) {
        self.appliedEdits = appliedEdits
    }

    enum CodingKeys: String, CodingKey {
        case appliedEdits = "applied_edits"
    }
}

extension BetaContextManagementResponse {

    public indirect enum AppliedEdit: Codable, Hashable, Sendable {
        case clearToolUses20250919(BetaClearToolUses20250919EditResponse)
        case clearThinking20251015(BetaClearThinking20251015EditResponse)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "clear_tool_uses_20250919": self = .clearToolUses20250919(try BetaClearToolUses20250919EditResponse(from: decoder))
            case "clear_thinking_20251015": self = .clearThinking20251015(try BetaClearThinking20251015EditResponse(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .clearToolUses20250919(let v): try v.encode(to: encoder)
            case .clearThinking20251015(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
