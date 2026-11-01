// Transformed from `anthropic.types.browser_left_mouse_up_input` (browser_left_mouse_up_input.py).

import Foundation

/// Release the left mouse button at a viewport coordinate.
public struct BrowserLeftMouseUpInput: Codable, Hashable, Sendable {
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BrowserCoordinateTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BrowserCoordinateTarget, tabID: String? = nil) {
        self.target = target
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabID = "tab_id"
    }
}
