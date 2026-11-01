// Transformed from `anthropic.types.beta.beta_browser_toolset_20260801` (beta_browser_toolset_20260801.py).

import Foundation

/// The browser toolset: a single ``tools[]`` entry (carrying no
/// ``name``) that declares the browser tool family. The model is served
/// the family's tool with any members disabled via ``configs`` removed
/// from its schema.
public struct BetaBrowserToolset20260801: Codable, Hashable, Sendable {
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeral?
    /// Sparse per-member overrides, keyed by member name.
    ///
    /// Absent, null, and {} are equivalent; a member's defaults apply wherever its key
    /// is absent.
    public var configs: BetaBrowserToolsetConfigs?

    public init(type: String = "browser_toolset_20260801", cacheControl: BetaCacheControlEphemeral? = nil, configs: BetaBrowserToolsetConfigs? = nil) {
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
