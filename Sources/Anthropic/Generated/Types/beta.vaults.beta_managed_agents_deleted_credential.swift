// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_deleted_credential` (beta_managed_agents_deleted_credential.py).

import Foundation

/// Confirmation of a deleted credential.
public struct BetaManagedAgentsDeletedCredential: Codable, Hashable, Sendable {
    /// The unique ID of the deleted credential (`vcrd_...`).
    public var id: String
    public var type: String

    public init(id: String, type: String = "vault_credential_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
