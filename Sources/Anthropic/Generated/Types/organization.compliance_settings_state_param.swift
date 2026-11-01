// Transformed from `anthropic.types.organization.compliance_settings_state_param` (compliance_settings_state_param.py).

import Foundation

public indirect enum ComplianceSettingsStateParam: Codable, Hashable, Sendable {
    case enabled(ComplianceSettingsStateEnabledParam)
    case disabled(ComplianceSettingsStateDisabledParam)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try ComplianceSettingsStateEnabledParam(from: decoder))
        case "disabled": self = .disabled(try ComplianceSettingsStateDisabledParam(from: decoder))
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
