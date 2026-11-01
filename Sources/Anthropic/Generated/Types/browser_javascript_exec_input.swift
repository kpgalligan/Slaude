// Transformed from `anthropic.types.browser_javascript_exec_input` (browser_javascript_exec_input.py).

import Foundation

/// Execute JavaScript in the page context and return the value of the last
/// expression. The code runs with access to the DOM, `window`, and page variables.
/// Write the expression you want evaluated — do NOT use `return`.
public struct BrowserJavascriptExecInput: Codable, Hashable, Sendable {
    /// JavaScript to execute in the page context.
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
