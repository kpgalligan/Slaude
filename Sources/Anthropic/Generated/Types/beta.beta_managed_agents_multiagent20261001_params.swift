// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent20261001_params` (beta_managed_agents_multiagent20261001_params.py).

import Foundation

/// Multiagent configuration with three members, each enabled or disabled on its own.
///
/// On an update, if the agent's stored `multiagent` also has type `multiagent_20261001`, this configuration is merged into the stored one, level by level, instead of replacing it. A key that the update omits keeps its stored value. A key sent as null takes its default, on create as well, so `"workflows": null` enables workflows. An object sent with a `type` other than the stored one replaces the stored object, and the keys that it omits take their defaults. A `predefined_agents` list that is sent replaces the stored list. Every object that is sent needs its `type`, and an enabled `advisor` needs its `model`. Other validation applies to the merged result.
public struct BetaManagedAgentsMultiagent20261001Params: Codable, Hashable, Sendable {
    public var type: String
    /// Whether the session's primary thread can consult an advisor model.
    ///
    /// Defaults to disabled.
    public var advisor: BetaManagedAgentsMultiagentAdvisorParams??
    /// Whether the agent can spawn session threads. Defaults to enabled.
    public var subagents: BetaManagedAgentsMultiagentSubagentsParams??
    /// Whether the agent can start workflow runs. Defaults to enabled.
    public var workflows: BetaManagedAgentsMultiagentWorkflowsParams??

    public init(type: String = "multiagent_20261001", advisor: BetaManagedAgentsMultiagentAdvisorParams?? = nil, subagents: BetaManagedAgentsMultiagentSubagentsParams?? = nil, workflows: BetaManagedAgentsMultiagentWorkflowsParams?? = nil) {
        self.type = type
        self.advisor = advisor
        self.subagents = subagents
        self.workflows = workflows
    }

    enum CodingKeys: String, CodingKey {
        case type
        case advisor
        case subagents
        case workflows
    }
}
