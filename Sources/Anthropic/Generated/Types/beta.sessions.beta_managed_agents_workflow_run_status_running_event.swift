// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_status_running_event` (beta_managed_agents_workflow_run_status_running_event.py).

import Foundation

/// A workflow run is running.
///
/// Emitted when the run starts to execute, and each time it resumes after being idle. A run that starts idle emits `workflow_run.status_idle` first.
public struct BetaManagedAgentsWorkflowRunStatusRunningEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// Identifier of the run.
    ///
    /// The same value is on all of the run's `workflow_run.*` events.
    public var workflowRunID: String

    public init(id: String, processedAt: Date, type: String = "workflow_run.status_running", workflowRunID: String) {
        self.id = id
        self.processedAt = processedAt
        self.type = type
        self.workflowRunID = workflowRunID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
        case workflowRunID = "workflow_run_id"
    }
}
