// Transformed from `anthropic.types.beta.beta_skill_source` (beta_skill_source.py).

import Foundation

public struct BetaSkillSource: Codable, Hashable, Sendable {
    /// Where the Skill comes from.
    ///
    /// Possible values:
    ///
    /// - `"custom"`: authored by the platform user; private to their workspace
    /// - `"anthropic"`: published by Anthropic; shared and read-only
    /// - `"anthropic_example"`: Anthropic-published sample Skill
    /// - `"plugin"`: resolved from an installed plugin
    public var type: TypeValue

    public init(type: TypeValue) {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }

    public enum TypeValue: OpenEnum, CaseIterable {
        case custom
        case anthropic
        case anthropicExample
        case plugin
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TypeValue] = [.custom, .anthropic, .anthropicExample, .plugin]

        public init(rawValue: String) {
            switch rawValue {
            case "custom": self = .custom
            case "anthropic": self = .anthropic
            case "anthropic_example": self = .anthropicExample
            case "plugin": self = .plugin
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .custom: return "custom"
            case .anthropic: return "anthropic"
            case .anthropicExample: return "anthropic_example"
            case .plugin: return "plugin"
            case .unknown(let value): return value
            }
        }
    }
}
