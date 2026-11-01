// Transformed from `anthropic.types.beta.organization.beta_api_key_organization_scope` (beta_api_key_organization_scope.py).

import Foundation

public struct BetaAPIKeyOrganizationScope: Codable, Hashable, Sendable {
    /// Scope type.
    ///
    /// Always `"organization"`: the API key has no Workspace. Only a principal-bound
    /// API key can have this scope.
    public var type: String

    public init(type: String = "organization") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
