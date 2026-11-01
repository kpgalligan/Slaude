// Transformed from `anthropic.types.beta.organization.beta_compliance_settings_state_disabled_param` (beta_compliance_settings_state_disabled_param.py).

import Foundation

public struct BetaComplianceSettingsStateDisabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
