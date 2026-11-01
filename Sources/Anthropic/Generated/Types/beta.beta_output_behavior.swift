// Transformed from `anthropic.types.beta.beta_output_behavior` (beta_output_behavior.py).

import Foundation

public indirect enum BetaOutputBehavior: Codable, Hashable, Sendable {
    case createNew(BetaOutputBehaviorCreateNew)
    case updateExisting(BetaOutputBehaviorUpdateExisting)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "create_new": self = .createNew(try BetaOutputBehaviorCreateNew(from: decoder))
        case "update_existing": self = .updateExisting(try BetaOutputBehaviorUpdateExisting(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .createNew(let v): try v.encode(to: encoder)
        case .updateExisting(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
