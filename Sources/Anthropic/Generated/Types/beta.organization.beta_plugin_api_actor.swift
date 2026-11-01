// Transformed from `anthropic.types.beta.organization.beta_plugin_api_actor` (beta_plugin_api_actor.py).

import Foundation

public struct BetaPluginAPIActor: Codable, Hashable, Sendable {
    /// The key's ID.
    public var apiKeyId: String
    /// An Admin API key, in the same form the Compliance API activity feed uses for it.
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
