// Transformed from `anthropic.types.beta.beta_browser_mouse_move_input` (beta_browser_mouse_move_input.py).

import Foundation

/// Move the pointer to a viewport coordinate without clicking.
public struct BetaBrowserMouseMoveInput: Codable, Hashable, Sendable {
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BetaBrowserCoordinateTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(target: BetaBrowserCoordinateTarget, tabId: String? = nil) {
        self.target = target
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabId = "tab_id"
    }
}
