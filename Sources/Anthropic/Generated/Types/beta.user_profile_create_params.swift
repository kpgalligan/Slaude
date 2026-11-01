// Transformed from `anthropic.types.beta.user_profile_create_params` (user_profile_create_params.py).

import Foundation

public struct BetaUserProfileCreateParams: Codable, Hashable, Sendable {
    /// How the platform uses the API for this entity.
    ///
    /// `application` (default): the profile represents an individual end-user of the
    /// platform's product. `passthrough`: the profile identifies a company the platform
    /// resells Claude access to.
    ///
    /// - `application` - The user profile represents an individual end-user of a
    ///   product that the platform builds on the API. New profiles get this value by
    ///   default.
    /// - `passthrough` - The user profile represents a company that the platform
    ///   resells Claude access to.
    public var accessType: AccessType?
    /// Platform's own identifier for this user.
    ///
    /// Not enforced unique. Maximum 255 characters. Legacy field, accepted only under
    /// the `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers;
    /// without one of them, send `external_user_details.reference_id`.
    public var externalId: String??
    /// Details about the entity this profile represents, as the platform states them.
    ///
    /// Every field is optional. Not accepted under the legacy
    /// `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    /// take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    /// `external_user_onboarded_at`) instead.
    public var externalUserDetails: BetaUserProfileExternalUserDetailsParams?
    /// When the entity this profile represents opened its account with the platform, in
    /// RFC 3339 format: for an `application` profile, when the end-user signed up; for
    /// a `passthrough` profile, when the company became the platform's customer. Must
    /// be a complete timestamp no more than 1 minute in the future. Optional. Legacy
    /// field, accepted only under the `user-profiles-2026-08-18` beta header; without a
    /// legacy header, send `external_user_details.onboarded_at`.
    public var externalUserOnboardedAt: ExternalUserOnboardedAt?
    /// Free-form key-value data to attach to this user profile.
    ///
    /// Maximum 16 keys, with keys up to 64 characters and values up to 512 characters.
    /// Values must be non-empty strings.
    public var metadata: [String: String]?
    /// Optional for all profiles.
    ///
    /// Real-world name of the entity this profile represents (company or individual);
    /// for a company the platform resells Claude access to (`access_type`
    /// `passthrough`), that company's name where known. Maximum 255 characters.
    public var name: String??
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(accessType: AccessType? = nil, externalId: String?? = nil, externalUserDetails: BetaUserProfileExternalUserDetailsParams? = nil, externalUserOnboardedAt: ExternalUserOnboardedAt? = nil, metadata: [String: String]? = nil, name: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.accessType = accessType
        self.externalId = externalId
        self.externalUserDetails = externalUserDetails
        self.externalUserOnboardedAt = externalUserOnboardedAt
        self.metadata = metadata
        self.name = name
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case accessType = "access_type"
        case externalId = "external_id"
        case externalUserDetails = "external_user_details"
        case externalUserOnboardedAt = "external_user_onboarded_at"
        case metadata
        case name
        case betas
        case workspaceId = "workspace_id"
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

    public indirect enum ExternalUserOnboardedAt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
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
