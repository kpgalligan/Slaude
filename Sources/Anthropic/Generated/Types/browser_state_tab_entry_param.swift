// Transformed from `anthropic.types.browser_state_tab_entry_param` (browser_state_tab_entry_param.py).

import Foundation

/// One open browser tab reported in a `browser_state` block's `tabs`
/// inventory.
///
/// `tab_id` is the caller-assigned identifier for the tab; `title` and
/// `url` describe the page the tab is currently showing and may be empty
/// strings (a blank tab legitimately has both empty). `active` marks the
/// tab that is active after this call; whenever `tabs` is non-empty,
/// exactly one entry is marked.
public struct BrowserStateTabEntryParam: Codable, Hashable, Sendable {
    /// The caller-assigned identifier for this tab, unique within the inventory.
    public var tabId: String
    /// The title of the page the tab is showing. May be empty.
    public var title: String
    /// The URL of the page the tab is showing. May be empty.
    public var url: String
    /// Whether this tab is the active tab after this call.
    ///
    /// Whenever `tabs` is non-empty, exactly one entry is marked `active: true`.
    public var active: Bool?

    public init(tabId: String, title: String, url: String, active: Bool? = nil) {
        self.tabId = tabId
        self.title = title
        self.url = url
        self.active = active
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
        case title
        case url
        case active
    }
}
