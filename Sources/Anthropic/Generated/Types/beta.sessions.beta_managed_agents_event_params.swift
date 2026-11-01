// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_event_params` (beta_managed_agents_event_params.py).

import Foundation

public indirect enum BetaManagedAgentsEventParams: Codable, Hashable, Sendable {
    case userMessage(BetaManagedAgentsUserMessageEventParams)
    case userInterrupt(BetaManagedAgentsUserInterruptEventParams)
    case userToolConfirmation(BetaManagedAgentsUserToolConfirmationEventParams)
    case userCustomToolResult(BetaManagedAgentsUserCustomToolResultEventParams)
    case userDefineOutcome(BetaManagedAgentsUserDefineOutcomeEventParams)
    case userToolResult(BetaManagedAgentsUserToolResultEventParams)
    case systemMessage(BetaManagedAgentsSystemMessageEventParams)
    /// A value that matched none of the known variants.
    case unknown(JSONValue)

    public init(from decoder: Decoder) throws {
        switch _Coding.discriminator(decoder, "type") {
        case "user.message": self = .userMessage(try BetaManagedAgentsUserMessageEventParams(from: decoder))
        case "user.interrupt": self = .userInterrupt(try BetaManagedAgentsUserInterruptEventParams(from: decoder))
        case "user.tool_confirmation": self = .userToolConfirmation(try BetaManagedAgentsUserToolConfirmationEventParams(from: decoder))
        case "user.custom_tool_result": self = .userCustomToolResult(try BetaManagedAgentsUserCustomToolResultEventParams(from: decoder))
        case "user.define_outcome": self = .userDefineOutcome(try BetaManagedAgentsUserDefineOutcomeEventParams(from: decoder))
        case "user.tool_result": self = .userToolResult(try BetaManagedAgentsUserToolResultEventParams(from: decoder))
        case "system.message": self = .systemMessage(try BetaManagedAgentsSystemMessageEventParams(from: decoder))
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
