// Transformed from `anthropic.types.beta.beta_browser_type_input` (beta_browser_type_input.py).

import Foundation

/// Type a literal string at the current focus.
public struct BetaBrowserTypeInput: Codable, Hashable, Sendable {
    /// The text to type.
    public var text: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(text: String, tabId: String? = nil) {
        self.text = text
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case text
        case tabId = "tab_id"
    }
}
