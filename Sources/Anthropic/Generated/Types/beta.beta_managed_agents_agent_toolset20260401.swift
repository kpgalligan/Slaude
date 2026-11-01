// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401` (beta_managed_agents_agent_toolset20260401.py).

import Foundation

public struct BetaManagedAgentsAgentToolset20260401: Codable, Hashable, Sendable {
    public var configs: [BetaManagedAgentsAgentToolConfig]
    /// Resolved default configuration for agent tools.
    public var defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfig
    public var type: String

    public init(configs: [BetaManagedAgentsAgentToolConfig], defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfig, type: String = "agent_toolset_20260401") {
        self.configs = configs
        self.defaultConfig = defaultConfig
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case configs
        case defaultConfig = "default_config"
        case type
    }
}
