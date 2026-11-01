// Transformed from `anthropic.types.beta.organization.workspaces.rate_limit_update_params` (rate_limit_update_params.py).

import Foundation

public struct BetaOrganizationWorkspacesRateLimitUpdateParams: Codable, Hashable, Sendable {
    /// The ID of the workspace.
    public var workspaceID: String
    /// Limits to set or clear. Unspecified limit types are unchanged.
    public var limits: [BetaWorkspaceRateLimitUpdateValueParam]

    public init(workspaceID: String, limits: [BetaWorkspaceRateLimitUpdateValueParam]) {
        self.workspaceID = workspaceID
        self.limits = limits
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case limits
    }
}
