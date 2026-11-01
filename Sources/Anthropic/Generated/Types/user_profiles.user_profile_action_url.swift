// Transformed from `anthropic.types.user_profiles.user_profile_action_url` (user_profile_action_url.py).

import Foundation

/// A URL to give to the person who takes the requested action.
public struct UserProfileActionURL: Codable, Hashable, Sendable {
    /// When the URL stops working, in RFC 3339 format.
    public var expiresAt: Date
    /// Object type. Always `user_profile_action_url`.
    public var type: String
    /// The URL to give to the person who takes the action.
    ///
    /// Anyone who holds it can open it until `expires_at`.
    public var url: String

    public init(expiresAt: Date, type: String = "user_profile_action_url", url: String) {
        self.expiresAt = expiresAt
        self.type = type
        self.url = url
    }

    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case type
        case url
    }
}
