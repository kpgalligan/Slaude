// Transformed from `anthropic.types.message_param` (message_param.py).

import Foundation

public indirect enum MessageParam: Codable, Hashable, Sendable {
    case user(UserMessageParam)
    case assistant(AssistantMessageParam)
    case system(SystemMessageParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "role") {
        case "user": self = .user(try UserMessageParam(from: decoder))
        case "assistant": self = .assistant(try AssistantMessageParam(from: decoder))
        case "system": self = .system(try SystemMessageParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .user(let v): try v.encode(to: encoder)
        case .assistant(let v): try v.encode(to: encoder)
        case .system(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
