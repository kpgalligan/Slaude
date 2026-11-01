// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_unknown_workflow_run_error` (beta_managed_agents_unknown_workflow_run_error.py).

import Foundation

/// A failure that has no type of its own.
public struct BetaManagedAgentsUnknownWorkflowRunError: Codable, Hashable, Sendable {
    /// Short explanation written by the server.
    ///
    /// It never contains content from the run or its agents.
    public var message: String
    public var type: String

    public init(message: String, type: String = "unknown_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
