// Transformed from `anthropic.types.beta.beta_dream_output` (beta_dream_output.py).

import Foundation

/// An entry in a dream's `outputs` that references the memory store holding its result.
public struct BetaDreamOutput: Codable, Hashable, Sendable {
    /// The ID of the memory store that the dream writes its result to (`memstore_...`).
    ///
    /// With `output_behavior` set to `create_new`, this is a new memory store. With
    /// `update_existing`, it is the input memory store.
    public var memoryStoreID: String
    public var type: String

    public init(memoryStoreID: String, type: String = "memory_store") {
        self.memoryStoreID = memoryStoreID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreID = "memory_store_id"
        case type
    }
}
