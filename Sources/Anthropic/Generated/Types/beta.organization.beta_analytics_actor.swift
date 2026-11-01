// Transformed from `anthropic.types.beta.organization.beta_analytics_actor` (beta_analytics_actor.py).

import Foundation

public indirect enum BetaAnalyticsActor: Codable, Hashable, Sendable {
    case userActor(BetaAnalyticsReportUserActor)
    case serviceAccountActor(BetaAnalyticsServiceAccountActor)
    case federatedActor(BetaAnalyticsFederatedActor)
    case apiActor(BetaAnalyticsAPIActor)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "user_actor": self = .userActor(try BetaAnalyticsReportUserActor(from: decoder))
        case "service_account_actor": self = .serviceAccountActor(try BetaAnalyticsServiceAccountActor(from: decoder))
        case "federated_actor": self = .federatedActor(try BetaAnalyticsFederatedActor(from: decoder))
        case "api_actor": self = .apiActor(try BetaAnalyticsAPIActor(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .userActor(let v): try v.encode(to: encoder)
        case .serviceAccountActor(let v): try v.encode(to: encoder)
        case .federatedActor(let v): try v.encode(to: encoder)
        case .apiActor(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
