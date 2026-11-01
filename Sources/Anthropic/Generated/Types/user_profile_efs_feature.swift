// Transformed from `anthropic.types.user_profile_efs_feature` (user_profile_efs_feature.py).

import Foundation

/// One feature of Enterprise Frontier Safeguards.
public struct UserProfileEfsFeature: Codable, Hashable, Sendable {
    /// `active` when Anthropic has approved the entity the profile represents to use
    /// the feature, otherwise `inactive`. `active` does not mean that the feature is
    /// set up or switched on, which is a separate step.
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
