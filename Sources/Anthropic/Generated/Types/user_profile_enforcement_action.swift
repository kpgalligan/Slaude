// Transformed from `anthropic.types.user_profile_enforcement_action` (user_profile_enforcement_action.py).

import Foundation

public indirect enum UserProfileEnforcementAction: Codable, Hashable, Sendable {
    case restriction(UserProfileEnforcementActionRestriction)
    case ban(UserProfileEnforcementActionBan)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "restriction": self = .restriction(try UserProfileEnforcementActionRestriction(from: decoder))
        case "ban": self = .ban(try UserProfileEnforcementActionBan(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .restriction(let v): try v.encode(to: encoder)
        case .ban(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
