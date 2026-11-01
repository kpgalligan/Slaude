// Transformed from `anthropic.types.beta.beta_browser_key_input` (beta_browser_key_input.py).

import Foundation

/// Press a key or key chord.
///
/// Use "+" to combine modifiers with a key (e.g. "ctrl+a",
/// "cmd+shift+p") and space to sequence presses (e.g. "Backspace Backspace Delete").
/// Common names like "Return", "Tab", "Escape", "BackSpace" are supported.
public struct BetaBrowserKeyInput: Codable, Hashable, Sendable {
    /// The key, chord, or space-separated sequence to press.
    public var text: String
    /// Number of times to repeat. Default 1.
    public var `repeat`: Int?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(text: String, `repeat`: Int? = nil, tabID: String? = nil) {
        self.text = text
        self.repeat = `repeat`
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case text
        case `repeat`
        case tabID = "tab_id"
    }
}
