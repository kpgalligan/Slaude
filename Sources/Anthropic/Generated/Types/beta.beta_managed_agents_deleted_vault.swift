// Transformed from `anthropic.types.beta.beta_managed_agents_deleted_vault` (beta_managed_agents_deleted_vault.py).

import Foundation

/// Confirmation of a deleted vault.
public struct BetaManagedAgentsDeletedVault: Codable, Hashable, Sendable {
    /// The unique ID of the deleted vault (`vlt_...`).
    public var id: String
    public var type: String

    public init(id: String, type: String = "vault_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
