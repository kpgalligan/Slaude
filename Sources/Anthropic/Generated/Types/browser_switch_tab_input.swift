// Transformed from `anthropic.types.browser_switch_tab_input` (browser_switch_tab_input.py).

import Foundation

/// Make the tab with the given tab_id the active tab — the tab that actions without
/// a tab_id apply to.
public struct BrowserSwitchTabInput: Codable, Hashable, Sendable {
    /// The tab to switch to.
    public var tabId: String

    public init(tabId: String) {
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
    }
}
