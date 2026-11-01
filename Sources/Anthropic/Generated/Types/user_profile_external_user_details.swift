// Transformed from `anthropic.types.user_profile_external_user_details` (user_profile_external_user_details.py).

import Foundation

/// Details about the entity this profile represents, as the platform states them.
///
/// Anthropic does not verify them. Every field is present, `null` until the platform supplies a value.
public struct UserProfileExternalUserDetails: Codable, Hashable, Sendable {
    /// The status of the entity's account on the platform: `active`, `suspended` or
    /// `blocked`. `null` until the platform supplies one.
    public var accountStatus: UserProfileExternalUserAccountStatus?
    /// The country the platform associates with the entity, as an ISO 3166-1 alpha-2
    /// code. `null` until the platform supplies one.
    public var country: String?
    /// The platform-computed hash of the entity's email address.
    ///
    /// `null` until the platform supplies one.
    public var emailHash: String?
    /// What kind of entity the profile represents: `individual`, `business`,
    /// `non_profit` or `government`. `null` until the platform supplies one.
    public var entityType: UserProfileExternalUserEntityType?
    /// The platform-computed hash of the entity's name.
    ///
    /// `null` until the platform supplies one.
    public var nameHash: String?
    /// When the entity opened its account with the platform, as stated by the platform,
    /// in RFC 3339 format (UTC). `null` until the platform supplies one.
    public var onboardedAt: Date?
    /// The platform's own reference for the entity.
    ///
    /// `null` until the platform supplies one.
    public var referenceId: String?

    public init(accountStatus: UserProfileExternalUserAccountStatus? = nil, country: String? = nil, emailHash: String? = nil, entityType: UserProfileExternalUserEntityType? = nil, nameHash: String? = nil, onboardedAt: Date? = nil, referenceId: String? = nil) {
        self.accountStatus = accountStatus
        self.country = country
        self.emailHash = emailHash
        self.entityType = entityType
        self.nameHash = nameHash
        self.onboardedAt = onboardedAt
        self.referenceId = referenceId
    }

    enum CodingKeys: String, CodingKey {
        case accountStatus = "account_status"
        case country
        case emailHash = "email_hash"
        case entityType = "entity_type"
        case nameHash = "name_hash"
        case onboardedAt = "onboarded_at"
        case referenceId = "reference_id"
    }
}
