// Transformed from `anthropic.types.browser_hold_key_input` (browser_hold_key_input.py).

import Foundation

/// Hold a key or key chord down for a duration, then release it.
///
/// Uses the same key
/// names and "+" chord syntax as the key action.
public struct BrowserHoldKeyInput: Codable, Hashable, Sendable {
    /// Seconds to hold the key down (maximum 30).
    public var duration: Double
    /// The key or chord to hold.
    public var text: String
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(duration: Double, text: String, tabID: String? = nil) {
        self.duration = duration
        self.text = text
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case duration
        case text
        case tabID = "tab_id"
    }
}
