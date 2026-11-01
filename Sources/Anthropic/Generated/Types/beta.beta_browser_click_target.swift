// Transformed from `anthropic.types.beta.beta_browser_click_target` (beta_browser_click_target.py).

import Foundation

public indirect enum BetaBrowserClickTarget: Codable, Hashable, Sendable {
    case coordinate(BetaBrowserCoordinateTarget)
    case ref(BetaBrowserRefTarget)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "coordinate": self = .coordinate(try BetaBrowserCoordinateTarget(from: decoder))
        case "ref": self = .ref(try BetaBrowserRefTarget(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .coordinate(let v): try v.encode(to: encoder)
        case .ref(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
