// Transformed from `anthropic.types.beta.beta_browser_form_input_input` (beta_browser_form_input_input.py).

import Foundation

/// Set the value of a form element (input, textarea, select, checkbox).
///
/// Use a
/// boolean for checkboxes, an option value or text for selects.
public struct BetaBrowserFormInputInput: Codable, Hashable, Sendable {
    /// An element on the page, identified by a reference from a prior `read_page` or
    /// `find` result. References are scoped to the tab that produced them and become
    /// stale after navigation or a major re-render.
    public var target: BetaBrowserRefTarget
    /// The value to set.
    public var value: BetaBrowserFormInputValue
    /// Tab to act on. Defaults to the active tab when omitted.
    public var tabID: String?

    public init(target: BetaBrowserRefTarget, value: BetaBrowserFormInputValue, tabID: String? = nil) {
        self.target = target
        self.value = value
        self.tabID = tabID
    }

    enum CodingKeys: String, CodingKey {
        case target
        case value
        case tabID = "tab_id"
    }
}
