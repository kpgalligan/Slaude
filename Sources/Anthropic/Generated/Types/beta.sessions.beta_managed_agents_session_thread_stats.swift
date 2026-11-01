// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_stats` (beta_managed_agents_session_thread_stats.py).

import Foundation

/// Timing statistics for a session thread.
public struct BetaManagedAgentsSessionThreadStats: Codable, Hashable, Sendable {
    /// Cumulative time in seconds the thread spent actively running.
    ///
    /// Excludes idle time.
    public var activeSeconds: Double?
    /// Elapsed time since thread creation in seconds.
    ///
    /// For archived threads, frozen at the final update.
    public var durationSeconds: Double?
    /// Time in seconds for the thread to begin running.
    ///
    /// Zero for child threads, which start immediately.
    public var startupSeconds: Double?

    public init(activeSeconds: Double? = nil, durationSeconds: Double? = nil, startupSeconds: Double? = nil) {
        self.activeSeconds = activeSeconds
        self.durationSeconds = durationSeconds
        self.startupSeconds = startupSeconds
    }

    enum CodingKeys: String, CodingKey {
        case activeSeconds = "active_seconds"
        case durationSeconds = "duration_seconds"
        case startupSeconds = "startup_seconds"
    }
}
