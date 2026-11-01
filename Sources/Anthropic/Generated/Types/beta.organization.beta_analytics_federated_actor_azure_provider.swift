// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_azure_provider` (beta_analytics_federated_actor_azure_provider.py).

import Foundation

public struct BetaAnalyticsFederatedActorAzureProvider: Codable, Hashable, Sendable {
    /// The Azure subscription the organization is bound to.
    public var subscriptionId: String
    public var type: String

    public init(subscriptionId: String, type: String = "azure") {
        self.subscriptionId = subscriptionId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case subscriptionId = "subscription_id"
        case type
    }
}
