// Transformed from `anthropic.types.beta.organization.analytics.artifact_list_params` (artifact_list_params.py).

import Foundation

public struct ArtifactListParams: Codable, Hashable, Sendable {
    /// UTC date in YYYY-MM-DD format.
    ///
    /// The day to get artifact activity for. Data is typically available with a 1-day
    /// lag (varies by query; the error for a too-recent date names the latest available
    /// day) and may be revised by a few percent over the following days. No earlier
    /// than 2026-01-01.
    public var date: Date
    /// Filters as `dimension:value`, e.g.
    ///
    /// `filter[]=rbac_group_id:{id}`. Repeat the param for OR within a dimension and
    /// across dimensions for AND. Supported dimensions on this endpoint:
    /// `artifact_type`, `is_shared`, `product`, `rbac_group_id`, `user_id`. Value
    /// forms: `artifact_type` is a canonical artifact MIME type (e.g. `text/markdown`)
    /// or `other`; `is_shared` is `true` or `false`; `product` is
    /// `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the surfaces that
    /// create artifacts); `rbac_group_id` takes the tagged id (`rbac_group_...`, as
    /// emitted in responses and by the spend-limits API) or a bare group UUID, and
    /// matches users who held the group at any point during each covered UTC day
    /// (time-of-usage attribution); `user_id` takes a tagged user id (`user_...`), as
    /// emitted in responses. An unsupported dimension returns 400. At most 100 entries.
    /// `chat_cowork_unified` is accepted as a `product` value only on deployments that
    /// offer Chat and Cowork unified.
    public var filter: [String]??
    /// Dimensions to break results out by: `product`, `user_id` and/or `rbac_group_id`.
    ///
    /// The ungrouped artifact-type cube is finite and returned in full; grouped queries
    /// multiply the cube and paginate via `next_page`. `product` takes the values
    /// `chat_cowork_unified`, `chat`, `claude_code`, or `cowork` (the surfaces that
    /// create artifacts). `rbac_group_id` attributes a user to every group they held at
    /// any point during the requested UTC day, so grouped rows are not an exclusive
    /// partition. At most 100 entries.
    public var groupBy: [GroupBy]??
    /// Maximum rows to return (1-1000, default 100).
    ///
    /// The ungrouped artifact-type cube is finite and returned in full; `limit` is the
    /// page size only when `group_by[]` multiplies the cube.
    public var limit: Int??
    /// Opaque cursor from a previous response's `next_page` field.
    ///
    /// Only valid with `group_by[]` — the ungrouped cube is never paginated.
    public var page: String??

    public init(date: Date, filter: [String]?? = nil, groupBy: [GroupBy]?? = nil, limit: Int?? = nil, page: String?? = nil) {
        self.date = date
        self.filter = filter
        self.groupBy = groupBy
        self.limit = limit
        self.page = page
    }

    enum CodingKeys: String, CodingKey {
        case date
        case filter
        case groupBy = "group_by"
        case limit
        case page
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

    public enum GroupBy: OpenEnum, CaseIterable {
        case product
        case rbacGroupId
        case userId
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [GroupBy] = [.product, .rbacGroupId, .userId]

        public init(rawValue: String) {
            switch rawValue {
            case "product": self = .product
            case "rbac_group_id": self = .rbacGroupId
            case "user_id": self = .userId
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .product: return "product"
            case .rbacGroupId: return "rbac_group_id"
            case .userId: return "user_id"
            case .unknown(let value): return value
            }
        }
    }
}
