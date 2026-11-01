// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_status` (beta_managed_agents_deployment_status.py).

import Foundation

public enum BetaManagedAgentsDeploymentStatus: OpenEnum, CaseIterable {
    case active
    case paused
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsDeploymentStatus] = [.active, .paused]

    public init(rawValue: String) {
        switch rawValue {
        case "active": self = .active
        case "paused": self = .paused
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .active: return "active"
        case .paused: return "paused"
        case .unknown(let value): return value
        }
    }
}
