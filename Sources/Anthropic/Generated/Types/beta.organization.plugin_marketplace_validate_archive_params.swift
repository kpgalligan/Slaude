// Transformed from `anthropic.types.beta.organization.plugin_marketplace_validate_archive_params` (plugin_marketplace_validate_archive_params.py).

import Foundation

public struct PluginMarketplaceValidateArchiveParams: Codable, Hashable, Sendable {
    /// A .zip of the marketplace directory (its contents at the root, or wrapped in one
    /// folder as a Git host's download produces), sent as a file part with a filename;
    /// DEFLATE- or STORE-compressed, at most 32 MB. A part sent without a filename, a
    /// second archive part, or any other form field is a 400; a larger archive is
    /// a 413.
    public var archive: FileUpload
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(archive: FileUpload, betas: [AnthropicBetaParam]? = nil) {
        self.archive = archive
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case archive
        case betas
    }
}
