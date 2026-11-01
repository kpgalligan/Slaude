// Transformed from `anthropic.types.beta.beta_managed_agents_custom_tool` (beta_managed_agents_custom_tool.py).

import Foundation

/// A custom tool as returned in API responses.
public struct BetaManagedAgentsCustomTool: Codable, Hashable, Sendable {
    public var description: String
    /// JSON Schema for custom tool input parameters.
    public var inputSchema: BetaManagedAgentsCustomToolInputSchema
    public var name: String
    public var type: String

    public init(description: String, inputSchema: BetaManagedAgentsCustomToolInputSchema, name: String, type: String = "custom") {
        self.description = description
        self.inputSchema = inputSchema
        self.name = name
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case description
        case inputSchema = "input_schema"
        case name
        case type
    }
}
