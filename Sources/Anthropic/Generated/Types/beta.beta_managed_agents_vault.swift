// Transformed from `anthropic.types.beta.beta_managed_agents_vault` (beta_managed_agents_vault.py).

import Foundation

/// A vault that stores credentials for use by agents during sessions.
public struct BetaManagedAgentsVault: Codable, Hashable, Sendable {
    /// The unique ID of the vault (`vlt_...`).
    public var id: String
    /// When the vault was archived. Null if not archived.
    public var archivedAt: Date?
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    /// Human-readable name for the vault.
    public var displayName: String
    /// Arbitrary key-value metadata attached to the vault.
    public var metadata: [String: String]
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date

    public init(id: String, archivedAt: Date? = nil, createdAt: Date, displayName: String, metadata: [String: String], type: String = "vault", updatedAt: Date) {
        self.id = id
        self.archivedAt = archivedAt
        self.createdAt = createdAt
        self.displayName = displayName
        self.metadata = metadata
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case createdAt = "created_at"
        case displayName = "display_name"
        case metadata
        case type
        case updatedAt = "updated_at"
    }
}
