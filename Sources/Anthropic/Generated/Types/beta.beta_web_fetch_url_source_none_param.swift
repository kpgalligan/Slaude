// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_none_param` (beta_web_fetch_url_source_none_param.py).

import Foundation

/// The ``url_sources`` variant under which a source contributes nothing:
/// no result of the tool filter's source, or no user input.
public struct BetaWebFetchURLSourceNoneParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "none") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
