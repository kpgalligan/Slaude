// Transformed from `anthropic.types.browser_left_mouse_down_input` (browser_left_mouse_down_input.py).

import Foundation

/// Press and hold the left mouse button at a viewport coordinate.
///
/// Pair with
/// left_mouse_up to perform a custom drag.
public struct BrowserLeftMouseDownInput: Codable, Hashable, Sendable {
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BrowserCoordinateTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(target: BrowserCoordinateTarget, tabId: String? = nil) {
        self.target = target
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabId = "tab_id"
    }
}
