// Transformed from `anthropic.types.beta.beta_browser_find_input` (beta_browser_find_input.py).

import Foundation

/// Find elements matching a natural-language description (e.g.
///
/// "search bar", "add to
/// cart button") and return up to 20 matches with element references.
public struct BetaBrowserFindInput: Codable, Hashable, Sendable {
    /// Natural-language description of the element(s) to find.
    public var query: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(query: String, tabID: String? = nil) {
        self.query = query
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case query
        case tabID = "tab_id"
    }
}
