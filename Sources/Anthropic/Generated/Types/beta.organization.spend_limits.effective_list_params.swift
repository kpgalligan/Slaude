// Transformed from `anthropic.types.beta.organization.spend_limits.effective_list_params` (effective_list_params.py).

import Foundation

public struct EffectiveListParams: Codable, Hashable, Sendable {
    /// Maximum number of members per page.
    ///
    /// A member's period rows never split across pages, so a page may carry more rows
    /// than this. Defaults to `20`.
    public var limit: Int?
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// Restrict the report to these limit periods.
    ///
    /// Omit to return one row per period each member resolves a spend limit for.
    public var period: [Period]??
    /// Restrict the report to these members, by tagged user ID (`user_...`).
    ///
    /// At most 100 entries.
    public var userIDs: [String]??

    public init(limit: Int? = nil, page: String?? = nil, period: [Period]?? = nil, userIDs: [String]?? = nil) {
        self.limit = limit
        self.page = page
        self.period = period
        self.userIDs = userIDs
    }

    enum CodingKeys: String, CodingKey {
        case limit
        case page
        case period
        case userIDs = "user_ids"
    }

    public enum Period: OpenEnum, CaseIterable {
        case daily
        case monthly
        case weekly
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Period] = [.daily, .monthly, .weekly]

        public init(rawValue: String) {
            switch rawValue {
            case "daily": self = .daily
            case "monthly": self = .monthly
            case "weekly": self = .weekly
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .daily: return "daily"
            case .monthly: return "monthly"
            case .weekly: return "weekly"
            case .unknown(let value): return value
            }
        }
    }
}
