// Transformed from `anthropic.types.beta.sessions.resource_add_params` (resource_add_params.py).

import Foundation

public struct ResourceAddParams: Codable, Hashable, Sendable {
    /// ID of a previously uploaded file.
    public var fileId: String
    public var type: String
    /// Mount path in the container. Defaults to `/mnt/session/uploads/<file_id>`.
    public var mountPath: String??
    /// This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
    /// header.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceId: String?

    public init(fileId: String, type: String = "file", mountPath: String?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceId: String? = nil) {
        self.fileId = fileId
        self.type = type
        self.mountPath = mountPath
        self.betas = betas
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
        case mountPath = "mount_path"
        case betas
        case workspaceId = "workspace_id"
    }
}
