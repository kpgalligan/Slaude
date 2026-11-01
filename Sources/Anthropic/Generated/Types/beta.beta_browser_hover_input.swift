// Transformed from `anthropic.types.beta.beta_browser_hover_input` (beta_browser_hover_input.py).

import Foundation

/// Move the cursor to a coordinate or element without clicking.
public struct BetaBrowserHoverInput: Codable, Hashable, Sendable {
    /// Where to act: either a viewport coordinate or an element reference.
    public var target: BetaBrowserClickTarget
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BetaBrowserClickTarget, tabID: String? = nil) {
        self.target = target
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case tabID = "tab_id"
    }
}
