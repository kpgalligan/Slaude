// Transformed from `anthropic.types.beta.organization.beta_azure_external_key_config_param` (beta_azure_external_key_config_param.py).

import Foundation

/// Azure Key Vault provider configuration.
public struct BetaAzureExternalKeyConfigParam: Codable, Hashable, Sendable {
    /// Name of the key within the vault.
    public var keyName: String
    /// Azure AD tenant ID.
    public var tenantId: String
    public var type: String
    /// Key Vault data-plane URI — `https://{vault-name}.vault.azure.net` or
    /// `https://{hsm-name}.managedhsm.azure.net`.
    public var vaultUri: String
    /// Azure AD application (client) ID.
    ///
    /// Omit to use Anthropic's multitenant app. Provide only if using a single-tenant
    /// app registration in the customer's directory.
    public var clientId: String??

    public init(keyName: String, tenantId: String, type: String = "azure", vaultUri: String, clientId: String?? = nil) {
        self.keyName = keyName
        self.tenantId = tenantId
        self.type = type
        self.vaultUri = vaultUri
        self.clientId = clientId
    }

    enum CodingKeys: String, CodingKey {
        case keyName = "key_name"
        case tenantId = "tenant_id"
        case type
        case vaultUri = "vault_uri"
        case clientId = "client_id"
    }
}
