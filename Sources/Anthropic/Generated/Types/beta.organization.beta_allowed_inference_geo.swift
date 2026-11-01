// Transformed from `anthropic.types.beta.organization.beta_allowed_inference_geo` (beta_allowed_inference_geo.py).

import Foundation

public enum BetaAllowedInferenceGeo: OpenEnum, CaseIterable {
    case global
    case us
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAllowedInferenceGeo] = [.global, .us]

    public init(rawValue: String) {
        switch rawValue {
        case "global": self = .global
        case "us": self = .us
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .global: return "global"
        case .us: return "us"
        case .unknown(let value): return value
        }
    }
}
