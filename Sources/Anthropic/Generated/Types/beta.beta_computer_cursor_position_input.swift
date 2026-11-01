// Transformed from `anthropic.types.beta.beta_computer_cursor_position_input` (beta_computer_cursor_position_input.py).

import Foundation

/// Get the current (x, y) pixel coordinate of the cursor.
public struct BetaComputerCursorPositionInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
