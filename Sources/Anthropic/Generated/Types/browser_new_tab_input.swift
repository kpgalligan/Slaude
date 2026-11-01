// Transformed from `anthropic.types.browser_new_tab_input` (browser_new_tab_input.py).

import Foundation

/// Open a new empty tab and return its tab_id.
public struct BrowserNewTabInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
