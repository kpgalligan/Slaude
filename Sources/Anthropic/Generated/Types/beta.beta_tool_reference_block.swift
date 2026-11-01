// Transformed from `anthropic.types.beta.beta_tool_reference_block` (beta_tool_reference_block.py).

import Foundation

public struct BetaToolReferenceBlock: Codable, Hashable, Sendable {
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
