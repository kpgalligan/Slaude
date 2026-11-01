// Transformed from `anthropic.types.beta.beta_mcp_tool_listing_block_param` (beta_mcp_tool_listing_block_param.py).

import Foundation

/// The tool listing an MCP server returned while an earlier response was
/// produced, as that response carried it. Send the assistant message back
/// unchanged, this block included, and the server uses this listing for the
/// matching `mcp_toolset` instead of asking the MCP server again.
public struct BetaMCPToolListingBlockParam: Codable, Hashable, Sendable {
    /// The name of the MCP server this listing came from, as `mcp_servers` declares it.
    public var mcpServerName: String
    /// The server's tools, exactly as the response listed them.
    public var tools: [BetaMCPToolParamParam]
    public var type: String

    public init(mcpServerName: String, tools: [BetaMCPToolParamParam], type: String = "mcp_tool_listing") {
        self.mcpServerName = mcpServerName
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerName = "mcp_server_name"
        case tools
        case type
    }
}
