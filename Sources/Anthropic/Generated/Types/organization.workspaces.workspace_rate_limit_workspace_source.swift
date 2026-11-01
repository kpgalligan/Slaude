// Transformed from `anthropic.types.organization.workspaces.workspace_rate_limit_workspace_source` (workspace_rate_limit_workspace_source.py).

import Foundation

public struct WorkspaceRateLimitWorkspaceSource: Codable, Hashable, Sendable {
    /// Always `workspace`: a workspace-level override is stored.
    public var type: String

    public init(type: String = "workspace") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
