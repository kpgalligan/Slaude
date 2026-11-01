// Transformed from `anthropic.types.beta.beta_tool_change_tool_reference_param` (beta_tool_change_tool_reference_param.py).

import Foundation

/// Reference to a single tool, by the name the model uses to call it: a
/// tool declared in ``tools`` or defined by an earlier ``tool_addition``
/// block. Does not accept the composed ``{server}_{name}`` form the server
/// assigns to MCP-resolved tools; use ``mcp_tool_reference`` or
/// ``mcp_toolset_reference`` for those.
public struct BetaToolChangeToolReferenceParam: Codable, Hashable, Sendable {
    public var name: String
    public var type: String

    public init(name: String, type: String = "tool_reference") {
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}
