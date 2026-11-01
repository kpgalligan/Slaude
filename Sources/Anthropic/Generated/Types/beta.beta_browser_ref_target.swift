// Transformed from `anthropic.types.beta.beta_browser_ref_target` (beta_browser_ref_target.py).

import Foundation

/// An element on the page, identified by a reference from a prior `read_page` or
/// `find` result. References are scoped to the tab that produced them and become
/// stale after navigation or a major re-render.
public struct BetaBrowserRefTarget: Codable, Hashable, Sendable {
    /// An element reference (e.g.
    ///
    /// "ref_7") returned by a prior `read_page` or `find` result.
    public var ref: String
    public var type: String

    public init(ref: String, type: String = "ref") {
        self.ref = ref
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case ref
        case type
    }
}
