// Transformed from `anthropic.types.beta.organization.service_accounts.workspace_add_params` (workspace_add_params.py).

import Foundation

public struct BetaOrganizationServiceAccountsWorkspaceAddParams: Codable, Hashable, Sendable {
    /// Tagged workspace ID to add the service account to.
    public var workspaceID: String
    /// Role to assign to the service account in this workspace.
    public var workspaceRole: BetaNoBillingWorkspaceRole
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(workspaceID: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil) {
        self.workspaceID = workspaceID
        self.workspaceRole = workspaceRole
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case workspaceRole = "workspace_role"
        case betas
    }
}
