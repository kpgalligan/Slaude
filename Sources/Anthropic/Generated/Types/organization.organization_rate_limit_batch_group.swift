// Transformed from `anthropic.types.organization.organization_rate_limit_batch_group` (organization_rate_limit_batch_group.py).

import Foundation

public struct OrganizationRateLimitBatchGroup: Codable, Hashable, Sendable {
    /// Opaque identifier of the rate-limit group (for example,
    /// `rlg_01VPTCmyiu5ZLsWkcxYG2pY8`). It is the same in every organization and never
    /// changes, unlike the entry's own identifier, which differs per organization.
    public var id: String
    /// Always `batch`: the Message Batches API.
    public var type: String

    public init(id: String, type: String = "batch") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
