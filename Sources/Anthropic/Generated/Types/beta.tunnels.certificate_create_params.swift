// Transformed from `anthropic.types.beta.tunnels.certificate_create_params` (certificate_create_params.py).

import Foundation

public struct CertificateCreateParams: Codable, Hashable, Sendable {
    /// PEM-encoded X.509 CA certificate.
    ///
    /// Must contain exactly one certificate and no private-key material. Maximum 8KB.
    public var caCertificatePem: String
    /// This endpoint is in beta: requests must send `mcp-tunnels-2026-06-22` in this
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

    public init(caCertificatePem: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.caCertificatePem = caCertificatePem
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case caCertificatePem = "ca_certificate_pem"
        case betas
        case workspaceID = "workspace_id"
    }
}
