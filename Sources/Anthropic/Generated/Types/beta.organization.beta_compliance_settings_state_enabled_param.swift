// Transformed from `anthropic.types.beta.organization.beta_compliance_settings_state_enabled_param` (beta_compliance_settings_state_enabled_param.py).

import Foundation

public struct BetaComplianceSettingsStateEnabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
