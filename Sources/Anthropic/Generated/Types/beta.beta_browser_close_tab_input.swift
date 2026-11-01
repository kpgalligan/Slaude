// Transformed from `anthropic.types.beta.beta_browser_close_tab_input` (beta_browser_close_tab_input.py).

import Foundation

/// Close the tab with the given tab_id.
public struct BetaBrowserCloseTabInput: Codable, Hashable, Sendable {
    /// The tab to close.
    public var tabID: String

    public init(tabID: String) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
