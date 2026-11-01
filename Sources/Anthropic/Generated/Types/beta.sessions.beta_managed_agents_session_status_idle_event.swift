// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_status_idle_event` (beta_managed_agents_session_status_idle_event.py).

import Foundation

/// Indicates the agent has paused and is awaiting user input.
public struct BetaManagedAgentsSessionStatusIdleEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Timestamp of status change.
    public var processedAt: Date
    /// Structured information about why the session stopped.
    ///
    /// `null` when there is nothing more to report.
    public var stopDetails: BetaManagedAgentsSessionRefusalStopDetails?
    public var stopReason: BetaManagedAgentsSessionStatusIdleEvent.StopReason
    public var type: String

    public init(id: String, processedAt: Date, stopDetails: BetaManagedAgentsSessionRefusalStopDetails? = nil, stopReason: BetaManagedAgentsSessionStatusIdleEvent.StopReason, type: String = "session.status_idle") {
        self.id = id
        self.processedAt = processedAt
        self.stopDetails = stopDetails
        self.stopReason = stopReason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case processedAt = "processed_at"
        case stopDetails = "stop_details"
        case stopReason = "stop_reason"
        case type
    }
}

extension BetaManagedAgentsSessionStatusIdleEvent {

    public indirect enum StopReason: Codable, Hashable, Sendable {
        case endTurn(BetaManagedAgentsSessionEndTurn)
        case requiresAction(BetaManagedAgentsSessionRequiresAction)
        case retriesExhausted(BetaManagedAgentsSessionRetriesExhausted)
        case budgetReached(BetaManagedAgentsSessionBudgetReached)
        case refusal(BetaManagedAgentsSessionRefusal)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "end_turn": self = .endTurn(try BetaManagedAgentsSessionEndTurn(from: decoder))
            case "requires_action": self = .requiresAction(try BetaManagedAgentsSessionRequiresAction(from: decoder))
            case "retries_exhausted": self = .retriesExhausted(try BetaManagedAgentsSessionRetriesExhausted(from: decoder))
            case "budget_reached": self = .budgetReached(try BetaManagedAgentsSessionBudgetReached(from: decoder))
            case "refusal": self = .refusal(try BetaManagedAgentsSessionRefusal(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .endTurn(let v): try v.encode(to: encoder)
            case .requiresAction(let v): try v.encode(to: encoder)
            case .retriesExhausted(let v): try v.encode(to: encoder)
            case .budgetReached(let v): try v.encode(to: encoder)
            case .refusal(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
