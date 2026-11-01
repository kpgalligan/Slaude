// Transformed from `anthropic.types.beta.beta_webhook_deployment_run_succeeded_event_data` (beta_webhook_deployment_run_succeeded_event_data.py).

import Foundation

public struct BetaWebhookDeploymentRunSucceededEventData: Codable, Hashable, Sendable {
    /// ID of the deployment run that triggered the event.
    public var id: String
    public var organizationId: String
    public var type: String
    public var workspaceId: String

    public init(id: String, organizationId: String, type: String = "deployment_run.succeeded", workspaceId: String) {
        self.id = id
        self.organizationId = organizationId
        self.type = type
        self.workspaceId = workspaceId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case organizationId = "organization_id"
        case type
        case workspaceId = "workspace_id"
    }
}
