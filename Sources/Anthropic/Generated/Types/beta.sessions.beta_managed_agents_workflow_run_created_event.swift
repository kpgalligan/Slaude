// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_created_event` (beta_managed_agents_workflow_run_created_event.py).

import Foundation

/// A workflow run was created.
///
/// A workflow run is background work that the session's agent starts. Emitted once per run, before the run's other `workflow_run.*` events.
public struct BetaManagedAgentsWorkflowRunCreatedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Description that the agent gave the run, passed on as written, or `null` if it
    /// gave none.
    public var description: String?
    /// Name that the agent gave the run, passed on as written, or a name that the
    /// server assigned.
    public var name: String
    /// The phases that the run's plan declares, in the plan's order. Can be empty.
    public var phases: [BetaManagedAgentsWorkflowRunPhase]
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// Identifier of the run.
    ///
    /// The same value is on all of the run's `workflow_run.*` events.
    public var workflowRunId: String

    public init(id: String, description: String? = nil, name: String, phases: [BetaManagedAgentsWorkflowRunPhase], processedAt: Date, type: String = "workflow_run.created", workflowRunId: String) {
        self.id = id
        self.description = description
        self.name = name
        self.phases = phases
        self.processedAt = processedAt
        self.type = type
        self.workflowRunId = workflowRunId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case name
        case phases
        case processedAt = "processed_at"
        case type
        case workflowRunId = "workflow_run_id"
    }
}
