// Transformed from `anthropic.types.beta.beta_browser_zoom_input` (beta_browser_zoom_input.py).

import Foundation

/// Return a cropped screenshot of the given viewport region, scaled up for closer
/// inspection — useful for small icons, buttons, or text. Coordinates are in the
/// same viewport-pixel space as a full screenshot.
public struct BetaBrowserZoomInput: Codable, Hashable, Sendable {
    /// [x0, y0, x1, y1] in viewport pixels.
    public var region: [Int]
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(region: [Int], tabId: String? = nil) {
        self.region = region
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case region
        case tabId = "tab_id"
    }
}
