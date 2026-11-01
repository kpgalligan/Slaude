// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_mcp_tool_result_event` (beta_managed_agents_agent_mcp_tool_result_event.py).

import Foundation

/// Event representing the result of an MCP tool execution.
public struct BetaManagedAgentsAgentMCPToolResultEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// The id of the `agent.mcp_tool_use` event this result corresponds to.
    public var mcpToolUseID: String
    /// Timestamp when this event was processed.
    public var processedAt: Date
    public var type: String
    /// The result content returned by the tool.
    public var content: [BetaManagedAgentsAgentMCPToolResultEvent.Content]?
    /// Whether the tool execution resulted in an error.
    public var isError: Bool?

    public init(id: String, mcpToolUseID: String, processedAt: Date, type: String = "agent.mcp_tool_result", content: [BetaManagedAgentsAgentMCPToolResultEvent.Content]? = nil, isError: Bool? = nil) {
        self.id = id
        self.mcpToolUseID = mcpToolUseID
        self.processedAt = processedAt
        self.type = type
        self.content = content
        self.isError = isError
    }

    enum CodingKeys: String, CodingKey {
        case id
        case mcpToolUseID = "mcp_tool_use_id"
        case processedAt = "processed_at"
        case type
        case content
        case isError = "is_error"
    }
}

extension BetaManagedAgentsAgentMCPToolResultEvent {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaManagedAgentsTextBlock)
        case image(BetaManagedAgentsImageBlock)
        case document(BetaManagedAgentsDocumentBlock)
        case searchResult(BetaManagedAgentsSearchResultBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaManagedAgentsTextBlock(from: decoder))
            case "image": self = .image(try BetaManagedAgentsImageBlock(from: decoder))
            case "document": self = .document(try BetaManagedAgentsDocumentBlock(from: decoder))
            case "search_result": self = .searchResult(try BetaManagedAgentsSearchResultBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .image(let v): try v.encode(to: encoder)
            case .document(let v): try v.encode(to: encoder)
            case .searchResult(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
