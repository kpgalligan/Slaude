// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_status_ended_event` (beta_managed_agents_workflow_run_status_ended_event.py).

import Foundation

/// A workflow run ended.
///
/// Emitted once per run, as the last of the run's `workflow_run.*` events.
public struct BetaManagedAgentsWorkflowRunStatusEndedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    /// How the run ended.
    public var result: BetaManagedAgentsWorkflowRunResult
    public var type: String
    /// Identifier of the run.
    ///
    /// The same value is on all of the run's `workflow_run.*` events.
    public var workflowRunId: String

    public init(id: String, processedAt: Date, result: BetaManagedAgentsWorkflowRunResult, type: String = "workflow_run.status_ended", workflowRunId: String) {
        self.id = id
        self.processedAt = processedAt
        self.result = result
        self.type = type
        self.workflowRunId = workflowRunId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case result
        case type
        case workflowRunId = "workflow_run_id"
    }
}
