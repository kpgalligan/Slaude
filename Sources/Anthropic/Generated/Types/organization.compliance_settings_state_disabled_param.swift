// Transformed from `anthropic.types.organization.compliance_settings_state_disabled_param` (compliance_settings_state_disabled_param.py).

import Foundation

public struct ComplianceSettingsStateDisabledParam: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
