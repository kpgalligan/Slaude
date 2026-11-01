// Transformed from `anthropic.types.beta.beta_skill_params` (beta_skill_params.py).

import Foundation

/// Specification for a skill to be loaded in a container.
public struct BetaSkillParams: Codable, Hashable, Sendable {
    /// Skill ID
    public var skillId: String
    /// Type of skill - either 'anthropic' (built-in) or 'custom' (user-defined)
    public var type: TypeValue
    /// Skill version or 'latest' for most recent version
    public var version: String?

    public init(skillId: String, type: TypeValue, version: String? = nil) {
        self.skillId = skillId
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case skillId = "skill_id"
        case type
        case version
    }

    public enum TypeValue: OpenEnum, CaseIterable {
        case anthropic
        case custom
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [TypeValue] = [.anthropic, .custom]

        public init(rawValue: String) {
            switch rawValue {
            case "anthropic": self = .anthropic
            case "custom": self = .custom
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .anthropic: return "anthropic"
            case .custom: return "custom"
            case .unknown(let value): return value
            }
        }
    }
}
