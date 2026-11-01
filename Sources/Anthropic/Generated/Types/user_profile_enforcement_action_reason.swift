// Transformed from `anthropic.types.user_profile_enforcement_action_reason` (user_profile_enforcement_action_reason.py).

import Foundation

public enum UserProfileEnforcementActionReason: OpenEnum, CaseIterable {
    case unsupportedRegion
    case fraudOrAbuse
    case highHarm
    case usagePolicyViolation
    case accountCompromise
    case unspecified
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileEnforcementActionReason] = [.unsupportedRegion, .fraudOrAbuse, .highHarm, .usagePolicyViolation, .accountCompromise, .unspecified]

    public init(rawValue: String) {
        switch rawValue {
        case "unsupported_region": self = .unsupportedRegion
        case "fraud_or_abuse": self = .fraudOrAbuse
        case "high_harm": self = .highHarm
        case "usage_policy_violation": self = .usagePolicyViolation
        case "account_compromise": self = .accountCompromise
        case "unspecified": self = .unspecified
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .unsupportedRegion: return "unsupported_region"
        case .fraudOrAbuse: return "fraud_or_abuse"
        case .highHarm: return "high_harm"
        case .usagePolicyViolation: return "usage_policy_violation"
        case .accountCompromise: return "account_compromise"
        case .unspecified: return "unspecified"
        case .unknown(let value): return value
        }
    }
}
