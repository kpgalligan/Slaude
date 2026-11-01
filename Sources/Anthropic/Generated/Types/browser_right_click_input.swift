// Transformed from `anthropic.types.browser_right_click_input` (browser_right_click_input.py).

import Foundation

/// Right-click at a viewport coordinate or on an element by reference.
public struct BrowserRightClickInput: Codable, Hashable, Sendable {
    /// Where to act: either a viewport coordinate or an element reference.
    public var target: BrowserClickTarget
    /// Optional modifier key chord to hold for the duration of this action (e.g.
    ///
    /// "shift", "ctrl+shift", "cmd+alt").
    public var modifiers: String?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(target: BrowserClickTarget, modifiers: String? = nil, tabId: String? = nil) {
        self.target = target
        self.modifiers = modifiers
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case target
        case modifiers
        case tabId = "tab_id"
    }
}
