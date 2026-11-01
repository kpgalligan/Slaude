// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_workflows_enabled` (beta_managed_agents_multiagent_workflows_enabled.py).

import Foundation

/// The agent can start workflow runs.
public struct BetaManagedAgentsMultiagentWorkflowsEnabled: Codable, Hashable, Sendable {
    /// Whether a run's plan can define inline agents, which are not saved.
    public var inlineAgents: BetaManagedAgentsMultiagentInlineAgents
    /// Predefined agents, which are saved agents that a run's plan can use, each
    /// resolved to a specific version.
    public var predefinedAgents: [BetaManagedAgentsAgentReference]
    public var type: String

    public init(inlineAgents: BetaManagedAgentsMultiagentInlineAgents, predefinedAgents: [BetaManagedAgentsAgentReference], type: String = "enabled") {
        self.inlineAgents = inlineAgents
        self.predefinedAgents = predefinedAgents
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case inlineAgents = "inline_agents"
        case predefinedAgents = "predefined_agents"
        case type
    }
}
