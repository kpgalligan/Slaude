// Transformed from `anthropic.types.browser_scroll_to_input` (browser_scroll_to_input.py).

import Foundation

/// Scroll an element into view.
public struct BrowserScrollToInput: Codable, Hashable, Sendable {
    /// An element on the page, identified by a reference from a prior `read_page` or
    /// `find` result. References are scoped to the tab that produced them and become
    /// stale after navigation or a major re-render.
    public var target: BrowserRefTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(target: BrowserRefTarget, tabId: String? = nil) {
        self.target = target
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabId = "tab_id"
    }
}
