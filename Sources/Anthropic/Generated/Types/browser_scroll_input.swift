// Transformed from `anthropic.types.browser_scroll_input` (browser_scroll_input.py).

import Foundation

/// Scroll at a viewport position. `target` must be a coordinate target.
public struct BrowserScrollInput: Codable, Hashable, Sendable {
    public var scrollDirection: BrowserScrollDirection
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BrowserCoordinateTarget
    /// Scroll-wheel notches (1–10). Default 3.
    public var scrollAmount: Int?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(scrollDirection: BrowserScrollDirection, target: BrowserCoordinateTarget, scrollAmount: Int? = nil, tabID: String? = nil) {
        self.scrollDirection = scrollDirection
        self.target = target
        self.scrollAmount = scrollAmount
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case scrollDirection = "scroll_direction"
        case target
        case scrollAmount = "scroll_amount"
        case tabID = "tab_id"
    }
}
