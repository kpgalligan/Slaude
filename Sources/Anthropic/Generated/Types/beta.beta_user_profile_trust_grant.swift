// Transformed from `anthropic.types.beta.beta_user_profile_trust_grant` (beta_user_profile_trust_grant.py).

import Foundation

/// The status of one trust grant on a user profile, listed in the profile's `trust_grants` map under the grant's name.
public struct BetaUserProfileTrustGrant: Codable, Hashable, Sendable {
    /// Status of the trust grant.
    public var status: Status

    public init(status: Status) {
        self.status = status
    }

    enum CodingKeys: String, CodingKey {
        case status
    }

    public enum Status: OpenEnum, CaseIterable {
        case active
        case pending
        case rejected
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Status] = [.active, .pending, .rejected]

        public init(rawValue: String) {
            switch rawValue {
            case "active": self = .active
            case "pending": self = .pending
            case "rejected": self = .rejected
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .active: return "active"
            case .pending: return "pending"
            case .rejected: return "rejected"
            case .unknown(let value): return value
            }
        }
    }
}
