// Transformed from `anthropic.types.browser_type_input` (browser_type_input.py).

import Foundation

/// Type a literal string at the current focus.
public struct BrowserTypeInput: Codable, Hashable, Sendable {
    /// The text to type.
    public var text: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(text: String, tabID: String? = nil) {
        self.text = text
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case text
        case tabID = "tab_id"
    }
}
