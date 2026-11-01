// Transformed from `anthropic.types.beta.organization.analytics.user_list_params` (user_list_params.py).

import Foundation

public struct BetaOrganizationAnalyticsUserListParams: Codable, Hashable, Sendable {
    /// UTC date in YYYY-MM-DD format.
    ///
    /// The day to get user activity for. Data is typically available with a 1-day lag
    /// (varies by query; the error for a too-recent date names the latest available
    /// day) and may be revised by a few percent over the following days. No earlier
    /// than 2026-01-01.
    public var date: Date??
    /// UTC date in YYYY-MM-DD format.
    ///
    /// End of the date range (exclusive); only valid with `starting_date`. Data is
    /// typically available with a 1-day lag (varies by query; the error for a
    /// too-recent date names the latest available day), so this can be at most today —
    /// which is also the default when omitted, resolved once when the first page is
    /// served and reused for the rest of the pagination sequence. At most 366 days
    /// after `starting_date`.
    public var endingDate: EndingDate??
    /// Filters as `dimension:value`, e.g.
    ///
    /// `filter[]=rbac_group_id:{id}`. Repeat the param for OR within a dimension and
    /// across dimensions for AND. Supported dimensions on this endpoint: `project_id`,
    /// `rbac_group_id`, `user_id`. Value forms: `project_id` takes a tagged project id
    /// (`claude_proj_...`); `rbac_group_id` takes the tagged id (`rbac_group_...`, as
    /// emitted in responses and by the spend-limits API) or a bare group UUID, and
    /// matches users who held the group at any point during each covered UTC day
    /// (time-of-usage attribution); `user_id` takes a tagged user id (`user_...`), as
    /// emitted in responses. An unsupported dimension returns 400. At most 100 entries.
    /// A `project_id` filter limits each member's row to their claude.ai chat activity
    /// in that project and cannot be combined with `group_by[]` or an `rbac_group_id`
    /// filter. On these rows, every count in `chat_cowork_unified_metrics.sessions` is
    /// 0, because sessions are not measured per project. On any day a member sent a
    /// chat message in Chat and Cowork unified, all of that member's project activity
    /// for the day is counted in `chat_cowork_unified_metrics.chat` instead of
    /// `chat_metrics`.
    public var filter: [String]??
    /// Dimensions to break results out by (e.g.
    ///
    /// `group_by[]=rbac_group_id`). Supported on this endpoint: `rbac_group_id`. Rows
    /// are already per-member, so the one supported grouping aggregates them per RBAC
    /// group instead. Grouped rows carry the requested dimension values as additional
    /// fields and paginate like ungrouped responses via `next_page`; an unsupported
    /// dimension returns 400. `rbac_group_id` attributes a user to every group they
    /// held at any point during each covered UTC day, so grouped rows are not an
    /// exclusive partition and can sum above org-level totals. At most 100 entries.
    public var groupBy: [String]??
    /// Number of results per page (1-1000, default 100).
    public var limit: Int??
    /// Sort direction: `asc` or `desc`.
    ///
    /// Defaults to `asc` for the endpoint's sort column and to `desc` when `order_by`
    /// names a metric (a top-N ranking). Applies to `order_by`, or to the endpoint's
    /// default sort field when `order_by` is omitted.
    public var order: Order??
    /// Sort field.
    ///
    /// Restricted to the endpoint's sort column plus its rankable metrics (metrics
    /// default to descending; a few metrics rank in date-range mode only, per the
    /// endpoint's documented orderable set).
    public var orderBy: String??
    /// Opaque cursor from a previous response's `next_page` field.
    public var page: String??
    /// UTC date in YYYY-MM-DD format.
    ///
    /// Start of a date range (inclusive). Enables rollup mode: one row per entity
    /// aggregated over the whole range — addable counters are summed across days, and a
    /// distinct count is never summed where summing could double-count (a field's range
    /// value is recomputed exactly over the window, approximate via HLL with typical
    /// error under 2%, null, or — for the creation-event counts, whose per-day values
    /// cannot overlap — a per-day sum that is itself exact; each field's own
    /// description says which). Use either `date` or `starting_date`, not both. Data is
    /// typically available with a 1-day lag (varies by query; the error for a
    /// too-recent date names the latest available day) and may be revised by a few
    /// percent over the following days. No earlier than 2026-01-01.
    public var startingDate: StartingDate??

    public init(date: Date?? = nil, endingDate: EndingDate?? = nil, filter: [String]?? = nil, groupBy: [String]?? = nil, limit: Int?? = nil, order: Order?? = nil, orderBy: String?? = nil, page: String?? = nil, startingDate: StartingDate?? = nil) {
        self.date = date
        self.endingDate = endingDate
        self.filter = filter
        self.groupBy = groupBy
        self.limit = limit
        self.order = order
        self.orderBy = orderBy
        self.page = page
        self.startingDate = startingDate
    }

    enum CodingKeys: String, CodingKey {
        case date
        case endingDate = "ending_date"
        case filter
        case groupBy = "group_by"
        case limit
        case order
        case orderBy = "order_by"
        case page
        case startingDate = "starting_date"
    }

    public indirect enum Date: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
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

    public enum Order: OpenEnum, CaseIterable {
        case asc
        case desc
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Order] = [.asc, .desc]

        public init(rawValue: String) {
            switch rawValue {
            case "asc": self = .asc
            case "desc": self = .desc
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .asc: return "asc"
            case .desc: return "desc"
            case .unknown(let value): return value
            }
        }
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
}
