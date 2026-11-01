// Transformed from `anthropic.types.organization.azure_external_key_config` (azure_external_key_config.py).

import Foundation

public struct AzureExternalKeyConfig: Codable, Hashable, Sendable {
    /// Name of the key within the vault.
    public var keyName: String
    /// Azure AD tenant ID.
    public var tenantID: String
    public var type: String
    /// Key Vault data-plane URI — `https://{vault-name}.vault.azure.net` or
    /// `https://{hsm-name}.managedhsm.azure.net`.
    public var vaultURI: String
    /// Azure AD application (client) ID.
    ///
    /// Omit to use Anthropic's multitenant app. Provide only if using a single-tenant
    /// app registration in the customer's directory.
    public var clientID: String?

    public init(keyName: String, tenantID: String, type: String = "azure", vaultURI: String, clientID: String? = nil) {
        self.keyName = keyName
        self.tenantID = tenantID
        self.type = type
        self.vaultURI = vaultURI
        self.clientID = clientID
    }

    enum CodingKeys: String, CodingKey {
        case keyName = "key_name"
        case tenantID = "tenant_id"
        case type
        case vaultURI = "vault_uri"
        case clientID = "client_id"
    }
}
