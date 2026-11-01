// Transformed from `anthropic.types.beta.beta_managed_agents_agent_toolset20260401_params` (beta_managed_agents_agent_toolset20260401_params.py).

import Foundation

/// Configuration for built-in agent tools.
///
/// Use this to enable or disable groups of tools available to the agent.
public struct BetaManagedAgentsAgentToolset20260401Params: Codable, Hashable, Sendable {
    public var type: String
    /// Per-tool configuration overrides.
    public var configs: [BetaManagedAgentsAgentToolConfigParams]?
    /// Default configuration applied to all tools in this set.
    public var defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfigParams??

    public init(type: String = "agent_toolset_20260401", configs: [BetaManagedAgentsAgentToolConfigParams]? = nil, defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfigParams?? = nil) {
        self.type = type
        self.configs = configs
        self.defaultConfig = defaultConfig
    }

    enum CodingKeys: String, CodingKey {
        case type
        case configs
        case defaultConfig = "default_config"
    }
}
