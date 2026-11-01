// Transformed from `anthropic.types.beta.organization.external_key_create_params` (external_key_create_params.py).

import Foundation

public struct BetaOrganizationExternalKeyCreateParams: Codable, Hashable, Sendable {
    /// KMS provider identity and auth coordinates.
    public var providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig
    /// Human-friendly display name.
    public var displayName: String??
    /// Data residency geo. Only `us` is supported.
    public var geo: String?

    public init(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig, displayName: String?? = nil, geo: String? = nil) {
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

extension BetaOrganizationExternalKeyCreateParams {

    public indirect enum ProviderConfig: Codable, Hashable, Sendable {
        case aws(BetaAWSExternalKeyConfigParam)
        case gcp(BetaGCPExternalKeyConfigParam)
        case azure(BetaAzureExternalKeyConfigParam)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "aws": self = .aws(try BetaAWSExternalKeyConfigParam(from: decoder))
            case "gcp": self = .gcp(try BetaGCPExternalKeyConfigParam(from: decoder))
            case "azure": self = .azure(try BetaAzureExternalKeyConfigParam(from: decoder))
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
