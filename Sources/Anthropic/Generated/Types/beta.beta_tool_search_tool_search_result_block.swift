// Transformed from `anthropic.types.beta.beta_tool_search_tool_search_result_block` (beta_tool_search_tool_search_result_block.py).

import Foundation

public struct BetaToolSearchToolSearchResultBlock: Codable, Hashable, Sendable {
    public var toolReferences: [BetaToolReferenceBlock]
    public var type: String

    public init(toolReferences: [BetaToolReferenceBlock], type: String = "tool_search_tool_search_result") {
        self.toolReferences = toolReferences
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolReferences = "tool_references"
        case type
    }
}
