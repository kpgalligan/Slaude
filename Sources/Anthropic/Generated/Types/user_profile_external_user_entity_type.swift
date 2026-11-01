// Transformed from `anthropic.types.user_profile_external_user_entity_type` (user_profile_external_user_entity_type.py).

import Foundation

public enum UserProfileExternalUserEntityType: OpenEnum, CaseIterable {
    case individual
    case business
    case nonProfit
    case government
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileExternalUserEntityType] = [.individual, .business, .nonProfit, .government]

    public init(rawValue: String) {
        switch rawValue {
        case "individual": self = .individual
        case "business": self = .business
        case "non_profit": self = .nonProfit
        case "government": self = .government
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .individual: return "individual"
        case .business: return "business"
        case .nonProfit: return "non_profit"
        case .government: return "government"
        case .unknown(let value): return value
        }
    }
}
