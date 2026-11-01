// Transformed from `anthropic.types.beta.beta_managed_agents_advisor_params` (beta_managed_agents_advisor_params.py).

import Foundation

/// Platform advisor roster entry: a model the session's primary thread may consult mid-turn. At most one per roster; the entry occupies the roster name `anthropic.advisor`.
public struct BetaManagedAgentsAdvisorParams: Codable, Hashable, Sendable {
    /// A Claude model id.
    ///
    /// The model must be permitted as an advisor for this agent's model.
    public var model: String
    public var type: String

    public init(model: String, type: String = "advisor") {
        self.model = model
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case model
        case type
    }
}
