// Transformed from `anthropic.resources.beta.organization.analytics.analytics` (analytics.py).

import Foundation

public struct BetaOrganizationAnalyticsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var summaries: BetaOrganizationAnalyticsSummariesResource { BetaOrganizationAnalyticsSummariesResource(client: client) }

    public var users: BetaOrganizationAnalyticsUsersResource { BetaOrganizationAnalyticsUsersResource(client: client) }

    public var apps: BetaOrganizationAnalyticsAppsResource { BetaOrganizationAnalyticsAppsResource(client: client) }

    public var connectors: BetaOrganizationAnalyticsConnectorsResource { BetaOrganizationAnalyticsConnectorsResource(client: client) }

    public var plugins: BetaOrganizationAnalyticsPluginsResource { BetaOrganizationAnalyticsPluginsResource(client: client) }

    public var skills: BetaOrganizationAnalyticsSkillsResource { BetaOrganizationAnalyticsSkillsResource(client: client) }

    public var artifacts: BetaOrganizationAnalyticsArtifactsResource { BetaOrganizationAnalyticsArtifactsResource(client: client) }

    public var usage: BetaOrganizationAnalyticsUsageResource { BetaOrganizationAnalyticsUsageResource(client: client) }

    public var cost: BetaOrganizationAnalyticsCostResource { BetaOrganizationAnalyticsCostResource(client: client) }

    public var usageReport: BetaOrganizationAnalyticsUsageReportResource { BetaOrganizationAnalyticsUsageReportResource(client: client) }

    public var userUsageReport: BetaOrganizationAnalyticsUserUsageReportResource { BetaOrganizationAnalyticsUserUsageReportResource(client: client) }

    public var costReport: BetaOrganizationAnalyticsCostReportResource { BetaOrganizationAnalyticsCostReportResource(client: client) }

    public var userCostReport: BetaOrganizationAnalyticsUserCostReportResource { BetaOrganizationAnalyticsUserCostReportResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsResource

        public var summaries: BetaOrganizationAnalyticsSummariesResource.WithRawResponse { resource.summaries.withRawResponse }

        public var users: BetaOrganizationAnalyticsUsersResource.WithRawResponse { resource.users.withRawResponse }

        public var apps: BetaOrganizationAnalyticsAppsResource.WithRawResponse { resource.apps.withRawResponse }

        public var connectors: BetaOrganizationAnalyticsConnectorsResource.WithRawResponse { resource.connectors.withRawResponse }

        public var plugins: BetaOrganizationAnalyticsPluginsResource.WithRawResponse { resource.plugins.withRawResponse }

        public var skills: BetaOrganizationAnalyticsSkillsResource.WithRawResponse { resource.skills.withRawResponse }

        public var artifacts: BetaOrganizationAnalyticsArtifactsResource.WithRawResponse { resource.artifacts.withRawResponse }

        public var usage: BetaOrganizationAnalyticsUsageResource.WithRawResponse { resource.usage.withRawResponse }

        public var cost: BetaOrganizationAnalyticsCostResource.WithRawResponse { resource.cost.withRawResponse }

        public var usageReport: BetaOrganizationAnalyticsUsageReportResource.WithRawResponse { resource.usageReport.withRawResponse }

        public var userUsageReport: BetaOrganizationAnalyticsUserUsageReportResource.WithRawResponse { resource.userUsageReport.withRawResponse }

        public var costReport: BetaOrganizationAnalyticsCostReportResource.WithRawResponse { resource.costReport.withRawResponse }

        public var userCostReport: BetaOrganizationAnalyticsUserCostReportResource.WithRawResponse { resource.userCostReport.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsResource

        public var summaries: BetaOrganizationAnalyticsSummariesResource.WithStreamingResponse { resource.summaries.withStreamingResponse }

        public var users: BetaOrganizationAnalyticsUsersResource.WithStreamingResponse { resource.users.withStreamingResponse }

        public var apps: BetaOrganizationAnalyticsAppsResource.WithStreamingResponse { resource.apps.withStreamingResponse }

        public var connectors: BetaOrganizationAnalyticsConnectorsResource.WithStreamingResponse { resource.connectors.withStreamingResponse }

        public var plugins: BetaOrganizationAnalyticsPluginsResource.WithStreamingResponse { resource.plugins.withStreamingResponse }

        public var skills: BetaOrganizationAnalyticsSkillsResource.WithStreamingResponse { resource.skills.withStreamingResponse }

        public var artifacts: BetaOrganizationAnalyticsArtifactsResource.WithStreamingResponse { resource.artifacts.withStreamingResponse }

        public var usage: BetaOrganizationAnalyticsUsageResource.WithStreamingResponse { resource.usage.withStreamingResponse }

        public var cost: BetaOrganizationAnalyticsCostResource.WithStreamingResponse { resource.cost.withStreamingResponse }

        public var usageReport: BetaOrganizationAnalyticsUsageReportResource.WithStreamingResponse { resource.usageReport.withStreamingResponse }

        public var userUsageReport: BetaOrganizationAnalyticsUserUsageReportResource.WithStreamingResponse { resource.userUsageReport.withStreamingResponse }

        public var costReport: BetaOrganizationAnalyticsCostReportResource.WithStreamingResponse { resource.costReport.withStreamingResponse }

        public var userCostReport: BetaOrganizationAnalyticsUserCostReportResource.WithStreamingResponse { resource.userCostReport.withStreamingResponse }
    }
}
