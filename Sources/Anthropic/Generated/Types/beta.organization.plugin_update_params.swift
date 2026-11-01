// Transformed from `anthropic.types.beta.organization.plugin_update_params` (plugin_update_params.py).

import Foundation

public struct PluginUpdateParams: Codable, Hashable, Sendable {
    /// Serve this version of the Plugin (prefixed `pluginver_`) and pin the served
    /// version to it; `latest` is not accepted.
    public var servedVersionId: String
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(servedVersionId: String, betas: [AnthropicBetaParam]? = nil) {
        self.servedVersionId = servedVersionId
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case servedVersionId = "served_version_id"
        case betas
    }
}
