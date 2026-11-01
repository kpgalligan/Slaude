// Transformed from `anthropic.types.beta.beta_managed_agents_custom_tool_input_schema` (beta_managed_agents_custom_tool_input_schema.py).

import Foundation

/// JSON Schema for custom tool input parameters.
public struct BetaManagedAgentsCustomToolInputSchema: Codable, Hashable, Sendable {
    public var type: String
    public var properties: [String: JSONValue]?
    public var required: [String]?

    public init(type: String = "object", properties: [String: JSONValue]? = nil, required: [String]? = nil) {
        self.type = type
        self.properties = properties
        self.required = required
    }

    enum CodingKeys: String, CodingKey {
        case type
        case properties
        case required
    }
}
