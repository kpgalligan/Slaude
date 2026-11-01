// Transformed from `anthropic.types.beta.beta_managed_agents_user_tool_result_event` (beta_managed_agents_user_tool_result_event.py).

import Foundation

/// Event sent by the client providing the result of an agent-toolset tool execution.
///
/// Only valid on `self_hosted` environments, where sandbox-routed tools are executed by the client rather than the server.
public struct BetaManagedAgentsUserToolResultEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// The id of the `agent.tool_use` event this result corresponds to, which can be
    /// found in the last `session.status_idle`
    /// [event's](https://platform.claude.com/docs/en/api/beta/sessions/events/list#beta_managed_agents_session_requires_action.event_ids)
    /// `stop_reason.event_ids` field.
    public var toolUseID: String
    public var type: String
    /// The result content returned by the tool.
    public var content: [BetaManagedAgentsUserToolResultEvent.Content]?
    /// Whether the tool execution resulted in an error.
    public var isError: Bool?
    /// Timestamp when this result was processed.
    public var processedAt: Date?
    /// Set by the server to the subagent thread this result was routed to.
    ///
    /// Omitted when it was routed to the primary thread.
    public var sessionThreadID: String?

    public init(id: String, toolUseID: String, type: String = "user.tool_result", content: [BetaManagedAgentsUserToolResultEvent.Content]? = nil, isError: Bool? = nil, processedAt: Date? = nil, sessionThreadID: String? = nil) {
        self.id = id
        self.toolUseID = toolUseID
        self.type = type
        self.content = content
        self.isError = isError
        self.processedAt = processedAt
        self.sessionThreadID = sessionThreadID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case toolUseID = "tool_use_id"
        case type
        case content
        case isError = "is_error"
        case processedAt = "processed_at"
        case sessionThreadID = "session_thread_id"
    }
}

extension BetaManagedAgentsUserToolResultEvent {

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
