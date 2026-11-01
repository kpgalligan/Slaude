// Transformed from `anthropic.types.organization.federation.rules.workspace_add_params` (workspace_add_params.py).

import Foundation

public struct OrganizationFederationRulesWorkspaceAddParams: Codable, Hashable, Sendable {
    /// Tagged ID of the workspace to enable this rule for.
    public var workspaceID: String

    public init(workspaceID: String) {
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
    }
}
