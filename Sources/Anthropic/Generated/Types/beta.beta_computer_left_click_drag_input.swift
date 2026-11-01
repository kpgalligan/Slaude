// Transformed from `anthropic.types.beta.beta_computer_left_click_drag_input` (beta_computer_left_click_drag_input.py).

import Foundation

/// Click and drag the cursor from `start_coordinate` to `coordinate`.
public struct BetaComputerLeftClickDragInput: Codable, Hashable, Sendable {
    /// (x, y): x pixels from the left edge, y pixels from the top edge.
    public var coordinate: [Int]
    /// (x, y): x pixels from the left edge, y pixels from the top edge.
    public var startCoordinate: [Int]
    /// Optional key combination to hold down during this action (e.g.
    ///
    /// "ctrl", "shift", "ctrl+shift").
    public var text: String?

    public init(coordinate: [Int], startCoordinate: [Int], text: String? = nil) {
        self.coordinate = coordinate
        self.startCoordinate = startCoordinate
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case coordinate
        case startCoordinate = "start_coordinate"
        case text
    }
}
