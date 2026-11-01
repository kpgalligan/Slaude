// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_message_event` (beta_managed_agents_agent_message_event.py).

import Foundation

/// An agent response event in the session conversation.
public struct BetaManagedAgentsAgentMessageEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Array of text blocks comprising the agent response.
    public var content: [BetaManagedAgentsAgentMessageEvent.Content]
    /// Timestamp when this response was generated.
    public var processedAt: Date
    public var type: String

    public init(id: String, content: [BetaManagedAgentsAgentMessageEvent.Content], processedAt: Date, type: String = "agent.message") {
        self.id = id
        self.content = content
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case processedAt = "processed_at"
        case type
    }
}

extension BetaManagedAgentsAgentMessageEvent {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaManagedAgentsTextBlock)
        case redacted(BetaManagedAgentsRedactedBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaManagedAgentsTextBlock(from: decoder))
            case "redacted": self = .redacted(try BetaManagedAgentsRedactedBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .redacted(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
