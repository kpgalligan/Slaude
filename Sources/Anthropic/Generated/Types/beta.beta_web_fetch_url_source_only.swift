// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_only` (beta_web_fetch_url_source_only.py).

import Foundation

/// The tool filter variant under which only the named tools' results
/// contribute.
public struct BetaWebFetchURLSourceOnly: Codable, Hashable, Sendable {
    public var tools: [BetaWebFetchURLSourceToolReference]
    public var type: String

    public init(tools: [BetaWebFetchURLSourceToolReference], type: String = "only") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
