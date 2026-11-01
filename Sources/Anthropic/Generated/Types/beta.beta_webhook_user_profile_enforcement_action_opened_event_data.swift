// Transformed from `anthropic.types.beta.beta_webhook_user_profile_enforcement_action_opened_event_data` (beta_webhook_user_profile_enforcement_action_opened_event_data.py).

import Foundation

public struct BetaWebhookUserProfileEnforcementActionOpenedEventData: Codable, Hashable, Sendable {
    /// ID of the user profile the enforcement action is on.
    public var id: String
    /// ID (`enac_...`) of the enforcement action that was opened or resolved.
    public var enforcementActionId: String
    public var organizationId: String
    public var type: String

    public init(id: String, enforcementActionId: String, organizationId: String, type: String = "user_profile.enforcement_action_opened") {
        self.id = id
        self.enforcementActionId = enforcementActionId
        self.organizationId = organizationId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case enforcementActionId = "enforcement_action_id"
        case organizationId = "organization_id"
        case type
    }
}
