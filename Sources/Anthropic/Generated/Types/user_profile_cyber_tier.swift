// Transformed from `anthropic.types.user_profile_cyber_tier` (user_profile_cyber_tier.py).

import Foundation

/// One tier of the Cyber Verification Program.
public struct UserProfileCyberTier: Codable, Hashable, Sendable {
    /// `active` when the tier applies to the profile, otherwise `inactive`.
    ///
    /// The response does not say why a tier is `inactive`: it can be in review,
    /// declined, withdrawn, never applied for, or approved but not applied to this
    /// profile.
    public var status: Status

    public init(status: Status) {
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case status
    }

    public enum Status: OpenEnum, CaseIterable {
        case active
        case inactive
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.active, .inactive]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "inactive": self = .inactive
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .inactive: return "inactive"
            case .unknown(let value): return value
            }
        }
    }
}
