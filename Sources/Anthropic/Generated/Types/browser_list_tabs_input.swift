// Transformed from `anthropic.types.browser_list_tabs_input` (browser_list_tabs_input.py).

import Foundation

/// List all open tabs with each tab's tab_id, title, and URL.
public struct BrowserListTabsInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
