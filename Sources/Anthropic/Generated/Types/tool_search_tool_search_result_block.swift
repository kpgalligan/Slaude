// Transformed from `anthropic.types.tool_search_tool_search_result_block` (tool_search_tool_search_result_block.py).

import Foundation

public struct ToolSearchToolSearchResultBlock: Codable, Hashable, Sendable {
    public var toolReferences: [ToolReferenceBlock]
    public var type: String

    public init(toolReferences: [ToolReferenceBlock], type: String = "tool_search_tool_search_result") {
        self.toolReferences = toolReferences
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolReferences = "tool_references"
        case type
    }
}
