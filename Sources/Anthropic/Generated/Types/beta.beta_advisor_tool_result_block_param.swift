// Transformed from `anthropic.types.beta.beta_advisor_tool_result_block_param` (beta_advisor_tool_result_block_param.py).

import Foundation

public struct BetaAdvisorToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaAdvisorToolResultBlockParam.Content
    public var toolUseId: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(content: BetaAdvisorToolResultBlockParam.Content, toolUseId: String, type: String = "advisor_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}

extension BetaAdvisorToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case advisorToolResultError(BetaAdvisorToolResultErrorParam)
        case advisorResult(BetaAdvisorResultBlockParam)
        case advisorRedactedResult(BetaAdvisorRedactedResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "advisor_tool_result_error": self = .advisorToolResultError(try BetaAdvisorToolResultErrorParam(from: decoder))
            case "advisor_result": self = .advisorResult(try BetaAdvisorResultBlockParam(from: decoder))
            case "advisor_redacted_result": self = .advisorRedactedResult(try BetaAdvisorRedactedResultBlockParam(from: decoder))
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
