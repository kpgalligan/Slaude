// Transformed from `anthropic.types.beta.beta_browser_navigate_input` (beta_browser_navigate_input.py).

import Foundation

/// Navigate to a URL, or go back/forward/reload in history.
///
/// The protocol may be
/// omitted (defaults to https://).
public struct BetaBrowserNavigateInput: Codable, Hashable, Sendable {
    /// The URL to navigate to, or "back" / "forward" / "reload" for history navigation.
    public var url: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(url: String, tabId: String? = nil) {
        self.url = url
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case url
        case tabId = "tab_id"
    }
}
