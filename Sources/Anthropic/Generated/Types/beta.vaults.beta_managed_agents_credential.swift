// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_credential` (beta_managed_agents_credential.py).

import Foundation

/// A credential stored in a vault.
///
/// Sensitive fields are never returned in responses.
public struct BetaManagedAgentsCredential: Codable, Hashable, Sendable {
    /// The unique ID of the credential (`vcrd_...`).
    public var id: String
    /// When the credential was archived. Null if not archived.
    public var archivedAt: Date?
    /// Authentication configuration for this credential.
    public var auth: BetaManagedAgentsCredential.Auth
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    /// Arbitrary key-value metadata attached to the credential.
    public var metadata: [String: String]
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date
    /// Identifier of the vault this credential belongs to.
    public var vaultID: String
    /// Human-readable name for the credential.
    public var displayName: String?

    public init(id: String, archivedAt: Date? = nil, auth: BetaManagedAgentsCredential.Auth, createdAt: Date, metadata: [String: String], type: String = "vault_credential", updatedAt: Date, vaultID: String, displayName: String? = nil) {
        self.id = id
        self.archivedAt = archivedAt
        self.auth = auth
        self.createdAt = createdAt
        self.metadata = metadata
        self.type = type
        self.updatedAt = updatedAt
        self.vaultID = vaultID
        self.displayName = displayName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case auth
        case createdAt = "created_at"
        case metadata
        case type
        case updatedAt = "updated_at"
        case vaultID = "vault_id"
        case displayName = "display_name"
    }
}

extension BetaManagedAgentsCredential {

    public indirect enum Auth: Codable, Hashable, Sendable {
        case mcpOauth(BetaManagedAgentsMCPOAuthAuthResponse)
        case staticBearer(BetaManagedAgentsStaticBearerAuthResponse)
        case environmentVariable(BetaManagedAgentsEnvironmentVariableAuthResponse)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "mcp_oauth": self = .mcpOauth(try BetaManagedAgentsMCPOAuthAuthResponse(from: decoder))
            case "static_bearer": self = .staticBearer(try BetaManagedAgentsStaticBearerAuthResponse(from: decoder))
            case "environment_variable": self = .environmentVariable(try BetaManagedAgentsEnvironmentVariableAuthResponse(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .mcpOauth(let v): try v.encode(to: encoder)
            case .staticBearer(let v): try v.encode(to: encoder)
            case .environmentVariable(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
