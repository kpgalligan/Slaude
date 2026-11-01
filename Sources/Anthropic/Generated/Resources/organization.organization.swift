// Transformed from `anthropic.resources.organization.organization` (organization.py).

import Foundation

public struct OrganizationResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var apiKeys: OrganizationAPIKeysResource { OrganizationAPIKeysResource(client: client) }

    public var externalKeys: OrganizationExternalKeysResource { OrganizationExternalKeysResource(client: client) }

    public var federation: OrganizationFederationResource { OrganizationFederationResource(client: client) }

    public var invites: OrganizationInvitesResource { OrganizationInvitesResource(client: client) }

    public var serviceAccounts: OrganizationServiceAccountsResource { OrganizationServiceAccountsResource(client: client) }

    public var users: OrganizationUsersResource { OrganizationUsersResource(client: client) }

    public var workspaces: OrganizationWorkspacesResource { OrganizationWorkspacesResource(client: client) }

    public var rateLimits: OrganizationRateLimitsResource { OrganizationRateLimitsResource(client: client) }

    public var complianceSettings: OrganizationComplianceSettingsResource { OrganizationComplianceSettingsResource(client: client) }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
    public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> OrganizationInfo {
        try await _retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<OrganizationInfo> {
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/me", headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.retrieve")
        return try await client.requestResponse(OrganizationInfo.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: OrganizationResource

        public var apiKeys: OrganizationAPIKeysResource.WithRawResponse { resource.apiKeys.withRawResponse }

        public var externalKeys: OrganizationExternalKeysResource.WithRawResponse { resource.externalKeys.withRawResponse }

        public var federation: OrganizationFederationResource.WithRawResponse { resource.federation.withRawResponse }

        public var invites: OrganizationInvitesResource.WithRawResponse { resource.invites.withRawResponse }

        public var serviceAccounts: OrganizationServiceAccountsResource.WithRawResponse { resource.serviceAccounts.withRawResponse }

        public var users: OrganizationUsersResource.WithRawResponse { resource.users.withRawResponse }

        public var workspaces: OrganizationWorkspacesResource.WithRawResponse { resource.workspaces.withRawResponse }

        public var rateLimits: OrganizationRateLimitsResource.WithRawResponse { resource.rateLimits.withRawResponse }

        public var complianceSettings: OrganizationComplianceSettingsResource.WithRawResponse { resource.complianceSettings.withRawResponse }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
        public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<OrganizationInfo> {
            try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: OrganizationResource

        public var apiKeys: OrganizationAPIKeysResource.WithStreamingResponse { resource.apiKeys.withStreamingResponse }

        public var externalKeys: OrganizationExternalKeysResource.WithStreamingResponse { resource.externalKeys.withStreamingResponse }

        public var federation: OrganizationFederationResource.WithStreamingResponse { resource.federation.withStreamingResponse }

        public var invites: OrganizationInvitesResource.WithStreamingResponse { resource.invites.withStreamingResponse }

        public var serviceAccounts: OrganizationServiceAccountsResource.WithStreamingResponse { resource.serviceAccounts.withStreamingResponse }

        public var users: OrganizationUsersResource.WithStreamingResponse { resource.users.withStreamingResponse }

        public var workspaces: OrganizationWorkspacesResource.WithStreamingResponse { resource.workspaces.withStreamingResponse }

        public var rateLimits: OrganizationRateLimitsResource.WithStreamingResponse { resource.rateLimits.withStreamingResponse }

        public var complianceSettings: OrganizationComplianceSettingsResource.WithStreamingResponse { resource.complianceSettings.withStreamingResponse }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
        public func retrieve<R: Sendable>(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<OrganizationInfo>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
