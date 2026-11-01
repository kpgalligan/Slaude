// Transformed from `anthropic.types.beta.beta_browser_scroll_input` (beta_browser_scroll_input.py).

import Foundation

/// Scroll at a viewport position. `target` must be a coordinate target.
public struct BetaBrowserScrollInput: Codable, Hashable, Sendable {
    public var scrollDirection: BetaBrowserScrollDirection
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BetaBrowserCoordinateTarget
    /// Scroll-wheel notches (1–10). Default 3.
    public var scrollAmount: Int?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(scrollDirection: BetaBrowserScrollDirection, target: BetaBrowserCoordinateTarget, scrollAmount: Int? = nil, tabID: String? = nil) {
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
