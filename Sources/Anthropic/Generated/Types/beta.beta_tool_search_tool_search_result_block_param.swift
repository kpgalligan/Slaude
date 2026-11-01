// Transformed from `anthropic.types.beta.beta_tool_search_tool_search_result_block_param` (beta_tool_search_tool_search_result_block_param.py).

import Foundation

public struct BetaToolSearchToolSearchResultBlockParam: Codable, Hashable, Sendable {
    public var toolReferences: [BetaToolReferenceBlockParam]
    public var type: String

    public init(toolReferences: [BetaToolReferenceBlockParam], type: String = "tool_search_tool_search_result") {
        self.toolReferences = toolReferences
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolReferences = "tool_references"
        case type
    }
}
