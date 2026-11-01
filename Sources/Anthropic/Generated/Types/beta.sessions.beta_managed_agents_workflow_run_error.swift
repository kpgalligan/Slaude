// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_error` (beta_managed_agents_workflow_run_error.py).

import Foundation

public indirect enum BetaManagedAgentsWorkflowRunError: Codable, Hashable, Sendable {
    case timeoutError(BetaManagedAgentsTimeoutWorkflowRunError)
    case programError(BetaManagedAgentsProgramWorkflowRunError)
    case unknownError(BetaManagedAgentsUnknownWorkflowRunError)
    case threadLimitError(BetaManagedAgentsThreadLimitWorkflowRunError)
    case maxWorkflowRunsError(BetaManagedAgentsMaxWorkflowRunsWorkflowRunError)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "timeout_error": self = .timeoutError(try BetaManagedAgentsTimeoutWorkflowRunError(from: decoder))
        case "program_error": self = .programError(try BetaManagedAgentsProgramWorkflowRunError(from: decoder))
        case "unknown_error": self = .unknownError(try BetaManagedAgentsUnknownWorkflowRunError(from: decoder))
        case "thread_limit_error": self = .threadLimitError(try BetaManagedAgentsThreadLimitWorkflowRunError(from: decoder))
        case "max_workflow_runs_error": self = .maxWorkflowRunsError(try BetaManagedAgentsMaxWorkflowRunsWorkflowRunError(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .timeoutError(let v): try v.encode(to: encoder)
        case .programError(let v): try v.encode(to: encoder)
        case .unknownError(let v): try v.encode(to: encoder)
        case .threadLimitError(let v): try v.encode(to: encoder)
        case .maxWorkflowRunsError(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
