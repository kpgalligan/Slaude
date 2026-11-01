// Transformed from `anthropic.types.web_fetch_url_source_all_param` (web_fetch_url_source_all_param.py).

import Foundation

/// The ``url_sources`` variant under which a source contributes in
/// full: every result of the tool filter's source, or all user input.
public struct WebFetchURLSourceAllParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "all") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
