// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_phase_ended_event` (beta_managed_agents_workflow_run_phase_ended_event.py).

import Foundation

/// A workflow run's plan left a phase, or the run's end closed it.
///
/// Emitted once for every `workflow_run.phase_started` event, before the run's `workflow_run.status_ended` event. The event does not say whether the plan finished the phase's work, or why it left.
public struct BetaManagedAgentsWorkflowRunPhaseEndedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Identifier of the `workflow_run.phase_started` event that opened the phase.
    public var phaseStartedId: String
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

    public init(id: String, phaseStartedId: String, processedAt: Date, type: String = "workflow_run.phase_ended", workflowRunId: String, workflowRunPhaseId: String) {
        self.id = id
        self.phaseStartedId = phaseStartedId
        self.processedAt = processedAt
        self.type = type
        self.workflowRunId = workflowRunId
        self.workflowRunPhaseId = workflowRunPhaseId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case phaseStartedId = "phase_started_id"
        case processedAt = "processed_at"
        case type
        case workflowRunId = "workflow_run_id"
        case workflowRunPhaseId = "workflow_run_phase_id"
    }
}
