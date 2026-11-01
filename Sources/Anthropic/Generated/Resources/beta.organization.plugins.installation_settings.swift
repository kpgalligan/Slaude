// Transformed from `anthropic.resources.beta.organization.plugins.installation_settings` (installation_settings.py).

import Foundation

public struct BetaOrganizationPluginsInstallationSettingsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List an organization-owned Plugin's installation settings, which say which
    /// members it is for, most recently created first.
    ///
    /// The list holds the Plugin's own organization-wide setting (absent while the
    /// Plugin inherits its marketplace's default) and each RBAC Group's own setting. A
    /// member-owned Plugin has shares instead, so this path returns 404 for one.
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
    ///   target_type: Only settings for this kind of target: `organization` (the organization-wide
    ///       setting) or `rbac_group` (an RBAC Group's).
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
    public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: InstallationSettingListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaPluginInstallationSetting> {
        try await _list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: InstallationSettingListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaPluginInstallationSetting>> {
        try requireNonEmpty(pluginID, "plugin_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("organization_id", organizationID)
        try query.set("page", page)
        try query.set("target_type", targetType)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/installation_settings", ["plugin_id": pluginID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.installation_settings.list")
        return try await client.requestPageResponse(PageCursor<BetaPluginInstallationSetting>.self, options, stream: _mode == .stream)
    }

    /// Remove an organization-owned Plugin's own installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Removing the `organization` target returns the Plugin to its marketplace's
    /// default installation setting and leaves the groups' settings in place. Removing
    /// a group's setting makes the group's members fall back to the Plugin's
    /// organization-wide setting or to the settings of their other groups.
    ///
    /// A target that holds no setting of its own returns 404 (a Plugin that already
    /// inherits its marketplace's default holds no `organization` setting), and so does
    /// a member-owned Plugin.
    ///
    /// A removal counts as one of the Plugin's installation-setting writes: send all of
    /// those writes one at a time. If several arrive for the same Plugin at the same
    /// time, the server handles them one after another and can answer some of them with
    /// `503` and `x-should-retry: true` instead of applying them; wait a second or two
    /// and send the removal again. A `404` on the repeat means the setting is already
    /// gone.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose own setting is removed: the literal `organization` for the
    ///       Plugin's organization-wide setting, or an RBAC Group's ID (prefixed
    ///       `rbac_group_`) for that group's own setting. Removing the `organization` setting
    ///       returns the Plugin to its marketplace's default.
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
    public func remove(_ target: String, pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedPluginInstallationSetting {
        try await _remove(target, pluginID: pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _remove(_ target: String, pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedPluginInstallationSetting> {
        try requireNonEmpty(pluginID, "plugin_id")
        try requireNonEmpty(target, "target")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", ["plugin_id": pluginID, "target": target]), headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.installation_settings.remove")
        return try await client.requestResponse(BetaDeletedPluginInstallationSetting.self, options, stream: _mode == .stream)
    }

    /// Set or change an organization-owned Plugin's installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Writing the value a target already holds of its own changes nothing.
    ///
    /// A member-owned Plugin has shares instead of installation settings, so this path
    /// returns 404 for one.
    ///
    /// Send a Plugin's installation-setting writes one at a time. If several writes for
    /// the same Plugin arrive at the same time, the server handles them one after
    /// another and can answer some of them with `503` instead of applying them. That
    /// `503` carries `x-should-retry: true`, and the write is safe to repeat: wait a
    /// second or two, then send it again.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose setting is written: the literal `organization` for the Plugin's
    ///       organization-wide setting, or an RBAC Group's ID (prefixed `rbac_group_`) for
    ///       that group's own setting. Writing the `organization` target stops the Plugin
    ///       from inheriting its marketplace's default, even when the value written equals
    ///       that default.
    ///
    ///   installation_preference: The installation setting the target is to hold for this Plugin: one of
    ///       `required`, `auto_install`, `available`, `not_available`.
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
    public func set(_ target: String, pluginID: String, installationPreference: InstallationSettingSetParams.InstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginInstallationSetting {
        try await _set(target, pluginID: pluginID, installationPreference: installationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _set(_ target: String, pluginID: String, installationPreference: InstallationSettingSetParams.InstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginInstallationSetting> {
        try requireNonEmpty(pluginID, "plugin_id")
        try requireNonEmpty(target, "target")
        var body = ParamsBuilder()
        try body.set("installation_preference", installationPreference)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/installation_settings/{target}", ["plugin_id": pluginID, "target": target]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.installation_settings.set")
        return try await client.requestResponse(BetaPluginInstallationSetting.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationPluginsInstallationSettingsResource

    /// List an organization-owned Plugin's installation settings, which say which
    /// members it is for, most recently created first.
    ///
    /// The list holds the Plugin's own organization-wide setting (absent while the
    /// Plugin inherits its marketplace's default) and each RBAC Group's own setting. A
    /// member-owned Plugin has shares instead, so this path returns 404 for one.
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
    ///   target_type: Only settings for this kind of target: `organization` (the organization-wide
    ///       setting) or `rbac_group` (an RBAC Group's).
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
        public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: InstallationSettingListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaPluginInstallationSetting>> {
            try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Remove an organization-owned Plugin's own installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Removing the `organization` target returns the Plugin to its marketplace's
    /// default installation setting and leaves the groups' settings in place. Removing
    /// a group's setting makes the group's members fall back to the Plugin's
    /// organization-wide setting or to the settings of their other groups.
    ///
    /// A target that holds no setting of its own returns 404 (a Plugin that already
    /// inherits its marketplace's default holds no `organization` setting), and so does
    /// a member-owned Plugin.
    ///
    /// A removal counts as one of the Plugin's installation-setting writes: send all of
    /// those writes one at a time. If several arrive for the same Plugin at the same
    /// time, the server handles them one after another and can answer some of them with
    /// `503` and `x-should-retry: true` instead of applying them; wait a second or two
    /// and send the removal again. A `404` on the repeat means the setting is already
    /// gone.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose own setting is removed: the literal `organization` for the
    ///       Plugin's organization-wide setting, or an RBAC Group's ID (prefixed
    ///       `rbac_group_`) for that group's own setting. Removing the `organization` setting
    ///       returns the Plugin to its marketplace's default.
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
        public func remove(_ target: String, pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedPluginInstallationSetting> {
            try await resource._remove(target, pluginID: pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Set or change an organization-owned Plugin's installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Writing the value a target already holds of its own changes nothing.
    ///
    /// A member-owned Plugin has shares instead of installation settings, so this path
    /// returns 404 for one.
    ///
    /// Send a Plugin's installation-setting writes one at a time. If several writes for
    /// the same Plugin arrive at the same time, the server handles them one after
    /// another and can answer some of them with `503` instead of applying them. That
    /// `503` carries `x-should-retry: true`, and the write is safe to repeat: wait a
    /// second or two, then send it again.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose setting is written: the literal `organization` for the Plugin's
    ///       organization-wide setting, or an RBAC Group's ID (prefixed `rbac_group_`) for
    ///       that group's own setting. Writing the `organization` target stops the Plugin
    ///       from inheriting its marketplace's default, even when the value written equals
    ///       that default.
    ///
    ///   installation_preference: The installation setting the target is to hold for this Plugin: one of
    ///       `required`, `auto_install`, `available`, `not_available`.
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
        public func set(_ target: String, pluginID: String, installationPreference: InstallationSettingSetParams.InstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginInstallationSetting> {
            try await resource._set(target, pluginID: pluginID, installationPreference: installationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationPluginsInstallationSettingsResource

    /// List an organization-owned Plugin's installation settings, which say which
    /// members it is for, most recently created first.
    ///
    /// The list holds the Plugin's own organization-wide setting (absent while the
    /// Plugin inherits its marketplace's default) and each RBAC Group's own setting. A
    /// member-owned Plugin has shares instead, so this path returns 404 for one.
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
    ///   target_type: Only settings for this kind of target: `organization` (the organization-wide
    ///       setting) or `rbac_group` (an RBAC Group's).
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
        public func list<R: Sendable>(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, targetType: InstallationSettingListParams.TargetType?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaPluginInstallationSetting>>) async throws -> R) async throws -> R {
            let response = try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, targetType: targetType, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Remove an organization-owned Plugin's own installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Removing the `organization` target returns the Plugin to its marketplace's
    /// default installation setting and leaves the groups' settings in place. Removing
    /// a group's setting makes the group's members fall back to the Plugin's
    /// organization-wide setting or to the settings of their other groups.
    ///
    /// A target that holds no setting of its own returns 404 (a Plugin that already
    /// inherits its marketplace's default holds no `organization` setting), and so does
    /// a member-owned Plugin.
    ///
    /// A removal counts as one of the Plugin's installation-setting writes: send all of
    /// those writes one at a time. If several arrive for the same Plugin at the same
    /// time, the server handles them one after another and can answer some of them with
    /// `503` and `x-should-retry: true` instead of applying them; wait a second or two
    /// and send the removal again. A `404` on the repeat means the setting is already
    /// gone.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose own setting is removed: the literal `organization` for the
    ///       Plugin's organization-wide setting, or an RBAC Group's ID (prefixed
    ///       `rbac_group_`) for that group's own setting. Removing the `organization` setting
    ///       returns the Plugin to its marketplace's default.
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
        public func remove<R: Sendable>(_ target: String, pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedPluginInstallationSetting>) async throws -> R) async throws -> R {
            let response = try await resource._remove(target, pluginID: pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Set or change an organization-owned Plugin's installation setting for the whole
    /// organization or for one RBAC Group.
    ///
    /// Writing the value a target already holds of its own changes nothing.
    ///
    /// A member-owned Plugin has shares instead of installation settings, so this path
    /// returns 404 for one.
    ///
    /// Send a Plugin's installation-setting writes one at a time. If several writes for
    /// the same Plugin arrive at the same time, the server handles them one after
    /// another and can answer some of them with `503` instead of applying them. That
    /// `503` carries `x-should-retry: true`, and the write is safe to repeat: wait a
    /// second or two, then send it again.
    ///
    /// **Accepted credentials:** an Admin API key with the `write:plugins` scope.
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
    ///   target: The target whose setting is written: the literal `organization` for the Plugin's
    ///       organization-wide setting, or an RBAC Group's ID (prefixed `rbac_group_`) for
    ///       that group's own setting. Writing the `organization` target stops the Plugin
    ///       from inheriting its marketplace's default, even when the value written equals
    ///       that default.
    ///
    ///   installation_preference: The installation setting the target is to hold for this Plugin: one of
    ///       `required`, `auto_install`, `available`, `not_available`.
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
        public func set<R: Sendable>(_ target: String, pluginID: String, installationPreference: InstallationSettingSetParams.InstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginInstallationSetting>) async throws -> R) async throws -> R {
            let response = try await resource._set(target, pluginID: pluginID, installationPreference: installationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
