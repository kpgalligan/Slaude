// Transformed from `anthropic.types.beta.organization.workspaces.beta_workspace_rate_limit` (beta_workspace_rate_limit.py).

import Foundation

public struct BetaWorkspaceRateLimit: Codable, Hashable, Sendable {
    /// The rate-limit group this entry's limits apply to.
    public var group: BetaWorkspaceRateLimit.Group
    /// The workspace's limiter values for this group.
    ///
    /// By default only the limiter types with a workspace-level override are listed.
    /// With `include_inherited` set to `true`, the limiter types the workspace inherits
    /// from the organization are listed too, each marked by `source`.
    public var limits: [BetaWorkspaceRateLimitValue]
    /// Model names this entry's limits apply to, including aliases.
    ///
    /// `null` when `group.type` is not `"model_group"`. The list covers the models this
    /// workspace has access to, so it can differ between workspaces.
    public var models: [String]?
    /// The `id` of the organization's RateLimit entry this entry applies to.
    public var rateLimitId: String
    /// Object type. Always `workspace_rate_limit` for workspace rate-limit entries.
    public var type: String
    /// ID of the Workspace this entry applies to.
    public var workspaceId: String

    public init(group: BetaWorkspaceRateLimit.Group, limits: [BetaWorkspaceRateLimitValue], models: [String]? = nil, rateLimitId: String, type: String = "workspace_rate_limit", workspaceId: String) {
        self.group = group
        self.limits = limits
        self.models = models
        self.rateLimitId = rateLimitId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case group
        case limits
        case models
        case rateLimitId = "rate_limit_id"
        case type
        case workspaceId = "workspace_id"
    }
}

extension BetaWorkspaceRateLimit {

    public indirect enum Group: Codable, Hashable, Sendable {
        case modelGroup(BetaOrganizationRateLimitModelGroup)
        case batch(BetaOrganizationRateLimitBatchGroup)
        case tokenCount(BetaOrganizationRateLimitTokenCountGroup)
        case files(BetaOrganizationRateLimitFilesGroup)
        case skills(BetaOrganizationRateLimitSkillsGroup)
        case webSearch(BetaOrganizationRateLimitWebSearchGroup)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "model_group": self = .modelGroup(try BetaOrganizationRateLimitModelGroup(from: decoder))
            case "batch": self = .batch(try BetaOrganizationRateLimitBatchGroup(from: decoder))
            case "token_count": self = .tokenCount(try BetaOrganizationRateLimitTokenCountGroup(from: decoder))
            case "files": self = .files(try BetaOrganizationRateLimitFilesGroup(from: decoder))
            case "skills": self = .skills(try BetaOrganizationRateLimitSkillsGroup(from: decoder))
            case "web_search": self = .webSearch(try BetaOrganizationRateLimitWebSearchGroup(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .modelGroup(let v): try v.encode(to: encoder)
            case .batch(let v): try v.encode(to: encoder)
            case .tokenCount(let v): try v.encode(to: encoder)
            case .files(let v): try v.encode(to: encoder)
            case .skills(let v): try v.encode(to: encoder)
            case .webSearch(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
