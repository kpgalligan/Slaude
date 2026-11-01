// Transformed from `anthropic.types.web_fetch_url_source_only_param` (web_fetch_url_source_only_param.py).

import Foundation

/// The tool filter variant under which only the named tools' results
/// contribute.
public struct WebFetchURLSourceOnlyParam: Codable, Hashable, Sendable {
    public var tools: [WebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [WebFetchURLSourceToolReferenceParam], type: String = "only") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
