// Transformed from `anthropic.types.beta.environments.work_heartbeat_params` (work_heartbeat_params.py).

import Foundation

public struct WorkHeartbeatParams: Codable, Hashable, Sendable {
    public var environmentID: String
    /// Desired TTL in seconds
    public var desiredTtlSeconds: Int??
    /// Expected last_heartbeat for conditional update (optimistic concurrency).
    ///
    /// Use literal 'NO_HEARTBEAT' to claim an unclaimed lease (first heartbeat). For
    /// subsequent heartbeats, echo the server's previous last_heartbeat value exactly.
    /// Returns 412 Precondition Failed if the actual value doesn't match.
    public var expectedLastHeartbeat: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(environmentID: String, desiredTtlSeconds: Int?? = nil, expectedLastHeartbeat: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.environmentID = environmentID
        self.desiredTtlSeconds = desiredTtlSeconds
        self.expectedLastHeartbeat = expectedLastHeartbeat
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case environmentID = "environment_id"
        case desiredTtlSeconds = "desired_ttl_seconds"
        case expectedLastHeartbeat = "expected_last_heartbeat"
        case betas
    }
}
