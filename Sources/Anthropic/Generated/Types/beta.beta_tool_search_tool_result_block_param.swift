// Transformed from `anthropic.types.beta.beta_tool_search_tool_result_block_param` (beta_tool_search_tool_result_block_param.py).

import Foundation

public struct BetaToolSearchToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: BetaToolSearchToolResultBlockParam.Content
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(content: BetaToolSearchToolResultBlockParam.Content, toolUseID: String, type: String = "tool_search_tool_result", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.content = content
        self.toolUseID = toolUseID
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseID = "tool_use_id"
        case type
        case cacheControl = "cache_control"
    }
}

extension BetaToolSearchToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case toolSearchToolResultError(BetaToolSearchToolResultErrorParam)
        case toolSearchToolSearchResult(BetaToolSearchToolSearchResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_search_tool_result_error": self = .toolSearchToolResultError(try BetaToolSearchToolResultErrorParam(from: decoder))
            case "tool_search_tool_search_result": self = .toolSearchToolSearchResult(try BetaToolSearchToolSearchResultBlockParam(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .toolSearchToolResultError(let v): try v.encode(to: encoder)
            case .toolSearchToolSearchResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
