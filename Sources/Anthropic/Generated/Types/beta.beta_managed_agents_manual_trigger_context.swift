// Transformed from `anthropic.types.beta.beta_managed_agents_manual_trigger_context` (beta_managed_agents_manual_trigger_context.py).

import Foundation

/// The run was started manually by creating a session directly against the deployment.
public struct BetaManagedAgentsManualTriggerContext: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "manual") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
