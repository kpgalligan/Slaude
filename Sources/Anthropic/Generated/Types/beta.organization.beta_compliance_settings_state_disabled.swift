// Transformed from `anthropic.types.beta.organization.beta_compliance_settings_state_disabled` (beta_compliance_settings_state_disabled.py).

import Foundation

public struct BetaComplianceSettingsStateDisabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
