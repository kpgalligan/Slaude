// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread` (beta_managed_agents_session_thread.py).

import Foundation

/// An execution thread within a `session`.
///
/// Each session has one primary thread plus zero or more child threads.
public struct BetaManagedAgentsSessionThread: Codable, Hashable, Sendable {
    /// Unique identifier for this thread.
    public var id: String
    /// Resolved agent definition for this thread.
    ///
    /// Snapshot of the agent at thread creation time.
    public var agent: BetaManagedAgentsSessionThread.Agent
    /// When the thread was archived. Null if not archived.
    public var archivedAt: Date?
    /// When the thread was created.
    public var createdAt: Date
    /// Parent thread that spawned this thread. Null for the primary thread.
    public var parentThreadId: String?
    /// The session this thread belongs to.
    public var sessionId: String
    /// Timing statistics for this thread.
    ///
    /// Null until the thread's first status transition.
    public var stats: BetaManagedAgentsSessionThreadStats?
    /// Current execution status of the thread.
    public var status: BetaManagedAgentsSessionThreadStatus
    public var type: String
    /// When the thread was last updated.
    public var updatedAt: Date
    /// Cumulative token usage for this thread.
    ///
    /// Null until the thread's first idle transition.
    public var usage: BetaManagedAgentsSessionThreadUsage?
    /// Identifier of the workflow run that created the thread, or `null` for any other
    /// thread.
    public var workflowRunId: String?

    public init(id: String, agent: BetaManagedAgentsSessionThread.Agent, archivedAt: Date? = nil, createdAt: Date, parentThreadId: String? = nil, sessionId: String, stats: BetaManagedAgentsSessionThreadStats? = nil, status: BetaManagedAgentsSessionThreadStatus, type: String = "session_thread", updatedAt: Date, usage: BetaManagedAgentsSessionThreadUsage? = nil, workflowRunId: String? = nil) {
        self.id = id
        self.agent = agent
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.parentThreadId = parentThreadId
        self.sessionId = sessionId
        self.stats = stats
        self.status = status
        self.type = type
        self.updatedAt = updatedAt
        self.usage = usage
        self.workflowRunId = workflowRunId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agent
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case parentThreadId = "parent_thread_id"
        case sessionId = "session_id"
        case stats
        case status
        case type
        case updatedAt = "updated_at"
        case usage
        case workflowRunId = "workflow_run_id"
    }
}

extension BetaManagedAgentsSessionThread {

    public indirect enum Agent: Codable, Hashable, Sendable {
        case agent(BetaManagedAgentsSessionThreadAgent)
        case advisor(BetaManagedAgentsAdvisor)
        case inline(BetaManagedAgentsInlineAgent)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "agent": self = .agent(try BetaManagedAgentsSessionThreadAgent(from: decoder))
            case "advisor": self = .advisor(try BetaManagedAgentsAdvisor(from: decoder))
            case "inline": self = .inline(try BetaManagedAgentsInlineAgent(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .agent(let v): try v.encode(to: encoder)
            case .advisor(let v): try v.encode(to: encoder)
            case .inline(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
