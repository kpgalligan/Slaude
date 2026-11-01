// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_none` (beta_web_fetch_url_source_none.py).

import Foundation

/// The ``url_sources`` variant under which a source contributes nothing:
/// no result of the tool filter's source, or no user input.
public struct BetaWebFetchURLSourceNone: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
