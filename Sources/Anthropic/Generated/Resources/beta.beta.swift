// Transformed from `anthropic.resources.beta.beta` (beta.py).

import Foundation

public struct BetaResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var models: BetaModelsResource { BetaModelsResource(client: client) }

    public var messages: BetaMessagesResource { BetaMessagesResource(client: client) }

    public var agents: BetaAgentsResource { BetaAgentsResource(client: client) }

    public var environments: BetaEnvironmentsResource { BetaEnvironmentsResource(client: client) }

    public var sessions: BetaSessionsResource { BetaSessionsResource(client: client) }

    public var deployments: BetaDeploymentsResource { BetaDeploymentsResource(client: client) }

    public var deploymentRuns: BetaDeploymentRunsResource { BetaDeploymentRunsResource(client: client) }

    public var vaults: BetaVaultsResource { BetaVaultsResource(client: client) }

    public var memoryStores: BetaMemoryStoresResource { BetaMemoryStoresResource(client: client) }

    public var files: BetaFilesResource { BetaFilesResource(client: client) }

    public var skills: BetaSkillsResource { BetaSkillsResource(client: client) }

    public var webhooks: BetaWebhooksResource { BetaWebhooksResource(client: client) }

    public var userProfiles: BetaUserProfilesResource { BetaUserProfilesResource(client: client) }

    public var dreams: BetaDreamsResource { BetaDreamsResource(client: client) }

    public var tunnels: BetaTunnelsResource { BetaTunnelsResource(client: client) }

    public var organization: BetaOrganizationResource { BetaOrganizationResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaResource

        public var models: BetaModelsResource.WithRawResponse { resource.models.withRawResponse }

        public var messages: BetaMessagesResource.WithRawResponse { resource.messages.withRawResponse }

        public var agents: BetaAgentsResource.WithRawResponse { resource.agents.withRawResponse }

        public var environments: BetaEnvironmentsResource.WithRawResponse { resource.environments.withRawResponse }

        public var sessions: BetaSessionsResource.WithRawResponse { resource.sessions.withRawResponse }

        public var deployments: BetaDeploymentsResource.WithRawResponse { resource.deployments.withRawResponse }

        public var deploymentRuns: BetaDeploymentRunsResource.WithRawResponse { resource.deploymentRuns.withRawResponse }

        public var vaults: BetaVaultsResource.WithRawResponse { resource.vaults.withRawResponse }

        public var memoryStores: BetaMemoryStoresResource.WithRawResponse { resource.memoryStores.withRawResponse }

        public var files: BetaFilesResource.WithRawResponse { resource.files.withRawResponse }

        public var skills: BetaSkillsResource.WithRawResponse { resource.skills.withRawResponse }

        public var webhooks: BetaWebhooksResource.WithRawResponse { resource.webhooks.withRawResponse }

        public var userProfiles: BetaUserProfilesResource.WithRawResponse { resource.userProfiles.withRawResponse }

        public var dreams: BetaDreamsResource.WithRawResponse { resource.dreams.withRawResponse }

        public var tunnels: BetaTunnelsResource.WithRawResponse { resource.tunnels.withRawResponse }

        public var organization: BetaOrganizationResource.WithRawResponse { resource.organization.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaResource

        public var models: BetaModelsResource.WithStreamingResponse { resource.models.withStreamingResponse }

        public var messages: BetaMessagesResource.WithStreamingResponse { resource.messages.withStreamingResponse }

        public var agents: BetaAgentsResource.WithStreamingResponse { resource.agents.withStreamingResponse }

        public var environments: BetaEnvironmentsResource.WithStreamingResponse { resource.environments.withStreamingResponse }

        public var sessions: BetaSessionsResource.WithStreamingResponse { resource.sessions.withStreamingResponse }

        public var deployments: BetaDeploymentsResource.WithStreamingResponse { resource.deployments.withStreamingResponse }

        public var deploymentRuns: BetaDeploymentRunsResource.WithStreamingResponse { resource.deploymentRuns.withStreamingResponse }

        public var vaults: BetaVaultsResource.WithStreamingResponse { resource.vaults.withStreamingResponse }

        public var memoryStores: BetaMemoryStoresResource.WithStreamingResponse { resource.memoryStores.withStreamingResponse }

        public var files: BetaFilesResource.WithStreamingResponse { resource.files.withStreamingResponse }

        public var skills: BetaSkillsResource.WithStreamingResponse { resource.skills.withStreamingResponse }

        public var webhooks: BetaWebhooksResource.WithStreamingResponse { resource.webhooks.withStreamingResponse }

        public var userProfiles: BetaUserProfilesResource.WithStreamingResponse { resource.userProfiles.withStreamingResponse }

        public var dreams: BetaDreamsResource.WithStreamingResponse { resource.dreams.withStreamingResponse }

        public var tunnels: BetaTunnelsResource.WithStreamingResponse { resource.tunnels.withStreamingResponse }

        public var organization: BetaOrganizationResource.WithStreamingResponse { resource.organization.withStreamingResponse }
    }
}
