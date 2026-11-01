// Transformed from `anthropic.resources.beta.organization.analytics.apps.apps` (apps.py).

import Foundation

public struct BetaOrganizationAnalyticsAppsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var chat: BetaOrganizationAnalyticsAppsChatResource { BetaOrganizationAnalyticsAppsChatResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsResource

        public var chat: BetaOrganizationAnalyticsAppsChatResource.WithRawResponse { resource.chat.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationAnalyticsAppsResource

        public var chat: BetaOrganizationAnalyticsAppsChatResource.WithStreamingResponse { resource.chat.withStreamingResponse }
    }
}
