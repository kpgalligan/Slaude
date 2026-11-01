// Transformed from `anthropic.types.browser_screenshot_input` (browser_screenshot_input.py).

import Foundation

/// Capture the current browser viewport.
public struct BrowserScreenshotInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(tabId: String? = nil) {
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
    }
}
