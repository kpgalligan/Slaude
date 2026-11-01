// Transformed from `anthropic.types.user_profile_update_params` (user_profile_update_params.py).

import Foundation

public struct UserProfileUpdateParams: Codable, Hashable, Sendable {
    /// If present, replaces the stored access type. Omit to leave unchanged.
    public var accessType: UserProfileAccessType??
    /// Details about the entity this profile represents, as the platform states them.
    ///
    /// Each field sent replaces the stored value; omit a field to leave it unchanged.
    /// Once set, a value cannot be cleared and `null` is rejected. Not accepted under
    /// the legacy `user-profiles-2026-03-24` and `user-profiles-2026-08-18` beta
    /// headers.
    public var externalUserDetails: UserProfileExternalUserDetailsParams?
    /// Key-value pairs to merge into the stored metadata.
    ///
    /// Keys provided overwrite existing values. To remove a key, set its value to an
    /// empty string. Keys not provided are left unchanged. Maximum 16 keys, with keys
    /// up to 64 characters and values up to 512 characters.
    public var metadata: [String: String]?
    /// If present, replaces the stored name.
    ///
    /// Omit to leave unchanged. Maximum 255 characters.
    public var name: String??
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(accessType: UserProfileAccessType?? = nil, externalUserDetails: UserProfileExternalUserDetailsParams? = nil, metadata: [String: String]? = nil, name: String?? = nil, workspaceID: String? = nil) {
        self.accessType = accessType
        self.externalUserDetails = externalUserDetails
        self.metadata = metadata
        self.name = name
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case accessType = "access_type"
        case externalUserDetails = "external_user_details"
        case metadata
        case name
        case workspaceID = "workspace_id"
    }
}
