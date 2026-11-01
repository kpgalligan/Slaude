// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_message_event` (beta_managed_agents_user_message_event.py).

import Foundation

/// A user message event in the session conversation.
public struct BetaManagedAgentsUserMessageEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Array of content blocks comprising the user message.
    public var content: [BetaManagedAgentsUserMessageEvent.Content]
    public var type: String
    /// Timestamp when the agent finished processing this message.
    public var processedAt: Date?

    public init(id: String, content: [BetaManagedAgentsUserMessageEvent.Content], type: String = "user.message", processedAt: Date? = nil) {
        self.id = id
        self.content = content
        self.type = type
        self.processedAt = processedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case content
        case type
        case processedAt = "processed_at"
    }
}

extension BetaManagedAgentsUserMessageEvent {

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
