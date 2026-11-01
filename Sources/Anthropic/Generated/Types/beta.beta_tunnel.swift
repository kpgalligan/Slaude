// Transformed from `anthropic.types.beta.beta_tunnel` (beta_tunnel.py).

import Foundation

/// An MCP tunnel.
public struct BetaTunnel: Codable, Hashable, Sendable {
    /// Unique identifier for the tunnel, prefixed with `tnl_`.
    public var id: String
    /// RFC 3339 datetime string indicating when the tunnel was archived.
    ///
    /// Null if it is not archived.
    public var archivedAt: Date?
    /// RFC 3339 datetime string indicating when the tunnel was created.
    public var createdAt: Date
    /// Human-readable name for the tunnel (1-255 characters). Null if unset.
    public var displayName: String?
    /// Anthropic-assigned hostname for the tunnel.
    ///
    /// MCP server URLs whose host is a subdomain of this value are routed through the
    /// tunnel. Globally unique and never reused, even after the tunnel is archived.
    public var domain: String
    public var type: String

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, displayName: String? = nil, domain: String, type: String = "tunnel") {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.displayName = displayName
        self.domain = domain
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case displayName = "display_name"
        case domain
        case type
    }
}
