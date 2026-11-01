// Transformed from `anthropic.types.beta.vaults.credential_update_params` (credential_update_params.py).

import Foundation

public struct CredentialUpdateParams: Codable, Hashable, Sendable {
    /// Identifier of the vault containing the credential.
    public var vaultID: String
    /// New authentication settings for the credential.
    ///
    /// The `type` must match the credential's current type, which can't be changed.
    public var auth: CredentialUpdateParams.Auth?
    /// Updated human-readable name for the credential. 1-255 characters.
    public var displayName: String??
    /// Metadata patch.
    ///
    /// Set a key to a string to upsert it, or to null to delete it. Omitted keys are
    /// preserved.
    public var metadata: [String: String?]??
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(vaultID: String, auth: CredentialUpdateParams.Auth? = nil, displayName: String?? = nil, metadata: [String: String?]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.vaultID = vaultID
        self.auth = auth
        self.displayName = displayName
        self.metadata = metadata
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case vaultID = "vault_id"
        case auth
        case displayName = "display_name"
        case metadata
        case betas
        case workspaceID = "workspace_id"
    }
}

extension CredentialUpdateParams {

    public indirect enum Auth: Codable, Hashable, Sendable {
        case mcpOauth(BetaManagedAgentsMCPOAuthUpdateParams)
        case staticBearer(BetaManagedAgentsStaticBearerUpdateParams)
        case environmentVariable(BetaManagedAgentsEnvironmentVariableUpdateParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "mcp_oauth": self = .mcpOauth(try BetaManagedAgentsMCPOAuthUpdateParams(from: decoder))
            case "static_bearer": self = .staticBearer(try BetaManagedAgentsStaticBearerUpdateParams(from: decoder))
            case "environment_variable": self = .environmentVariable(try BetaManagedAgentsEnvironmentVariableUpdateParams(from: decoder))
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
