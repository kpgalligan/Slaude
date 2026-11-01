// Transformed from `anthropic.types.beta.organization.beta_spend_limit_workspace_scope` (beta_spend_limit_workspace_scope.py).

import Foundation

/// Scope selecting one workspace of a Claude Console organization.
public struct BetaSpendLimitWorkspaceScope: Codable, Hashable, Sendable {
    /// Scope type. Always `workspace` for this scope.
    public var type: String
    /// Tagged ID of the workspace the spend limit applies to.
    public var workspaceID: String

    public init(type: String = "workspace", workspaceID: String) {
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case workspaceID = "workspace_id"
    }
}
