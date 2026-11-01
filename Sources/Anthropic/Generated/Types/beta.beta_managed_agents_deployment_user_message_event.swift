// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_user_message_event` (beta_managed_agents_deployment_user_message_event.py).

import Foundation

/// A user message sent to the session.
public struct BetaManagedAgentsDeploymentUserMessageEvent: Codable, Hashable, Sendable {
    /// Array of content blocks for the user message.
    public var content: [BetaManagedAgentsDeploymentUserMessageEvent.Content]
    public var type: String

    public init(content: [BetaManagedAgentsDeploymentUserMessageEvent.Content], type: String = "user.message") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }
}

extension BetaManagedAgentsDeploymentUserMessageEvent {

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
