// Transformed from `anthropic.types.beta.organization.beta_plugin_target_organization_member` (beta_plugin_target_organization_member.py).

import Foundation

public struct BetaPluginTargetOrganizationMember: Codable, Hashable, Sendable {
    /// One member of the organization.
    public var type: String
    /// The member's User ID.
    public var userID: String

    public init(type: String = "organization_member", userID: String) {
        self.type = type
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case type
        case userID = "user_id"
    }
}
