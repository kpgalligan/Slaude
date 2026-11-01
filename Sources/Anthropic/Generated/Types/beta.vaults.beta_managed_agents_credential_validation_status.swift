// Transformed from `anthropic.types.beta.vaults.beta_managed_agents_credential_validation_status` (beta_managed_agents_credential_validation_status.py).

import Foundation

public enum BetaManagedAgentsCredentialValidationStatus: OpenEnum, CaseIterable {
    case valid
    case invalid
    case unknown_
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsCredentialValidationStatus] = [.valid, .invalid, .unknown_]

    public init(rawValue: String) {
        switch rawValue {
        case "valid": self = .valid
        case "invalid": self = .invalid
        case "unknown": self = .unknown_
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .valid: return "valid"
        case .invalid: return "invalid"
        case .unknown_: return "unknown"
        case .unknown(let value): return value
        }
    }
}
