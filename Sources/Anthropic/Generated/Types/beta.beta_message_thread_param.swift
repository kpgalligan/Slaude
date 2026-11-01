// Transformed from `anthropic.types.beta.beta_message_thread_param` (beta_message_thread_param.py).

import Foundation

public indirect enum BetaMessageThreadParam: Codable, Hashable, Sendable {
    case create(BetaThreadCreateParams)
    case `continue`(BetaThreadContinueParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "create": self = .create(try BetaThreadCreateParams(from: decoder))
        case "continue": self = .continue(try BetaThreadContinueParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .create(let v): try v.encode(to: encoder)
        case .continue(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
