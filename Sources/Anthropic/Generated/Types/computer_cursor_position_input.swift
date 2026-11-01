// Transformed from `anthropic.types.computer_cursor_position_input` (computer_cursor_position_input.py).

import Foundation

/// Get the current (x, y) pixel coordinate of the cursor.
public struct ComputerCursorPositionInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
