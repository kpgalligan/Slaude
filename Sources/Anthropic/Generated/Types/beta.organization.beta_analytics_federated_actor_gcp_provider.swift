// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_gcp_provider` (beta_analytics_federated_actor_gcp_provider.py).

import Foundation

public struct BetaAnalyticsFederatedActorGCPProvider: Codable, Hashable, Sendable {
    /// The Google Cloud project the organization is bound to.
    public var projectNumber: String
    public var type: String

    public init(projectNumber: String, type: String = "gcp") {
        self.projectNumber = projectNumber
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case projectNumber = "project_number"
        case type
    }
}
