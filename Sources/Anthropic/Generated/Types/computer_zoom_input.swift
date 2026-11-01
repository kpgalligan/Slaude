// Transformed from `anthropic.types.computer_zoom_input` (computer_zoom_input.py).

import Foundation

/// Take a screenshot of a rectangular region.
///
/// Region coordinates are in the
/// full-screenshot space (not physical display pixels). The crop is scaled up to
/// fill the image budget so fine details become legible.
public struct ComputerZoomInput: Codable, Hashable, Sendable {
    /// (x0, y0, x1, y1): The region to capture.
    public var region: [Int]

    public init(region: [Int]) {
        self.region = region
    }

    enum CodingKeys: String, CodingKey {
        case region
    }
}
