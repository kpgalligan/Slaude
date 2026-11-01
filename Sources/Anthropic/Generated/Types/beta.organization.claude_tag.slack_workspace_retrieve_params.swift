// Transformed from `anthropic.types.beta.organization.claude_tag.slack_workspace_retrieve_params` (slack_workspace_retrieve_params.py).

import Foundation

public struct SlackWorkspaceRetrieveParams: Codable, Hashable, Sendable {
    /// When `true`, `settings` holds what applies in the workspace once the
    /// organization's Slack defaults are taken into account, and every member of
    /// `sources` names the level a value comes from. When `false` or left out,
    /// `settings` holds what the workspace itself stores.
    public var includeInherited: Bool?
    /// This endpoint is in beta: requests must send
    /// `experimental-claude-tag-2026-10-21` in this header.
    public var betas: [AnthropicBetaParam]?

    public init(includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.includeInherited = includeInherited
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case includeInherited = "include_inherited"
        case betas
    }
}
