// Transformed from `anthropic.types.beta.organization.workspaces.service_account_add_params` (service_account_add_params.py).

import Foundation

public struct BetaOrganizationWorkspacesServiceAccountAddParams: Codable, Hashable, Sendable {
    /// Tagged service account ID to add.
    public var serviceAccountId: String
    /// Role to assign to the service account in this workspace.
    public var workspaceRole: BetaNoBillingWorkspaceRole
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(serviceAccountId: String, workspaceRole: BetaNoBillingWorkspaceRole, betas: [AnthropicBetaParam]? = nil) {
        self.serviceAccountId = serviceAccountId
        self.workspaceRole = workspaceRole
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case serviceAccountId = "service_account_id"
        case workspaceRole = "workspace_role"
        case betas
    }
}
