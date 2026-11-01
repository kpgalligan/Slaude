// Transformed from `anthropic.types.user_profile_cyber_program` (user_profile_cyber_program.py).

import Foundation

/// A user profile's standing in the Cyber Verification Program, which relaxes cyber safeguards for requests that name the profile.
public struct UserProfileCyberProgram: Codable, Hashable, Sendable {
    /// What a request that names the profile must allow to get the relaxed safeguards
    /// of every `active` tier. `null` when no tier is `active`, and wherever `tiers` is
    /// `{}`.
    public var requirements: UserProfileCyberRequirements?
    /// `active` when at least one tier is `active`, or when the profile has the
    /// program's access to earlier models. That access is not a tier: a profile that
    /// has it alone reads `active` with every tier `inactive`, or with `tiers` `{}` on
    /// a response that does not report tiers. When nothing is `active`, `pending` means
    /// that an application or enrollment is under review, or that what Anthropic
    /// approved does not yet apply to this profile, and `rejected` means that the
    /// application or enrollment was declined.
    public var status: UserProfileProgramStatus
    /// The program's tiers, keyed by tier: `a` (Specialized Access), `b` (Red Team
    /// Access) and `c` (Defense Access). A response reports either every tier or none.
    /// When it reports them, as retrieving the profile normally does, every tier has a
    /// key, whether or not it applies to the profile. When it does not, as in the list
    /// of user profiles, `tiers` is `{}`, which does not mean that the tiers are
    /// inactive. No tier implies another, so read the tier you need. Anthropic may add
    /// tiers; ignore a key you do not recognize.
    public var tiers: [String: UserProfileCyberTier]

    public init(requirements: UserProfileCyberRequirements? = nil, status: UserProfileProgramStatus, tiers: [String: UserProfileCyberTier]) {
        self.requirements = requirements
        self.status = status
        self.tiers = tiers
    }

    enum CodingKeys: String, CodingKey {
        case requirements
        case status
        case tiers
    }
}
