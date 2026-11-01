// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_workflows_enabled_params` (beta_managed_agents_multiagent_workflows_enabled_params.py).

import Foundation

/// The agent can start workflow runs.
///
/// Each run follows a plan, a program that the agent writes. A plan can use predefined agents, which are the saved agents in `predefined_agents`, and inline agents, which it defines itself and which are not saved. If `inline_agents` is disabled, `predefined_agents` must name at least one agent.
public struct BetaManagedAgentsMultiagentWorkflowsEnabledParams: Codable, Hashable, Sendable {
    public var type: String
    /// Whether a run's plan can define inline agents. Defaults to enabled.
    public var inlineAgents: BetaManagedAgentsMultiagentInlineAgentsParams??
    /// Predefined agents that a run's plan can use.
    ///
    /// At most 20. Defaults to null. Null and an empty list both mean no predefined
    /// agents. This list is separate from `subagents.predefined_agents`, and an agent
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
