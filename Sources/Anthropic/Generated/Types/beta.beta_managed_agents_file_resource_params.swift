// Transformed from `anthropic.types.beta.beta_managed_agents_file_resource_params` (beta_managed_agents_file_resource_params.py).

import Foundation

/// Mount a file uploaded via the Files API into the session.
public struct BetaManagedAgentsFileResourceParams: Codable, Hashable, Sendable {
    /// ID of a previously uploaded file.
    public var fileId: String
    public var type: String
    /// Mount path in the container. Defaults to `/mnt/session/uploads/<file_id>`.
    public var mountPath: String??

    public init(fileId: String, type: String = "file", mountPath: String?? = nil) {
        self.fileId = fileId
        self.type = type
        self.mountPath = mountPath
    }

    enum CodingKeys: String, CodingKey {
        case fileId = "file_id"
        case type
        case mountPath = "mount_path"
    }
}
