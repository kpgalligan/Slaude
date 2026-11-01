// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_span_outcome_evaluation_end_event` (beta_managed_agents_span_outcome_evaluation_end_event.py).

import Foundation

/// Emitted when an outcome evaluation cycle completes.
///
/// Carries the verdict and aggregate token usage. A verdict of `needs_revision` means another evaluation cycle follows; `satisfied`, `max_iterations_reached`, `failed`, or `interrupted` are terminal — no further evaluation cycles follow.
public struct BetaManagedAgentsSpanOutcomeEvaluationEndEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// Human-readable explanation of the verdict.
    ///
    /// For `needs_revision`, describes which criteria failed and why.
    public var explanation: String
    /// 0-indexed revision cycle, matching the corresponding
    /// `span.outcome_evaluation_start`.
    public var iteration: Int
    /// The id of the corresponding `span.outcome_evaluation_start` event.
    public var outcomeEvaluationStartId: String
    /// The `outc_` ID of the outcome being evaluated.
    public var outcomeId: String
    /// Timestamp when outcome evaluation ended.
    public var processedAt: Date
    /// Evaluation verdict.
    ///
    /// 'satisfied': criteria met, session goes idle. 'needs_revision': criteria not
    /// met, another revision cycle follows. 'max_iterations_reached': evaluation budget
    /// exhausted with criteria still unmet — one final acknowledgment turn follows
    /// before the session goes idle, but no further evaluation runs. 'failed': grader
    /// determined the rubric does not apply to the deliverables. 'interrupted': user
    /// sent an interrupt while evaluation was in progress.
    public var result: String
    public var type: String
    /// Aggregate token usage for this evaluation cycle.
    ///
    /// Sums across all grader model requests within the cycle.
    public var usage: BetaManagedAgentsSpanModelUsage

    public init(id: String, explanation: String, iteration: Int, outcomeEvaluationStartId: String, outcomeId: String, processedAt: Date, result: String, type: String = "span.outcome_evaluation_end", usage: BetaManagedAgentsSpanModelUsage) {
        self.id = id
        self.explanation = explanation
        self.iteration = iteration
        self.outcomeEvaluationStartId = outcomeEvaluationStartId
        self.outcomeId = outcomeId
        self.processedAt = processedAt
        self.result = result
        self.type = type
        self.usage = usage
    }

    enum CodingKeys: String, CodingKey {
        case id
        case explanation
        case iteration
        case outcomeEvaluationStartId = "outcome_evaluation_start_id"
        case outcomeId = "outcome_id"
        case processedAt = "processed_at"
        case result
        case type
        case usage
    }
}
