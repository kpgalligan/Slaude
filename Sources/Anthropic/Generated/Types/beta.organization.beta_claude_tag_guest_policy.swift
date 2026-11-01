// Transformed from `anthropic.types.beta.organization.beta_claude_tag_guest_policy` (beta_claude_tag_guest_policy.py).

import Foundation

public indirect enum BetaClaudeTagGuestPolicy: Codable, Hashable, Sendable {
    case allow(BetaClaudeTagGuestPolicyAllow)
    case restrict(BetaClaudeTagGuestPolicyRestrict)
    case channelOnly(BetaClaudeTagGuestPolicyChannelOnly)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "allow": self = .allow(try BetaClaudeTagGuestPolicyAllow(from: decoder))
        case "restrict": self = .restrict(try BetaClaudeTagGuestPolicyRestrict(from: decoder))
        case "channel_only": self = .channelOnly(try BetaClaudeTagGuestPolicyChannelOnly(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .allow(let v): try v.encode(to: encoder)
        case .restrict(let v): try v.encode(to: encoder)
        case .channelOnly(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
