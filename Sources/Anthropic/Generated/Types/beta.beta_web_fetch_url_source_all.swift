// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_all` (beta_web_fetch_url_source_all.py).

import Foundation

/// The ``url_sources`` variant under which a source contributes in
/// full: every result of the tool filter's source, or all user input.
public struct BetaWebFetchURLSourceAll: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
