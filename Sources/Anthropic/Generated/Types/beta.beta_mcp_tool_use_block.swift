// Transformed from `anthropic.types.beta.beta_mcp_tool_use_block` (beta_mcp_tool_use_block.py).

import Foundation

public struct BetaMCPToolUseBlock: Codable, Hashable, Sendable {
    public var id: String
    public var input: [String: JSONValue]
    /// The name of the MCP tool
    public var name: String
    /// The name of the MCP server
    public var serverName: String
    public var type: String

    public init(id: String, input: [String: JSONValue], name: String, serverName: String, type: String = "mcp_tool_use") {
        self.id = id
        self.input = input
        self.name = name
        self.serverName = serverName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case name
        case serverName = "server_name"
        case type
    }
}
