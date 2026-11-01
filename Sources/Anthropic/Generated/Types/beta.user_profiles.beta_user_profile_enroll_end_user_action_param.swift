// Transformed from `anthropic.types.beta.user_profiles.beta_user_profile_enroll_end_user_action_param` (beta_user_profile_enroll_end_user_action_param.py).

import Foundation

/// The end-user that the profile represents enrolls in a program.
public struct BetaUserProfileEnrollEndUserActionParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enroll_end_user") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
