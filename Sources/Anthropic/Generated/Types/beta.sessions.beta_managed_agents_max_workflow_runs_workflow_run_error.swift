// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_max_workflow_runs_workflow_run_error` (beta_managed_agents_max_workflow_runs_workflow_run_error.py).

import Foundation

/// No run was created, because the session was at its limit of open workflow runs, which are runs that have not ended. Only `workflow_run.error` carries this type.
public struct BetaManagedAgentsMaxWorkflowRunsWorkflowRunError: Codable, Hashable, Sendable {
    /// Short explanation written by the server.
    ///
    /// It never contains content from the run or its agents.
    public var message: String
    public var type: String

    public init(message: String, type: String = "max_workflow_runs_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
