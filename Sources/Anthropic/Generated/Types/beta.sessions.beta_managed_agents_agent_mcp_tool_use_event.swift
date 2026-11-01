// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_mcp_tool_use_event` (beta_managed_agents_agent_mcp_tool_use_event.py).

import Foundation

/// Event emitted when the agent invokes a tool provided by an MCP server.
public struct BetaManagedAgentsAgentMCPToolUseEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Input parameters for the tool call.
    public var input: [String: JSONValue]
    /// Name of the MCP server providing the tool.
    public var mcpServerName: String
    /// Name of the MCP tool being used.
    public var name: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// The evaluated permission policy for this tool invocation.
    public var evaluatedPermission: BetaManagedAgentsAgentEvaluatedPermission?
    /// Which resolved permission_policy produced evaluated_permission: always_allow,
    /// always_ask, or auto (with the server's per-invocation judgement). Absent only
    /// when the server refused the call before any policy applied (for example, the
    /// named tool is not enabled in the session); such a refusal has
    /// evaluated_permission deny. An event recorded before this field existed reads as
    /// the arm its evaluated_permission implies (always_allow for allow, always_ask for
    /// ask).
    public var evaluation: BetaManagedAgentsAgentToolEvaluation?
    /// When set, this event was cross-posted from a subagent's thread to surface its
    /// permission request on the primary thread's stream. Empty on the thread's own
    /// events. Informational only: the server routes the matching
    /// `user.tool_confirmation` by `tool_use_id`, so clients do not send it back.
    public var sessionThreadId: String?

    public init(id: String, input: [String: JSONValue], mcpServerName: String, name: String, processedAt: Date, type: String = "agent.mcp_tool_use", evaluatedPermission: BetaManagedAgentsAgentEvaluatedPermission? = nil, evaluation: BetaManagedAgentsAgentToolEvaluation? = nil, sessionThreadId: String? = nil) {
        self.id = id
        self.input = input
        self.mcpServerName = mcpServerName
        self.name = name
        self.processedAt = processedAt
        self.type = type
        self.evaluatedPermission = evaluatedPermission
        self.evaluation = evaluation
        self.sessionThreadId = sessionThreadId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case input
        case mcpServerName = "mcp_server_name"
        case name
        case processedAt = "processed_at"
        case type
        case evaluatedPermission = "evaluated_permission"
        case evaluation
        case sessionThreadId = "session_thread_id"
    }
}
