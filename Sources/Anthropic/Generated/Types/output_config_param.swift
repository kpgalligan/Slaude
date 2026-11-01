// Transformed from `anthropic.types.output_config_param` (output_config_param.py).

import Foundation

public struct OutputConfigParam: Codable, Hashable, Sendable {
    /// How much effort the model should put into its response.
    ///
    /// Higher effort levels may result in more thorough analysis but take longer.
    ///
    /// Valid values are `low`, `medium`, `high`, `xhigh`, or `max`.
    public var effort: Effort??
    /// A schema to specify Claude's output format in responses.
    ///
    /// See
    /// [structured outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)
    public var format: JSONOutputFormatParam??

    public init(effort: Effort?? = nil, format: JSONOutputFormatParam?? = nil) {
        self.effort = effort
        self.format = format
    }

    enum CodingKeys: String, CodingKey {
        case effort
        case format
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
