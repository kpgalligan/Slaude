// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_phase` (beta_managed_agents_workflow_run_phase.py).

import Foundation

/// A phase that a workflow run's plan declares.
public struct BetaManagedAgentsWorkflowRunPhase: Codable, Hashable, Sendable {
    /// Unique identifier for the phase.
    public var id: String
    /// Description that the agent gave the phase, passed on as written, or `null` if it
    /// gave none.
    public var description: String?
    /// Name that the agent gave the phase, passed on as written.
    public var name: String

    public init(id: String, description: String? = nil, name: String) {
        self.id = id
        self.description = description
        self.name = name
    }

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case name
    }
}
