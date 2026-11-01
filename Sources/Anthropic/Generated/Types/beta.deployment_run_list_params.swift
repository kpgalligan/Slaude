// Transformed from `anthropic.types.beta.deployment_run_list_params` (deployment_run_list_params.py).

import Foundation

public struct DeploymentRunListParams: Codable, Hashable, Sendable {
    /// Return runs created strictly after this time (exclusive).
    public var createdAtGt: CreatedAtGt?
    /// Return runs created at or after this time (inclusive).
    public var createdAtGte: CreatedAtGte?
    /// Return runs created strictly before this time (exclusive).
    public var createdAtLt: CreatedAtLt?
    /// Return runs created at or before this time (inclusive).
    public var createdAtLte: CreatedAtLte?
    /// Filter to a specific deployment.
    ///
    /// Omit to list across all deployments in the workspace. Filtering by a
    /// non-existent `deployment_id` returns 200 with empty data.
    public var deploymentID: String?
    /// Filter: true for runs with non-null `error`, false for runs with non-null
    /// `session_id`. Omit for all.
    public var hasError: Bool?
    /// Maximum results per page. Default 20, maximum 1000.
    public var limit: Int?
    /// Opaque pagination cursor.
    ///
    /// Pass `next_page` from the previous response. Invalid or expired cursors
    /// return 400.
    public var page: String?
    /// Filter runs by what triggered them. Omit to return all runs.
    public var triggerType: BetaManagedAgentsTriggerType?
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

    public init(createdAtGt: CreatedAtGt? = nil, createdAtGte: CreatedAtGte? = nil, createdAtLt: CreatedAtLt? = nil, createdAtLte: CreatedAtLte? = nil, deploymentID: String? = nil, hasError: Bool? = nil, limit: Int? = nil, page: String? = nil, triggerType: BetaManagedAgentsTriggerType? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.createdAtGt = createdAtGt
        self.createdAtGte = createdAtGte
        self.createdAtLt = createdAtLt
        self.createdAtLte = createdAtLte
        self.deploymentID = deploymentID
        self.hasError = hasError
        self.limit = limit
        self.page = page
        self.triggerType = triggerType
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case createdAtGt = "created_at_gt"
        case createdAtGte = "created_at_gte"
        case createdAtLt = "created_at_lt"
        case createdAtLte = "created_at_lte"
        case deploymentID = "deployment_id"
        case hasError = "has_error"
        case limit
        case page
        case triggerType = "trigger_type"
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
}
