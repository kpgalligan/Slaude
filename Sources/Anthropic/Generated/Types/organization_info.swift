// Transformed from `anthropic.types.organization_info` (organization_info.py).

import Foundation

public struct OrganizationInfo: Codable, Hashable, Sendable {
    /// ID of the Organization.
    public var id: String
    /// Name of the Organization.
    public var name: String
    /// Object type.
    ///
    /// For Organizations, this is always `"organization"`.
    public var type: String

    public init(id: String, name: String, type: String = "organization") {
        self.id = id
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
    }
}
