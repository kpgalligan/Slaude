// Transformed from `anthropic.types.beta.environments.beta_self_hosted_work_queue_stats` (beta_self_hosted_work_queue_stats.py).

import Foundation

/// Statistics about the work queue for an environment.
public struct BetaSelfHostedWorkQueueStats: Codable, Hashable, Sendable {
    /// Number of work items waiting to be picked up
    public var depth: Int
    /// RFC 3339 timestamp of oldest item in the work stream (includes both queued and
    /// pending items), null if stream empty
    public var oldestQueuedAt: String?
    /// Number of work items being processed (polled but not acknowledged)
    public var pending: Int
    /// The type of object
    public var type: String
    /// Number of workers that have polled for work in the last 30 seconds.
    ///
    /// Requires worker_id to be sent with poll requests.
    public var workersPolling: Int?

    public init(depth: Int, oldestQueuedAt: String? = nil, pending: Int, type: String = "work_queue_stats", workersPolling: Int? = nil) {
        self.depth = depth
        self.oldestQueuedAt = oldestQueuedAt
        self.pending = pending
        self.type = type
        self.workersPolling = workersPolling
    }

    enum CodingKeys: String, CodingKey {
        case depth
        case oldestQueuedAt = "oldest_queued_at"
        case pending
        case type
        case workersPolling = "workers_polling"
    }
}
