// Transformed from `anthropic.types.container_skill` (container_skill.py).

import Foundation

/// A skill that was loaded in a container (response model).
public struct ContainerSkill: Codable, Hashable, Sendable {
    /// Skill ID
    public var skillID: String
    /// Type of skill - either 'anthropic' (built-in) or 'custom' (user-defined)
    public var type: TypeValue
    /// The resolved version: a skill version ID for custom skills.
    public var version: String

    public init(skillID: String, type: TypeValue, version: String) {
        self.skillID = skillID
        self.type = type
        self.version = version
    }

    enum CodingKeys: String, CodingKey {
        case skillID = "skill_id"
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
