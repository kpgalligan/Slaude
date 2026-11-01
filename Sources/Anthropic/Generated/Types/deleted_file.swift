// Transformed from `anthropic.types.deleted_file` (deleted_file.py).

import Foundation

public struct DeletedFile: Codable, Hashable, Sendable {
    /// ID of the deleted file.
    public var id: String
    /// Deleted object type.
    ///
    /// For file deletion, this is always `"file_deleted"`.
    public var type: String?

    public init(id: String, type: String? = nil) {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
