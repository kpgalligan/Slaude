// Transformed from `anthropic.types.beta.organization.claude_tag.bundles.beta_claude_tag_bundle_target` (beta_claude_tag_bundle_target.py).

import Foundation

public indirect enum BetaClaudeTagBundleTarget: Codable, Hashable, Sendable {
    case slackChannel(BetaClaudeTagSlackChannelBundleTarget)
    case slackWorkspace(BetaClaudeTagSlackWorkspaceBundleTarget)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "slack_channel": self = .slackChannel(try BetaClaudeTagSlackChannelBundleTarget(from: decoder))
        case "slack_workspace": self = .slackWorkspace(try BetaClaudeTagSlackWorkspaceBundleTarget(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .slackChannel(let v): try v.encode(to: encoder)
        case .slackWorkspace(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
