// Transformed from `anthropic.types.beta.beta_managed_agents_multiagent_workflows_params` (beta_managed_agents_multiagent_workflows_params.py).

import Foundation

public indirect enum BetaManagedAgentsMultiagentWorkflowsParams: Codable, Hashable, Sendable {
    case enabled(BetaManagedAgentsMultiagentWorkflowsEnabledParams)
    case disabled(BetaManagedAgentsMultiagentWorkflowsDisabledParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaManagedAgentsMultiagentWorkflowsEnabledParams(from: decoder))
        case "disabled": self = .disabled(try BetaManagedAgentsMultiagentWorkflowsDisabledParams(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .enabled(let v): try v.encode(to: encoder)
        case .disabled(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
