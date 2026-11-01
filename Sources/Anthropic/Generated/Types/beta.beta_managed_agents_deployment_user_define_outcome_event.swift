// Transformed from `anthropic.types.beta.beta_managed_agents_deployment_user_define_outcome_event` (beta_managed_agents_deployment_user_define_outcome_event.py).

import Foundation

/// An outcome the agent should work toward. The agent begins work on receipt.
public struct BetaManagedAgentsDeploymentUserDefineOutcomeEvent: Codable, Hashable, Sendable {
    /// What the agent should produce. This is the task specification.
    public var description: String
    /// How to grade the outcome. Text or file reference.
    public var rubric: BetaManagedAgentsDeploymentUserDefineOutcomeEvent.Rubric
    public var type: String
    /// Eval→revision cycles before giving up. Default 3, max 20.
    public var maxIterations: Int?

    public init(description: String, rubric: BetaManagedAgentsDeploymentUserDefineOutcomeEvent.Rubric, type: String = "user.define_outcome", maxIterations: Int? = nil) {
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

extension BetaManagedAgentsDeploymentUserDefineOutcomeEvent {

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
