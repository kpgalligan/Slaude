// Transformed from `anthropic.types.beta.beta_browser_state_change_tab_opened_param` (beta_browser_state_change_tab_opened_param.py).

import Foundation

/// A tab this call's execution opened that remains open at its end —
/// the creation delta of the `tabs` inventory, not an event log.
///
/// Carries only the `tab_id`; the tab's `title` and `url` live on its
/// `tabs` entry, which must include the same `tab_id`. A tab opened
/// during a failed call gets no deferred `tab_opened`; it simply appears
/// in the next result's `tabs` inventory.
public struct BetaBrowserStateChangeTabOpenedParam: Codable, Hashable, Sendable {
    /// The `tab_id` of the opened tab, present in `tabs`.
    public var tabID: String
    public var type: String

    public init(tabID: String, type: String = "tab_opened") {
        self.tabID = tabID
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
        case type
    }
}
