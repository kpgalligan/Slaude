// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor` (beta_analytics_federated_actor.py).

import Foundation

public struct BetaAnalyticsFederatedActor: Codable, Hashable, Sendable {
    /// The trusted provider that asserted the caller's identity.
    public var provider: BetaAnalyticsFederatedActorProvider
    /// The provider's identifier for the caller: on `aws`, the IAM principal ARN (one
    /// role is one actor across its sessions); on `gcp`, the caller's IAM principal
    /// identifier as Google Cloud reports it, such as `serviceAccount:<email>`,
    /// `user:<email>`, or a `principal://...` URI.
    public var subject: String?
    public var type: String

    public init(provider: BetaAnalyticsFederatedActorProvider, subject: String? = nil, type: String = "federated_actor") {
        self.provider = provider
        self.subject = subject
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case provider
        case subject
        case type
    }
}
