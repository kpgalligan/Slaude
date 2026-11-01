// Transformed from `anthropic.types.organization.workspaces.rate_limit_update_params` (rate_limit_update_params.py).

import Foundation

public struct RateLimitUpdateParams: Codable, Hashable, Sendable {
    /// The ID of the workspace.
    public var workspaceId: String
    /// Limits to set or clear. Unspecified limit types are unchanged.
    public var limits: [WorkspaceRateLimitUpdateValueParam]

    public init(workspaceId: String, limits: [WorkspaceRateLimitUpdateValueParam]) {
        self.workspaceId = workspaceId
        self.limits = limits
    }

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case limits
    }
}
