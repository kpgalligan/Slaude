// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_toolset_params` (beta_managed_agents_mcp_toolset_params.py).

import Foundation

/// Configuration for tools from an MCP server defined in `mcp_servers`.
public struct BetaManagedAgentsMCPToolsetParams: Codable, Hashable, Sendable {
    /// Name of the MCP server.
    ///
    /// Must match a server name from the mcp_servers array. 1-255 characters.
    public var mcpServerName: String
    public var type: String
    /// Per-tool configuration overrides.
    public var configs: [BetaManagedAgentsMCPToolConfigParams]?
    /// Default configuration for all tools from this server.
    public var defaultConfig: BetaManagedAgentsMCPToolsetDefaultConfigParams??

    public init(mcpServerName: String, type: String = "mcp_toolset", configs: [BetaManagedAgentsMCPToolConfigParams]? = nil, defaultConfig: BetaManagedAgentsMCPToolsetDefaultConfigParams?? = nil) {
        self.mcpServerName = mcpServerName
        self.type = type
        self.configs = configs
        self.defaultConfig = defaultConfig
    }

    enum CodingKeys: String, CodingKey {
        case mcpServerName = "mcp_server_name"
        case type
        case configs
        case defaultConfig = "default_config"
    }
}
