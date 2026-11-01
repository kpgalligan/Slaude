// Transformed from `anthropic.types.beta.beta_managed_agents_file_not_found_deployment_paused_reason_error` (beta_managed_agents_file_not_found_deployment_paused_reason_error.py).

import Foundation

/// A file resource referenced by the deployment no longer exists.
public struct BetaManagedAgentsFileNotFoundDeploymentPausedReasonError: Codable, Hashable, Sendable {
    public var type: String

    public init(type: String = "file_not_found_error") {
        self.type = type
    }

    enum CodingKeys: String, CodingKey {
        case type
    }
}
