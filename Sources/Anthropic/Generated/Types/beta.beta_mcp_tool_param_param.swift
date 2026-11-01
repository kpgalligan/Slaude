// Transformed from `anthropic.types.beta.beta_mcp_tool_param_param` (beta_mcp_tool_param_param.py).

import Foundation

/// A tool as an MCP server lists it: its name on that server, its
/// description, and its input schema.
public struct BetaMCPToolParamParam: Codable, Hashable, Sendable {
    /// The tool's input schema as the MCP server lists it, verbatim.
    public var inputSchema: [String: JSONValue]
    /// The tool's name as the MCP server lists it (not prefixed with the server name).
    public var name: String
    /// The tool's description as the MCP server lists it.
    public var description: String??

    public init(inputSchema: [String: JSONValue], name: String, description: String?? = nil) {
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
