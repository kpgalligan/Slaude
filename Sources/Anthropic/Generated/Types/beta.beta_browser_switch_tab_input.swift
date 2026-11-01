// Transformed from `anthropic.types.beta.beta_browser_switch_tab_input` (beta_browser_switch_tab_input.py).

import Foundation

/// Make the tab with the given tab_id the active tab — the tab that actions without
/// a tab_id apply to.
public struct BetaBrowserSwitchTabInput: Codable, Hashable, Sendable {
    /// The tab to switch to.
    public var tabID: String

    public init(tabID: String) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
