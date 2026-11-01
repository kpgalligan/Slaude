// Transformed from `anthropic.types.beta.organization.webhook_update_params` (webhook_update_params.py).

import Foundation

public struct WebhookUpdateParams: Codable, Hashable, Sendable {
    /// Notes about the endpoint.
    public var description: String?
    /// The event types to deliver to the endpoint.
    ///
    /// Replaces the whole set; an empty list leaves it unchanged.
    public var enabledEvents: [EnabledEvents]?
    /// A short label for the endpoint.
    public var name: String?
    /// `disabled` stops deliveries.
    ///
    /// `enabled` resumes them and clears `disabled_reason`. Events that happen while
    /// the endpoint is disabled are never delivered.
    public var state: State?
    /// The HTTPS URL that deliveries are sent to.
    public var url: String?
    /// This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(description: String? = nil, enabledEvents: [EnabledEvents]? = nil, name: String? = nil, state: State? = nil, url: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.description = description
        self.enabledEvents = enabledEvents
        self.name = name
        self.state = state
        self.url = url
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case description
        case enabledEvents = "enabled_events"
        case name
        case state
        case url
        case betas
    }

    public enum EnabledEvents: OpenEnum, CaseIterable {
        case userProfileEnforcementActionOpened
        case userProfileEnforcementActionResolved
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [EnabledEvents] = [.userProfileEnforcementActionOpened, .userProfileEnforcementActionResolved]

        public init(rawValue: String) {
            switch rawValue {
            case "user_profile.enforcement_action_opened": self = .userProfileEnforcementActionOpened
            case "user_profile.enforcement_action_resolved": self = .userProfileEnforcementActionResolved
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .userProfileEnforcementActionOpened: return "user_profile.enforcement_action_opened"
            case .userProfileEnforcementActionResolved: return "user_profile.enforcement_action_resolved"
            case .unknown(let value): return value
            }
        }
    }

    public enum State: OpenEnum, CaseIterable {
        case disabled
        case enabled
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [State] = [.disabled, .enabled]

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
}
