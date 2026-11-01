// Transformed from `anthropic.types.beta.organization.analytics.summary_list_params` (summary_list_params.py).

import Foundation

public struct SummaryListParams: Codable, Hashable, Sendable {
    /// UTC date in YYYY-MM-DD format.
    ///
    /// Start of the date range (inclusive). Data is typically available with a 1-day
    /// lag (varies by query; the error for a too-recent date names the latest available
    /// day) and may be revised by a few percent over the following days. No earlier
    /// than 2026-01-01.
    public var startingDate: StartingDate
    /// UTC date in YYYY-MM-DD format.
    ///
    /// End of the date range (exclusive). Data is typically available with a 1-day lag,
    /// so this can be at most today — which is also the default when omitted, making
    /// the last entry cover the most recent available day. Data may be revised by a few
    /// percent over the following days. The range may span at most 366 days.
    public var endingDate: EndingDate??
    /// Filters as `dimension:value`.
    ///
    /// Only `rbac_group_id` is supported (e.g. `filter[]=rbac_group_id:{id}`); repeat
    /// the param to OR across groups. Scopes the whole day series to members of the
    /// matching group(s), re-aggregated from member-level activity — org-wide
    /// seat/invite fields and the adoption rates derived from them are null on scoped
    /// rows. `rbac_group_id` accepts the tagged id (`rbac_group_...`, as emitted in
    /// responses and by the spend-limits API) or a bare group UUID, and matches users
    /// who held the group at any point during each UTC day (time-of-usage attribution).
    /// At most 100 entries.
    public var filter: [String]??
    /// Number of results per page (1-1000, default 100).
    ///
    /// The day series (at most 366 entries) is currently returned in full in a single
    /// page, so `limit` does not yet shorten it.
    public var limit: Int??
    /// Opaque cursor from a previous response's `next_page` field.
    ///
    /// `next_page` is currently always null, so there is never a cursor to send.
    public var page: String??

    public init(startingDate: StartingDate, endingDate: EndingDate?? = nil, filter: [String]?? = nil, limit: Int?? = nil, page: String?? = nil) {
        self.startingDate = startingDate
        self.endingDate = endingDate
        self.filter = filter
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case startingDate = "starting_date"
        case endingDate = "ending_date"
        case filter
        case limit
        case page
    }

    public indirect enum StartingDate: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(ISODate)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? ISODate(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum EndingDate: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(ISODate)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? ISODate(from: decoder) { self = .date(v); return }
            self = .unknown(try _Coding.raw(decoder))
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .string(let v): try v.encode(to: encoder)
            case .date(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
