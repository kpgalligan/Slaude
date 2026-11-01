// Transformed from `anthropic.types.beta.beta_computer_left_mouse_down_input` (beta_computer_left_mouse_down_input.py).

import Foundation

/// Press and hold the left mouse button at the current cursor position.
public struct BetaComputerLeftMouseDownInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
