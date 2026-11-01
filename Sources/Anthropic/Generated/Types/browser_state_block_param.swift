// Transformed from `anthropic.types.browser_state_block_param` (browser_state_block_param.py).

import Foundation

/// The caller's browser state after a browser toolset member call —
/// the full inventory of open tabs, which tab is active, and any side
/// effects (tabs opened, download state changes) the call produced.
///
/// At most one per `tool_result`, only on a non-error result answering a
/// browser toolset member `tool_use`. The server renders the
/// model-visible text from it; the model never sees the raw fields.
public struct BrowserStateBlockParam: Codable, Hashable, Sendable {
    /// All tabs open in the browser after this call — the full inventory, not a delta.
    ///
    /// May be empty. Whenever non-empty, exactly one entry carries `active: true`.
    public var tabs: [BrowserStateTabEntryParam]
    public var type: String
    /// Create a cache control breakpoint at this content block.
    public var cacheControl: CacheControlEphemeralParam??
    /// Tabs opened and download state changes during this call.
    ///
    /// "Nothing to report" is expressed by omitting the field, never by an empty list.
    public var stateChanges: [BrowserStateChangeParam]??

    public init(tabs: [BrowserStateTabEntryParam], type: String = "browser_state", cacheControl: CacheControlEphemeralParam?? = nil, stateChanges: [BrowserStateChangeParam]?? = nil) {
        self.tabs = tabs
        self.type = type
        self.cacheControl = cacheControl
        self.stateChanges = stateChanges
    }

    enum CodingKeys: String, CodingKey {
        case tabs
        case type
        case cacheControl = "cache_control"
        case stateChanges = "state_changes"
    }
}
