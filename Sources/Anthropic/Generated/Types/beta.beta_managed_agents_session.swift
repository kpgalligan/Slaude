// Transformed from `anthropic.types.beta.beta_managed_agents_session` (beta_managed_agents_session.py).

import Foundation

/// A Managed Agents `session`.
public struct BetaManagedAgentsSession: Codable, Hashable, Sendable {
    public var id: String
    /// Resolved `agent` definition for a `session`.
    ///
    /// Snapshot of the `agent` at `session` creation time.
    public var agent: BetaManagedAgentsSessionAgent
    /// When the session was archived. Null if not archived.
    public var archivedAt: Date?
    /// The session's enforced spend ceiling, or null when no budget is set.
    public var budget: BetaManagedAgentsBudgetLimit?
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    public var environmentId: String
    public var metadata: [String: String]
    /// Per-outcome evaluation state.
    ///
    /// One entry per `define_outcome` event sent to the session.
    public var outcomeEvaluations: [BetaManagedAgentsOutcomeEvaluationResource]
    public var resources: [BetaManagedAgentsSessionResource]
    /// Timing statistics for the session.
    public var stats: BetaManagedAgentsSessionStats
    /// - `rescheduling` - Transient error occurred, retrying automatically.
    /// - `running` - Agent is actively executing.
    /// - `idle` - Agent is waiting for input, including user messages or tool
    ///   confirmations. Sessions start in idle.
    /// - `terminated` - Session has ended, either due to an error or completion.
    public var status: Status
    public var title: String?
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date
    /// Cumulative token usage for the session.
    public var usage: BetaManagedAgentsSessionUsage
    /// Vault IDs attached to the session at creation.
    ///
    /// Empty when no vaults were supplied.
    public var vaultIds: [String]
    /// Deployment ID when the session was created from a deployment reference.
    ///
    /// Null otherwise.
    public var deploymentId: String?

    public init(id: String, agent: BetaManagedAgentsSessionAgent, archivedAt: Date? = nil, budget: BetaManagedAgentsBudgetLimit? = nil, createdAt: Date, environmentId: String, metadata: [String: String], outcomeEvaluations: [BetaManagedAgentsOutcomeEvaluationResource], resources: [BetaManagedAgentsSessionResource], stats: BetaManagedAgentsSessionStats, status: Status, title: String? = nil, type: String = "session", updatedAt: Date, usage: BetaManagedAgentsSessionUsage, vaultIds: [String], deploymentId: String? = nil) {
        self.id = id
        self.agent = agent
        self.archivedAt = archivedAt
        self.budget = budget
        self.createdAt = createdAt
        self.environmentId = environmentId
        self.metadata = metadata
        self.outcomeEvaluations = outcomeEvaluations
        self.resources = resources
        self.stats = stats
        self.status = status
        self.title = title
        self.type = type
        self.updatedAt = updatedAt
        self.usage = usage
        self.vaultIds = vaultIds
        self.deploymentId = deploymentId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agent
        case archivedAt = "archived_at"
        case budget
        case createdAt = "created_at"
        case environmentId = "environment_id"
        case metadata
        case outcomeEvaluations = "outcome_evaluations"
        case resources
        case stats
        case status
        case title
        case type
        case updatedAt = "updated_at"
        case usage
        case vaultIds = "vault_ids"
        case deploymentId = "deployment_id"
    }

    public enum Status: OpenEnum, CaseIterable {
        case rescheduling
        case running
        case idle
        case terminated
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.rescheduling, .running, .idle, .terminated]

        public init(rawValue: String) {
            switch rawValue {
            case "rescheduling": self = .rescheduling
            case "running": self = .running
            case "idle": self = .idle
            case "terminated": self = .terminated
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .rescheduling: return "rescheduling"
            case .running: return "running"
            case .idle: return "idle"
            case .terminated: return "terminated"
            case .unknown(let value): return value
            }
        }
    }
}
