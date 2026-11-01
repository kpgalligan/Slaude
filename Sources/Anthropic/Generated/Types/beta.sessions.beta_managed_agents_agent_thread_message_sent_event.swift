// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_thread_message_sent_event` (beta_managed_agents_agent_thread_message_sent_event.py).

import Foundation

/// Observability event emitted to the sender's output stream when an agent-to-agent message is sent.
public struct BetaManagedAgentsAgentThreadMessageSentEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Message content blocks.
    public var content: [BetaManagedAgentsAgentThreadMessageSentEvent.Content]
    /// Timestamp when the message was sent.
    public var processedAt: Date
    /// Public `sthr_` ID of the thread the message was sent to.
    public var toSessionThreadID: String
    public var type: String
    /// Name of the callable agent this message was sent to.
    ///
    /// Absent when sent to the primary agent.
    public var toAgentName: String?

    public init(id: String, content: [BetaManagedAgentsAgentThreadMessageSentEvent.Content], processedAt: Date, toSessionThreadID: String, type: String = "agent.thread_message_sent", toAgentName: String? = nil) {
        self.id = id
        self.content = content
        self.processedAt = processedAt
        self.toSessionThreadID = toSessionThreadID
        self.type = type
        self.toAgentName = toAgentName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case processedAt = "processed_at"
        case toSessionThreadID = "to_session_thread_id"
        case type
        case toAgentName = "to_agent_name"
    }
}

extension BetaManagedAgentsAgentThreadMessageSentEvent {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaManagedAgentsTextBlock)
        case image(BetaManagedAgentsImageBlock)
        case document(BetaManagedAgentsDocumentBlock)
        case redacted(BetaManagedAgentsRedactedBlock)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaManagedAgentsTextBlock(from: decoder))
            case "image": self = .image(try BetaManagedAgentsImageBlock(from: decoder))
            case "document": self = .document(try BetaManagedAgentsDocumentBlock(from: decoder))
            case "redacted": self = .redacted(try BetaManagedAgentsRedactedBlock(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .text(let v): try v.encode(to: encoder)
            case .image(let v): try v.encode(to: encoder)
            case .document(let v): try v.encode(to: encoder)
            case .redacted(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
