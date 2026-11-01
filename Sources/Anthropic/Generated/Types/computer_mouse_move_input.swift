// Transformed from `anthropic.types.computer_mouse_move_input` (computer_mouse_move_input.py).

import Foundation

/// Move the cursor to a specified (x, y) pixel coordinate.
///
/// Use this ONLY to hover
/// without clicking; otherwise use a click action directly.
public struct ComputerMouseMoveInput: Codable, Hashable, Sendable {
    /// (x, y): x pixels from the left edge, y pixels from the top edge.
    public var coordinate: [Int]

    public init(coordinate: [Int]) {
        self.coordinate = coordinate
    }

    enum CodingKeys: String, CodingKey {
        case coordinate
    }
}
