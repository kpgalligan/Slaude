// Transformed from `anthropic.types.beta.organization.beta_new_organization_webhook_endpoint` (beta_new_organization_webhook_endpoint.py).

import Foundation

/// A new organization webhook endpoint, with its signing secret.
public struct BetaNewOrganizationWebhookEndpoint: Codable, Hashable, Sendable {
    /// ID of the webhook endpoint.
    public var id: String
    /// When the endpoint was created, in RFC 3339 format.
    public var createdAt: Date
    /// Notes about the endpoint. An empty string when none were given.
    public var description: String
    /// Why Anthropic disabled the endpoint automatically.
    ///
    /// An empty string when the endpoint is enabled, or when you disabled it.
    public var disabledReason: String
    /// The event types delivered to the endpoint.
    public var enabledEvents: [EnabledEvents]
    /// A short label for the endpoint. An empty string when none was given.
    public var name: String
    /// The secret Anthropic signs deliveries to the endpoint with (prefix `whsec_`).
    ///
    /// No other response returns it, so store it now. To replace it, regenerate the
    /// signing secret.
    public var signingSecret: String
    /// Whether deliveries are sent to the endpoint.
    public var state: BetaOrganizationWebhookEndpointState
    /// When the endpoint was last changed, in RFC 3339 format.
    public var updatedAt: Date
    /// The HTTPS URL that deliveries are sent to.
    public var url: String

    public init(id: String, createdAt: Date, description: String, disabledReason: String, enabledEvents: [EnabledEvents], name: String, signingSecret: String, state: BetaOrganizationWebhookEndpointState, updatedAt: Date, url: String) {
        self.id = id
        self.createdAt = createdAt
        self.description = description
        self.disabledReason = disabledReason
        self.enabledEvents = enabledEvents
        self.name = name
        self.signingSecret = signingSecret
        self.state = state
        self.updatedAt = updatedAt
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case description
        case disabledReason = "disabled_reason"
        case enabledEvents = "enabled_events"
        case name
        case signingSecret = "signing_secret"
        case state
        case updatedAt = "updated_at"
        case url
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
