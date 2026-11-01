// Transformed from `anthropic.types.beta.organization.plugin_create_params` (plugin_create_params.py).

import Foundation

public struct PluginCreateParams: Codable, Hashable, Sendable {
    /// The version's files: one part per file, the part's filename being the file's
    /// path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    /// `.zip` or `.plugin` archive holding them all. On the wire each part is named
    /// `files[]`, and a part named plain `files` is not read; with cURL,
    /// `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    /// include the manifest, `.claude-plugin/plugin.json`.
    public var files: [FileUpload]
    /// ID of the organization-owned plugin marketplace to create the Plugin in
    /// (prefixed `marketplace_`). It must be a `manual` marketplace, one whose Plugins
    /// are uploaded rather than synchronized from a repository. When omitted, the
    /// Plugin is created in the organization's library marketplace, an
    /// organization-owned `manual` marketplace created on first use.
    public var marketplaceId: String?
    /// Release notes stored with the version and shown in its version history in
    /// claude.ai; up to 5,000 characters.
    public var releaseNotes: String?
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(files: [FileUpload], marketplaceId: String? = nil, releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.files = files
        self.marketplaceId = marketplaceId
        self.releaseNotes = releaseNotes
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case files
        case marketplaceId = "marketplace_id"
        case releaseNotes = "release_notes"
        case betas
    }
}
