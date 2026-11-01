// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_error_event` (beta_managed_agents_workflow_run_error_event.py).

import Foundation

/// A workflow run met an error, or an error kept a run from being created.
///
/// A run that ends with a `result.type` of `error` emits this event before its `workflow_run.status_ended`, with the same `error`.
public struct BetaManagedAgentsWorkflowRunErrorEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Why the run did not finish, or was not created.
    public var error: BetaManagedAgentsWorkflowRunError
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// Identifier of the run that met the error, or `null` when the error kept a run
    /// from being created.
    public var workflowRunID: String?

    public init(id: String, error: BetaManagedAgentsWorkflowRunError, processedAt: Date, type: String = "workflow_run.error", workflowRunID: String? = nil) {
        self.id = id
        self.error = error
        self.processedAt = processedAt
        self.type = type
        self.workflowRunID = workflowRunID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case error
        case processedAt = "processed_at"
        case type
        case workflowRunID = "workflow_run_id"
    }
}
