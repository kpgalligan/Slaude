// Transformed from `anthropic.types.beta.beta_computer_key_input` (beta_computer_key_input.py).

import Foundation

/// Press a key or key-combination on the keyboard.
///
/// Use "+" to combine modifiers with
/// a key (e.g. "ctrl+s", "alt+Tab", "ctrl+shift+Escape"). Key names are
/// case-insensitive; common names like "Return", "Tab", "Escape", "Up", "Down",
/// "Left", "Right", "Home", "End", "Page_Up", "Page_Down", "Delete", "BackSpace" are
/// supported.
public struct BetaComputerKeyInput: Codable, Hashable, Sendable {
    /// The key or key-combination to press.
    public var text: String
    /// Number of times to repeat the key press. Default is 1.
    public var `repeat`: Int?

    public init(text: String, `repeat`: Int? = nil) {
        self.text = text
        self.repeat = `repeat`
    }

    enum CodingKeys: String, CodingKey {
        case text
        case `repeat`
    }
}
