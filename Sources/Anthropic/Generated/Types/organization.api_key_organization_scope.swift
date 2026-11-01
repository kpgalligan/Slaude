// Transformed from `anthropic.types.organization.api_key_organization_scope` (api_key_organization_scope.py).

import Foundation

public struct APIKeyOrganizationScope: Codable, Hashable, Sendable {
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
