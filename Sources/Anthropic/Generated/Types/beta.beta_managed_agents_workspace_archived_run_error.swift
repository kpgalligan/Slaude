// Transformed from `anthropic.types.beta.beta_managed_agents_workspace_archived_run_error` (beta_managed_agents_workspace_archived_run_error.py).

import Foundation

/// The deployment's workspace was archived.
public struct BetaManagedAgentsWorkspaceArchivedRunError: Codable, Hashable, Sendable {
    /// Human-readable error description.
    public var message: String
    public var type: String

    public init(message: String, type: String = "workspace_archived_error") {
        self.message = message
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case message
        case type
    }
}
