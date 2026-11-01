// Transformed from `anthropic.types.organization.compliance_settings_state` (compliance_settings_state.py).

import Foundation

public indirect enum ComplianceSettingsState: Codable, Hashable, Sendable {
    case enabled(ComplianceSettingsStateEnabled)
    case disabled(ComplianceSettingsStateDisabled)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "enabled": self = .enabled(try ComplianceSettingsStateEnabled(from: decoder))
        case "disabled": self = .disabled(try ComplianceSettingsStateDisabled(from: decoder))
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
