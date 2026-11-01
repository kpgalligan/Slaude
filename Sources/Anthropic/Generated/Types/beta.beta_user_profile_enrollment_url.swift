// Transformed from `anthropic.types.beta.beta_user_profile_enrollment_url` (beta_user_profile_enrollment_url.py).

import Foundation

/// A URL to give to the entity that a user profile represents, so that the entity can enroll in a program.
public struct BetaUserProfileEnrollmentURL: Codable, Hashable, Sendable {
    /// When this enrollment URL expires, in RFC 3339 format.
    public var expiresAt: Date
    /// Object type. Always `enrollment_url`.
    public var type: String
    /// Enrollment URL to send to the end user. Valid until `expires_at`.
    public var url: String

    public init(expiresAt: Date, type: String = "enrollment_url", url: String) {
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
