// Transformed from `anthropic.types.beta.beta_webhook_vault_credential_deleted_event_data` (beta_webhook_vault_credential_deleted_event_data.py).

import Foundation

public struct BetaWebhookVaultCredentialDeletedEventData: Codable, Hashable, Sendable {
    /// ID of the vault credential that triggered the event.
    public var id: String
    public var organizationId: String
    public var type: String
    /// ID of the vault that owns this credential.
    public var vaultId: String
    public var workspaceId: String

    public init(id: String, organizationId: String, type: String = "vault_credential.deleted", vaultId: String, workspaceId: String) {
        self.id = id
        self.organizationId = organizationId
        self.type = type
        self.vaultId = vaultId
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case type
        case vaultId = "vault_id"
        case workspaceId = "workspace_id"
    }
}
