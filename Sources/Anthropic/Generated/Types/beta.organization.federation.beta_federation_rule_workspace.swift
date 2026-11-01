// Transformed from `anthropic.types.beta.organization.federation.beta_federation_rule_workspace` (beta_federation_rule_workspace.py).

import Foundation

public struct BetaFederationRuleWorkspace: Codable, Hashable, Sendable {
    /// When this workspace was enabled for the rule.
    public var createdAt: Date
    /// Tagged ID (`user_...` or `svac_...`) of the actor that enabled this workspace
    /// for the rule, if known.
    public var createdByActorID: String?
    /// Tagged ID of the federation rule.
    public var federationRuleID: String
    public var type: String
    /// Tagged ID of the workspace this rule is enabled for.
    public var workspaceID: String
    /// Workspace display name. Populated when listing; null in the enable response.
    public var workspaceName: String?

    public init(createdAt: Date, createdByActorID: String? = nil, federationRuleID: String, type: String = "federation_rule_workspace", workspaceID: String, workspaceName: String? = nil) {
        self.createdAt = createdAt
        self.createdByActorID = createdByActorID
        self.federationRuleID = federationRuleID
        self.type = type
        self.workspaceID = workspaceID
        self.workspaceName = workspaceName
    }

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case createdByActorID = "created_by_actor_id"
        case federationRuleID = "federation_rule_id"
        case type
        case workspaceID = "workspace_id"
        case workspaceName = "workspace_name"
    }
}
