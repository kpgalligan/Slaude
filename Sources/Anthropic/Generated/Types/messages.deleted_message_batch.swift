// Transformed from `anthropic.types.messages.deleted_message_batch` (deleted_message_batch.py).

import Foundation

public struct DeletedMessageBatch: Codable, Hashable, Sendable {
    /// ID of the Message Batch.
    public var id: String
    /// Deleted object type.
    ///
    /// For Message Batches, this is always `"message_batch_deleted"`.
    public var type: String

    public init(id: String, type: String = "message_batch_deleted") {
        self.id = id
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }
}
