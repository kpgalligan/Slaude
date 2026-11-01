// Transformed from `anthropic.types.beta.environments.beta_self_hosted_work_heartbeat_response` (beta_self_hosted_work_heartbeat_response.py).

import Foundation

/// Response after recording a heartbeat for a work item.
public struct BetaSelfHostedWorkHeartbeatResponse: Codable, Hashable, Sendable {
    /// RFC 3339 timestamp of the most recent heartbeat recorded for this work item, or
    /// an empty string if none has been recorded
    public var lastHeartbeat: String
    /// Whether the heartbeat succeeded in extending the lease
    public var leaseExtended: Bool
    /// Current state of the work item (active/stopping/stopped)
    public var state: State
    /// Effective TTL applied to the lease
    public var ttlSeconds: Int
    /// The type of response
    public var type: String

    public init(lastHeartbeat: String, leaseExtended: Bool, state: State, ttlSeconds: Int, type: String = "work_heartbeat") {
        self.lastHeartbeat = lastHeartbeat
        self.leaseExtended = leaseExtended
        self.state = state
        self.ttlSeconds = ttlSeconds
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case lastHeartbeat = "last_heartbeat"
        case leaseExtended = "lease_extended"
        case state
        case ttlSeconds = "ttl_seconds"
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
