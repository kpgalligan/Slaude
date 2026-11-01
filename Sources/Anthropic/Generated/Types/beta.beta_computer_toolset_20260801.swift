// Transformed from `anthropic.types.beta.beta_computer_toolset_20260801` (beta_computer_toolset_20260801.py).

import Foundation

/// The computer toolset: a single ``tools[]`` entry (carrying no
/// ``name``) that declares the computer tool family. The model is
/// served the family's tool with any members disabled via ``configs``
/// removed from its schema. Every member is enabled by default, zoom
/// included. The single-tool options ``display_number`` and
/// ``enable_zoom`` are not fields of a toolset entry — it carries only
/// ``type``, ``configs``, and ``cache_control``; zoom is controlled
/// via ``configs.zoom.enabled``.
public struct BetaComputerToolset20260801: Codable, Hashable, Sendable {
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: BetaCacheControlEphemeral?
    /// Sparse per-member overrides, keyed by member name.
    ///
    /// Absent, null, and {} are equivalent; a member's defaults apply wherever its key
    /// is absent.
    public var configs: BetaComputerToolsetConfigs?

    public init(type: String = "computer_toolset_20260801", cacheControl: BetaCacheControlEphemeral? = nil, configs: BetaComputerToolsetConfigs? = nil) {
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
