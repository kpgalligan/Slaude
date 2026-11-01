// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_result_error` (beta_managed_agents_workflow_run_result_error.py).

import Foundation

/// The run failed or reached its time limit.
public struct BetaManagedAgentsWorkflowRunResultError: Codable, Hashable, Sendable {
    /// Why the run did not finish.
    public var error: BetaManagedAgentsWorkflowRunError
    public var type: String

    public init(error: BetaManagedAgentsWorkflowRunError, type: String = "error") {
        self.error = error
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case error
        case type
    }
}
