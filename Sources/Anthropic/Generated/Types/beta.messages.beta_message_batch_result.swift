// Transformed from `anthropic.types.beta.messages.beta_message_batch_result` (beta_message_batch_result.py).

import Foundation

public indirect enum BetaMessageBatchResult: Codable, Hashable, Sendable {
    case succeeded(BetaMessageBatchSucceededResult)
    case errored(BetaMessageBatchErroredResult)
    case canceled(BetaMessageBatchCanceledResult)
    case expired(BetaMessageBatchExpiredResult)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "succeeded": self = .succeeded(try BetaMessageBatchSucceededResult(from: decoder))
        case "errored": self = .errored(try BetaMessageBatchErroredResult(from: decoder))
        case "canceled": self = .canceled(try BetaMessageBatchCanceledResult(from: decoder))
        case "expired": self = .expired(try BetaMessageBatchExpiredResult(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .succeeded(let v): try v.encode(to: encoder)
        case .errored(let v): try v.encode(to: encoder)
        case .canceled(let v): try v.encode(to: encoder)
        case .expired(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
