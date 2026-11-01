// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_azure_provider` (beta_analytics_federated_actor_azure_provider.py).

import Foundation

public struct BetaAnalyticsFederatedActorAzureProvider: Codable, Hashable, Sendable {
    /// The Azure subscription the organization is bound to.
    public var subscriptionID: String
    public var type: String

    public init(subscriptionID: String, type: String = "azure") {
        self.subscriptionID = subscriptionID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case subscriptionID = "subscription_id"
        case type
    }
}
