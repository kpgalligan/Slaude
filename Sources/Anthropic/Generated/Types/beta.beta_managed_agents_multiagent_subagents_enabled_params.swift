// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_subagents_enabled_params` (beta_managed_agents_multiagent_subagents_enabled_params.py).

import Foundation

/// The agent can spawn session threads.
///
/// Each thread runs a predefined agent, which is a saved agent in `predefined_agents`, or an inline agent, which the agent defines when it spawns the thread and which is not saved. If `inline_agents` is disabled, `predefined_agents` must name at least one agent.
public struct BetaManagedAgentsMultiagentSubagentsEnabledParams: Codable, Hashable, Sendable {
    public var type: String
    /// Whether the agent can define inline agents when it spawns session threads.
    ///
    /// Defaults to enabled.
    public var inlineAgents: BetaManagedAgentsMultiagentInlineAgentsParams??
    /// Predefined agents that this agent can spawn as session threads.
    ///
    /// At most 20. Defaults to null. Null and an empty list both mean no predefined
    /// agents. This list is separate from `workflows.predefined_agents`, and an agent
    /// in one list is not added to the other.
    public var predefinedAgents: [BetaManagedAgentsMultiagentPredefinedAgentParams]??

    public init(type: String = "enabled", inlineAgents: BetaManagedAgentsMultiagentInlineAgentsParams?? = nil, predefinedAgents: [BetaManagedAgentsMultiagentPredefinedAgentParams]?? = nil) {
        self.type = type
        self.inlineAgents = inlineAgents
        self.predefinedAgents = predefinedAgents
    }

    enum CodingKeys: String, CodingKey {
        case type
        case inlineAgents = "inline_agents"
        case predefinedAgents = "predefined_agents"
    }
}
