// Transformed from `anthropic.types.beta.beta_managed_agents_session_stats` (beta_managed_agents_session_stats.py).

import Foundation

/// Timing statistics for a session.
public struct BetaManagedAgentsSessionStats: Codable, Hashable, Sendable {
    /// Cumulative time in seconds the session spent in `running` status.
    ///
    /// Excludes idle time.
    public var activeSeconds: Double?
    /// Elapsed time since session creation in seconds.
    ///
    /// For terminated sessions, frozen at the final update.
    public var durationSeconds: Double?

    public init(activeSeconds: Double? = nil, durationSeconds: Double? = nil) {
        self.activeSeconds = activeSeconds
        self.durationSeconds = durationSeconds
    }

    enum CodingKeys: String, CodingKey {
        case activeSeconds = "active_seconds"
        case durationSeconds = "duration_seconds"
    }
}
