// Transformed from `anthropic.resources.beta.organization.analytics.apps.chat.chat` (chat.py).

import Foundation

public struct BetaOrganizationAnalyticsAppsChatResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var projects: BetaOrganizationAnalyticsAppsChatProjectsResource { BetaOrganizationAnalyticsAppsChatProjectsResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsChatResource

        public var projects: BetaOrganizationAnalyticsAppsChatProjectsResource.WithRawResponse { resource.projects.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsChatResource

        public var projects: BetaOrganizationAnalyticsAppsChatProjectsResource.WithStreamingResponse { resource.projects.withStreamingResponse }
    }
}
