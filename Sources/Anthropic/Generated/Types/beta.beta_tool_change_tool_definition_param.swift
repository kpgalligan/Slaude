// Transformed from `anthropic.types.beta.beta_tool_change_tool_definition_param` (beta_tool_change_tool_definition_param.py).

import Foundation

/// A tool defined by value: `definition` is a `tools` entry (any kind
/// `tools` accepts, an MCP toolset included). An `mcp_toolset` given here
/// also requires the `mcp-client-2026-09-15` beta.
public struct BetaToolChangeToolDefinitionParam: Codable, Hashable, Sendable {
    public var definition: BetaToolUnionParam
    public var type: String

    public init(definition: BetaToolUnionParam, type: String = "tool_definition") {
        self.definition = definition
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case definition
        case type
    }
}
