// Transformed from `anthropic.types.beta.organization.beta_plugin_target_organization` (beta_plugin_target_organization.py).

import Foundation

public struct BetaPluginTargetOrganization: Codable, Hashable, Sendable {
    /// Every member of the organization.
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
