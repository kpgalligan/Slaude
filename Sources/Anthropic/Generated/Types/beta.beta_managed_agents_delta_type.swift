// Transformed from `anthropic.types.beta.beta_managed_agents_delta_type` (beta_managed_agents_delta_type.py).

import Foundation

public enum BetaManagedAgentsDeltaType: OpenEnum, CaseIterable {
    case agentMessage
    case agentThinking
    /// A value this version of the SDK doesn't know about.
    case unknown(String)

    public static let allCases: [BetaManagedAgentsDeltaType] = [.agentMessage, .agentThinking]

    public init(rawValue: String) {
        switch rawValue {
        case "agent.message": self = .agentMessage
        case "agent.thinking": self = .agentThinking
        default: self = .unknown(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .agentMessage: return "agent.message"
        case .agentThinking: return "agent.thinking"
        case .unknown(let value): return value
        }
    }
}
