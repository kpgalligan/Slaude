// Transformed from `anthropic.types.beta.environments.beta_self_hosted_work` (beta_self_hosted_work.py).

import Foundation

/// Work resource representing a unit of work in a self-hosted environment.
///
/// Work items are queued when sessions are created or when long-dormant sessions
/// receive new messages. The environment worker polls for work to execute in a
/// self-hosted sandbox.
public struct BetaSelfHostedWork: Codable, Hashable, Sendable {
    /// Work identifier (e.g., 'work\__...')
    public var id: String
    /// RFC 3339 timestamp when the work item was acknowledged and assigned to a
    /// self-hosted sandbox
    public var acknowledgedAt: String?
    /// RFC 3339 timestamp when work was created
    public var createdAt: String
    /// The actual work to be performed
    public var data: BetaSessionWorkData
    /// Environment identifier this work belongs to (e.g., `env_...`)
    public var environmentID: String
    /// RFC 3339 timestamp of the most recent heartbeat
    public var latestHeartbeatAt: String?
    /// User-provided metadata key-value pairs associated with this work item
    public var metadata: [String: String]
    /// Credential payload used by the environment worker to execute this work item.
    ///
    /// May be populated when polling for work; null on all other retrieval paths.
    public var secret: String?
    /// RFC 3339 timestamp when work execution started
    public var startedAt: String?
    /// Current state of the work item
    public var state: State
    /// RFC 3339 timestamp when stop was requested
    public var stopRequestedAt: String?
    /// RFC 3339 timestamp when work execution stopped
    public var stoppedAt: String?
    /// The type of object (always 'work')
    public var type: String

    public init(id: String, acknowledgedAt: String? = nil, createdAt: String, data: BetaSessionWorkData, environmentID: String, latestHeartbeatAt: String? = nil, metadata: [String: String], secret: String? = nil, startedAt: String? = nil, state: State, stopRequestedAt: String? = nil, stoppedAt: String? = nil, type: String = "work") {
        self.id = id
        self.acknowledgedAt = acknowledgedAt
        self.createdAt = createdAt
        self.data = data
        self.environmentID = environmentID
        self.latestHeartbeatAt = latestHeartbeatAt
        self.metadata = metadata
        self.secret = secret
        self.startedAt = startedAt
        self.state = state
        self.stopRequestedAt = stopRequestedAt
        self.stoppedAt = stoppedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case acknowledgedAt = "acknowledged_at"
        case createdAt = "created_at"
        case data
        case environmentID = "environment_id"
        case latestHeartbeatAt = "latest_heartbeat_at"
        case metadata
        case secret
        case startedAt = "started_at"
        case state
        case stopRequestedAt = "stop_requested_at"
        case stoppedAt = "stopped_at"
        case type
    }

    public enum State: OpenEnum, CaseIterable {
        case queued
        case starting
        case active
        case stopping
        case stopped
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [State] = [.queued, .starting, .active, .stopping, .stopped]

        public init(rawValue: String) {
            switch rawValue {
            case "queued": self = .queued
            case "starting": self = .starting
            case "active": self = .active
            case "stopping": self = .stopping
            case "stopped": self = .stopped
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .queued: return "queued"
            case .starting: return "starting"
            case .active: return "active"
            case .stopping: return "stopping"
            case .stopped: return "stopped"
            case .unknown(let value): return value
            }
        }
    }
}
