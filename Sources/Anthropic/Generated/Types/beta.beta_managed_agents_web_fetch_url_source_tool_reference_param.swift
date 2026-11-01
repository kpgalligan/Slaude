// Transformed from `anthropic.types.beta.beta_managed_agents_web_fetch_url_source_tool_reference_param` (beta_managed_agents_web_fetch_url_source_tool_reference_param.py).

import Foundation

/// Names one tool in an only or except list.
public struct BetaManagedAgentsWebFetchURLSourceToolReferenceParam: Codable, Hashable, Sendable {
    /// Name of the tool.
    ///
    /// Compared exactly, so upper and lower case letters are different.
    public var name: String
    /// Must be "tool_reference".
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
