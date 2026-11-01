// Transformed from `anthropic.types.tool_reference_block` (tool_reference_block.py).

import Foundation

public struct ToolReferenceBlock: Codable, Hashable, Sendable {
    public var toolName: String
    public var type: String

    public init(toolName: String, type: String = "tool_reference") {
        self.toolName = toolName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case toolName = "tool_name"
        case type
    }
}
