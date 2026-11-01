// Transformed from `anthropic.types.beta.organization.webhook_create_params` (webhook_create_params.py).

import Foundation

public struct WebhookCreateParams: Codable, Hashable, Sendable {
    /// The event types to deliver to the endpoint. Must list at least one.
    public var enabledEvents: [EnabledEvents]
    /// The HTTPS URL that deliveries are sent to.
    public var url: String
    /// Notes about the endpoint.
    public var description: String?
    /// A short label for the endpoint.
    public var name: String?
    /// This endpoint is in beta: requests must send `webhooks-2026-10-07` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(enabledEvents: [EnabledEvents], url: String, description: String? = nil, name: String? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.enabledEvents = enabledEvents
        self.url = url
        self.description = description
        self.name = name
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case enabledEvents = "enabled_events"
        case url
        case description
        case name
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
}
