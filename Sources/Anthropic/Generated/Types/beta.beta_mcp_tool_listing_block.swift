// Transformed from `anthropic.types.beta.beta_mcp_tool_listing_block` (beta_mcp_tool_listing_block.py).

import Foundation

/// The tool listing the server fetched from an MCP server while producing
/// this response. Send the assistant message back unchanged, this block
/// included, so later requests use this listing instead of asking the MCP
/// server again.
public struct BetaMCPToolListingBlock: Codable, Hashable, Sendable {
    public var mcpServerName: String
    public var tools: [BetaMCPTool]
    public var type: String

    public init(mcpServerName: String, tools: [BetaMCPTool], type: String = "mcp_tool_listing") {
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
