// Transformed from `anthropic.resources.beta.organization.plugins.shares` (shares.py).

import Foundation

public struct BetaOrganizationPluginsSharesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List the shares the owner of a member-owned Plugin has given — to every member
    /// of the organization, to an RBAC Group, or to one member — most recently granted
    /// first.
    ///
    /// Shares are read-only in this API: members give and withdraw them in claude.ai,
    /// and who gave a share is recorded on the Compliance API activity feed rather than
    /// on the share. An organization-owned Plugin has installation settings instead, so
    /// this path returns 404 for one.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   target_type: Only shares with this kind of target: `organization` (every member),
    ///       `rbac_group` (one RBAC Group), or `organization_member` (one member).
    ///
    ///   betas: This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: ShareListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaPluginShare> {
        try await _list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: ShareListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaPluginShare>> {
        try requireNonEmpty(pluginID, "plugin_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("organization_id", organizationID)
        try query.set("page", page)
        try query.set("target_type", targetType)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/shares", ["plugin_id": pluginID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.shares.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaPluginShare>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationPluginsSharesResource

    /// List the shares the owner of a member-owned Plugin has given — to every member
    /// of the organization, to an RBAC Group, or to one member — most recently granted
    /// first.
    ///
    /// Shares are read-only in this API: members give and withdraw them in claude.ai,
    /// and who gave a share is recorded on the Compliance API activity feed rather than
    /// on the share. An organization-owned Plugin has installation settings instead, so
    /// this path returns 404 for one.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   target_type: Only shares with this kind of target: `organization` (every member),
    ///       `rbac_group` (one RBAC Group), or `organization_member` (one member).
    ///
    ///   betas: This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: ShareListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaPluginShare>> {
            try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationPluginsSharesResource

    /// List the shares the owner of a member-owned Plugin has given — to every member
    /// of the organization, to an RBAC Group, or to one member — most recently granted
    /// first.
    ///
    /// Shares are read-only in this API: members give and withdraw them in claude.ai,
    /// and who gave a share is recorded on the Compliance API activity feed rather than
    /// on the share. An organization-owned Plugin has installation settings instead, so
    /// this path returns 404 for one.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   target_type: Only shares with this kind of target: `organization` (every member),
    ///       `rbac_group` (one RBAC Group), or `organization_member` (one member).
    ///
    ///   betas: This endpoint is in beta: requests must send `ce-plugins-2026-09-01` in this
    ///       header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: ShareListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaPluginShare>>) async throws -> R) async throws -> R {
            let response = try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
