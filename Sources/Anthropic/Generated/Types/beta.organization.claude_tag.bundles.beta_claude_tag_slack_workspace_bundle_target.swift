// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_slack_workspace_bundle_target` (beta_claude_tag_slack_workspace_bundle_target.py).

import Foundation

/// One Bundle attached to one Slack workspace.
///
/// The Bundle can be used in the workspace and in every channel in it.
public struct BetaClaudeTagSlackWorkspaceBundleTarget: Codable, Hashable, Sendable {
    /// The Bundle Target's identifier.
    ///
    /// Starts with `btgt_`. No two Bundle Targets have the same one, and the same
    /// Bundle and target always give the same one, also after a detach and a new
    /// attach. It is opaque.
    public var id: String
    /// Time the Bundle was attached.
    public var createdAt: Date
    /// The identifier of the Slack workspace the Bundle is attached to, starting with
    /// `slws_`.
    public var slackWorkspaceID: String
    public var type: String

    public init(id: String, createdAt: Date, slackWorkspaceID: String, type: String = "slack_workspace") {
        self.id = id
        self.createdAt = createdAt
        self.slackWorkspaceID = slackWorkspaceID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case slackWorkspaceID = "slack_workspace_id"
        case type
    }
}
