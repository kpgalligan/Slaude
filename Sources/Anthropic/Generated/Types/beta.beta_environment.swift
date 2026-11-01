// Transformed from `anthropic.types.beta.beta_environment` (beta_environment.py).

import Foundation

/// Unified Environment resource for both cloud and self-hosted environments.
public struct BetaEnvironment: Codable, Hashable, Sendable {
    /// Environment identifier (e.g., 'env\__...')
    public var id: String
    /// RFC 3339 timestamp when environment was archived, or null if not archived
    public var archivedAt: String?
    /// Environment configuration (either Anthropic Cloud or self-hosted)
    public var config: BetaEnvironment.Config
    /// RFC 3339 timestamp when environment was created
    public var createdAt: String
    /// User-provided description for the environment; null when unset
    public var description: String?
    /// User-provided metadata key-value pairs
    public var metadata: [String: String]
    /// Human-readable name for the environment
    public var name: String
    /// The type of object (always 'environment')
    public var type: String
    /// RFC 3339 timestamp when environment was last updated
    public var updatedAt: String
    /// The visibility scope for this environment.
    ///
    /// 'organization' means visible to all accounts. 'account' means visible only to
    /// the owning account.
    public var scope: Scope?

    public init(id: String, archivedAt: String? = nil, config: BetaEnvironment.Config, createdAt: String, description: String? = nil, metadata: [String: String], name: String, type: String = "environment", updatedAt: String, scope: Scope? = nil) {
        self.id = id
        self.archivedAt = archivedAt
        self.config = config
        self.createdAt = createdAt
        self.description = description
        self.metadata = metadata
        self.name = name
        self.type = type
        self.updatedAt = updatedAt
        self.scope = scope
    }

    enum CodingKeys: String, CodingKey {
        case id
        case archivedAt = "archived_at"
        case config
        case createdAt = "created_at"
        case description
        case metadata
        case name
        case type
        case updatedAt = "updated_at"
        case scope
    }

    public enum Scope: OpenEnum, CaseIterable {
        case organization
        case account
        /// A value this version of the SDK doesn't know about.
        case unknown(String)

        public static let allCases: [Scope] = [.organization, .account]

        public init(rawValue: String) {
            switch rawValue {
            case "organization": self = .organization
            case "account": self = .account
            default: self = .unknown(rawValue)
            }
        }

        public var rawValue: String {
            switch self {
            case .organization: return "organization"
            case .account: return "account"
            case .unknown(let value): return value
            }
        }
    }
}

extension BetaEnvironment {

    public indirect enum Config: Codable, Hashable, Sendable {
        case cloud(BetaCloudConfig)
        case selfHosted(BetaSelfHostedConfig)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "cloud": self = .cloud(try BetaCloudConfig(from: decoder))
            case "self_hosted": self = .selfHosted(try BetaSelfHostedConfig(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .cloud(let v): try v.encode(to: encoder)
            case .selfHosted(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
