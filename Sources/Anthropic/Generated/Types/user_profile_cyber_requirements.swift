// Transformed from `anthropic.types.user_profile_cyber_requirements` (user_profile_cyber_requirements.py).

import Foundation

/// What a request that names the profile must allow to get the relaxed safeguards of the profile's `active` tiers. A field reads `true` when at least one of those tiers has the requirement and Anthropic has not waived it on that tier for the profile. A request that does not meet a requirement is still served, without the relaxed safeguards of the tiers that have it. The values differ between profiles and can change, so read them rather than assuming them.
public struct UserProfileCyberRequirements: Codable, Hashable, Sendable {
    /// Whether Anthropic must be able to retain the request's inference data.
    public var dataRetention: Bool
    /// Whether Anthropic personnel must be allowed to review the data retained from the
    /// request.
    public var humanReview: Bool

    public init(dataRetention: Bool, humanReview: Bool) {
        self.dataRetention = dataRetention
        self.humanReview = humanReview
    }

    enum CodingKeys: String, CodingKey {
        case dataRetention = "data_retention"
        case humanReview = "human_review"
    }
}
