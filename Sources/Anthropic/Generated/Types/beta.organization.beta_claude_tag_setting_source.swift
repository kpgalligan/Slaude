// Transformed from `anthropic.types.beta.organization.beta_claude_tag_setting_source` (beta_claude_tag_setting_source.py).

import Foundation

public indirect enum BetaClaudeTagSettingSource: Codable, Hashable, Sendable {
    case slackChannel(BetaClaudeTagSlackChannelSettingSource)
    case slackWorkspace(BetaClaudeTagSlackWorkspaceSettingSource)
    case slackParentChannel(BetaClaudeTagSlackParentChannelSettingSource)
    case slackDefault(BetaClaudeTagSlackDefaultSettingSource)
    case `default`(BetaClaudeTagDefaultSettingSource)
    case slackGridChannel(BetaClaudeTagSlackGridChannelSettingSource)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "slack_channel": self = .slackChannel(try BetaClaudeTagSlackChannelSettingSource(from: decoder))
        case "slack_workspace": self = .slackWorkspace(try BetaClaudeTagSlackWorkspaceSettingSource(from: decoder))
        case "slack_parent_channel": self = .slackParentChannel(try BetaClaudeTagSlackParentChannelSettingSource(from: decoder))
        case "slack_default": self = .slackDefault(try BetaClaudeTagSlackDefaultSettingSource(from: decoder))
        case "default": self = .default(try BetaClaudeTagDefaultSettingSource(from: decoder))
        case "slack_grid_channel": self = .slackGridChannel(try BetaClaudeTagSlackGridChannelSettingSource(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .slackChannel(let v): try v.encode(to: encoder)
        case .slackWorkspace(let v): try v.encode(to: encoder)
        case .slackParentChannel(let v): try v.encode(to: encoder)
        case .slackDefault(let v): try v.encode(to: encoder)
        case .default(let v): try v.encode(to: encoder)
        case .slackGridChannel(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
