// Transformed from `anthropic.types.browser_wait_input` (browser_wait_input.py).

import Foundation

/// Pause for the given duration.
public struct BrowserWaitInput: Codable, Hashable, Sendable {
    /// Seconds to wait (maximum 30).
    public var duration: Double
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(duration: Double, tabId: String? = nil) {
        self.duration = duration
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case duration
        case tabId = "tab_id"
    }
}
