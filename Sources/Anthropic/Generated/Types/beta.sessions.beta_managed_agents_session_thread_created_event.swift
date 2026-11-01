// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_created_event` (beta_managed_agents_session_thread_created_event.py).

import Foundation

/// Emitted when a child thread is created.
///
/// Written to the parent thread's output stream so clients observing the session see child creation.
public struct BetaManagedAgentsSessionThreadCreatedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Name of the callable agent the thread runs.
    public var agentName: String
    /// Timestamp when the thread was created.
    public var processedAt: Date
    /// Public `sthr_` ID of the newly created thread.
    public var sessionThreadId: String
    public var type: String
    /// Identifier of the workflow run that created the thread, or `null` for any other
    /// thread.
    public var workflowRunId: String?

    public init(id: String, agentName: String, processedAt: Date, sessionThreadId: String, type: String = "session.thread_created", workflowRunId: String? = nil) {
        self.id = id
        self.agentName = agentName
        self.processedAt = processedAt
        self.sessionThreadId = sessionThreadId
        self.type = type
        self.workflowRunId = workflowRunId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agentName = "agent_name"
        case processedAt = "processed_at"
        case sessionThreadId = "session_thread_id"
        case type
        case workflowRunId = "workflow_run_id"
    }
}
