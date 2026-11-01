// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_credential_validation` (beta_managed_agents_credential_validation.py).

import Foundation

/// Result of live-probing a credential against its configured MCP server.
public struct BetaManagedAgentsCredentialValidation: Codable, Hashable, Sendable {
    /// Unique identifier of the credential that was validated.
    public var credentialId: String
    /// Whether the credential has a refresh token configured.
    public var hasRefreshToken: Bool
    /// Details of the MCP probe step that failed, or `null` if the probe succeeded or
    /// there was no access token to test.
    public var mcpProbe: BetaManagedAgentsMCPProbe?
    /// Details of the refresh-token exchange attempted on a 401.
    ///
    /// Null when no refresh was attempted.
    public var refresh: BetaManagedAgentsRefreshObject?
    /// Overall verdict of the validation probe.
    public var status: BetaManagedAgentsCredentialValidationStatus
    public var type: String
    /// When the validation probe was performed.
    public var validatedAt: Date
    /// Identifier of the vault containing the credential.
    public var vaultId: String

    public init(credentialId: String, hasRefreshToken: Bool, mcpProbe: BetaManagedAgentsMCPProbe? = nil, refresh: BetaManagedAgentsRefreshObject? = nil, status: BetaManagedAgentsCredentialValidationStatus, type: String = "vault_credential_validation", validatedAt: Date, vaultId: String) {
        self.credentialId = credentialId
        self.hasRefreshToken = hasRefreshToken
        self.mcpProbe = mcpProbe
        self.refresh = refresh
        self.status = status
        self.type = type
        self.validatedAt = validatedAt
        self.vaultId = vaultId
    }

    enum CodingKeys: String, CodingKey {
        case credentialId = "credential_id"
        case hasRefreshToken = "has_refresh_token"
        case mcpProbe = "mcp_probe"
        case refresh
        case status
        case type
        case validatedAt = "validated_at"
        case vaultId = "vault_id"
    }
}
