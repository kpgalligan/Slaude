// Transformed from `anthropic.types.beta.memory_store_list_params` (memory_store_list_params.py).

import Foundation

public struct MemoryStoreListParams: Codable, Hashable, Sendable {
    /// Return only memory stores created at or after this time (inclusive).
    public var createdAtGte: CreatedAtGte?
    /// Return only memory stores created at or before this time (inclusive).
    public var createdAtLte: CreatedAtLte?
    /// When `true`, archived stores are included in the results.
    ///
    /// Defaults to `false` (archived stores are excluded).
    public var includeArchived: Bool?
    /// Maximum number of stores to return per page.
    ///
    /// Must be between 1 and 100. Defaults to 20 when omitted.
    public var limit: Int?
    /// The `next_page` value from a previous response, to get the next page.
    ///
    /// Omit it to get the first page.
    public var page: String?
    /// This endpoint is in beta: requests must send `agent-memory-2026-07-22` or
    /// `managed-agents-2026-04-01` in this header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(createdAtGte: CreatedAtGte? = nil, createdAtLte: CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.createdAtGte = createdAtGte
        self.createdAtLte = createdAtLte
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case createdAtGte = "created_at_gte"
        case createdAtLte = "created_at_lte"
        case includeArchived = "include_archived"
        case limit
        case page
        case betas
        case workspaceId = "workspace_id"
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
}
