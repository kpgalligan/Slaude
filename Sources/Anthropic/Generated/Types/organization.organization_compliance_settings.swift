// Transformed from `anthropic.types.organization.organization_compliance_settings` (organization_compliance_settings.py).

import Foundation

public struct OrganizationComplianceSettings: Codable, Hashable, Sendable {
    /// Whether the Compliance API is enabled for this organization.
    public var state: ComplianceSettingsState
    public var type: String

    public init(state: ComplianceSettingsState, type: String = "compliance_settings") {
        self.state = state
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case state
        case type
    }
}
