// Transformed from `anthropic.types.user_profile_enforcement_action_next_step` (user_profile_enforcement_action_next_step.py).

import Foundation

public enum UserProfileEnforcementActionNextStep: OpenEnum, CaseIterable {
    case verify
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [UserProfileEnforcementActionNextStep] = [.verify]

    public init(rawValue: String) {
        switch rawValue {
        case "verify": self = .verify
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .verify: return "verify"
        case .unknown(let value): return value
        }
    }
}
