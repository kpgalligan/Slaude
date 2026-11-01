// Transformed from `anthropic.types.beta.beta_managed_agents_session_multiagent_subagents_enabled` (beta_managed_agents_session_multiagent_subagents_enabled.py).

import Foundation

/// The agent can spawn session threads.
public struct BetaManagedAgentsSessionMultiagentSubagentsEnabled: Codable, Hashable, Sendable {
    /// Whether the agent can define inline agents, which are not saved, when it spawns
    /// session threads.
    public var inlineAgents: BetaManagedAgentsMultiagentInlineAgents
    /// Full `agent` definitions of the predefined agents, which are saved agents that
    /// this agent can spawn as session threads.
    public var predefinedAgents: [BetaManagedAgentsSessionThreadAgent]
    public var type: String

    public init(inlineAgents: BetaManagedAgentsMultiagentInlineAgents, predefinedAgents: [BetaManagedAgentsSessionThreadAgent], type: String = "enabled") {
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
