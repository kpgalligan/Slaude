// Transformed from `anthropic.types.beta.organization.claude_tag.slack_workspace_list_params` (slack_workspace_list_params.py).

import Foundation

public struct SlackWorkspaceListParams: Codable, Hashable, Sendable {
    /// When `true`, `settings` holds what applies in each workspace once the
    /// organization's Slack defaults are taken into account, and every member of
    /// `sources` names the level a value comes from. When `false` or left out,
    /// `settings` holds what each workspace itself stores.
    public var includeInherited: Bool?
    /// Number of items to return per page, between 1 and 100. Defaults to 20.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page`.
    public var page: String?
    /// Slack's identifier for one workspace, as in the workspace object's
    /// `slack.workspace_id`, not its `id`. With it `data` holds that workspace alone,
    /// or nothing when it is not set up.
    public var slackWorkspaceID: String?
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackWorkspaceID: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.includeInherited = includeInherited
        self.limit = limit
        self.page = page
        self.slackWorkspaceID = slackWorkspaceID
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case includeInherited = "include_inherited"
        case limit
        case page
        case slackWorkspaceID = "slack_workspace_id"
        case betas
    }
}
