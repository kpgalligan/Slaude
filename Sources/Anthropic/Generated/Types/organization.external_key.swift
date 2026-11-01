// Transformed from `anthropic.types.organization.external_key` (external_key.py).

import Foundation

/// CMEK external key config belonging to the caller's organization.
///
/// Configs are organization-scoped. Workspaces attach to a config; once any
/// workspace references it, the provider fields become effectively immutable
/// (existing encrypted data needs the config for decrypt).
public struct ExternalKey: Codable, Hashable, Sendable {
    /// Identifier of the external key config.
    ///
    /// A tagged ID prefixed `ekey_`, or — for organizations on the Claude Platform on
    /// AWS — the AWS KMS key ARN.
    public var id: String
    /// Whether any workspace uses this config to encrypt its data — counting live and
    /// archived workspaces (an archived workspace's data remains encrypted under the
    /// config), excluding deleted ones. Only an attached config is used by the
    /// encryption path; an `unattached` config is inert and can be deleted.
    public var attachment: ExternalKey.Attachment
    public var createdAt: Date
    /// Human-friendly display name. Null if none was set.
    public var displayName: String?
    /// Data residency geo.
    ///
    /// Selects the region that handles this key's encrypt/decrypt roundtrips.
    public var geo: String
    /// KMS provider identity and auth coordinates.
    public var providerConfig: ExternalKey.ProviderConfig
    public var type: String
    public var updatedAt: Date

    public init(id: String, attachment: ExternalKey.Attachment, createdAt: Date, displayName: String? = nil, geo: String, providerConfig: ExternalKey.ProviderConfig, type: String = "external_key", updatedAt: Date) {
        self.id = id
        self.attachment = attachment
        self.createdAt = createdAt
        self.displayName = displayName
        self.geo = geo
        self.providerConfig = providerConfig
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case attachment
        case createdAt = "created_at"
        case displayName = "display_name"
        case geo
        case providerConfig = "provider_config"
        case type
        case updatedAt = "updated_at"
    }
}

extension ExternalKey {

    public indirect enum Attachment: Codable, Hashable, Sendable {
        case attached(ExternalKeyAttachedAttachment)
        case unattached(ExternalKeyUnattachedAttachment)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "attached": self = .attached(try ExternalKeyAttachedAttachment(from: decoder))
            case "unattached": self = .unattached(try ExternalKeyUnattachedAttachment(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .attached(let v): try v.encode(to: encoder)
            case .unattached(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }

    public indirect enum ProviderConfig: Codable, Hashable, Sendable {
        case aws(AWSExternalKeyConfig)
        case gcp(GCPExternalKeyConfig)
        case azure(AzureExternalKeyConfig)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "aws": self = .aws(try AWSExternalKeyConfig(from: decoder))
            case "gcp": self = .gcp(try GCPExternalKeyConfig(from: decoder))
            case "azure": self = .azure(try AzureExternalKeyConfig(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .aws(let v): try v.encode(to: encoder)
            case .gcp(let v): try v.encode(to: encoder)
            case .azure(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
