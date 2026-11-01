// Transformed from `anthropic.types.organization.workspaces.workspace_rate_limit_organization_source` (workspace_rate_limit_organization_source.py).

import Foundation

public struct WorkspaceRateLimitOrganizationSource: Codable, Hashable, Sendable {
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
