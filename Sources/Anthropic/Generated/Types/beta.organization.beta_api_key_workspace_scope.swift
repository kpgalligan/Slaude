// Transformed from `anthropic.types.beta.organization.beta_api_key_workspace_scope` (beta_api_key_workspace_scope.py).

import Foundation

public struct BetaAPIKeyWorkspaceScope: Codable, Hashable, Sendable {
    /// Scope type. Always `"workspace"`: the API key belongs to one Workspace.
    public var type: String
    /// ID of the Workspace the API key belongs to, including when it is the
    /// organization's default Workspace.
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
