// Transformed from `anthropic.types.beta.beta_computer_type_input` (beta_computer_type_input.py).

import Foundation

/// Type a string of text on the keyboard.
public struct BetaComputerTypeInput: Codable, Hashable, Sendable {
    /// The text to type.
    public var text: String

    public init(text: String) {
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case text
    }
}
