// Transformed from `anthropic.types.beta.organization.beta_organization_webhook_endpoint_state` (beta_organization_webhook_endpoint_state.py).

import Foundation

public enum BetaOrganizationWebhookEndpointState: OpenEnum, CaseIterable {
    case disabled
    case enabled
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaOrganizationWebhookEndpointState] = [.disabled, .enabled]

    public init(rawValue: String) {
        switch rawValue {
        case "disabled": self = .disabled
        case "enabled": self = .enabled
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .disabled: return "disabled"
        case .enabled: return "enabled"
        case .unknown(let value): return value
        }
    }
}
