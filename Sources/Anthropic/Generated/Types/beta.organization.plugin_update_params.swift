// Transformed from `anthropic.types.beta.organization.plugin_update_params` (plugin_update_params.py).

import Foundation

public struct PluginUpdateParams: Codable, Hashable, Sendable {
    /// Serve this version of the Plugin (prefixed `pluginver_`) and pin the served
    /// version to it; `latest` is not accepted.
    public var servedVersionID: String
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(servedVersionID: String, betas: [AnthropicBetaParam]? = nil) {
        self.servedVersionID = servedVersionID
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case servedVersionID = "served_version_id"
        case betas
    }
}
