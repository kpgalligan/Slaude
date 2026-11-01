// Transformed from `anthropic.types.beta.beta_computer_middle_click_input` (beta_computer_middle_click_input.py).

import Foundation

/// Click the middle mouse button at the specified (x, y) pixel coordinate, or the
/// current cursor position if `coordinate` is omitted.
public struct BetaComputerMiddleClickInput: Codable, Hashable, Sendable {
    /// (x, y): x pixels from the left edge, y pixels from the top edge.
    public var coordinate: [Int]?
    /// Optional key combination to hold down during this action (e.g.
    ///
    /// "ctrl", "shift", "ctrl+shift").
    public var text: String?

    public init(coordinate: [Int]? = nil, text: String? = nil) {
        self.coordinate = coordinate
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case coordinate
        case text
    }
}
