// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent20261001` (beta_managed_agents_multiagent20261001.py).

import Foundation

/// Resolved multiagent configuration with three members, each enabled or disabled on its own.
public struct BetaManagedAgentsMultiagent20261001: Codable, Hashable, Sendable {
    /// Whether the session's primary thread can consult an advisor model.
    public var advisor: BetaManagedAgentsMultiagentAdvisor
    /// Whether the agent can spawn session threads.
    public var subagents: BetaManagedAgentsMultiagentSubagents
    public var type: String
    /// Whether the agent can start workflow runs.
    public var workflows: BetaManagedAgentsMultiagentWorkflows

    public init(advisor: BetaManagedAgentsMultiagentAdvisor, subagents: BetaManagedAgentsMultiagentSubagents, type: String = "multiagent_20261001", workflows: BetaManagedAgentsMultiagentWorkflows) {
        self.advisor = advisor
        self.subagents = subagents
        self.type = type
        self.workflows = workflows
    }

    enum CodingKeys: String, CodingKey {
        case advisor
        case subagents
        case type
        case workflows
    }
}
