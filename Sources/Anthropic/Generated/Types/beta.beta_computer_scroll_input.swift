// Transformed from `anthropic.types.beta.beta_computer_scroll_input` (beta_computer_scroll_input.py).

import Foundation

/// Scroll the screen at the specified (x, y) pixel coordinate, or the current cursor
/// position if `coordinate` is omitted. Do NOT use PageUp/PageDown to scroll.
public struct BetaComputerScrollInput: Codable, Hashable, Sendable {
    /// Number of 'clicks' of the scroll wheel.
    public var scrollAmount: Int
    public var scrollDirection: BetaComputerScrollDirection
    /// (x, y): x pixels from the left edge, y pixels from the top edge.
    public var coordinate: [Int]?
    /// Optional key combination to hold down during this action (e.g.
    ///
    /// "ctrl", "shift", "ctrl+shift").
    public var text: String?

    public init(scrollAmount: Int, scrollDirection: BetaComputerScrollDirection, coordinate: [Int]? = nil, text: String? = nil) {
        self.scrollAmount = scrollAmount
        self.scrollDirection = scrollDirection
        self.coordinate = coordinate
        self.text = text
    }

    enum CodingKeys: String, CodingKey {
        case scrollAmount = "scroll_amount"
        case scrollDirection = "scroll_direction"
        case coordinate
        case text
    }
}
