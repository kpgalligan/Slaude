// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_slack_workspace_bundle_target_create_param` (beta_claude_tag_slack_workspace_bundle_target_create_param.py).

import Foundation

/// Attach the Bundle to a Slack workspace.
public struct BetaClaudeTagSlackWorkspaceBundleTargetCreateParam: Codable, Hashable, Sendable {
    /// The identifier of the Slack workspace to attach the Bundle to, starting with
    /// `slws_`.
    public var slackWorkspaceId: String
    public var type: String

    public init(slackWorkspaceId: String, type: String = "slack_workspace") {
        self.slackWorkspaceId = slackWorkspaceId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case slackWorkspaceId = "slack_workspace_id"
        case type
    }
}
