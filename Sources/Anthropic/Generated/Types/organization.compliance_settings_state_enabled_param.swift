// Transformed from `anthropic.types.organization.compliance_settings_state_enabled_param` (compliance_settings_state_enabled_param.py).

import Foundation

public struct ComplianceSettingsStateEnabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
