// Transformed from `anthropic.types.computer_type_input` (computer_type_input.py).

import Foundation

/// Type a string of text on the keyboard.
public struct ComputerTypeInput: Codable, Hashable, Sendable {
    /// The text to type.
    public var text: String

    public init(text: String) {
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case text
    }
}
