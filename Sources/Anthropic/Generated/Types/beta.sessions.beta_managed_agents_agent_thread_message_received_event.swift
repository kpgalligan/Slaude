// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_agent_thread_message_received_event` (beta_managed_agents_agent_thread_message_received_event.py).

import Foundation

/// Delivery event written to the target thread's input stream when an agent-to-agent message arrives.
public struct BetaManagedAgentsAgentThreadMessageReceivedEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Message content blocks.
    public var content: [BetaManagedAgentsAgentThreadMessageReceivedEvent.Content]
    /// Public `sthr_` ID of the thread that sent the message.
    public var fromSessionThreadID: String
    /// Timestamp when the message was received.
    public var processedAt: Date
    public var type: String
    /// Name of the callable agent this message came from.
    ///
    /// Absent when received from the primary agent.
    public var fromAgentName: String?

    public init(id: String, content: [BetaManagedAgentsAgentThreadMessageReceivedEvent.Content], fromSessionThreadID: String, processedAt: Date, type: String = "agent.thread_message_received", fromAgentName: String? = nil) {
        self.id = id
        self.content = content
        self.fromSessionThreadID = fromSessionThreadID
        self.processedAt = processedAt
        self.type = type
        self.fromAgentName = fromAgentName
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case fromSessionThreadID = "from_session_thread_id"
        case processedAt = "processed_at"
        case type
        case fromAgentName = "from_agent_name"
    }
}

extension BetaManagedAgentsAgentThreadMessageReceivedEvent {

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
