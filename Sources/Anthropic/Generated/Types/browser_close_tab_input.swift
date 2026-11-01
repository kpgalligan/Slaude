// Transformed from `anthropic.types.browser_close_tab_input` (browser_close_tab_input.py).

import Foundation

/// Close the tab with the given tab_id.
public struct BrowserCloseTabInput: Codable, Hashable, Sendable {
    /// The tab to close.
    public var tabId: String

    public init(tabId: String) {
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
    }
}
