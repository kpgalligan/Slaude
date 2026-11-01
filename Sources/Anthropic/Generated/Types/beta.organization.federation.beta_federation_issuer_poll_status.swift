// Transformed from `anthropic.types.beta.organization.federation.beta_federation_issuer_poll_status` (beta_federation_issuer_poll_status.py).

import Foundation

/// Status of automatic JWKS polling for a federation issuer.
///
/// Anthropic periodically fetches the issuer's signing keys in the
/// background. These fields summarize the most recent fetches so the
/// health of the JWKS endpoint can be monitored.
public struct BetaFederationIssuerPollStatus: Codable, Hashable, Sendable {
    /// Consecutive fetch failures since the last success.
    public var consecutiveFailures: Int
    /// When the last successful fetch completed.
    public var lastFetchedAt: Date?
    /// When the next fetch is scheduled. Null if paused.
    public var nextPollAt: Date?

    public init(consecutiveFailures: Int, lastFetchedAt: Date? = nil, nextPollAt: Date? = nil) {
        self.consecutiveFailures = consecutiveFailures
        self.lastFetchedAt = lastFetchedAt
        self.nextPollAt = nextPollAt
    }

    enum CodingKeys: String, CodingKey {
        case consecutiveFailures = "consecutive_failures"
        case lastFetchedAt = "last_fetched_at"
        case nextPollAt = "next_poll_at"
    }
}
