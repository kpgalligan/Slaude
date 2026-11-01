// Transformed from `anthropic.types.beta.deployment_list_params` (deployment_list_params.py).

import Foundation

public struct DeploymentListParams: Codable, Hashable, Sendable {
    /// Filter by agent ID.
    public var agentId: String?
    /// Return deployments created at or after this time (inclusive).
    public var createdAtGte: CreatedAtGte?
    /// Return deployments created at or before this time (inclusive).
    public var createdAtLte: CreatedAtLte?
    /// When true, includes archived deployments. Default: false (exclude archived).
    public var includeArchived: Bool?
    /// Maximum results per page. Default 20, maximum 100.
    public var limit: Int?
    /// Opaque pagination cursor.
    public var page: String?
    /// Filter by status: `active` or `paused`.
    ///
    /// Omit for both. To include archived deployments, use `include_archived` instead;
    /// the two cannot be combined.
    public var status: BetaManagedAgentsDeploymentStatus?
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
    public var workspaceId: String?

    public init(agentId: String? = nil, createdAtGte: CreatedAtGte? = nil, createdAtLte: CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, status: BetaManagedAgentsDeploymentStatus? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.agentId = agentId
        self.createdAtGte = createdAtGte
        self.createdAtLte = createdAtLte
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
        self.status = status
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case agentId = "agent_id"
        case createdAtGte = "created_at_gte"
        case createdAtLte = "created_at_lte"
        case includeArchived = "include_archived"
        case limit
        case page
        case status
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
