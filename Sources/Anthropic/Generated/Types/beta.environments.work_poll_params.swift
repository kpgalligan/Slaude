// Transformed from `anthropic.types.beta.environments.work_poll_params` (work_poll_params.py).

import Foundation

public struct WorkPollParams: Codable, Hashable, Sendable {
    /// How long to wait for work to arrive before returning.
    ///
    /// Must be 1-999 in milliseconds. Defaults to non-blocking (returns immediately if
    /// no work is available).
    public var blockMs: Int??
    /// Reclaim unacknowledged work items older than this many milliseconds.
    ///
    /// If omitted, uses the default (5000ms).
    public var reclaimOlderThanMs: Int??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Unique identifier for the specific worker polling, used to track aggregated
    /// environment-level work metrics in Console
    public var anthropicWorkerID: String?

    public init(blockMs: Int?? = nil, reclaimOlderThanMs: Int?? = nil, betas: [AnthropicBetaParam]? = nil, anthropicWorkerID: String? = nil) {
        self.blockMs = blockMs
        self.reclaimOlderThanMs = reclaimOlderThanMs
        self.betas = betas
        self.anthropicWorkerID = anthropicWorkerID
    }

    enum CodingKeys: String, CodingKey {
        case blockMs = "block_ms"
        case reclaimOlderThanMs = "reclaim_older_than_ms"
        case betas
        case anthropicWorkerID = "anthropic_worker_id"
    }
}
