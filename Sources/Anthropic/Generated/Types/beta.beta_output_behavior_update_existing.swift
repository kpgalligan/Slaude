// Transformed from `anthropic.types.beta.beta_output_behavior_update_existing` (beta_output_behavior_update_existing.py).

import Foundation

/// Write the result into the input memory store instead of a new memory store.
///
/// The credential must be allowed to write memory stores, or the request returns a 403 error. While another `update_existing` dream on the same memory store hasn't fully stopped, the request returns a 409 error.
public struct BetaOutputBehaviorUpdateExisting: Codable, Hashable, Sendable {
    /// The ID of the memory store for the dream to write its result to
    /// (`memstore_...`).
    ///
    /// It must be the memory store in the `memory_store` entry of `inputs`.
    public var memoryStoreId: String
    public var type: String

    public init(memoryStoreId: String, type: String = "update_existing") {
        self.memoryStoreId = memoryStoreId
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case memoryStoreId = "memory_store_id"
        case type
    }
}
