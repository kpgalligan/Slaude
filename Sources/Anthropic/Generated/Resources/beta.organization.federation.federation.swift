// Transformed from `anthropic.resources.beta.organization.federation.federation` (federation.py).

import Foundation

public struct BetaOrganizationFederationResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var issuers: BetaOrganizationFederationIssuersResource { BetaOrganizationFederationIssuersResource(client: client) }

    public var rules: BetaOrganizationFederationRulesResource { BetaOrganizationFederationRulesResource(client: client) }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationFederationResource

        public var issuers: BetaOrganizationFederationIssuersResource.WithRawResponse { resource.issuers.withRawResponse }

        public var rules: BetaOrganizationFederationRulesResource.WithRawResponse { resource.rules.withRawResponse }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationFederationResource

        public var issuers: BetaOrganizationFederationIssuersResource.WithStreamingResponse { resource.issuers.withStreamingResponse }

        public var rules: BetaOrganizationFederationRulesResource.WithStreamingResponse { resource.rules.withStreamingResponse }
    }
}
