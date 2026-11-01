// Transformed from `anthropic.types.browser_get_page_text_input` (browser_get_page_text_input.py).

import Foundation

/// Return the page's visible text content as plain text, prioritizing article
/// content. Suited to articles, documentation, and other text-heavy pages.
public struct BrowserGetPageTextInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(tabId: String? = nil) {
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
    }
}
