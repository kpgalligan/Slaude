// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_coordinator_params` (beta_managed_agents_multiagent_coordinator_params.py).

import Foundation

/// A coordinator topology: the session's primary thread orchestrates work by spawning session threads, each running an agent drawn from the `agents` roster.
public struct BetaManagedAgentsMultiagentCoordinatorParams: Codable, Hashable, Sendable {
    /// Agents the coordinator may spawn as session threads.
    ///
    /// 1–20 entries. Each entry is an agent ID string, a versioned
    /// `{"type":"agent","id","version"}` reference, or `{"type":"self"}` to allow
    /// recursive self-invocation. Entries must reference distinct agents (after
    /// resolving `self` and string forms); at most one `self`. Referenced agents must
    /// exist, must not be archived, and must not themselves have `multiagent` set
    /// (depth limit 1).
    public var agents: [BetaManagedAgentsMultiagentRosterEntryParams]
    public var type: String

    public init(agents: [BetaManagedAgentsMultiagentRosterEntryParams], type: String = "coordinator") {
        self.agents = agents
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case agents
        case type
    }
}
