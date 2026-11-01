// Transformed from `anthropic.types.browser_toolset_20260801_param` (browser_toolset_20260801_param.py).

import Foundation

/// The browser toolset: a single ``tools[]`` entry (carrying no
/// ``name``) that declares the browser tool family. The model is served
/// the family's tool with any members disabled via ``configs`` removed
/// from its schema.
public struct BrowserToolset20260801Param: Codable, Hashable, Sendable {
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    /// Sparse per-member overrides, keyed by member name.
    ///
    /// Absent, null, and {} are equivalent; a member's defaults apply wherever its key
    /// is absent.
    public var configs: BrowserToolsetConfigsParam??

    public init(type: String = "browser_toolset_20260801", cacheControl: CacheControlEphemeralParam?? = nil, configs: BrowserToolsetConfigsParam?? = nil) {
        self.type = type
        self.cacheControl = cacheControl
        self.configs = configs
    }

    enum CodingKeys: String, CodingKey {
        case type
        case cacheControl = "cache_control"
        case configs
    }
}
