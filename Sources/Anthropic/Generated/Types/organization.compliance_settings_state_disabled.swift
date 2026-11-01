// Transformed from `anthropic.types.organization.compliance_settings_state_disabled` (compliance_settings_state_disabled.py).

import Foundation

public struct ComplianceSettingsStateDisabled: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "disabled") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
