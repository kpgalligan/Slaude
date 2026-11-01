// Transformed from `anthropic.types.beta.beta_browser_get_page_text_input` (beta_browser_get_page_text_input.py).

import Foundation

/// Return the page's visible text content as plain text, prioritizing article
/// content. Suited to articles, documentation, and other text-heavy pages.
public struct BetaBrowserGetPageTextInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(tabID: String? = nil) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
