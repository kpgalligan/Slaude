// Transformed from `anthropic.resources.beta.organization.organization` (organization.py).

import Foundation

public struct BetaOrganizationResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var apiKeys: BetaOrganizationAPIKeysResource { BetaOrganizationAPIKeysResource(client: client) }

    public var externalKeys: BetaOrganizationExternalKeysResource { BetaOrganizationExternalKeysResource(client: client) }

    public var federation: BetaOrganizationFederationResource { BetaOrganizationFederationResource(client: client) }

    public var invites: BetaOrganizationInvitesResource { BetaOrganizationInvitesResource(client: client) }

    public var serviceAccounts: BetaOrganizationServiceAccountsResource { BetaOrganizationServiceAccountsResource(client: client) }

    public var users: BetaOrganizationUsersResource { BetaOrganizationUsersResource(client: client) }

    public var workspaces: BetaOrganizationWorkspacesResource { BetaOrganizationWorkspacesResource(client: client) }

    public var rateLimits: BetaOrganizationRateLimitsResource { BetaOrganizationRateLimitsResource(client: client) }

    public var complianceSettings: BetaOrganizationComplianceSettingsResource { BetaOrganizationComplianceSettingsResource(client: client) }

    public var analytics: BetaOrganizationAnalyticsResource { BetaOrganizationAnalyticsResource(client: client) }

    public var spendLimits: BetaOrganizationSpendLimitsResource { BetaOrganizationSpendLimitsResource(client: client) }

    public var rbacGroups: BetaOrganizationRbacGroupsRBACGroupsResource { BetaOrganizationRbacGroupsRBACGroupsResource(client: client) }

    public var rbacRoles: BetaOrganizationRbacRolesRBACRolesResource { BetaOrganizationRbacRolesRBACRolesResource(client: client) }

    public var plugins: BetaOrganizationPluginsResource { BetaOrganizationPluginsResource(client: client) }

    public var pluginMarketplaces: BetaOrganizationPluginMarketplacesResource { BetaOrganizationPluginMarketplacesResource(client: client) }

    public var telemetryDestinations: BetaOrganizationTelemetryDestinationsResource { BetaOrganizationTelemetryDestinationsResource(client: client) }

    public var webhooks: BetaOrganizationWebhooksResource { BetaOrganizationWebhooksResource(client: client) }

    public var claudeTag: BetaOrganizationClaudeTagResource { BetaOrganizationClaudeTagResource(client: client) }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
    public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaOrganization {
        try await _retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaOrganization> {
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/me", headers: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaOrganization.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationResource

        public var apiKeys: BetaOrganizationAPIKeysResource.WithRawResponse { resource.apiKeys.withRawResponse }

        public var externalKeys: BetaOrganizationExternalKeysResource.WithRawResponse { resource.externalKeys.withRawResponse }

        public var federation: BetaOrganizationFederationResource.WithRawResponse { resource.federation.withRawResponse }

        public var invites: BetaOrganizationInvitesResource.WithRawResponse { resource.invites.withRawResponse }

        public var serviceAccounts: BetaOrganizationServiceAccountsResource.WithRawResponse { resource.serviceAccounts.withRawResponse }

        public var users: BetaOrganizationUsersResource.WithRawResponse { resource.users.withRawResponse }

        public var workspaces: BetaOrganizationWorkspacesResource.WithRawResponse { resource.workspaces.withRawResponse }

        public var rateLimits: BetaOrganizationRateLimitsResource.WithRawResponse { resource.rateLimits.withRawResponse }

        public var complianceSettings: BetaOrganizationComplianceSettingsResource.WithRawResponse { resource.complianceSettings.withRawResponse }

        public var analytics: BetaOrganizationAnalyticsResource.WithRawResponse { resource.analytics.withRawResponse }

        public var spendLimits: BetaOrganizationSpendLimitsResource.WithRawResponse { resource.spendLimits.withRawResponse }

        public var rbacGroups: BetaOrganizationRbacGroupsRBACGroupsResource.WithRawResponse { resource.rbacGroups.withRawResponse }

        public var rbacRoles: BetaOrganizationRbacRolesRBACRolesResource.WithRawResponse { resource.rbacRoles.withRawResponse }

        public var plugins: BetaOrganizationPluginsResource.WithRawResponse { resource.plugins.withRawResponse }

        public var pluginMarketplaces: BetaOrganizationPluginMarketplacesResource.WithRawResponse { resource.pluginMarketplaces.withRawResponse }

        public var telemetryDestinations: BetaOrganizationTelemetryDestinationsResource.WithRawResponse { resource.telemetryDestinations.withRawResponse }

        public var webhooks: BetaOrganizationWebhooksResource.WithRawResponse { resource.webhooks.withRawResponse }

        public var claudeTag: BetaOrganizationClaudeTagResource.WithRawResponse { resource.claudeTag.withRawResponse }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
        public func retrieve(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaOrganization> {
            try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationResource

        public var apiKeys: BetaOrganizationAPIKeysResource.WithStreamingResponse { resource.apiKeys.withStreamingResponse }

        public var externalKeys: BetaOrganizationExternalKeysResource.WithStreamingResponse { resource.externalKeys.withStreamingResponse }

        public var federation: BetaOrganizationFederationResource.WithStreamingResponse { resource.federation.withStreamingResponse }

        public var invites: BetaOrganizationInvitesResource.WithStreamingResponse { resource.invites.withStreamingResponse }

        public var serviceAccounts: BetaOrganizationServiceAccountsResource.WithStreamingResponse { resource.serviceAccounts.withStreamingResponse }

        public var users: BetaOrganizationUsersResource.WithStreamingResponse { resource.users.withStreamingResponse }

        public var workspaces: BetaOrganizationWorkspacesResource.WithStreamingResponse { resource.workspaces.withStreamingResponse }

        public var rateLimits: BetaOrganizationRateLimitsResource.WithStreamingResponse { resource.rateLimits.withStreamingResponse }

        public var complianceSettings: BetaOrganizationComplianceSettingsResource.WithStreamingResponse { resource.complianceSettings.withStreamingResponse }

        public var analytics: BetaOrganizationAnalyticsResource.WithStreamingResponse { resource.analytics.withStreamingResponse }

        public var spendLimits: BetaOrganizationSpendLimitsResource.WithStreamingResponse { resource.spendLimits.withStreamingResponse }

        public var rbacGroups: BetaOrganizationRbacGroupsRBACGroupsResource.WithStreamingResponse { resource.rbacGroups.withStreamingResponse }

        public var rbacRoles: BetaOrganizationRbacRolesRBACRolesResource.WithStreamingResponse { resource.rbacRoles.withStreamingResponse }

        public var plugins: BetaOrganizationPluginsResource.WithStreamingResponse { resource.plugins.withStreamingResponse }

        public var pluginMarketplaces: BetaOrganizationPluginMarketplacesResource.WithStreamingResponse { resource.pluginMarketplaces.withStreamingResponse }

        public var telemetryDestinations: BetaOrganizationTelemetryDestinationsResource.WithStreamingResponse { resource.telemetryDestinations.withStreamingResponse }

        public var webhooks: BetaOrganizationWebhooksResource.WithStreamingResponse { resource.webhooks.withStreamingResponse }

        public var claudeTag: BetaOrganizationClaudeTagResource.WithStreamingResponse { resource.claudeTag.withStreamingResponse }

    /// Retrieve information about the organization associated with the authenticated
    /// API key.
        public func retrieve<R: Sendable>(extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaOrganization>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
