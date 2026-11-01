// Transformed from `anthropic.types.messages.message_batch_result` (message_batch_result.py).

import Foundation

public indirect enum MessageBatchResult: Codable, Hashable, Sendable {
    case succeeded(MessageBatchSucceededResult)
    case errored(MessageBatchErroredResult)
    case canceled(MessageBatchCanceledResult)
    case expired(MessageBatchExpiredResult)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "succeeded": self = .succeeded(try MessageBatchSucceededResult(from: decoder))
        case "errored": self = .errored(try MessageBatchErroredResult(from: decoder))
        case "canceled": self = .canceled(try MessageBatchCanceledResult(from: decoder))
        case "expired": self = .expired(try MessageBatchExpiredResult(from: decoder))
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
