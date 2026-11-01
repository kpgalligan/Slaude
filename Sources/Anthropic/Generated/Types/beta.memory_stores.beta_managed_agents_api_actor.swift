// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_api_actor` (beta_managed_agents_api_actor.py).

import Foundation

/// A direct caller of the public API, identified by the API key that authenticated the request.
public struct BetaManagedAgentsAPIActor: Codable, Hashable, Sendable {
    /// ID of the API key (an `apikey_...` value).
    ///
    /// This identifies the key, not the secret.
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
