// Transformed from `anthropic.types.organization.compliance_settings_state_enabled` (compliance_settings_state_enabled.py).

import Foundation

public struct ComplianceSettingsStateEnabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "enabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
