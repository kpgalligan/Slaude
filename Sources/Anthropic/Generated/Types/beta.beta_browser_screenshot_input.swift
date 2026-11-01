// Transformed from `anthropic.types.beta.beta_browser_screenshot_input` (beta_browser_screenshot_input.py).

import Foundation

/// Capture the current browser viewport.
public struct BetaBrowserScreenshotInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(tabID: String? = nil) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
