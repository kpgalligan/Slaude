// Transformed from `anthropic.types.beta.beta_webhook_vault_credential_deleted_event_data` (beta_webhook_vault_credential_deleted_event_data.py).

import Foundation

public struct BetaWebhookVaultCredentialDeletedEventData: Codable, Hashable, Sendable {
    /// ID of the vault credential that triggered the event.
    public var id: String
    public var organizationID: String
    public var type: String
    /// ID of the vault that owns this credential.
    public var vaultID: String
    public var workspaceID: String

    public init(id: String, organizationID: String, type: String = "vault_credential.deleted", vaultID: String, workspaceID: String) {
        self.id = id
        self.organizationID = organizationID
        self.type = type
        self.vaultID = vaultID
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationID = "organization_id"
        case type
        case vaultID = "vault_id"
        case workspaceID = "workspace_id"
    }
}
