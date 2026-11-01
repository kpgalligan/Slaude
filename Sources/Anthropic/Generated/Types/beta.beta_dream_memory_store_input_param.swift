// Transformed from `anthropic.types.beta.beta_dream_memory_store_input_param` (beta_dream_memory_store_input_param.py).

import Foundation

/// The memory store that a dream reads, given as an entry in `inputs`.
///
/// With `output_behavior` set to `update_existing`, the dream writes its result into this memory store. Otherwise the dream doesn't change it.
public struct BetaDreamMemoryStoreInputParam: Codable, Hashable, Sendable {
    /// The ID of the memory store for the dream to read (`memstore_...`).
    ///
    /// The memory store must be in the same workspace as the dream and must not be
    /// archived.
    public var memoryStoreId: String
    public var type: String

    public init(memoryStoreId: String, type: String = "memory_store") {
        self.memoryStoreId = memoryStoreId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case type
    }
}
