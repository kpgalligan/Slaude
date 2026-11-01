// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_user_define_outcome_event_params` (beta_managed_agents_user_define_outcome_event_params.py).

import Foundation

/// Parameters for defining an outcome the agent should work toward.
///
/// The agent begins work on receipt.
public struct BetaManagedAgentsUserDefineOutcomeEventParams: Codable, Hashable, Sendable {
    /// What the agent should produce. This is the task specification.
    public var description: String
    /// How to grade the outcome. Text or file reference.
    public var rubric: BetaManagedAgentsUserDefineOutcomeEventParams.Rubric
    public var type: String
    /// Eval→revision cycles before giving up. Default 3, max 20.
    public var maxIterations: Int??

    public init(description: String, rubric: BetaManagedAgentsUserDefineOutcomeEventParams.Rubric, type: String = "user.define_outcome", maxIterations: Int?? = nil) {
        self.description = description
        self.rubric = rubric
        self.type = type
        self.maxIterations = maxIterations
    }

    enum CodingKeys: String, CodingKey {
        case description
        case rubric
        case type
        case maxIterations = "max_iterations"
    }
}

extension BetaManagedAgentsUserDefineOutcomeEventParams {

    public indirect enum Rubric: Codable, Hashable, Sendable {
        case file(BetaManagedAgentsFileRubricParams)
        case text(BetaManagedAgentsTextRubricParams)
        /// A value that matched none of the known variants.
        case unknown(JSONValue)

        public init(from decoder: Decoder) throws {
            switch _Coding.discriminator(decoder, "type") {
            case "file": self = .file(try BetaManagedAgentsFileRubricParams(from: decoder))
            case "text": self = .text(try BetaManagedAgentsTextRubricParams(from: decoder))
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
