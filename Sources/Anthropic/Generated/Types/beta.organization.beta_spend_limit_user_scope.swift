// Transformed from `anthropic.types.beta.organization.beta_spend_limit_user_scope` (beta_spend_limit_user_scope.py).

import Foundation

/// Scope selecting a single member of the organization.
public struct BetaSpendLimitUserScope: Codable, Hashable, Sendable {
    /// Scope type. Always `user` for this scope.
    public var type: String
    /// Tagged ID of the member the spend limit applies to.
    public var userID: String

    public init(type: String = "user", userID: String) {
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
    }
}
