// Transformed from `anthropic.types.organization.compliance_setting_update_params` (compliance_setting_update_params.py).

import Foundation

public struct ComplianceSettingUpdateParams: Codable, Hashable, Sendable {
    /// Desired state.
    ///
    /// Accepts the string shorthand "enabled" or "disabled" in place of the object
    /// form; the response always returns the canonical object form.
    public var state: ComplianceSettingsStateParam

    public init(state: ComplianceSettingsStateParam) {
        self.state = state
    }

    enum CodingKeys: String, CodingKey {
        case state
    }
}
