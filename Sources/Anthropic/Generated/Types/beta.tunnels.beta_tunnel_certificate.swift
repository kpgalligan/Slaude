// Transformed from `anthropic.types.beta.tunnels.beta_tunnel_certificate` (beta_tunnel_certificate.py).

import Foundation

/// A CA certificate attached to a tunnel.
public struct BetaTunnelCertificate: Codable, Hashable, Sendable {
    /// Unique identifier for the certificate, prefixed with `tcrt_`.
    public var id: String
    /// RFC 3339 datetime string indicating when the certificate was archived.
    ///
    /// Null if it is still in the trusted set.
    public var archivedAt: Date?
    /// RFC 3339 datetime string indicating when the certificate was registered.
    public var createdAt: Date
    /// RFC 3339 datetime string indicating when the certificate expires, or `null` if
    /// it does not expire.
    public var expiresAt: Date?
    /// Lowercase hex SHA-256 fingerprint of the certificate's DER encoding.
    public var fingerprint: String
    /// ID of the tunnel the certificate is registered against.
    public var tunnelId: String
    public var type: String

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, expiresAt: Date? = nil, fingerprint: String, tunnelId: String, type: String = "tunnel_certificate") {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.fingerprint = fingerprint
        self.tunnelId = tunnelId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case expiresAt = "expires_at"
        case fingerprint
        case tunnelId = "tunnel_id"
        case type
    }
}
