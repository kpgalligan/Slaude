// Transformed from `anthropic.types.beta.organization.claude_tag.beta_claude_tag_bundle` (beta_claude_tag_bundle.py).

import Foundation

/// A named set of access that Claude can use in a Slack channel or a Slack workspace: connectors, repositories and credentials. Created and edited in claude.ai.
public struct BetaClaudeTagBundle: Codable, Hashable, Sendable {
    /// The Bundle's identifier. Starts with `capp_`.
    public var id: String
    /// Time the Bundle was created.
    public var createdAt: Date
    /// What the Bundle is for. Null when it has none. Read-only.
    public var description: String?
    /// The Bundle's name. Always set. Read-only.
    public var displayName: String
    public var type: String
    /// Time of the last change to the Bundle.
    public var updatedAt: Date

    public init(id: String, createdAt: Date, description: String? = nil, displayName: String, type: String = "bundle", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.description = description
        self.displayName = displayName
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case displayName = "display_name"
        case type
        case updatedAt = "updated_at"
    }
}
