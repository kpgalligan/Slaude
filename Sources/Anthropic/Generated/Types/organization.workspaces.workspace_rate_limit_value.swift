// Transformed from `anthropic.types.organization.workspaces.workspace_rate_limit_value` (workspace_rate_limit_value.py).

import Foundation

public struct WorkspaceRateLimitValue: Codable, Hashable, Sendable {
    /// The organization-level value for the same limiter type, for reference.
    ///
    /// `null` when the organization has no limit configured for this limiter type.
    public var orgLimit: Int?
    /// Where `value` comes from.
    ///
    /// `organization` values are listed only when `include_inherited` is `true`, and
    /// then `value` equals `org_limit`.
    public var source: WorkspaceRateLimitValue.Source
    /// The limiter type (for example, `requests_per_minute` or
    /// `input_tokens_per_minute`).
    public var type: String
    /// The workspace's value for this limiter type: the workspace-level override when
    /// `source.type` is `workspace`, otherwise the organization's value.
    public var value: Int

    public init(orgLimit: Int? = nil, source: WorkspaceRateLimitValue.Source, type: String, value: Int) {
        self.orgLimit = orgLimit
        self.source = source
        self.type = type
        self.value = value
    }

    enum CodingKeys: String, CodingKey {
        case orgLimit = "org_limit"
        case source
        case type
        case value
    }
}

extension WorkspaceRateLimitValue {

    public indirect enum Source: Codable, Hashable, Sendable {
        case workspace(WorkspaceRateLimitWorkspaceSource)
        case organization(WorkspaceRateLimitOrganizationSource)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "workspace": self = .workspace(try WorkspaceRateLimitWorkspaceSource(from: decoder))
            case "organization": self = .organization(try WorkspaceRateLimitOrganizationSource(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .workspace(let v): try v.encode(to: encoder)
            case .organization(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
