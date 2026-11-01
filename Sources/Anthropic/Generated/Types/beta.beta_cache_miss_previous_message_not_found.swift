// Transformed from `anthropic.types.beta.beta_cache_miss_previous_message_not_found` (beta_cache_miss_previous_message_not_found.py).

import Foundation

/// A `cache_miss_reason` for when the API doesn't have a stored record of the request that `diagnostics.previous_message_id` references.
///
/// This doesn't mean that this request changed.
///
/// See the [cache diagnostics guide](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics#cache-miss-reason-types) to learn what to change for each reason.
public struct BetaCacheMissPreviousMessageNotFound: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "previous_message_not_found") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
