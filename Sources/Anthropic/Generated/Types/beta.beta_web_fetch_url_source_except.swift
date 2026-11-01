// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_except` (beta_web_fetch_url_source_except.py).

import Foundation

/// The tool filter variant under which every result but the named
/// tools' contributes.
public struct BetaWebFetchURLSourceExcept: Codable, Hashable, Sendable {
    public var tools: [BetaWebFetchURLSourceToolReference]
    public var type: String

    public init(tools: [BetaWebFetchURLSourceToolReference], type: String = "except") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
