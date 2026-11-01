// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_result_stopped` (beta_managed_agents_workflow_run_result_stopped.py).

import Foundation

/// The agent stopped the run.
public struct BetaManagedAgentsWorkflowRunResultStopped: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "stopped") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
