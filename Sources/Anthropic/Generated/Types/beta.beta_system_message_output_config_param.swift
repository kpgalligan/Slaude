// Transformed from `anthropic.types.beta.beta_system_message_output_config_param` (beta_system_message_output_config_param.py).

import Foundation

/// Per-message output configuration on a role:"system" input message.
///
/// Fields here apply per-turn; ``format`` remains top-level only. An
/// empty ``{}`` is accepted on a message that carries content; a message
/// with neither content nor output_config fields is rejected.
public struct BetaSystemMessageOutputConfigParam: Codable, Hashable, Sendable {
    /// How much effort the model should put into its response.
    ///
    /// Higher effort levels may result in more thorough analysis but take longer.
    ///
    /// Valid values are `low`, `medium`, `high`, `xhigh`, or `max`.
    public var effort: Effort??

    public init(effort: Effort?? = nil) {
        self.effort = effort
    }

    enum CodingKeys: String, CodingKey {
        case effort
    }

    public enum Effort: OpenEnum, CaseIterable {
        case low
        case medium
        case high
        case xhigh
        case max
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Effort] = [.low, .medium, .high, .xhigh, .max]

        public init(rawValue: String) {
            switch rawValue {
            case "low": self = .low
            case "medium": self = .medium
            case "high": self = .high
            case "xhigh": self = .xhigh
            case "max": self = .max
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .low: return "low"
            case .medium: return "medium"
            case .high: return "high"
            case .xhigh: return "xhigh"
            case .max: return "max"
            case .unknown(let value): return value
            }
        }
    }
}
