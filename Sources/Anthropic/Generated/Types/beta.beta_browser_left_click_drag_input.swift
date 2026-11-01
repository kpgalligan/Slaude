// Transformed from `anthropic.types.beta.beta_browser_left_click_drag_input` (beta_browser_left_click_drag_input.py).

import Foundation

/// Press at `from`, drag to `target`, release. Both must be coordinate targets.
public struct BetaBrowserLeftClickDragInput: Codable, Hashable, Sendable {
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var from: BetaBrowserCoordinateTarget?
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BetaBrowserCoordinateTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(from: BetaBrowserCoordinateTarget? = nil, target: BetaBrowserCoordinateTarget, tabID: String? = nil) {
        self.from = from
        self.target = target
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case from
        case target
        case tabID = "tab_id"
    }
}
