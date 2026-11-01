// Transformed from `anthropic.types.beta.dream_list_params` (dream_list_params.py).

import Foundation

public struct DreamListParams: Codable, Hashable, Sendable {
    /// Return only dreams created after this time (exclusive), in RFC 3339.
    public var createdAtGt: CreatedAtGt?
    /// Return only dreams created before this time (exclusive), in RFC 3339.
    public var createdAtLt: CreatedAtLt?
    /// Whether to include archived dreams. Defaults to `false`.
    public var includeArchived: Bool?
    /// The maximum number of dreams to return, from 1 to 100. Defaults to 20.
    public var limit: Int?
    /// The cursor for the page to return, taken from `next_page` in a previous
    /// response.
    ///
    /// Leave it out to get the first page.
    public var page: String?
    /// Return only dreams that have one of these statuses.
    ///
    /// Repeat the parameter to give more than one status. Leave it out to return dreams
    /// of every status.
    public var statuses: [BetaDreamStatus]?
    /// This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
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

    public init(createdAtGt: CreatedAtGt? = nil, createdAtLt: CreatedAtLt? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, statuses: [BetaDreamStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.createdAtGt = createdAtGt
        self.createdAtLt = createdAtLt
        self.includeArchived = includeArchived
        self.limit = limit
        self.page = page
        self.statuses = statuses
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case createdAtGt = "created_at_gt"
        case createdAtLt = "created_at_lt"
        case includeArchived = "include_archived"
        case limit
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
}
