// Transformed from `anthropic.types.organization.federation.rules.workspace_remove_response` (workspace_remove_response.py).

import Foundation

public struct OrganizationFederationRulesWorkspaceRemoveResponse: Codable, Hashable, Sendable {
    /// Tagged ID of the federation rule.
    public var federationRuleId: String
    public var type: String
    /// Tagged ID of the workspace named in the delete request. Removal is idempotent.
    public var workspaceId: String

    public init(federationRuleId: String, type: String = "federation_rule_workspace_deleted", workspaceId: String) {
        self.federationRuleId = federationRuleId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case federationRuleId = "federation_rule_id"
        case type
        case workspaceId = "workspace_id"
    }
}
