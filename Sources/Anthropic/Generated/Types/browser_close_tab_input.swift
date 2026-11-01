// Transformed from `anthropic.types.browser_close_tab_input` (browser_close_tab_input.py).

import Foundation

/// Close the tab with the given tab_id.
public struct BrowserCloseTabInput: Codable, Hashable, Sendable {
    /// The tab to close.
    public var tabID: String

    public init(tabID: String) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
