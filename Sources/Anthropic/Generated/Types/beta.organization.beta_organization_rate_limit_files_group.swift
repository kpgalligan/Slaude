// Transformed from `anthropic.types.beta.organization.beta_organization_rate_limit_files_group` (beta_organization_rate_limit_files_group.py).

import Foundation

public struct BetaOrganizationRateLimitFilesGroup: Codable, Hashable, Sendable {
    /// Opaque identifier of the rate-limit group (for example,
    /// `rlg_01VPTCmyiu5ZLsWkcxYG2pY8`). It is the same in every organization and never
    /// changes, unlike the entry's own identifier, which differs per organization.
    public var id: String
    /// Always `files`: the Files API.
    public var type: String

    public init(id: String, type: String = "files") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
