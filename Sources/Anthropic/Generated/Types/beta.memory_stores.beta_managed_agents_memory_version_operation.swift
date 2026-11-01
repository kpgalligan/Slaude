// Transformed from `anthropic.types.beta.memory_stores.beta_managed_agents_memory_version_operation` (beta_managed_agents_memory_version_operation.py).

import Foundation

public enum BetaManagedAgentsMemoryVersionOperation: OpenEnum, CaseIterable {
    case created
    case modified
    case deleted
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsMemoryVersionOperation] = [.created, .modified, .deleted]

    public init(rawValue: String) {
        switch rawValue {
        case "created": self = .created
        case "modified": self = .modified
        case "deleted": self = .deleted
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .created: return "created"
        case .modified: return "modified"
        case .deleted: return "deleted"
        case .unknown(let value): return value
        }
    }
}
