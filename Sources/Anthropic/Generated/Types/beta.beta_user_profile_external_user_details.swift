// Transformed from `anthropic.types.beta.beta_user_profile_external_user_details` (beta_user_profile_external_user_details.py).

import Foundation

/// Details about the entity this profile represents, as the platform states them.
///
/// Anthropic does not verify them. Every field is present, `null` until the platform supplies a value.
public struct BetaUserProfileExternalUserDetails: Codable, Hashable, Sendable {
    /// The status of the entity's account on the platform: `active`, `suspended` or
    /// `blocked`. `null` until the platform supplies one.
    ///
    /// - `active` - The platform has neither restricted nor barred the account of the
    ///   entity that the user profile represents.
    /// - `suspended` - The platform has restricted the account of the entity that the
    ///   user profile represents and may restore it.
    /// - `blocked` - The platform has barred the account of the entity that the user
    ///   profile represents.
    public var accountStatus: AccountStatus?
    /// The country the platform associates with the entity, as an ISO 3166-1 alpha-2
    /// code. `null` until the platform supplies one.
    public var country: String?
    /// The platform-computed hash of the entity's email address.
    ///
    /// `null` until the platform supplies one.
    public var emailHash: String?
    /// What kind of entity the profile represents: `individual`, `business`,
    /// `non_profit` or `government`. `null` until the platform supplies one.
    public var entityType: EntityType?
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

    public init(accountStatus: AccountStatus? = nil, country: String? = nil, emailHash: String? = nil, entityType: EntityType? = nil, nameHash: String? = nil, onboardedAt: Date? = nil, referenceId: String? = nil) {
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

    public enum AccountStatus: OpenEnum, CaseIterable {
        case active
        case suspended
        case blocked
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [AccountStatus] = [.active, .suspended, .blocked]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "suspended": self = .suspended
            case "blocked": self = .blocked
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .suspended: return "suspended"
            case .blocked: return "blocked"
            case .unknown(let value): return value
            }
        }
    }

    public enum EntityType: OpenEnum, CaseIterable {
        case individual
        case business
        case nonProfit
        case government
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [EntityType] = [.individual, .business, .nonProfit, .government]

        public init(rawValue: String) {
            switch rawValue {
            case "individual": self = .individual
            case "business": self = .business
            case "non_profit": self = .nonProfit
            case "government": self = .government
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .individual: return "individual"
            case .business: return "business"
            case .nonProfit: return "non_profit"
            case .government: return "government"
            case .unknown(let value): return value
            }
        }
    }
}
