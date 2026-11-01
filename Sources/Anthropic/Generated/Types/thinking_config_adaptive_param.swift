// Transformed from `anthropic.types.thinking_config_adaptive_param` (thinking_config_adaptive_param.py).

import Foundation

public struct ThinkingConfigAdaptiveParam: Codable, Hashable, Sendable {
    public var type: String
    /// Controls how thinking content appears in the response.
    ///
    /// When set to `summarized`, thinking is returned normally. When set to `omitted`,
    /// thinking content is redacted but a signature is returned for multi-turn
    /// continuity. The default depends on the model; see
    /// [Controlling thinking display](https://platform.claude.com/docs/en/build-with-claude/thinking#controlling-thinking-display).
    public var display: Display??

    public init(type: String = "adaptive", display: Display?? = nil) {
        self.type = type
        self.display = display
    }

    enum CodingKeys: String, CodingKey {
        case type
        case display
    }

    public enum Display: OpenEnum, CaseIterable {
        case summarized
        case omitted
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Display] = [.summarized, .omitted]

        public init(rawValue: String) {
            switch rawValue {
            case "summarized": self = .summarized
            case "omitted": self = .omitted
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .summarized: return "summarized"
            case .omitted: return "omitted"
            case .unknown(let value): return value
            }
        }
    }
}
