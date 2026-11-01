// Transformed from `anthropic.types.browser_middle_click_input` (browser_middle_click_input.py).

import Foundation

/// Middle-click at a viewport coordinate or on an element by reference.
public struct BrowserMiddleClickInput: Codable, Hashable, Sendable {
    /// Where to act: either a viewport coordinate or an element reference.
    public var target: BrowserClickTarget
    /// Optional modifier key chord to hold for the duration of this action (e.g.
    ///
    /// "shift", "ctrl+shift", "cmd+alt").
    public var modifiers: String?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BrowserClickTarget, modifiers: String? = nil, tabID: String? = nil) {
        self.target = target
        self.modifiers = modifiers
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case modifiers
        case tabID = "tab_id"
    }
}
