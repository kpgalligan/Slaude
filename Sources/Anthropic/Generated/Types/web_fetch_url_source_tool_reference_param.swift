// Transformed from `anthropic.types.web_fetch_url_source_tool_reference_param` (web_fetch_url_source_tool_reference_param.py).

import Foundation

/// One entry of a tool filter's ``tools``: it must name a tool declared
/// in this request's ``tools[]``.
public struct WebFetchURLSourceToolReferenceParam: Codable, Hashable, Sendable {
    public var name: String
    public var type: String

    public init(name: String, type: String = "tool_reference") {
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case name
        case type
    }
}
