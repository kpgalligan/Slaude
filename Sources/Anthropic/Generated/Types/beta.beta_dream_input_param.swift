// Transformed from `anthropic.types.beta.beta_dream_input_param` (beta_dream_input_param.py).

import Foundation

public indirect enum BetaDreamInputParam: Codable, Hashable, Sendable {
    case memoryStore(BetaDreamMemoryStoreInputParam)
    case sessions(BetaDreamSessionsInputParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "memory_store": self = .memoryStore(try BetaDreamMemoryStoreInputParam(from: decoder))
        case "sessions": self = .sessions(try BetaDreamSessionsInputParam(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .memoryStore(let v): try v.encode(to: encoder)
        case .sessions(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
