// Transformed from `anthropic.types.beta.organization.beta_analytics_api_actor` (beta_analytics_api_actor.py).

import Foundation

public struct BetaAnalyticsAPIActor: Codable, Hashable, Sendable {
    /// Tagged API key ID.
    public var apiKeyId: String
    public var type: String

    public init(apiKeyId: String, type: String = "api_actor") {
        self.apiKeyId = apiKeyId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case apiKeyId = "api_key_id"
        case type
    }
}
