// Transformed from `anthropic.resources.organization.federation.federation` (federation.py).

import Foundation

public struct OrganizationFederationResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var issuers: OrganizationFederationIssuersResource { OrganizationFederationIssuersResource(client: client) }

    public var rules: OrganizationFederationRulesResource { OrganizationFederationRulesResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationFederationResource

        public var issuers: OrganizationFederationIssuersResource.WithRawResponse { resource.issuers.withRawResponse }

        public var rules: OrganizationFederationRulesResource.WithRawResponse { resource.rules.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationFederationResource

        public var issuers: OrganizationFederationIssuersResource.WithStreamingResponse { resource.issuers.withStreamingResponse }

        public var rules: OrganizationFederationRulesResource.WithStreamingResponse { resource.rules.withStreamingResponse }
    }
}
