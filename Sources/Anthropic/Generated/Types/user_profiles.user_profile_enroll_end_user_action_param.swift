// Transformed from `anthropic.types.user_profiles.user_profile_enroll_end_user_action_param` (user_profile_enroll_end_user_action_param.py).

import Foundation

/// The end-user that the profile represents enrolls in a program.
public struct UserProfileEnrollEndUserActionParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enroll_end_user") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
