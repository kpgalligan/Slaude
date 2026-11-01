// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_program_workflow_run_error` (beta_managed_agents_program_workflow_run_error.py).

import Foundation

/// The plan, a program that the agent wrote, failed, or the server refused it.
public struct BetaManagedAgentsProgramWorkflowRunError: Codable, Hashable, Sendable {
    /// Short explanation written by the server.
    ///
    /// It never contains content from the run or its agents.
    public var message: String
    public var type: String

    public init(message: String, type: String = "program_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
