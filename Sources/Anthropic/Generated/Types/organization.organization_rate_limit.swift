// Transformed from `anthropic.types.organization.organization_rate_limit` (organization_rate_limit.py).

import Foundation

public struct OrganizationRateLimit: Codable, Hashable, Sendable {
    /// Identifier of this rate-limit entry.
    ///
    /// It is stable within the organization and differs between organizations; the
    /// group's own identifier is `group.id`. Pass it as `rate_limit_id` to set a
    /// workspace's overrides for this group.
    public var id: String
    /// The rate-limit group this entry's limits apply to.
    public var group: OrganizationRateLimit.Group
    /// The limiter values that apply to this group.
    public var limits: [OrganizationRateLimitValue]
    /// Model names this entry's limits apply to, including aliases.
    ///
    /// `null` when `group.type` is not `"model_group"`. The list covers the models your
    /// organization has access to, so it can differ between organizations.
    public var models: [String]?
    /// Object type. Always `rate_limit` for organization rate-limit entries.
    public var type: String

    public init(id: String, group: OrganizationRateLimit.Group, limits: [OrganizationRateLimitValue], models: [String]? = nil, type: String = "rate_limit") {
        self.id = id
        self.group = group
        self.limits = limits
        self.models = models
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case group
        case limits
        case models
        case type
    }
}

extension OrganizationRateLimit {

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
