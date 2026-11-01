// Transformed from `anthropic.types.beta.beta_cache_miss_messages_changed` (beta_cache_miss_messages_changed.py).

import Foundation

/// A `cache_miss_reason` for a request whose `messages` differ from the previous request's in an earlier entry, instead of only having entries appended. The `model`, `system`, and `tools` match.
///
/// See the [cache diagnostics guide](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics#cache-miss-reason-types) to learn what to change for each reason.
public struct BetaCacheMissMessagesChanged: Codable, Hashable, Sendable {
    /// Approximate number of input tokens that would have been read from cache had the
    /// prefix matched the previous request.
    public var cacheMissedInputTokens: Int
    public var type: String

    public init(cacheMissedInputTokens: Int, type: String = "messages_changed") {
        self.cacheMissedInputTokens = cacheMissedInputTokens
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case cacheMissedInputTokens = "cache_missed_input_tokens"
        case type
    }
}
