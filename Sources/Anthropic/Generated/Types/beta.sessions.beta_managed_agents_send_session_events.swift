// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_send_session_events` (beta_managed_agents_send_session_events.py).

import Foundation

/// Events that were successfully sent to the session.
public struct BetaManagedAgentsSendSessionEvents: Codable, Hashable, Sendable {
    /// Sent events
    public var data: [BetaManagedAgentsSendSessionEvents.Data]?

    public init(data: [BetaManagedAgentsSendSessionEvents.Data]? = nil) {
        self.data = data
    }

    enum CodingKeys: String, CodingKey {
        case data
    }
}

extension BetaManagedAgentsSendSessionEvents {

    public indirect enum Data: Codable, Hashable, Sendable {
        case userMessage(BetaManagedAgentsUserMessageEvent)
        case userInterrupt(BetaManagedAgentsUserInterruptEvent)
        case userToolConfirmation(BetaManagedAgentsUserToolConfirmationEvent)
        case userCustomToolResult(BetaManagedAgentsUserCustomToolResultEvent)
        case userDefineOutcome(BetaManagedAgentsUserDefineOutcomeEvent)
        case userToolResult(BetaManagedAgentsUserToolResultEvent)
        case systemMessage(BetaManagedAgentsSystemMessageEvent)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "user.message": self = .userMessage(try BetaManagedAgentsUserMessageEvent(from: decoder))
            case "user.interrupt": self = .userInterrupt(try BetaManagedAgentsUserInterruptEvent(from: decoder))
            case "user.tool_confirmation": self = .userToolConfirmation(try BetaManagedAgentsUserToolConfirmationEvent(from: decoder))
            case "user.custom_tool_result": self = .userCustomToolResult(try BetaManagedAgentsUserCustomToolResultEvent(from: decoder))
            case "user.define_outcome": self = .userDefineOutcome(try BetaManagedAgentsUserDefineOutcomeEvent(from: decoder))
            case "user.tool_result": self = .userToolResult(try BetaManagedAgentsUserToolResultEvent(from: decoder))
            case "system.message": self = .systemMessage(try BetaManagedAgentsSystemMessageEvent(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .userMessage(let v): try v.encode(to: encoder)
            case .userInterrupt(let v): try v.encode(to: encoder)
            case .userToolConfirmation(let v): try v.encode(to: encoder)
            case .userCustomToolResult(let v): try v.encode(to: encoder)
            case .userDefineOutcome(let v): try v.encode(to: encoder)
            case .userToolResult(let v): try v.encode(to: encoder)
            case .systemMessage(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
