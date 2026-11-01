// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_span_outcome_evaluation_start_event` (beta_managed_agents_span_outcome_evaluation_start_event.py).

import Foundation

/// Emitted when an outcome evaluation cycle begins.
public struct BetaManagedAgentsSpanOutcomeEvaluationStartEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// 0-indexed revision cycle.
    ///
    /// 0 is the first evaluation; 1 is the re-evaluation after the first revision; etc.
    public var iteration: Int
    /// The `outc_` ID of the outcome being evaluated.
    public var outcomeId: String
    /// Timestamp when outcome evaluation started.
    public var processedAt: Date
    public var type: String

    public init(id: String, iteration: Int, outcomeId: String, processedAt: Date, type: String = "span.outcome_evaluation_start") {
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
