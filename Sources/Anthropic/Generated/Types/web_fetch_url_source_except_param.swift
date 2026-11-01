// Transformed from `anthropic.types.web_fetch_url_source_except_param` (web_fetch_url_source_except_param.py).

import Foundation

/// The tool filter variant under which every result but the named
/// tools' contributes.
public struct WebFetchURLSourceExceptParam: Codable, Hashable, Sendable {
    public var tools: [WebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [WebFetchURLSourceToolReferenceParam], type: String = "except") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
