// Transformed from `anthropic.types.beta.beta_mcp_tool` (beta_mcp_tool.py).

import Foundation

/// A tool as an MCP server lists it: its name on that server, its
/// description, and its input schema.
public struct BetaMCPTool: Codable, Hashable, Sendable {
    public var inputSchema: [String: JSONValue]
    public var name: String
    public var description: String?

    public init(inputSchema: [String: JSONValue], name: String, description: String? = nil) {
        self.inputSchema = inputSchema
        self.name = name
        self.description = description
    }

    enum CodingKeys: String, CodingKey {
        case inputSchema = "input_schema"
        case name
        case description
    }
}
