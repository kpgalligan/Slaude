// Transformed from `anthropic.types.beta.beta_managed_agents_mcp_toolset` (beta_managed_agents_mcp_toolset.py).

import Foundation

public struct BetaManagedAgentsMCPToolset: Codable, Hashable, Sendable {
    public var configs: [BetaManagedAgentsMCPToolConfig]
    /// Resolved default configuration for all tools from an MCP server.
    public var defaultConfig: BetaManagedAgentsMCPToolsetDefaultConfig
    public var mcpServerName: String
    public var type: String

    public init(configs: [BetaManagedAgentsMCPToolConfig], defaultConfig: BetaManagedAgentsMCPToolsetDefaultConfig, mcpServerName: String, type: String = "mcp_toolset") {
        self.configs = configs
        self.defaultConfig = defaultConfig
        self.mcpServerName = mcpServerName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case configs
        case defaultConfig = "default_config"
        case mcpServerName = "mcp_server_name"
        case type
    }
}
