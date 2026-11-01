// Transformed from `anthropic.types.beta.organization.beta_api_key_workspace_scope` (beta_api_key_workspace_scope.py).

import Foundation

public struct BetaAPIKeyWorkspaceScope: Codable, Hashable, Sendable {
    /// Scope type. Always `"workspace"`: the API key belongs to one Workspace.
    public var type: String
    /// ID of the Workspace the API key belongs to, including when it is the
    /// organization's default Workspace.
    public var workspaceId: String

    public init(type: String = "workspace", workspaceId: String) {
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case workspaceId = "workspace_id"
    }
}
