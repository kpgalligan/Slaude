// Transformed from `anthropic.types.beta.organization.beta_plugin_target_organization_member` (beta_plugin_target_organization_member.py).

import Foundation

public struct BetaPluginTargetOrganizationMember: Codable, Hashable, Sendable {
    /// One member of the organization.
    public var type: String
    /// The member's User ID.
    public var userId: String

    public init(type: String = "organization_member", userId: String) {
        self.type = type
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userId = "user_id"
    }
}
