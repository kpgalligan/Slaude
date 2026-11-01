// Transformed from `anthropic.types.beta.beta_browser_mouse_move_input` (beta_browser_mouse_move_input.py).

import Foundation

/// Move the pointer to a viewport coordinate without clicking.
public struct BetaBrowserMouseMoveInput: Codable, Hashable, Sendable {
    /// A point in the browser viewport, in viewport pixels (the same frame as a
    /// full-viewport screenshot).
    public var target: BetaBrowserCoordinateTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BetaBrowserCoordinateTarget, tabID: String? = nil) {
        self.target = target
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabID = "tab_id"
    }
}
