// Transformed from `anthropic.types.beta.organization.federation.rules.workspace_add_params` (workspace_add_params.py).

import Foundation

public struct BetaOrganizationFederationRulesWorkspaceAddParams: Codable, Hashable, Sendable {
    /// Tagged ID of the workspace to enable this rule for.
    public var workspaceId: String
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?

    public init(workspaceId: String, betas: [AnthropicBetaParam]? = nil) {
        self.workspaceId = workspaceId
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case workspaceId = "workspace_id"
        case betas
    }
}
