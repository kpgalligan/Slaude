// Transformed from `anthropic.types.skills.version_create_params` (version_create_params.py).

import Foundation

public struct VersionCreateParams: Codable, Hashable, Sendable {
    /// Files to upload for the skill.
    ///
    /// All files must be in the same top-level directory and must include a SKILL.md
    /// file at the root of that directory.
    public var files: [FileUpload]
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(files: [FileUpload], workspaceID: String? = nil) {
        self.files = files
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case files
        case workspaceID = "workspace_id"
    }
}
