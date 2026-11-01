// Transformed from `anthropic.types.beta.organization.beta_compliance_settings` (beta_compliance_settings.py).

import Foundation

public struct BetaComplianceSettings: Codable, Hashable, Sendable {
    /// Whether the Compliance API is enabled for this organization.
    public var state: BetaComplianceSettingsState
    public var type: String

    public init(state: BetaComplianceSettingsState, type: String = "compliance_settings") {
        self.state = state
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case state
        case type
    }
}
