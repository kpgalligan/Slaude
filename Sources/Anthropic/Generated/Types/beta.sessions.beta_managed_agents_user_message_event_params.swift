// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_message_event_params` (beta_managed_agents_user_message_event_params.py).

import Foundation

/// Parameters for sending a user message to the session.
public struct BetaManagedAgentsUserMessageEventParams: Codable, Hashable, Sendable {
    /// Array of content blocks for the user message.
    public var content: [BetaManagedAgentsUserMessageEventParams.Content]
    public var type: String

    public init(content: [BetaManagedAgentsUserMessageEventParams.Content], type: String = "user.message") {
        self.content = content
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case content
        case type
    }
}

extension BetaManagedAgentsUserMessageEventParams {

    public indirect enum Content: Codable, Hashable, Sendable {
        case text(BetaManagedAgentsTextBlockParam)
        case image(BetaManagedAgentsImageBlockParam)
        case document(BetaManagedAgentsDocumentBlockParam)
        case redacted(BetaManagedAgentsRedactedBlockParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "text": self = .text(try BetaManagedAgentsTextBlockParam(from: decoder))
            case "image": self = .image(try BetaManagedAgentsImageBlockParam(from: decoder))
            case "document": self = .document(try BetaManagedAgentsDocumentBlockParam(from: decoder))
            case "redacted": self = .redacted(try BetaManagedAgentsRedactedBlockParam(from: decoder))
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
