// Transformed from `anthropic.types.beta.organization.beta_plugin_api_actor` (beta_plugin_api_actor.py).

import Foundation

public struct BetaPluginAPIActor: Codable, Hashable, Sendable {
    /// The key's ID.
    public var apiKeyID: String
    /// An Admin API key, in the same form the Compliance API activity feed uses for it.
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
