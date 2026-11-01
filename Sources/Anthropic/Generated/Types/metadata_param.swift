// Transformed from `anthropic.types.metadata_param` (metadata_param.py).

import Foundation

public struct MetadataParam: Codable, Hashable, Sendable {
    /// An external identifier for the user who is associated with the request.
    ///
    /// This should be a uuid, hash value, or other opaque identifier. Anthropic may use
    /// this id to help detect abuse. Do not include any identifying information such as
    /// name, email address, or phone number.
    public var userId: String??

    public init(userId: String?? = nil) {
        self.userId = userId
    }

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
}
