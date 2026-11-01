// Transformed from `anthropic.types.cache_miss_reason` (cache_miss_reason.py).

import Foundation

public indirect enum CacheMissReason: Codable, Hashable, Sendable {
    case modelChanged(CacheMissModelChanged)
    case systemChanged(CacheMissSystemChanged)
    case toolsChanged(CacheMissToolsChanged)
    case messagesChanged(CacheMissMessagesChanged)
    case previousMessageNotFound(CacheMissPreviousMessageNotFound)
    case unavailable(CacheMissUnavailable)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "model_changed": self = .modelChanged(try CacheMissModelChanged(from: decoder))
        case "system_changed": self = .systemChanged(try CacheMissSystemChanged(from: decoder))
        case "tools_changed": self = .toolsChanged(try CacheMissToolsChanged(from: decoder))
        case "messages_changed": self = .messagesChanged(try CacheMissMessagesChanged(from: decoder))
        case "previous_message_not_found": self = .previousMessageNotFound(try CacheMissPreviousMessageNotFound(from: decoder))
        case "unavailable": self = .unavailable(try CacheMissUnavailable(from: decoder))
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
