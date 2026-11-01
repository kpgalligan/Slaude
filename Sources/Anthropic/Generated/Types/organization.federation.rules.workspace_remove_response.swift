// Transformed from `anthropic.types.organization.federation.rules.workspace_remove_response` (workspace_remove_response.py).

import Foundation

public struct OrganizationFederationRulesWorkspaceRemoveResponse: Codable, Hashable, Sendable {
    /// Tagged ID of the federation rule.
    public var federationRuleID: String
    public var type: String
    /// Tagged ID of the workspace named in the delete request. Removal is idempotent.
    public var workspaceID: String

    public init(federationRuleID: String, type: String = "federation_rule_workspace_deleted", workspaceID: String) {
        self.federationRuleID = federationRuleID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case federationRuleID = "federation_rule_id"
        case type
        case workspaceID = "workspace_id"
    }
}
