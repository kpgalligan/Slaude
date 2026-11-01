// Transformed from `anthropic.types.beta.organization.beta_compliance_settings_state` (beta_compliance_settings_state.py).

import Foundation

public indirect enum BetaComplianceSettingsState: Codable, Hashable, Sendable {
    case enabled(BetaComplianceSettingsStateEnabled)
    case disabled(BetaComplianceSettingsStateDisabled)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try BetaComplianceSettingsStateEnabled(from: decoder))
        case "disabled": self = .disabled(try BetaComplianceSettingsStateDisabled(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .enabled(let v): try v.encode(to: encoder)
        case .disabled(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
