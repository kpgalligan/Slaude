// Transformed from `anthropic.types.beta.beta_web_fetch_url_source_only_param` (beta_web_fetch_url_source_only_param.py).

import Foundation

/// The tool filter variant under which only the named tools' results
/// contribute.
public struct BetaWebFetchURLSourceOnlyParam: Codable, Hashable, Sendable {
    public var tools: [BetaWebFetchURLSourceToolReferenceParam]
    public var type: String

    public init(tools: [BetaWebFetchURLSourceToolReferenceParam], type: String = "only") {
        self.tools = tools
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tools
        case type
    }
}
