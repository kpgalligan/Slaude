// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_url_image_source_param` (beta_managed_agents_url_image_source_param.py).

import Foundation

/// Image referenced by URL.
public struct BetaManagedAgentsURLImageSourceParam: Codable, Hashable, Sendable {
    public var type: String
    /// URL of the image to fetch.
    public var url: String

    public init(type: String = "url", url: String) {
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case type
        case url
    }
}
