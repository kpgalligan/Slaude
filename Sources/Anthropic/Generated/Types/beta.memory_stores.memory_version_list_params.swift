// Transformed from `anthropic.types.beta.memory_stores.memory_version_list_params` (memory_version_list_params.py).

import Foundation

public struct MemoryVersionListParams: Codable, Hashable, Sendable {
    /// Return only versions written with the API key that has this ID.
    public var apiKeyId: String?
    /// Return versions created at or after this time (inclusive).
    public var createdAtGte: CreatedAtGte?
    /// Return versions created at or before this time (inclusive).
    public var createdAtLte: CreatedAtLte?
    /// The maximum number of versions to return per page, from 1 to 100.
    ///
    /// Defaults to 20.
    ///
    /// With `view=full`, a page holds at most 20 versions.
    public var limit: Int?
    /// Return only versions of the memory with this ID (`mem_...`).
    ///
    /// The filter still works after the memory is deleted. While that memory's versions
    /// are retained, the results include the version whose `operation` is `deleted`.
    public var memoryId: String?
    /// Return only versions that record this kind of change.
    public var operation: BetaManagedAgentsMemoryVersionOperation?
    /// The `next_page` value from a previous response, to get the next page.
    ///
    /// Omit it to get the first page.
    public var page: String?
    /// Return only versions written by the service account with this ID (`svac_...`).
    public var serviceAccountId: String?
    /// Return only versions written by the session with this ID.
    public var sessionId: String?
    /// Whether a `memory` or `memory_version` in the response includes its `content`.
    ///
    /// Defaults to `full` on retrieve operations and to `basic` on list, create, and
    /// update operations.
    ///
    /// With `full`, list operations return at most 20 items per page.
    public var view: BetaManagedAgentsMemoryView?
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

    public init(apiKeyId: String? = nil, createdAtGte: CreatedAtGte? = nil, createdAtLte: CreatedAtLte? = nil, limit: Int? = nil, memoryId: String? = nil, operation: BetaManagedAgentsMemoryVersionOperation? = nil, page: String? = nil, serviceAccountId: String? = nil, sessionId: String? = nil, view: BetaManagedAgentsMemoryView? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.apiKeyId = apiKeyId
        self.createdAtGte = createdAtGte
        self.createdAtLte = createdAtLte
        self.limit = limit
        self.memoryId = memoryId
        self.operation = operation
        self.page = page
        self.serviceAccountId = serviceAccountId
        self.sessionId = sessionId
        self.view = view
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case apiKeyId = "api_key_id"
        case createdAtGte = "created_at_gte"
        case createdAtLte = "created_at_lte"
        case limit
        case memoryId = "memory_id"
        case operation
        case page
        case serviceAccountId = "service_account_id"
        case sessionId = "session_id"
        case view
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
