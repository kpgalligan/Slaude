// Transformed from `anthropic.types.beta.beta_mcp_tool_use_block_param` (beta_mcp_tool_use_block_param.py).

import Foundation

public struct BetaMCPToolUseBlockParam: Codable, Hashable, Sendable {
    public var id: String
    public var input: [String: JSONValue]
    public var name: String
    /// The name of the MCP server
    public var serverName: String
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeralParam??

    public init(id: String, input: [String: JSONValue], name: String, serverName: String, type: String = "mcp_tool_use", cacheControl: BetaCacheControlEphemeralParam?? = nil) {
        self.id = id
        self.input = input
        self.name = name
        self.serverName = serverName
        self.type = type
        self.cacheControl = cacheControl
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case name
        case serverName = "server_name"
        case type
        case cacheControl = "cache_control"
    }
}
