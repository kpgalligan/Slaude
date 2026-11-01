// Transformed from `anthropic.types.beta.organization.beta_spend_limit_user_scope_param` (beta_spend_limit_user_scope_param.py).

import Foundation

/// Scope selecting a single member of the organization.
public struct BetaSpendLimitUserScopeParam: Codable, Hashable, Sendable {
    /// Scope type. Always `user` for this scope.
    public var type: String
    /// Tagged ID of the member the spend limit applies to.
    public var userId: String

    public init(type: String = "user", userId: String) {
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
    }
}
