// Transformed from `anthropic.types.organization.workspaces.rate_limit_update_params` (rate_limit_update_params.py).

import Foundation

public struct RateLimitUpdateParams: Codable, Hashable, Sendable {
    /// The ID of the workspace.
    public var workspaceID: String
    /// Limits to set or clear. Unspecified limit types are unchanged.
    public var limits: [WorkspaceRateLimitUpdateValueParam]

    public init(workspaceID: String, limits: [WorkspaceRateLimitUpdateValueParam]) {
        self.workspaceID = workspaceID
        self.limits = limits
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case limits
    }
}
