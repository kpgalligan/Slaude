// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_thread_limit_workflow_run_error` (beta_managed_agents_thread_limit_workflow_run_error.py).

import Foundation

/// The run exceeded the limit on the number of threads that a run can create.
public struct BetaManagedAgentsThreadLimitWorkflowRunError: Codable, Hashable, Sendable {
    /// Short explanation written by the server.
    ///
    /// It never contains content from the run or its agents.
    public var message: String
    public var type: String

    public init(message: String, type: String = "thread_limit_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
