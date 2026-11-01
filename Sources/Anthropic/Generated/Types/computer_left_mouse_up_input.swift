// Transformed from `anthropic.types.computer_left_mouse_up_input` (computer_left_mouse_up_input.py).

import Foundation

/// Release the left mouse button.
public struct ComputerLeftMouseUpInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
