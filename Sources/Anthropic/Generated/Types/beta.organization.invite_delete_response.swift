// Transformed from `anthropic.types.beta.organization.invite_delete_response` (invite_delete_response.py).

import Foundation

public struct BetaOrganizationInviteDeleteResponse: Codable, Hashable, Sendable {
    /// ID of the Invite.
    public var id: String
    /// Deleted object type.
    ///
    /// For Invites, this is always `"invite_deleted"`.
    public var type: String

    public init(id: String, type: String = "invite_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
