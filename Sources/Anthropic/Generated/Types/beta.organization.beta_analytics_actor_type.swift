// Transformed from `anthropic.types.beta.organization.beta_analytics_actor_type` (beta_analytics_actor_type.py).

import Foundation

public enum BetaAnalyticsActorType: OpenEnum, CaseIterable {
    case apiActor
    case federatedActor
    case serviceAccountActor
    case userActor
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaAnalyticsActorType] = [.apiActor, .federatedActor, .serviceAccountActor, .userActor]

    public init(rawValue: String) {
        switch rawValue {
        case "api_actor": self = .apiActor
        case "federated_actor": self = .federatedActor
        case "service_account_actor": self = .serviceAccountActor
        case "user_actor": self = .userActor
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .apiActor: return "api_actor"
        case .federatedActor: return "federated_actor"
        case .serviceAccountActor: return "service_account_actor"
        case .userActor: return "user_actor"
        case .unknown(let value): return value
        }
    }
}
