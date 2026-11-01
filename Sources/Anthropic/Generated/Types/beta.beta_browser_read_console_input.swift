// Transformed from `anthropic.types.beta.beta_browser_read_console_input` (beta_browser_read_console_input.py).

import Foundation

/// Return console output (log entries, errors, warnings) accumulated since the
/// driver attached to the tab and since the last read, one line per entry. An empty
/// result does not mean no traffic for a tab that predates attach.
public struct BetaBrowserReadConsoleInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(tabID: String? = nil) {
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case tabID = "tab_id"
    }
}
