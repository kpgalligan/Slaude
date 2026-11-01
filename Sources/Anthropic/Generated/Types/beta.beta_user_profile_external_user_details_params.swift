// Transformed from `anthropic.types.beta.beta_user_profile_external_user_details_params` (beta_user_profile_external_user_details_params.py).

import Foundation

public struct BetaUserProfileExternalUserDetailsParams: Codable, Hashable, Sendable {
    /// The status of the entity's account on the platform: `active`, `suspended` or
    /// `blocked`.
    ///
    /// - `active` - The platform has neither restricted nor barred the account of the
    ///   entity that the user profile represents.
    /// - `suspended` - The platform has restricted the account of the entity that the
    ///   user profile represents and may restore it.
    /// - `blocked` - The platform has barred the account of the entity that the user
    ///   profile represents.
    public var accountStatus: AccountStatus??
    /// The country of the entity (not of the platform), as the platform determines it:
    /// an ISO 3166-1 alpha-2 code in upper case, for example `US`. Only the form, two
    /// uppercase ASCII letters, is checked.
    public var country: String??
    /// A hash of the entity's email address, computed by the platform.
    ///
    /// Anthropic treats it as an opaque string and does not prescribe the hash
    /// function. 1 to 255 characters.
    public var emailHash: String??
    /// What kind of entity the profile represents: `individual`, `business`,
    /// `non_profit` or `government`.
    public var entityType: EntityType??
    /// A hash of the entity's name, computed by the platform.
    ///
    /// Anthropic treats it as an opaque string and does not prescribe the hash
    /// function. 1 to 255 characters.
    public var nameHash: String??
    /// When the entity opened its account with the platform, in RFC 3339 format: for an
    /// `application` profile, when the end-user signed up; for a `passthrough` profile,
    /// when the company became the platform's customer. Must be a complete timestamp no
    /// more than 1 minute in the future.
    public var onboardedAt: OnboardedAt?
    /// The platform's own reference for the entity, for example the key of the
    /// end-user's row in the platform's database. Not interpreted by Anthropic and not
    /// enforced unique. 1 to 255 characters.
    public var referenceId: String??

    public init(accountStatus: AccountStatus?? = nil, country: String?? = nil, emailHash: String?? = nil, entityType: EntityType?? = nil, nameHash: String?? = nil, onboardedAt: OnboardedAt? = nil, referenceId: String?? = nil) {
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

    public indirect enum OnboardedAt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
