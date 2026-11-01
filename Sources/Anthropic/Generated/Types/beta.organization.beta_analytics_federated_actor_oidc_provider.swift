// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_oidc_provider` (beta_analytics_federated_actor_oidc_provider.py).

import Foundation

public struct BetaAnalyticsFederatedActorOIDCProvider: Codable, Hashable, Sendable {
    /// The federation issuer's URL.
    public var issuer: String?
    public var type: String

    public init(issuer: String? = nil, type: String = "oidc") {
        self.issuer = issuer
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case issuer
        case type
    }
}
