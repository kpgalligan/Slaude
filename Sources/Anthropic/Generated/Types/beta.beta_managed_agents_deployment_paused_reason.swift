// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_paused_reason` (beta_managed_agents_deployment_paused_reason.py).

import Foundation

public indirect enum BetaManagedAgentsDeploymentPausedReason: Codable, Hashable, Sendable {
    case manual(BetaManagedAgentsManualDeploymentPausedReason)
    case error(BetaManagedAgentsErrorDeploymentPausedReason)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "manual": self = .manual(try BetaManagedAgentsManualDeploymentPausedReason(from: decoder))
        case "error": self = .error(try BetaManagedAgentsErrorDeploymentPausedReason(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .manual(let v): try v.encode(to: encoder)
        case .error(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
