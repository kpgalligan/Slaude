// Transformed from `anthropic.types.beta.beta_tool_search_tool_result_block` (beta_tool_search_tool_result_block.py).

import Foundation

public struct BetaToolSearchToolResultBlock: Codable, Hashable, Sendable {
    public var content: BetaToolSearchToolResultBlock.Content
    public var toolUseId: String
    public var type: String

    public init(content: BetaToolSearchToolResultBlock.Content, toolUseId: String, type: String = "tool_search_tool_result") {
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

extension BetaToolSearchToolResultBlock {

    public indirect enum Content: Codable, Hashable, Sendable {
        case toolSearchToolResultError(BetaToolSearchToolResultError)
        case toolSearchToolSearchResult(BetaToolSearchToolSearchResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "tool_search_tool_result_error": self = .toolSearchToolResultError(try BetaToolSearchToolResultError(from: decoder))
            case "tool_search_tool_search_result": self = .toolSearchToolSearchResult(try BetaToolSearchToolSearchResultBlock(from: decoder))
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
