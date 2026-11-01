// Transformed from `anthropic.types.beta.organization.beta_spend_limit_scoped_api_key_actor` (beta_spend_limit_scoped_api_key_actor.py).

import Foundation

/// A scoped Admin API key acting on behalf of the organization.
public struct BetaSpendLimitScopedAPIKeyActor: Codable, Hashable, Sendable {
    public var scopedApiKeyId: String
    public var type: String

    public init(scopedApiKeyId: String, type: String = "scoped_api_key_actor") {
        self.scopedApiKeyId = scopedApiKeyId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case scopedApiKeyId = "scoped_api_key_id"
        case type
    }
}
