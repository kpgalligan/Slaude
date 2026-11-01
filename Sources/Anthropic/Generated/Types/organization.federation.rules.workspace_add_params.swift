// Transformed from `anthropic.types.organization.federation.rules.workspace_add_params` (workspace_add_params.py).

import Foundation

public struct OrganizationFederationRulesWorkspaceAddParams: Codable, Hashable, Sendable {
    /// Tagged ID of the workspace to enable this rule for.
    public var workspaceId: String

    public init(workspaceId: String) {
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
    }
}
