// Transformed from `anthropic.types.beta.organization.beta_analytics_api_actor` (beta_analytics_api_actor.py).

import Foundation

public struct BetaAnalyticsAPIActor: Codable, Hashable, Sendable {
    /// Tagged API key ID.
    public var apiKeyID: String
    public var type: String

    public init(apiKeyID: String, type: String = "api_actor") {
        self.apiKeyID = apiKeyID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case apiKeyID = "api_key_id"
        case type
    }
}
