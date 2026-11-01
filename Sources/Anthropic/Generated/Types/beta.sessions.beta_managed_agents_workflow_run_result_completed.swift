// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_workflow_run_result_completed` (beta_managed_agents_workflow_run_result_completed.py).

import Foundation

/// The run's plan, a program that the agent wrote, finished.
///
/// This does not say whether the work succeeded.
public struct BetaManagedAgentsWorkflowRunResultCompleted: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "completed") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
