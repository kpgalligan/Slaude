// Transformed from `anthropic.types.beta.organization.workspaces.beta_workspace_rate_limit_organization_source` (beta_workspace_rate_limit_organization_source.py).

import Foundation

public struct BetaWorkspaceRateLimitOrganizationSource: Codable, Hashable, Sendable {
    /// Always `organization`: no workspace-level override is stored, so the
    /// organization's value applies.
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
