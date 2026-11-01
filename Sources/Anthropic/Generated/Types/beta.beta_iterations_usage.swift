// Transformed from `anthropic.types.beta.beta_iterations_usage` (beta_iterations_usage.py).

import Foundation

public typealias BetaIterationsUsage = [BetaIterationsUsageBetaIterationsUsageItem]

public indirect enum BetaIterationsUsageBetaIterationsUsageItem: Codable, Hashable, Sendable {
    case message(BetaMessageIterationUsage)
    case compaction(BetaCompactionIterationUsage)
    case advisorMessage(BetaAdvisorMessageIterationUsage)
    case fallbackMessage(BetaFallbackMessageIterationUsage)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "message": self = .message(try BetaMessageIterationUsage(from: decoder))
        case "compaction": self = .compaction(try BetaCompactionIterationUsage(from: decoder))
        case "advisor_message": self = .advisorMessage(try BetaAdvisorMessageIterationUsage(from: decoder))
        case "fallback_message": self = .fallbackMessage(try BetaFallbackMessageIterationUsage(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .message(let v): try v.encode(to: encoder)
        case .compaction(let v): try v.encode(to: encoder)
        case .advisorMessage(let v): try v.encode(to: encoder)
        case .fallbackMessage(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
