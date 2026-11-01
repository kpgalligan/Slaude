// Transformed from `anthropic.types.user_profile_create_params` (user_profile_create_params.py).

import Foundation

public struct UserProfileCreateParams: Codable, Hashable, Sendable {
    /// How the platform uses the API for this entity.
    ///
    /// `application` (default): the profile represents an individual end-user of the
    /// platform's product. `passthrough`: the profile identifies a company the platform
    /// resells Claude access to.
    public var accessType: UserProfileAccessType?
    /// Details about the entity this profile represents, as the platform states them.
    ///
    /// Every field is optional. Not accepted under the legacy
    /// `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta headers, which
    /// take the top-level `external_id` (and, under `user-profiles-2026-08-18`,
    /// `external_user_onboarded_at`) instead.
    public var externalUserDetails: UserProfileExternalUserDetailsParams?
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
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(accessType: UserProfileAccessType? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceId: String? = nil) {
        self.accessType = accessType
        self.externalUserDetails = externalUserDetails
        self.metadata = metadata
        self.name = name
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case accessType = "access_type"
        case externalUserDetails = "external_user_details"
        case metadata
        case name
        case workspaceId = "workspace_id"
    }
}
