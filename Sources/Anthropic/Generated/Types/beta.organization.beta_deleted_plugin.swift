// Transformed from `anthropic.types.beta.organization.beta_deleted_plugin` (beta_deleted_plugin.py).

import Foundation

public struct BetaDeletedPlugin: Codable, Hashable, Sendable {
    /// The deleted Plugin's ID.
    public var id: String
    /// Always `plugin_deleted`.
    public var type: String

    public init(id: String, type: String = "plugin_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
