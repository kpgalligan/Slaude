// Transformed from `anthropic.types.beta.skill_create_params` (skill_create_params.py).

import Foundation

public struct BetaSkillCreateParams: Codable, Hashable, Sendable {
    /// Files to upload for the skill.
    ///
    /// All files must be in the same top-level directory and must include a SKILL.md
    /// file at the root of that directory.
    public var files: [FileUpload]
    /// Human-readable, single-line label for the Skill.
    ///
    /// Maximum 255 characters. Always set: derived from the SKILL.md frontmatter `name`
    /// when omitted at creation. Not unique.
    public var displayName: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(files: [FileUpload], displayName: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.files = files
        self.displayName = displayName
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case files
        case displayName = "display_name"
        case betas
        case workspaceID = "workspace_id"
    }
}
