// Transformed from `anthropic.types.organization.federation.federation_rule_workspace` (federation_rule_workspace.py).

import Foundation

public struct FederationRuleWorkspace: Codable, Hashable, Sendable {
    /// When this workspace was enabled for the rule.
    public var createdAt: Date
    /// Tagged ID (`user_...` or `svac_...`) of the actor that enabled this workspace
    /// for the rule, if known.
    public var createdByActorId: String?
    /// Tagged ID of the federation rule.
    public var federationRuleId: String
    public var type: String
    /// Tagged ID of the workspace this rule is enabled for.
    public var workspaceId: String
    /// Workspace display name. Populated when listing; null in the enable response.
    public var workspaceName: String?

    public init(createdAt: Date, createdByActorId: String? = nil, federationRuleId: String, type: String = "federation_rule_workspace", workspaceId: String, workspaceName: String? = nil) {
        self.createdAt = createdAt
        self.createdByActorId = createdByActorId
        self.federationRuleId = federationRuleId
        self.type = type
        self.workspaceId = workspaceId
        self.workspaceName = workspaceName
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case createdByActorId = "created_by_actor_id"
        case federationRuleId = "federation_rule_id"
        case type
        case workspaceId = "workspace_id"
        case workspaceName = "workspace_name"
    }
}
