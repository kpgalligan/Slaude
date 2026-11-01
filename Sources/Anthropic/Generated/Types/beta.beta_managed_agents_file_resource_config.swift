// Transformed from `anthropic.types.beta.beta_managed_agents_file_resource_config` (beta_managed_agents_file_resource_config.py).

import Foundation

/// A file mounted into each session's container.
public struct BetaManagedAgentsFileResourceConfig: Codable, Hashable, Sendable {
    /// ID of a previously uploaded file.
    public var fileID: String
    public var type: String
    /// Mount path in the container. Defaults to `/mnt/session/uploads/<file_id>`.
    public var mountPath: String?

    public init(fileID: String, type: String = "file", mountPath: String? = nil) {
        self.fileID = fileID
        self.type = type
        self.mountPath = mountPath
    }

    enum CodingKeys: String, CodingKey {
        case fileID = "file_id"
        case type
        case mountPath = "mount_path"
    }
}
