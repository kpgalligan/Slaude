// Transformed from `anthropic.types.beta.beta_managed_agents_deployment` (beta_managed_agents_deployment.py).

import Foundation

/// A deployment is a configured instance of an agent — it binds the agent to everything needed to run it autonomously: an environment, credentials, initial events, and an optional schedule.
public struct BetaManagedAgentsDeployment: Codable, Hashable, Sendable {
    /// Unique identifier for this deployment.
    public var id: String
    /// Reference to the agent this deployment runs, resolved to a concrete version.
    public var agent: BetaManagedAgentsAgentReference
    /// Time the deployment was archived. Null if not archived.
    public var archivedAt: Date?
    /// Time the deployment was created.
    public var createdAt: Date
    /// Description of what the deployment does.
    public var description: String?
    /// ID of the `environment` where sessions run.
    public var environmentID: String
    /// Events sent to each session immediately after creation.
    public var initialEvents: [BetaManagedAgentsDeploymentInitialEvent]
    /// Arbitrary key-value metadata. Maximum 16 pairs.
    public var metadata: [String: String]
    /// Human-readable name.
    public var name: String
    /// Why the deployment is `paused`.
    ///
    /// Non-null exactly when `status` is `paused`; null otherwise.
    public var pausedReason: BetaManagedAgentsDeploymentPausedReason?
    /// Resources attached to sessions created from this deployment.
    ///
    /// Echoes the input minus write-only credentials.
    public var resources: [BetaManagedAgentsSessionResourceConfig]
    /// Recurring cron schedule.
    ///
    /// Presence enables scheduled execution; null means manual-only. Includes computed
    /// timestamps (next fire times, last run) on the cron variant.
    public var schedule: BetaManagedAgentsSchedule?
    /// Computed status of the deployment: `active` or `paused`.
    ///
    /// Archived deployments report `active` with `archived_at` set.
    public var status: BetaManagedAgentsDeploymentStatus
    public var type: String
    /// Time the deployment was last updated.
    public var updatedAt: Date
    /// Vault IDs supplying stored credentials for sessions created from this
    /// deployment.
    public var vaultIDs: [String]
    /// Spend ceiling stamped onto each session created from this deployment.
    ///
    /// Absent when no budget is set.
    public var budget: BetaManagedAgentsBudgetLimit?

    public init(id: String, agent: BetaManagedAgentsAgentReference, archivedAt: Date? = nil, createdAt: Date, description: String? = nil, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEvent], metadata: [String: String], name: String, pausedReason: BetaManagedAgentsDeploymentPausedReason? = nil, resources: [BetaManagedAgentsSessionResourceConfig], schedule: BetaManagedAgentsSchedule? = nil, status: BetaManagedAgentsDeploymentStatus, type: String = "deployment", updatedAt: Date, vaultIDs: [String], budget: BetaManagedAgentsBudgetLimit? = nil) {
        self.id = id
        self.agent = agent
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.description = description
        self.environmentID = environmentID
        self.initialEvents = initialEvents
        self.metadata = metadata
        self.name = name
        self.pausedReason = pausedReason
        self.resources = resources
        self.schedule = schedule
        self.status = status
        self.type = type
        self.updatedAt = updatedAt
        self.vaultIDs = vaultIDs
        self.budget = budget
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agent
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case description
        case environmentID = "environment_id"
        case initialEvents = "initial_events"
        case metadata
        case name
        case pausedReason = "paused_reason"
        case resources
        case schedule
        case status
        case type
        case updatedAt = "updated_at"
        case vaultIDs = "vault_ids"
        case budget
    }
}
