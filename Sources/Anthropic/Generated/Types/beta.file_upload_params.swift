// Transformed from `anthropic.types.beta.file_upload_params` (file_upload_params.py).

import Foundation

public struct BetaFileUploadParams: Codable, Hashable, Sendable {
    /// The file to upload.
    ///
    /// Only the final path component of the part's `filename` is kept; an absent or
    /// empty `filename` is replaced with `unnamed` plus the extension for the file's
    /// stored `mime_type`, when known.
    public var file: FileUpload
    /// Seconds from upload until the file expires and its bytes become permanently
    /// unavailable. Must be between 3600 (one hour) and 7776000 (ninety days).
    public var expiresInSeconds: Int?
    /// Optional header to specify the beta version(s) you want to use.
    public var betas: [AnthropicBetaParam]?
    /// Optional header to select the Workspace for this request.
    ///
    /// The value is a Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    /// Only needed for credentials that can act on more than one Workspace. A
    /// credential that belongs to a specific Workspace may omit it; if sent, it must
    /// match that Workspace.
    public var workspaceID: String?

    public init(file: FileUpload, expiresInSeconds: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil) {
        self.file = file
        self.expiresInSeconds = expiresInSeconds
        self.betas = betas
        self.workspaceID = workspaceID
    }

    enum CodingKeys: String, CodingKey {
        case file
        case expiresInSeconds = "expires_in_seconds"
        case betas
        case workspaceID = "workspace_id"
    }
}
