// Transformed from `anthropic.types.browser_coordinate_target` (browser_coordinate_target.py).

import Foundation

/// A point in the browser viewport, in viewport pixels (the same frame as a
/// full-viewport screenshot).
public struct BrowserCoordinateTarget: Codable, Hashable, Sendable {
    public var type: String
    /// Pixels from the left edge of the viewport.
    public var x: Int
    /// Pixels from the top edge of the viewport.
    public var y: Int

    public init(type: String = "coordinate", x: Int, y: Int) {
        self.type = type
        self.x = x
        self.y = y
    }

    enum CodingKeys: String, CodingKey {
        case type
        case x
        case y
    }
}
