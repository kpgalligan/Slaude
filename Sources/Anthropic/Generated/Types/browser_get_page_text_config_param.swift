// Transformed from `anthropic.types.browser_get_page_text_config_param` (browser_get_page_text_config_param.py).

import Foundation

/// ``get_page_text``'s config overrides.
public struct BrowserGetPageTextConfigParam: Codable, Hashable, Sendable {
    /// Defer loading for this member.
    ///
    /// Must resolve to the same value on every enabled member of the toolset.
    public var deferLoading: Bool??
    /// Whether this member is offered to the model.
    ///
    /// Default is per member, per the toolset's documentation. A member whose enabled
    /// resolves false is withheld from the served schema.
    public var enabled: Bool??

    public init(deferLoading: Bool?? = nil, enabled: Bool?? = nil) {
        self.deferLoading = deferLoading
        self.enabled = enabled
    }

    enum CodingKeys: String, CodingKey {
        case deferLoading = "defer_loading"
        case enabled
    }
}
