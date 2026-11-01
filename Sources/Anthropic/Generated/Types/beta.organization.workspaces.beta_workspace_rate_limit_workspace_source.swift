// Transformed from `anthropic.types.beta.organization.workspaces.beta_workspace_rate_limit_workspace_source` (beta_workspace_rate_limit_workspace_source.py).

import Foundation

public struct BetaWorkspaceRateLimitWorkspaceSource: Codable, Hashable, Sendable {
    /// Always `workspace`: a workspace-level override is stored.
    public var type: String

    public init(type: String = "workspace") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
