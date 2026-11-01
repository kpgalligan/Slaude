// Transformed from `anthropic.types.beta.vaults.credential_create_params` (credential_create_params.py).

import Foundation

public struct CredentialCreateParams: Codable, Hashable, Sendable {
    /// Authentication configuration for the credential.
    public var auth: CredentialCreateParams.Auth
    /// Human-readable name for the credential. Up to 255 characters.
    public var displayName: String??
    /// Arbitrary key-value metadata to attach to the credential.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]?
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
    public var workspaceId: String?

    public init(auth: CredentialCreateParams.Auth, displayName: String?? = nil, metadata: [String: String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.auth = auth
        self.displayName = displayName
        self.metadata = metadata
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case auth
        case displayName = "display_name"
        case metadata
        case betas
        case workspaceId = "workspace_id"
    }
}

extension CredentialCreateParams {

    public indirect enum Auth: Codable, Hashable, Sendable {
        case mcpOauth(BetaManagedAgentsMCPOAuthCreateParams)
        case staticBearer(BetaManagedAgentsStaticBearerCreateParams)
        case environmentVariable(BetaManagedAgentsEnvironmentVariableCreateParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "mcp_oauth": self = .mcpOauth(try BetaManagedAgentsMCPOAuthCreateParams(from: decoder))
            case "static_bearer": self = .staticBearer(try BetaManagedAgentsStaticBearerCreateParams(from: decoder))
            case "environment_variable": self = .environmentVariable(try BetaManagedAgentsEnvironmentVariableCreateParams(from: decoder))
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
