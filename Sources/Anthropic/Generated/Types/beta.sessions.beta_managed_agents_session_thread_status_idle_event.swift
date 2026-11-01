// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_thread_status_idle_event` (beta_managed_agents_session_thread_status_idle_event.py).

import Foundation

/// A session thread has yielded and is awaiting input.
///
/// Emitted on the thread's own stream and cross-posted to the primary stream for child threads.
public struct BetaManagedAgentsSessionThreadStatusIdleEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Name of the agent the thread runs.
    public var agentName: String
    /// Timestamp of the status transition.
    public var processedAt: Date
    /// Public sthr\__ ID of the thread that went idle.
    public var sessionThreadID: String
    /// Structured information about why the thread stopped.
    ///
    /// `null` when there is nothing more to report.
    public var stopDetails: BetaManagedAgentsSessionRefusalStopDetails?
    public var stopReason: BetaManagedAgentsSessionThreadStatusIdleEvent.StopReason
    public var type: String

    public init(id: String, agentName: String, processedAt: Date, sessionThreadID: String, stopDetails: BetaManagedAgentsSessionRefusalStopDetails? = nil, stopReason: BetaManagedAgentsSessionThreadStatusIdleEvent.StopReason, type: String = "session.thread_status_idle") {
        self.id = id
        self.agentName = agentName
        self.processedAt = processedAt
        self.sessionThreadID = sessionThreadID
        self.stopDetails = stopDetails
        self.stopReason = stopReason
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case agentName = "agent_name"
        case processedAt = "processed_at"
        case sessionThreadID = "session_thread_id"
        case stopDetails = "stop_details"
        case stopReason = "stop_reason"
        case type
    }
}

extension BetaManagedAgentsSessionThreadStatusIdleEvent {

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
