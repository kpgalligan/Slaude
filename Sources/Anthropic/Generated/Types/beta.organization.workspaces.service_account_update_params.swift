// Transformed from `anthropic.types.beta.organization.workspaces.service_account_update_params` (service_account_update_params.py).

import Foundation

public struct BetaOrganizationWorkspacesServiceAccountUpdateParams: Codable, Hashable, Sendable {
    /// ID of the workspace.
    public var workspaceID: String
    /// New role for the service account in this workspace.
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
