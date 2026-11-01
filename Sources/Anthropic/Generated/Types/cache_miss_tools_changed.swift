// Transformed from `anthropic.types.cache_miss_tools_changed` (cache_miss_tools_changed.py).

import Foundation

/// A `cache_miss_reason` for a request whose `tools` differ from the previous request's, for example because tools were added, removed, or reordered.
///
/// See the [cache diagnostics guide](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics#cache-miss-reason-types) to learn what to change for each reason.
public struct CacheMissToolsChanged: Codable, Hashable, Sendable {
    /// Approximate number of input tokens that would have been read from cache had the
    /// prefix matched the previous request.
    public var cacheMissedInputTokens: Int
    public var type: String

    public init(cacheMissedInputTokens: Int, type: String = "tools_changed") {
        self.cacheMissedInputTokens = cacheMissedInputTokens
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case cacheMissedInputTokens = "cache_missed_input_tokens"
        case type
    }
}
