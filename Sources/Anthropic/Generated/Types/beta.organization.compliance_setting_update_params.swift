// Transformed from `anthropic.types.beta.organization.compliance_setting_update_params` (compliance_setting_update_params.py).

import Foundation

public struct BetaOrganizationComplianceSettingUpdateParams: Codable, Hashable, Sendable {
    /// Desired state.
    ///
    /// Accepts the string shorthand "enabled" or "disabled" in place of the object
    /// form; the response always returns the canonical object form.
    public var state: BetaComplianceSettingsStateParam

    public init(state: BetaComplianceSettingsStateParam) {
        self.state = state
    }

    enum CodingKeys: String, CodingKey {
        case state
    }
}
