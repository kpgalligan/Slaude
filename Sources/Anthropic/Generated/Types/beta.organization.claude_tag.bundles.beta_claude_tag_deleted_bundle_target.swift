// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_deleted_bundle_target` (beta_claude_tag_deleted_bundle_target.py).

import Foundation

/// Confirms that a Bundle was detached.
public struct BetaClaudeTagDeletedBundleTarget: Codable, Hashable, Sendable {
    /// The identifier the Bundle Target had.
    public var id: String
    public var type: String

    public init(id: String, type: String = "bundle_target_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
