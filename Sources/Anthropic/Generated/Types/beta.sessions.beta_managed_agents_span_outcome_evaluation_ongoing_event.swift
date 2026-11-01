// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_span_outcome_evaluation_ongoing_event` (beta_managed_agents_span_outcome_evaluation_ongoing_event.py).

import Foundation

/// Periodic heartbeat emitted while an outcome evaluation cycle is in progress.
///
/// Distinguishes 'evaluation is actively running' from 'evaluation is stuck' between the corresponding `span.outcome_evaluation_start` and `span.outcome_evaluation_end` events.
public struct BetaManagedAgentsSpanOutcomeEvaluationOngoingEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// 0-indexed revision cycle, matching the corresponding
    /// `span.outcome_evaluation_start`.
    public var iteration: Int
    /// The `outc_` ID of the outcome being evaluated.
    public var outcomeId: String
    /// Timestamp when this heartbeat was emitted.
    public var processedAt: Date
    public var type: String

    public init(id: String, iteration: Int, outcomeId: String, processedAt: Date, type: String = "span.outcome_evaluation_ongoing") {
        self.id = id
        self.iteration = iteration
        self.outcomeId = outcomeId
        self.processedAt = processedAt
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case iteration
        case outcomeId = "outcome_id"
        case processedAt = "processed_at"
        case type
    }
}
