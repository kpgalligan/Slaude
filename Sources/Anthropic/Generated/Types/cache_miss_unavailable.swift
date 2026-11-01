// Transformed from `anthropic.types.cache_miss_unavailable` (cache_miss_unavailable.py).

import Foundation

/// A `cache_miss_reason` for when the API can't give a diagnosis.
///
/// The request itself was processed normally.
///
/// This includes a request whose `model`, `system`, and `tools` match the previous request's but whose other prompt-affecting parameters, such as `thinking` or `tool_choice`, differ.
///
/// See the [cache diagnostics guide](https://platform.claude.com/docs/en/build-with-claude/cache-diagnostics#cache-miss-reason-types) to learn what to change for each reason.
public struct CacheMissUnavailable: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unavailable") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
