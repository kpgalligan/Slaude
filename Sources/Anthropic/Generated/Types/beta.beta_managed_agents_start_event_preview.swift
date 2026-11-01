// Transformed from `anthropic.types.beta.beta_managed_agents_start_event_preview` (beta_managed_agents_start_event_preview.py).

import Foundation

public indirect enum BetaManagedAgentsStartEventPreview: Codable, Hashable, Sendable {
    case agentMessage(BetaManagedAgentsAgentMessagePreview)
    case agentThinking(BetaManagedAgentsAgentThinkingPreview)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "agent.message": self = .agentMessage(try BetaManagedAgentsAgentMessagePreview(from: decoder))
        case "agent.thinking": self = .agentThinking(try BetaManagedAgentsAgentThinkingPreview(from: decoder))
        default: self = .unknown(try _Coding.raw(decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .agentMessage(let v): try v.encode(to: encoder)
        case .agentThinking(let v): try v.encode(to: encoder)
        case .unknown(let v): try v.encode(to: encoder)
        }
    }
}
