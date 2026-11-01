// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_define_outcome_event` (beta_managed_agents_user_define_outcome_event.py).

import Foundation

/// Echo of a `user.define_outcome` input event.
///
/// Carries the server-generated `outcome_id` that subsequent `span.outcome_evaluation_*` events reference.
public struct BetaManagedAgentsUserDefineOutcomeEvent: Codable, Hashable, Sendable {
    /// Unique identifier for this event.
    public var id: String
    /// What the agent should produce. Copied from the input event.
    public var description: String
    /// Evaluate-then-revise cycles before giving up. Default 3, max 20.
    public var maxIterations: Int?
    /// Server-generated `outc_` ID for this outcome.
    ///
    /// Referenced by `span.outcome_evaluation_*` events and the session's
    /// `outcome_evaluations` list.
    public var outcomeID: String
    /// Timestamp when the outcome was accepted.
    public var processedAt: Date
    /// How to grade the outcome.
    ///
    /// File rubrics are currently resolved to their text content; clients should handle
    /// both variants.
    public var rubric: BetaManagedAgentsUserDefineOutcomeEvent.Rubric
    public var type: String

    public init(id: String, description: String, maxIterations: Int? = nil, outcomeID: String, processedAt: Date, rubric: BetaManagedAgentsUserDefineOutcomeEvent.Rubric, type: String = "user.define_outcome") {
        self.id = id
        self.description = description
        self.maxIterations = maxIterations
        self.outcomeID = outcomeID
        self.processedAt = processedAt
        self.rubric = rubric
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case id
        case description
        case maxIterations = "max_iterations"
        case outcomeID = "outcome_id"
        case processedAt = "processed_at"
        case rubric
        case type
    }
}

extension BetaManagedAgentsUserDefineOutcomeEvent {

    public indirect enum Rubric: Codable, Hashable, Sendable {
        case file(BetaManagedAgentsFileRubric)
        case text(BetaManagedAgentsTextRubric)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "file": self = .file(try BetaManagedAgentsFileRubric(from: decoder))
            case "text": self = .text(try BetaManagedAgentsTextRubric(from: decoder))
            default: self = .unknown(try _Coding.raw(decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .file(let v): try v.encode(to: encoder)
            case .text(let v): try v.encode(to: encoder)
            case .unknown(let v): try v.encode(to: encoder)
            }
        }
    }
}
