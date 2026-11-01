// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_phase_started_event` (beta_managed_agents_workflow_run_phase_started_event.py).

import Foundation

/// A workflow run's plan entered a phase.
public struct BetaManagedAgentsWorkflowRunPhaseStartedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// Identifier of the run.
    ///
    /// The same value is on all of the run's `workflow_run.*` events.
    public var workflowRunId: String
    /// Identifier of the phase, as in `phases` on the run's `workflow_run.created`
    /// event.
    public var workflowRunPhaseId: String

    public init(id: String, processedAt: Date, type: String = "workflow_run.phase_started", workflowRunId: String, workflowRunPhaseId: String) {
        self.id = id
        self.processedAt = processedAt
        self.type = type
        self.workflowRunId = workflowRunId
        self.workflowRunPhaseId = workflowRunPhaseId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
        case workflowRunId = "workflow_run_id"
        case workflowRunPhaseId = "workflow_run_phase_id"
    }
}
