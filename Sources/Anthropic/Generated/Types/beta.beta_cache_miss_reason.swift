// Transformed from `anthropic.types.beta.beta_cache_miss_reason` (beta_cache_miss_reason.py).

import Foundation

public indirect enum BetaCacheMissReason: Codable, Hashable, Sendable {
    case modelChanged(BetaCacheMissModelChanged)
    case systemChanged(BetaCacheMissSystemChanged)
    case toolsChanged(BetaCacheMissToolsChanged)
    case messagesChanged(BetaCacheMissMessagesChanged)
    case previousMessageNotFound(BetaCacheMissPreviousMessageNotFound)
    case unavailable(BetaCacheMissUnavailable)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "model_changed": self = .modelChanged(try BetaCacheMissModelChanged(from: decoder))
        case "system_changed": self = .systemChanged(try BetaCacheMissSystemChanged(from: decoder))
        case "tools_changed": self = .toolsChanged(try BetaCacheMissToolsChanged(from: decoder))
        case "messages_changed": self = .messagesChanged(try BetaCacheMissMessagesChanged(from: decoder))
        case "previous_message_not_found": self = .previousMessageNotFound(try BetaCacheMissPreviousMessageNotFound(from: decoder))
        case "unavailable": self = .unavailable(try BetaCacheMissUnavailable(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .modelChanged(let v): try v.encode(to: encoder)
        case .systemChanged(let v): try v.encode(to: encoder)
        case .toolsChanged(let v): try v.encode(to: encoder)
        case .messagesChanged(let v): try v.encode(to: encoder)
        case .previousMessageNotFound(let v): try v.encode(to: encoder)
        case .unavailable(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
