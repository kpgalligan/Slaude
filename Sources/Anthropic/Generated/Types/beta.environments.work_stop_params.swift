// Transformed from `anthropic.types.beta.environments.work_stop_params` (work_stop_params.py).

import Foundation

public struct WorkStopParams: Codable, Hashable, Sendable {
    public var environmentId: String
    /// If true, immediately stop work without graceful shutdown
    public var force: Bool?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(environmentId: String, force: Bool? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.environmentId = environmentId
        self.force = force
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case environmentId = "environment_id"
        case force
        case betas
        case workspaceId = "workspace_id"
    }
}
