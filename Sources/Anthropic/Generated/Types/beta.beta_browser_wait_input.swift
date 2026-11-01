// Transformed from `anthropic.types.beta.beta_browser_wait_input` (beta_browser_wait_input.py).

import Foundation

/// Pause for the given duration.
public struct BetaBrowserWaitInput: Codable, Hashable, Sendable {
    /// Seconds to wait (maximum 30).
    public var duration: Double
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(duration: Double, tabID: String? = nil) {
        self.duration = duration
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case duration
        case tabID = "tab_id"
    }
}
