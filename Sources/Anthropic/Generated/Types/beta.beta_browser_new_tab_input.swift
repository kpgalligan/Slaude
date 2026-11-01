// Transformed from `anthropic.types.beta.beta_browser_new_tab_input` (beta_browser_new_tab_input.py).

import Foundation

/// Open a new empty tab and return its tab_id.
public struct BetaBrowserNewTabInput: Codable, Hashable, Sendable {
    public init() {
    }

    public init(from decoder: Decoder) throws {}
    public func encode(to encoder: Encoder) throws {
        _ = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
