// Transformed from `anthropic.types.beta.beta_browser_list_tabs_input` (beta_browser_list_tabs_input.py).

import Foundation

/// List all open tabs with each tab's tab_id, title, and URL.
public struct BetaBrowserListTabsInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
