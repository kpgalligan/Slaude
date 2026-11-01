// Transformed from `anthropic.types.beta.organization.beta_plugin_owner_organization` (beta_plugin_owner_organization.py).

import Foundation

public struct BetaPluginOwnerOrganization: Codable, Hashable, Sendable {
    /// The Plugin lives in a plugin marketplace the organization owns.
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
