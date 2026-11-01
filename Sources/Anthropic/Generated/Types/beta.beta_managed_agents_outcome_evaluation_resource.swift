// Transformed from `anthropic.types.beta.beta_managed_agents_outcome_evaluation_resource` (beta_managed_agents_outcome_evaluation_resource.py).

import Foundation

/// Evaluation state for a single outcome defined via a `define_outcome` event.
public struct BetaManagedAgentsOutcomeEvaluationResource: Codable, Hashable, Sendable {
    /// When the outcome reached a terminal result.
    ///
    /// Null while `pending`/`running`/`evaluating`.
    public var completedAt: Date?
    /// What the agent should produce.
    public var description: String
    /// Grader's verdict text from the most recent evaluation.
    ///
    /// For `satisfied`, explains why criteria are met; for `needs_revision`
    /// (intermediate), what's missing; for `failed`, why unrecoverable.
    public var explanation: String?
    /// 0-indexed revision cycle the outcome is currently on.
    public var iteration: Int
    /// Server-generated outc\__ ID for this outcome.
    public var outcomeID: String
    /// Current evaluation state.
    ///
    /// `pending` before the agent begins work; `running` while producing or revising;
    /// `evaluating` while the grader scores;
    /// `satisfied`/`max_iterations_reached`/`failed`/`interrupted` are terminal.
    public var result: String
    public var type: String

    public init(completedAt: Date? = nil, description: String, explanation: String? = nil, iteration: Int, outcomeID: String, result: String, type: String = "outcome_evaluation") {
        self.completedAt = completedAt
        self.description = description
        self.explanation = explanation
        self.iteration = iteration
        self.outcomeID = outcomeID
        self.result = result
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case completedAt = "completed_at"
        case description
        case explanation
        case iteration
        case outcomeID = "outcome_id"
        case result
        case type
    }
}
