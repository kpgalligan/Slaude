// Transformed from `anthropic.types.tool_search_tool_result_block_param` (tool_search_tool_result_block_param.py).

import Foundation

public struct ToolSearchToolResultBlockParam: Codable, Hashable, Sendable {
    public var content: ToolSearchToolResultBlockParam.Content
    public var toolUseID: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??

    public init(content: ToolSearchToolResultBlockParam.Content, toolUseID: String, type: String = "tool_search_tool_result", cacheControl: CacheControlEphemeralParam?? = nil) {
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

extension ToolSearchToolResultBlockParam {

    public indirect enum Content: Codable, Hashable, Sendable {
        case toolSearchToolResultError(ToolSearchToolResultErrorParam)
        case toolSearchToolSearchResult(ToolSearchToolSearchResultBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_search_tool_result_error": self = .toolSearchToolResultError(try ToolSearchToolResultErrorParam(from: decoder))
            case "tool_search_tool_search_result": self = .toolSearchToolSearchResult(try ToolSearchToolSearchResultBlockParam(from: decoder))
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
