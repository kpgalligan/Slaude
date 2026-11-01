// Transformed from `anthropic.types.organization.organization_rate_limit_model_group` (organization_rate_limit_model_group.py).

import Foundation

public struct OrganizationRateLimitModelGroup: Codable, Hashable, Sendable {
    /// Opaque identifier of the rate-limit group (for example,
    /// `rlg_01VPTCmyiu5ZLsWkcxYG2pY8`). It is the same in every organization and never
    /// changes, unlike the entry's own identifier, which differs per organization.
    public var id: String
    /// Human-readable name of the model group (for example, `Claude Sonnet 4.x`).
    ///
    /// For display only; it may change.
    public var displayName: String
    /// Always `model_group`: a family of models.
    public var type: String

    public init(id: String, displayName: String, type: String = "model_group") {
        self.id = id
        self.displayName = displayName
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case type
    }
}
