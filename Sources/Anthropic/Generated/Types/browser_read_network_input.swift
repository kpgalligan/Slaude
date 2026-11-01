// Transformed from `anthropic.types.browser_read_network_input` (browser_read_network_input.py).

import Foundation

/// Return the network requests (method, URL, status, MIME type, timing) recorded
/// since the driver attached to the tab and since the last read, one line per entry.
/// An empty result does not mean no traffic for a tab that predates attach.
public struct BrowserReadNetworkInput: Codable, Hashable, Sendable {
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabId: String?

    public init(tabId: String? = nil) {
        self.tabId = tabId
    }

    enum CodingKeys: String, CodingKey {
        case tabId = "tab_id"
    }
}
