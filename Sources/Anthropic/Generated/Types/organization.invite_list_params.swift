// Transformed from `anthropic.types.organization.invite_list_params` (invite_list_params.py).

import Foundation

public struct InviteListParams: Codable, Hashable, Sendable {
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately after this object.
    public var afterId: String?
    /// ID of the object to use as a cursor for pagination.
    ///
    /// When provided, returns the page of results immediately before this object.
    public var beforeId: String?
    /// Filter by the email address the Invite was sent to.
    ///
    /// Matches the same way as the Users list's `email` filter (normalized,
    /// case-insensitive).
    public var email: String?
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `1000`.
    public var limit: Int?
    /// Filter to items whose `role` equals one of the supplied values.
    ///
    /// Repeatable; values are OR'ed together.
    ///
    /// Accepted values depend on the organization type: Console and API organizations
    /// accept `user`, `developer`, `billing`, `admin`, and `claude_code_user`; Claude
    /// Enterprise organizations accept `user`, `owner`, `primary_owner`,
    /// `membership_admin`, and `managed`.
    public var roles: [String]?
    /// Filter by Invite status.
    ///
    /// Repeatable; values are OR'ed together. Omit to return `pending`, `accepted`, and
    /// `expired` Invites alike.
    public var statuses: [Statuses]?

    public init(afterId: String? = nil, beforeId: String? = nil, email: String? = nil, limit: Int? = nil, roles: [String]? = nil, statuses: [Statuses]? = nil) {
        self.afterId = afterId
        self.beforeId = beforeId
        self.email = email
        self.limit = limit
        self.roles = roles
        self.statuses = statuses
    }

    enum CodingKeys: String, CodingKey {
        case afterId = "after_id"
        case beforeId = "before_id"
        case email
        case limit
        case roles
        case statuses
    }

    public enum Statuses: OpenEnum, CaseIterable {
        case accepted
        case expired
        case pending
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Statuses] = [.accepted, .expired, .pending]

        public init(rawValue: String) {
            switch rawValue {
            case "accepted": self = .accepted
            case "expired": self = .expired
            case "pending": self = .pending
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .accepted: return "accepted"
            case .expired: return "expired"
            case .pending: return "pending"
            case .unknown(let value): return value
            }
        }
    }
}
