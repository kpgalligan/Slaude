// Transformed from `anthropic.types.beta.beta_dream_model_config_param` (beta_dream_model_config_param.py).

import Foundation

/// The object form of `model` in a request to create a dream.
public struct BetaDreamModelConfigParam: Codable, Hashable, Sendable {
    /// The ID of the model to run the dream with.
    ///
    /// The ID can be 1 to 256 characters long.
    ///
    /// The
    /// [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    /// lists the supported models.
    public var id: String
    /// How fast the model generates output for the dream. Defaults to `standard`.
    ///
    /// Dreams accept only `standard`.
    public var speed: Speed??

    public init(id: String, speed: Speed?? = nil) {
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
