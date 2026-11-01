// Transformed from `anthropic.types.beta.beta_managed_agents_custom_tool_params` (beta_managed_agents_custom_tool_params.py).

import Foundation

/// A custom tool that is executed by the API client rather than the agent.
///
/// When the agent calls this tool, an `agent.custom_tool_use` event is emitted and the session goes idle, waiting for the client to provide the result via a `user.custom_tool_result` event.
public struct BetaManagedAgentsCustomToolParams: Codable, Hashable, Sendable {
    /// Description of what the tool does, shown to the agent to help it decide when to
    /// use the tool.
    public var description: String
    /// JSON Schema defining the expected input parameters for the tool.
    public var inputSchema: BetaManagedAgentsCustomToolInputSchemaParam
    /// Unique name for the tool.
    ///
    /// 1-128 characters; letters, digits, underscores, and hyphens.
    public var name: String
    public var type: String

    public init(description: String, inputSchema: BetaManagedAgentsCustomToolInputSchemaParam, name: String, type: String = "custom") {
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
