// Transformed from `anthropic.types.browser_click_target` (browser_click_target.py).

import Foundation

public indirect enum BrowserClickTarget: Codable, Hashable, Sendable {
    case coordinate(BrowserCoordinateTarget)
    case ref(BrowserRefTarget)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "coordinate": self = .coordinate(try BrowserCoordinateTarget(from: decoder))
        case "ref": self = .ref(try BrowserRefTarget(from: decoder))
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
