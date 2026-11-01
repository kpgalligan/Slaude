// Transformed from `anthropic.types.beta.beta_metadata_param` (beta_metadata_param.py).

import Foundation

public struct BetaMetadataParam: Codable, Hashable, Sendable {
    /// An external identifier for the user who is associated with the request.
    ///
    /// This should be a uuid, hash value, or other opaque identifier. Anthropic may use
    /// this id to help detect abuse. Do not include any identifying information such as
    /// name, email address, or phone number.
    public var userID: String??

    public init(userID: String?? = nil) {
        self.userID = userID
    }

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}
