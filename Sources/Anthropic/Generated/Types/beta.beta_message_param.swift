// Transformed from `anthropic.types.beta.beta_message_param` (beta_message_param.py).

import Foundation

public indirect enum BetaMessageParam: Codable, Hashable, Sendable {
    case user(BetaUserMessageParam)
    case assistant(BetaAssistantMessageParam)
    case system(BetaSystemMessageParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "role") {
        case "user": self = .user(try BetaUserMessageParam(from: decoder))
        case "assistant": self = .assistant(try BetaAssistantMessageParam(from: decoder))
        case "system": self = .system(try BetaSystemMessageParam(from: decoder))
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
