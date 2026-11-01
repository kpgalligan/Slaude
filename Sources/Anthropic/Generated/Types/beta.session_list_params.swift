// Transformed from `anthropic.types.beta.session_list_params` (session_list_params.py).

import Foundation

public struct SessionListParams: Codable, Hashable, Sendable {
    /// Filter sessions created with this agent ID.
    public var agentID: String?
    /// Filter by agent version. Only applies when `agent_id` is also set.
    public var agentVersion: Int?
    /// Return sessions created after this time (exclusive).
    public var createdAtGt: CreatedAtGt?
    /// Return sessions created at or after this time (inclusive).
    public var createdAtGte: CreatedAtGte?
    /// Return sessions created before this time (exclusive).
    public var createdAtLt: CreatedAtLt?
    /// Return sessions created at or before this time (inclusive).
    public var createdAtLte: CreatedAtLte?
    /// Filter sessions created by this deployment ID.
    public var deploymentID: String?
    /// When true, includes archived sessions. Default: false (exclude archived).
    public var includeArchived: Bool?
    /// Maximum number of results to return.
    public var limit: Int?
    /// Filter sessions whose resources contain a `memory_store` with this memory store
    /// ID.
    public var memoryStoreID: String?
    /// Sort direction for results, ordered by `created_at`.
    ///
    /// Defaults to `desc` (newest first).
    public var order: Order?
    /// Opaque pagination cursor from a previous response.
    public var page: String?
    /// Filter by session status.
    ///
    /// Repeat the parameter to match any of multiple statuses.
    public var statuses: [Statuses]?
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(agentID: String? = nil, agentVersion: Int? = nil, createdAtGt: CreatedAtGt? = nil, createdAtGte: CreatedAtGte? = nil, createdAtLt: CreatedAtLt? = nil, createdAtLte: CreatedAtLte? = nil, deploymentID: String? = nil, includeArchived: Bool? = nil, limit: Int? = nil, memoryStoreID: String? = nil, order: Order? = nil, page: String? = nil, statuses: [Statuses]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.agentID = agentID
        self.agentVersion = agentVersion
        self.createdAtGt = createdAtGt
        self.createdAtGte = createdAtGte
        self.createdAtLt = createdAtLt
        self.createdAtLte = createdAtLte
        self.deploymentID = deploymentID
        self.includeArchived = includeArchived
        self.limit = limit
        self.memoryStoreID = memoryStoreID
        self.order = order
        self.page = page
        self.statuses = statuses
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case agentID = "agent_id"
        case agentVersion = "agent_version"
        case createdAtGt = "created_at_gt"
        case createdAtGte = "created_at_gte"
        case createdAtLt = "created_at_lt"
        case createdAtLte = "created_at_lte"
        case deploymentID = "deployment_id"
        case includeArchived = "include_archived"
        case limit
        case memoryStoreID = "memory_store_id"
        case order
        case page
        case statuses
        case betas
        case workspaceID = "workspace_id"
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

    public enum Statuses: OpenEnum, CaseIterable {
        case rescheduling
        case running
        case idle
        case terminated
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Statuses] = [.rescheduling, .running, .idle, .terminated]

        public init(rawValue: String) {
            switch rawValue {
            case "rescheduling": self = .rescheduling
            case "running": self = .running
            case "idle": self = .idle
            case "terminated": self = .terminated
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .rescheduling: return "rescheduling"
            case .running: return "running"
            case .idle: return "idle"
            case .terminated: return "terminated"
            case .unknown(let value): return value
            }
        }
    }
}
