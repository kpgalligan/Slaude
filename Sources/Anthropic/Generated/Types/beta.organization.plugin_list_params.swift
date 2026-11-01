// Transformed from `anthropic.types.beta.organization.plugin_list_params` (plugin_list_params.py).

import Foundation

public struct PluginListParams: Codable, Hashable, Sendable {
    /// RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    public var createdAtGt: CreatedAtGt??
    /// RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    public var createdAtGte: CreatedAtGte??
    /// RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    public var createdAtLt: CreatedAtLt??
    /// RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    public var createdAtLte: CreatedAtLte??
    /// Number of items to return per page.
    ///
    /// Defaults to `20`. Ranges from `1` to `100`.
    public var limit: Int?
    /// Only Plugins in this plugin marketplace (prefixed `marketplace_`).
    public var marketplaceID: String??
    /// For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    /// parent organization's linked organizations: a child organization of that parent
    /// to read instead of the organization the key was created in, given as the
    /// organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    /// 400; an organization that is not a child of the key's parent, or where the
    /// Plugins API is not available, returns a 404. Any other key may pass only its own
    /// organization's ID here; another organization returns a 404.
    public var organizationID: String??
    /// `organization` for Plugins in the organization's plugin marketplaces, `user` for
    /// Plugins in members' personal plugin marketplaces.
    public var ownerType: OwnerType??
    /// Only Plugins in this member's personal plugin marketplaces (prefixed `user_`); a
    /// removed member's ID is accepted.
    public var ownerUserID: String??
    /// Optionally set to the `next_page` token from the previous response.
    public var page: String??
    /// This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?

    public init(createdAtGt: CreatedAtGt?? = nil, createdAtGte: CreatedAtGte?? = nil, createdAtLt: CreatedAtLt?? = nil, createdAtLte: CreatedAtLte?? = nil, limit: Int? = nil, marketplaceID: String?? = nil, organizationID: String?? = nil, ownerType: OwnerType?? = nil, ownerUserID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil) {
        self.createdAtGt = createdAtGt
        self.createdAtGte = createdAtGte
        self.createdAtLt = createdAtLt
        self.createdAtLte = createdAtLte
        self.limit = limit
        self.marketplaceID = marketplaceID
        self.organizationID = organizationID
        self.ownerType = ownerType
        self.ownerUserID = ownerUserID
        self.page = page
        self.betas = betas
    }

    enum CodingKeys: String, CodingKey {
        case createdAtGt = "created_at_gt"
        case createdAtGte = "created_at_gte"
        case createdAtLt = "created_at_lt"
        case createdAtLte = "created_at_lte"
        case limit
        case marketplaceID = "marketplace_id"
        case organizationID = "organization_id"
        case ownerType = "owner_type"
        case ownerUserID = "owner_user_id"
        case page
        case betas
    }

    public indirect enum CreatedAtGt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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

    public indirect enum CreatedAtGte: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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

    public indirect enum CreatedAtLt: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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

    public indirect enum CreatedAtLte: Codable, Hashable, Sendable, ExpressibleByStringLiteral {
        case string(String)
        case date(Date)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(stringLiteral value: String) { self = .string(value) }

        public init(from decoder: Decoder) throws {
            if let v = try? String(from: decoder) { self = .string(v); return }
            if let v = try? Date(from: decoder) { self = .date(v); return }
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

    public enum OwnerType: OpenEnum, CaseIterable {
        case organization
        case user
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [OwnerType] = [.organization, .user]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "user": self = .user
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .user: return "user"
            case .unknown(let value): return value
            }
        }
    }
}
