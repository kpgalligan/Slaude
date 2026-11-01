// Transformed from `anthropic.types.beta.beta_dream_model_config` (beta_dream_model_config.py).

import Foundation

/// The model that runs a dream, from the request that created it.
///
/// The dream uses this model for all of its work. The response always gives the model as an object, even if the request gave only a model ID.
public struct BetaDreamModelConfig: Codable, Hashable, Sendable {
    /// The ID of the model that runs the dream, as given in the request that created
    /// it.
    public var id: String
    /// How fast the model generates output for the dream. Always `standard`.
    public var speed: Speed?

    public init(id: String, speed: Speed? = nil) {
        self.id = id
        self.speed = speed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case speed
    }

    public enum Speed: OpenEnum, CaseIterable {
        case standard
        case fast
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Speed] = [.standard, .fast]

        public init(rawValue: String) {
            switch rawValue {
            case "standard": self = .standard
            case "fast": self = .fast
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .standard: return "standard"
            case .fast: return "fast"
            case .unknown(let value): return value
            }
        }
    }
}
