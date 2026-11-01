// Transformed from `anthropic.types.beta.organization.beta_analytics_federated_actor_provider` (beta_analytics_federated_actor_provider.py).

import Foundation

public indirect enum BetaAnalyticsFederatedActorProvider: Codable, Hashable, Sendable {
    case aws(BetaAnalyticsFederatedActorAWSProvider)
    case azure(BetaAnalyticsFederatedActorAzureProvider)
    case gcp(BetaAnalyticsFederatedActorGCPProvider)
    case oidc(BetaAnalyticsFederatedActorOIDCProvider)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "aws": self = .aws(try BetaAnalyticsFederatedActorAWSProvider(from: decoder))
        case "azure": self = .azure(try BetaAnalyticsFederatedActorAzureProvider(from: decoder))
        case "gcp": self = .gcp(try BetaAnalyticsFederatedActorGCPProvider(from: decoder))
        case "oidc": self = .oidc(try BetaAnalyticsFederatedActorOIDCProvider(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .aws(let v): try v.encode(to: encoder)
        case .azure(let v): try v.encode(to: encoder)
        case .gcp(let v): try v.encode(to: encoder)
        case .oidc(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
