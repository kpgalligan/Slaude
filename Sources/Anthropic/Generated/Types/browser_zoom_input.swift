// Transformed from `anthropic.types.browser_zoom_input` (browser_zoom_input.py).

import Foundation

/// Return a cropped screenshot of the given viewport region, scaled up for closer
/// inspection — useful for small icons, buttons, or text. Coordinates are in the
/// same viewport-pixel space as a full screenshot.
public struct BrowserZoomInput: Codable, Hashable, Sendable {
    /// [x0, y0, x1, y1] in viewport pixels.
    public var region: [Int]
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(region: [Int], tabID: String? = nil) {
        self.region = region
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case region
        case tabID = "tab_id"
    }
}
