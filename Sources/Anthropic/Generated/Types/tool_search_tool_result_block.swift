// Transformed from `anthropic.types.tool_search_tool_result_block` (tool_search_tool_result_block.py).

import Foundation

public struct ToolSearchToolResultBlock: Codable, Hashable, Sendable {
    public var content: ToolSearchToolResultBlock.Content
    public var toolUseId: String
    public var type: String

    public init(content: ToolSearchToolResultBlock.Content, toolUseId: String, type: String = "tool_search_tool_result") {
        self.content = content
        self.toolUseId = toolUseId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case toolUseId = "tool_use_id"
        case type
    }
}

extension ToolSearchToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case toolSearchToolResultError(ToolSearchToolResultError)
        case toolSearchToolSearchResult(ToolSearchToolSearchResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_search_tool_result_error": self = .toolSearchToolResultError(try ToolSearchToolResultError(from: decoder))
            case "tool_search_tool_search_result": self = .toolSearchToolSearchResult(try ToolSearchToolSearchResultBlock(from: decoder))
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
