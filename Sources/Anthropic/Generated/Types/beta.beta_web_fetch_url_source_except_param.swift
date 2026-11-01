// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_except_param` (beta_web_fetch_url_source_except_param.py).

import Foundation

/// The tool filter variant under which every result but the named
/// tools' contributes.
public struct BetaWebFetchURLSourceExceptParam: Codable, Hashable, Sendable {
    public var tools: [BetaWebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [BetaWebFetchURLSourceToolReferenceParam], type: String = "except") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
