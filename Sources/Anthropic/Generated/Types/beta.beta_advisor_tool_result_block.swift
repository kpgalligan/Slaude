// Transformed from `anthropic.types.beta.beta_advisor_tool_result_block` (beta_advisor_tool_result_block.py).

import Foundation

public struct BetaAdvisorToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaAdvisorToolResultBlock.Content
    public var toolUseID: String
    public var type: String

    public init(content: BetaAdvisorToolResultBlock.Content, toolUseID: String, type: String = "advisor_tool_result") {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
    }
}

extension BetaAdvisorToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case advisorToolResultError(BetaAdvisorToolResultError)
        case advisorResult(BetaAdvisorResultBlock)
        case advisorRedactedResult(BetaAdvisorRedactedResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "advisor_tool_result_error": self = .advisorToolResultError(try BetaAdvisorToolResultError(from: decoder))
            case "advisor_result": self = .advisorResult(try BetaAdvisorResultBlock(from: decoder))
            case "advisor_redacted_result": self = .advisorRedactedResult(try BetaAdvisorRedactedResultBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .advisorToolResultError(let v): try v.encode(to: encoder)
            case .advisorResult(let v): try v.encode(to: encoder)
            case .advisorRedactedResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
