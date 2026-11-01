// Transformed from `anthropic.types.organization.external_key_create_params` (external_key_create_params.py).

import Foundation

public struct ExternalKeyCreateParams: Codable, Hashable, Sendable {
    /// KMS provider identity and auth coordinates.
    public var providerConfig: ExternalKeyCreateParams.ProviderConfig
    /// Human-friendly display name.
    public var displayName: String??
    /// Data residency geo. Only `us` is supported.
    public var geo: String?

    public init(providerConfig: ExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil) {
        self.providerConfig = providerConfig
        self.displayName = displayName
        self.geo = geo
    }

    enum CodingKeys: String, CodingKey {
        case providerConfig = "provider_config"
        case displayName = "display_name"
        case geo
    }
}

extension ExternalKeyCreateParams {

    public indirect enum ProviderConfig: Codable, Hashable, Sendable {
        case aws(AWSExternalKeyConfigParam)
        case gcp(GCPExternalKeyConfigParam)
        case azure(AzureExternalKeyConfigParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "aws": self = .aws(try AWSExternalKeyConfigParam(from: decoder))
            case "gcp": self = .gcp(try GCPExternalKeyConfigParam(from: decoder))
            case "azure": self = .azure(try AzureExternalKeyConfigParam(from: decoder))
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
