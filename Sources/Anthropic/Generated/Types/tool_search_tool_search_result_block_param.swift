// Transformed from `anthropic.types.tool_search_tool_search_result_block_param` (tool_search_tool_search_result_block_param.py).

import Foundation

public struct ToolSearchToolSearchResultBlockParam: Codable, Hashable, Sendable {
    public var toolReferences: [ToolReferenceBlockParam]
    public var type: String

    public init(toolReferences: [ToolReferenceBlockParam], type: String = "tool_search_tool_search_result") {
        self.toolReferences = toolReferences
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolReferences = "tool_references"
        case type
    }
}
