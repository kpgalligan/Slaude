// Transformed from `anthropic.types.browser_read_page_input` (browser_read_page_input.py).

import Foundation

/// Return a structured accessibility tree of the page (or the subtree rooted at
/// `ref`), with element references like [ref_7] that can be used as targets on later
/// actions. Output is capped at 50,000 characters — narrow with `ref` or a smaller
/// `depth` when exceeded.
public struct BrowserReadPageInput: Codable, Hashable, Sendable {
    /// Maximum tree depth. Default 15.
    public var depth: Int?
    /// Which elements to include.
    ///
    /// Omitted: every visible element. "interactive": interactive elements only. "all":
    /// additionally includes off-viewport elements.
    public var filter: BrowserReadPageFilter?
    /// Element reference to read a subtree from. Omit to read from the page root.
    public var ref: String?
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(depth: Int? = nil, filter: BrowserReadPageFilter? = nil, ref: String? = nil, tabID: String? = nil) {
        self.depth = depth
        self.filter = filter
        self.ref = ref
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case depth
        case filter
        case ref
        case tabID = "tab_id"
    }
}
