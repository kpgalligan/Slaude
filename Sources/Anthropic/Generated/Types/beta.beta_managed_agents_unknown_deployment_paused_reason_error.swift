// Transformed from `anthropic.types.beta.beta_managed_agents_unknown_deployment_paused_reason_error` (beta_managed_agents_unknown_deployment_paused_reason_error.py).

import Foundation

/// An unrecognized error auto-paused the deployment.
///
/// A fallback variant; matches a run whose `error.type` is `unknown_error`.
public struct BetaManagedAgentsUnknownDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "unknown_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
