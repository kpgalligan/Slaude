// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_file_resource` (beta_managed_agents_file_resource.py).

import Foundation

public struct BetaManagedAgentsFileResource: Codable, Hashable, Sendable {
    public var id: String
    /// A timestamp in RFC 3339 format
    public var createdAt: Date
    public var fileId: String
    public var mountPath: String
    public var type: String
    /// A timestamp in RFC 3339 format
    public var updatedAt: Date

    public init(id: String, createdAt: Date, fileId: String, mountPath: String, type: String = "file", updatedAt: Date) {
        self.id = id
        self.createdAt = createdAt
        self.fileId = fileId
        self.mountPath = mountPath
        self.type = type
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case fileId = "file_id"
        case mountPath = "mount_path"
        case type
        case updatedAt = "updated_at"
    }
}
