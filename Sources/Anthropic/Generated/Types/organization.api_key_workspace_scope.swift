// Transformed from `anthropic.types.organization.api_key_workspace_scope` (api_key_workspace_scope.py).

import Foundation

public struct APIKeyWorkspaceScope: Codable, Hashable, Sendable {
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
