// Transformed from `anthropic.types.organization.workspaces.workspace_rate_limit` (workspace_rate_limit.py).

import Foundation

public struct WorkspaceRateLimit: Codable, Hashable, Sendable {
    /// The rate-limit group this entry's limits apply to.
    public var group: WorkspaceRateLimit.Group
    /// The workspace's limiter values for this group.
    ///
    /// By default only the limiter types with a workspace-level override are listed.
    /// With `include_inherited` set to `true`, the limiter types the workspace inherits
    /// from the organization are listed too, each marked by `source`.
    public var limits: [WorkspaceRateLimitValue]
    /// Model names this entry's limits apply to, including aliases.
    ///
    /// `null` when `group.type` is not `"model_group"`. The list covers the models this
    /// workspace has access to, so it can differ between workspaces.
    public var models: [String]?
    /// The `id` of the organization's RateLimit entry this entry applies to.
    public var rateLimitID: String
    /// Object type. Always `workspace_rate_limit` for workspace rate-limit entries.
    public var type: String
    /// ID of the Workspace this entry applies to.
    public var workspaceID: String

    public init(group: WorkspaceRateLimit.Group, limits: [WorkspaceRateLimitValue], models: [String]? = nil, rateLimitID: String, type: String = "workspace_rate_limit", workspaceID: String) {
        self.group = group
        self.limits = limits
        self.models = models
        self.rateLimitID = rateLimitID
        self.type = type
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case group
        case limits
        case models
        case rateLimitID = "rate_limit_id"
        case type
        case workspaceID = "workspace_id"
    }
}

extension WorkspaceRateLimit {

    public indirect enum Group: Codable, Hashable, Sendable {
        case modelGroup(OrganizationRateLimitModelGroup)
        case batch(OrganizationRateLimitBatchGroup)
        case tokenCount(OrganizationRateLimitTokenCountGroup)
        case files(OrganizationRateLimitFilesGroup)
        case skills(OrganizationRateLimitSkillsGroup)
        case webSearch(OrganizationRateLimitWebSearchGroup)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "model_group": self = .modelGroup(try OrganizationRateLimitModelGroup(from: decoder))
            case "batch": self = .batch(try OrganizationRateLimitBatchGroup(from: decoder))
            case "token_count": self = .tokenCount(try OrganizationRateLimitTokenCountGroup(from: decoder))
            case "files": self = .files(try OrganizationRateLimitFilesGroup(from: decoder))
            case "skills": self = .skills(try OrganizationRateLimitSkillsGroup(from: decoder))
            case "web_search": self = .webSearch(try OrganizationRateLimitWebSearchGroup(from: decoder))
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
