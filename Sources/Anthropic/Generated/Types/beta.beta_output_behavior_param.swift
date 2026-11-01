// Transformed from `anthropic.types.beta.beta_output_behavior_param` (beta_output_behavior_param.py).

import Foundation

public indirect enum BetaOutputBehaviorParam: Codable, Hashable, Sendable {
    case createNew(BetaOutputBehaviorCreateNewParam)
    case updateExisting(BetaOutputBehaviorUpdateExistingParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "create_new": self = .createNew(try BetaOutputBehaviorCreateNewParam(from: decoder))
        case "update_existing": self = .updateExisting(try BetaOutputBehaviorUpdateExistingParam(from: decoder))
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
