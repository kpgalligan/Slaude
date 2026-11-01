// Transformed from `anthropic.types.beta.beta_user_profile` (beta_user_profile.py).

import Foundation

/// A record of an entity that the platform serves through the API, such as an end-user of the platform's product or a company that the platform resells Claude access to.
///
/// A Messages, Message Batches or token counting request can send a profile's `id` in the `anthropic-user-profile-id` header to attribute the request to that entity.
public struct BetaUserProfile: Codable, Hashable, Sendable {
    /// Unique identifier for this user profile, prefixed `uprof_`.
    public var id: String
    /// When this user profile was created, in RFC 3339 format.
    public var createdAt: Date
    /// Arbitrary key-value metadata.
    ///
    /// Maximum 16 pairs, keys up to 64 chars, values up to 512 chars.
    public var metadata: [String: String]
    /// Real-world name of the entity this profile represents (company or individual).
    ///
    /// For a company the platform resells Claude access to (`access_type`
    /// `passthrough`) this is that company's name. `null` until the platform supplies
    /// one.
    public var name: String?
    /// Trust grants for this profile, keyed by grant name.
    ///
    /// Key omitted when no grant is active or in flight.
    public var trustGrants: [String: BetaUserProfileTrustGrant]
    /// Object type. Always `user_profile`.
    public var type: String
    /// When this user profile was last modified, in RFC 3339 format.
    ///
    /// It normally also updates shortly after Anthropic gives the profile an approval
    /// or withdraws one. Other changes to the statuses that Anthropic reports do not
    /// always update it, so read the status itself rather than watching this timestamp.
    public var updatedAt: Date
    /// How the platform uses the API for this entity: `application` (default) or
    /// `passthrough`. Absent under the legacy `user-profiles-2026-03-24` beta header.
    ///
    /// - `application` - The user profile represents an individual end-user of a
    ///   product that the platform builds on the API. New profiles get this value by
    ///   default.
    /// - `passthrough` - The user profile represents a company that the platform
    ///   resells Claude access to.
    public var accessType: AccessType?
    /// Platform's own identifier for this user.
    ///
    /// Not enforced unique. Legacy field, present only under the
    /// `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers; without
    /// one of them, the value is `external_user_details.reference_id`.
    public var externalId: String?
    /// Details about the entity this profile represents, as the platform states them;
    /// not verified by Anthropic. Every field is present, `null` until the platform
    /// supplies a value. Absent under the legacy `user-profiles-2026-03-24` and
    /// `user-profiles-2026-08-18` beta headers, which serve `reference_id` as the
    /// top-level `external_id` and, under `user-profiles-2026-08-18`, `onboarded_at` as
    /// `external_user_onboarded_at`.
    public var externalUserDetails: BetaUserProfileExternalUserDetails?
    /// When the entity this profile represents opened its account with the platform, as
    /// stated by the platform, in RFC 3339 format (UTC). `null` until the platform
    /// supplies one. Legacy field, present only under the `user-profiles-2026-08-18`
    /// beta header; without a legacy header, the value is
    /// `external_user_details.onboarded_at`.
    public var externalUserOnboardedAt: Date?

    public init(id: String, createdAt: Date, metadata: [String: String], name: String? = nil, trustGrants: [String: BetaUserProfileTrustGrant], type: String = "user_profile", updatedAt: Date, accessType: AccessType? = nil, externalId: String? = nil, externalUserDetails: BetaUserProfileExternalUserDetails? = nil, externalUserOnboardedAt: Date? = nil) {
        self.id = id
        self.createdAt = createdAt
        self.metadata = metadata
        self.name = name
        self.trustGrants = trustGrants
        self.type = type
        self.updatedAt = updatedAt
        self.accessType = accessType
        self.externalId = externalId
        self.externalUserDetails = externalUserDetails
        self.externalUserOnboardedAt = externalUserOnboardedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case metadata
        case name
        case trustGrants = "trust_grants"
        case type
        case updatedAt = "updated_at"
        case accessType = "access_type"
        case externalId = "external_id"
        case externalUserDetails = "external_user_details"
        case externalUserOnboardedAt = "external_user_onboarded_at"
    }

    public enum AccessType: OpenEnum, CaseIterable {
        case application
        case passthrough
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [AccessType] = [.application, .passthrough]

        public init(rawValue: String) {
            switch rawValue {
            case "application": self = .application
            case "passthrough": self = .passthrough
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .application: return "application"
            case .passthrough: return "passthrough"
            case .unknown(let value): return value
            }
        }
    }
}
