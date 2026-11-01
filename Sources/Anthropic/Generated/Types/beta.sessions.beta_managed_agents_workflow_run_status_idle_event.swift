// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_status_idle_event` (beta_managed_agents_workflow_run_status_idle_event.py).

import Foundation

/// A workflow run is idle.
///
/// Emitted each time the run goes idle, whatever the cause. If the run ends while idle, no `workflow_run.status_running` comes between this event and its `workflow_run.status_ended`.
public struct BetaManagedAgentsWorkflowRunStatusIdleEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// Identifier of the run.
    ///
    /// The same value is on all of the run's `workflow_run.*` events.
    public var workflowRunId: String

    public init(id: String, processedAt: Date, type: String = "workflow_run.status_idle", workflowRunId: String) {
        self.id = id
        self.processedAt = processedAt
        self.type = type
        self.workflowRunId = workflowRunId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case type
        case workflowRunId = "workflow_run_id"
    }
}
