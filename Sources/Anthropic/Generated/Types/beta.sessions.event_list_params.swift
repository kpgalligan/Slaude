// Transformed from `anthropic.types.beta.sessions.event_list_params` (event_list_params.py).

import Foundation

public struct EventListParams: Codable, Hashable, Sendable {
    /// Return events created after this time (exclusive).
    ///
    /// Compared against the event's `processed_at` value.
    public var createdAtGt: CreatedAtGt?
    /// Return events created at or after this time (inclusive).
    ///
    /// Compared against the event's `processed_at` value.
    public var createdAtGte: CreatedAtGte?
    /// Return events created before this time (exclusive).
    ///
    /// Compared against the event's `processed_at` value.
    public var createdAtLt: CreatedAtLt?
    /// Return events created at or before this time (inclusive).
    ///
    /// Compared against the event's `processed_at` value.
    public var createdAtLte: CreatedAtLte?
    public var limit: Int?
    /// Sort direction for results, ordered by the event's `processed_at`.
    ///
    /// Defaults to `asc` (chronological).
    public var order: Order?
    /// Opaque pagination cursor from a previous response's `next_page`.
    public var page: String?
    /// Filter by event type.
    ///
    /// Values match the `type` field on returned events (for example, `user.message` or
    /// `agent.tool_use`). Omit to return all event types.
    public var types: [BetaManagedAgentsSessionEventType]?
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

    public init(createdAtGt: CreatedAtGt? = nil, createdAtGte: CreatedAtGte? = nil, createdAtLt: CreatedAtLt? = nil, createdAtLte: CreatedAtLte? = nil, limit: Int? = nil, order: Order? = nil, page: String? = nil, types: [BetaManagedAgentsSessionEventType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.createdAtGt = createdAtGt
        self.createdAtGte = createdAtGte
        self.createdAtLt = createdAtLt
        self.createdAtLte = createdAtLte
        self.limit = limit
        self.order = order
        self.page = page
        self.types = types
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case createdAtGt = "created_at_gt"
        case createdAtGte = "created_at_gte"
        case createdAtLt = "created_at_lt"
        case createdAtLte = "created_at_lte"
        case limit
        case order
        case page
        case types
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
}
