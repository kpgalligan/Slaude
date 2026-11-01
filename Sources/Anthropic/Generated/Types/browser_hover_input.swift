// Transformed from `anthropic.types.browser_hover_input` (browser_hover_input.py).

import Foundation

/// Move the cursor to a coordinate or element without clicking.
public struct BrowserHoverInput: Codable, Hashable, Sendable {
    /// Where to act: either a viewport coordinate or an element reference.
    public var target: BrowserClickTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(target: BrowserClickTarget, tabId: String? = nil) {
        self.target = target
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabId = "tab_id"
    }
}
