// Transformed from `anthropic.types.beta.beta_browser_hold_key_input` (beta_browser_hold_key_input.py).

import Foundation

/// Hold a key or key chord down for a duration, then release it.
///
/// Uses the same key
/// names and "+" chord syntax as the key action.
public struct BetaBrowserHoldKeyInput: Codable, Hashable, Sendable {
    /// Seconds to hold the key down (maximum 30).
    public var duration: Double
    /// The key or chord to hold.
    public var text: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(duration: Double, text: String, tabId: String? = nil) {
        self.duration = duration
        self.text = text
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case duration
        case text
        case tabId = "tab_id"
    }
}
