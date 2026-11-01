// Transformed from `anthropic.types.beta.sessions.beta_managed_agents_session_refusal` (beta_managed_agents_session_refusal.py).

import Foundation

/// The turn ended because the model's response was refused, for example by a safety classifier.
public struct BetaManagedAgentsSessionRefusal: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "refusal") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
