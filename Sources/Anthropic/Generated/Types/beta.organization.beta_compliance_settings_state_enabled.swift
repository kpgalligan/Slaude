// Transformed from `anthropic.types.beta.organization.beta_compliance_settings_state_enabled` (beta_compliance_settings_state_enabled.py).

import Foundation

public struct BetaComplianceSettingsStateEnabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
