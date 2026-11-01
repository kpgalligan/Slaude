// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_result` (beta_managed_agents_workflow_run_result.py).

import Foundation

public indirect enum BetaManagedAgentsWorkflowRunResult: Codable, Hashable, Sendable {
    case completed(BetaManagedAgentsWorkflowRunResultCompleted)
    case error(BetaManagedAgentsWorkflowRunResultError)
    case stopped(BetaManagedAgentsWorkflowRunResultStopped)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "completed": self = .completed(try BetaManagedAgentsWorkflowRunResultCompleted(from: decoder))
        case "error": self = .error(try BetaManagedAgentsWorkflowRunResultError(from: decoder))
        case "stopped": self = .stopped(try BetaManagedAgentsWorkflowRunResultStopped(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .completed(let v): try v.encode(to: encoder)
        case .error(let v): try v.encode(to: encoder)
        case .stopped(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
