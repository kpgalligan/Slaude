// Transformed from `anthropic.types.beta.beta_browser_scroll_to_input` (beta_browser_scroll_to_input.py).

import Foundation

/// Scroll an element into view.
public struct BetaBrowserScrollToInput: Codable, Hashable, Sendable {
    /// An element on the page, identified by a reference from a prior `read_page` or
    /// `find` result. References are scoped to the tab that produced them and become
    /// stale after navigation or a major re-render.
    public var target: BetaBrowserRefTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BetaBrowserRefTarget, tabID: String? = nil) {
        self.target = target
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabID = "tab_id"
    }
}
