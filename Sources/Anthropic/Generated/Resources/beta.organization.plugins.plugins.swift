// Transformed from `anthropic.resources.beta.organization.plugins.plugins` (plugins.py).

import Foundation

public struct BetaOrganizationPluginsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var versions: BetaOrganizationPluginsVersionsResource { BetaOrganizationPluginsVersionsResource(client: client) }

    public var installationSettings: BetaOrganizationPluginsInstallationSettingsResource { BetaOrganizationPluginsInstallationSettingsResource(client: client) }

    public var shares: BetaOrganizationPluginsSharesResource { BetaOrganizationPluginsSharesResource(client: client) }

    /// Create an organization-owned Plugin and its first version by uploading the
    /// version's files.
    ///
    /// The upload is `multipart/form-data`: the version's files (`files`, each part
    /// sent as `files[]`), with an optional `marketplace_id` and `release_notes`. The
    /// manifest's `name` becomes the Plugin's `name`, and `display_name`, `description`
    /// and `manifest_version` come from the manifest too.
    ///
    /// `name` may contain lowercase letters (from any alphabet), digits, and hyphens,
    /// up to 64 characters. Uppercase letters, spaces, underscores, and other
    /// punctuation are rejected.
    ///
    /// The `name` must be unique within the marketplace: a name already taken returns a
    /// 409 with `error_code` `plugin_name_taken` and, when a Plugin holds it, that
    /// Plugin's ID in `details.plugin_id`. A Plugin going into the organization's
    /// library marketplace is also refused with a 409 when one of its skills has the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai): `error_code` `skill_name_taken`, with that name in
    /// `details.skill_name`; rename the skill, or remove the organization skill in
    /// claude.ai. A 503 with `error_code` `registration_pending` means the Plugin and
    /// its version were stored (their IDs are in `details`) but are not yet usable in
    /// claude.ai: do not retry the create (the retry would return `plugin_name_taken`);
    /// create a version on the stored Plugin instead, which completes it.
    ///
    /// For a worked example, see
    /// [Create a plugin](/docs/en/manage-claude/plugins-api#create-a-plugin) in the
    /// Plugins API guide.
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
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
    ///
    ///   marketplace_id: ID of the organization-owned plugin marketplace to create the Plugin in
    ///       (prefixed `marketplace_`). It must be a `manual` marketplace, one whose Plugins
    ///       are uploaded rather than synchronized from a repository. When omitted, the
    ///       Plugin is created in the organization's library marketplace, an
    ///       organization-owned `manual` marketplace created on first use.
    ///
    ///   release_notes: Release notes stored with the version and shown in its version history in
    ///       claude.ai; up to 5,000 characters.
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
    public func create(files: [FileUpload], marketplaceID: String? = nil, releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPlugin {
        try await _create(files: files, marketplaceID: marketplaceID, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(files: [FileUpload], marketplaceID: String? = nil, releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPlugin> {
        var body = ParamsBuilder()
        body.setFiles("files", files)
        try body.set("marketplace_id", marketplaceID)
        try body.set("release_notes", releaseNotes)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/plugins", body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.create", spanRoute: "/v1/organizations/plugins", spanCreatedID: SpanCreatedID("anthropic.organization.plugin.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPlugin.self, options, stream: _mode == .stream)
    }

    /// Retrieve a Plugin by ID.
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
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
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
    public func retrieve(_ pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPlugin {
        try await _retrieve(pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPlugin> {
        try requireNonEmpty(pluginID, "plugin_id")
        var query = ParamsBuilder()
        try query.set("organization_id", organizationID)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}", ["plugin_id": pluginID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.retrieve", spanRoute: "/v1/organizations/plugins/{plugin_id}", spanAttributes: ["anthropic.organization.plugin.id": pluginID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPlugin.self, options, stream: _mode == .stream)
    }

    /// Change which stored version of an organization-owned Plugin is served to
    /// members, for example to roll back to an earlier one. This pins the served
    /// version: later uploads are stored but no longer change what is served, and
    /// pinning cannot currently be undone, here or in claude.ai.
    ///
    /// Pass the version as `served_version_id`: an earlier one to roll back, a later
    /// one to start serving a version that was stored without being served, or the one
    /// already served to pin it without changing what is served. No new version is
    /// created.
    ///
    /// When the organization has content scanning enabled, a version whose
    /// `content_scan.status` is `processing` is refused with a 409 (`error_code`
    /// `scan_pending`; retry once the scan finishes). A version whose
    /// `content_scan.status` is `errored`, or whose `content_scan.assessment` is `fail`
    /// or `unknown`, is refused with a 400 (`error_code` `scan_failed`); a `warn` is
    /// accepted. If the scan outcome cannot be read at that moment, the request fails
    /// with a retryable 503 instead. When the Plugin is in the organization's library
    /// marketplace, a version other than the one served is also refused with a 409 when
    /// one of its skills has a name that an organization skill (one an administrator
    /// uploaded for the whole organization in claude.ai) has since taken: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A member-owned
    /// Plugin cannot be updated here (403).
    ///
    /// This endpoint does not write installation settings; they are written at
    /// `/v1/organizations/plugins/{plugin_id}/installation_settings/{target}`.
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
    ///   served_version_id: Serve this version of the Plugin (prefixed `pluginver_`) and pin the served
    ///       version to it; `latest` is not accepted.
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
    public func update(_ pluginID: String, servedVersionID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPlugin {
        try await _update(pluginID, servedVersionID: servedVersionID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ pluginID: String, servedVersionID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPlugin> {
        try requireNonEmpty(pluginID, "plugin_id")
        var body = ParamsBuilder()
        try body.set("served_version_id", servedVersionID)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}", ["plugin_id": pluginID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.update", spanRoute: "/v1/organizations/plugins/{plugin_id}", spanAttributes: ["anthropic.organization.plugin.id": pluginID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPlugin.self, options, stream: _mode == .stream)
    }

    /// List the Plugins created under the organization, newest first: those in the
    /// organization's own plugin marketplaces and those in members' personal plugin
    /// marketplaces.
    ///
    /// Plugins in members' personal marketplaces are listed with the same detail as the
    /// organization's own, and their files can be downloaded through the version
    /// archive endpoint, which records each such download on the Compliance API
    /// activity feed.
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
    ///   created_at_gt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_gte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   marketplace_id: Only Plugins in this plugin marketplace (prefixed `marketplace_`).
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   owner_type: `organization` for Plugins in the organization's plugin marketplaces, `user` for
    ///       Plugins in members' personal plugin marketplaces.
    ///
    ///   owner_user_id: Only Plugins in this member's personal plugin marketplaces (prefixed `user_`); a
    ///       removed member's ID is accepted.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
    public func list(createdAtGt: PluginListParams.CreatedAtGt?? = nil, createdAtGte: PluginListParams.CreatedAtGte?? = nil, createdAtLt: PluginListParams.CreatedAtLt?? = nil, createdAtLte: PluginListParams.CreatedAtLte?? = nil, limit: Int? = nil, marketplaceID: String?? = nil, organizationID: String?? = nil, ownerType: PluginListParams.OwnerType?? = nil, ownerUserID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaPlugin> {
        try await _list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, marketplaceID: marketplaceID, organizationID: organizationID, ownerType: ownerType, ownerUserID: ownerUserID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(createdAtGt: PluginListParams.CreatedAtGt?? = nil, createdAtGte: PluginListParams.CreatedAtGte?? = nil, createdAtLt: PluginListParams.CreatedAtLt?? = nil, createdAtLte: PluginListParams.CreatedAtLte?? = nil, limit: Int? = nil, marketplaceID: String?? = nil, organizationID: String?? = nil, ownerType: PluginListParams.OwnerType?? = nil, ownerUserID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaPlugin>> {
        var query = ParamsBuilder()
        try query.set("created_at[gt]", createdAtGt)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lt]", createdAtLt)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("limit", limit)
        try query.set("marketplace_id", marketplaceID)
        try query.set("organization_id", organizationID)
        try query.set("owner_type", ownerType)
        try query.set("owner_user_id", ownerUserID)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/plugins", query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.list", spanRoute: "/v1/organizations/plugins", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaPlugin>.self, options, stream: _mode == .stream)
    }

    /// Permanently delete a Plugin and every version it holds, exactly as when an
    /// administrator deletes it in claude.ai. The Plugin may belong to the organization
    /// or to a member, including a member who has since left the organization.
    ///
    /// An organization-owned Plugin's installation settings go with it; a member-owned
    /// Plugin's shares are withdrawn and its owner no longer has it.
    ///
    /// To take an organization-owned Plugin out of use reversibly, set its
    /// organization-wide installation setting to `not_available` instead (and remove or
    /// change any group settings, which override it for their members). Only a Plugin
    /// in a `manual` marketplace can be deleted here; one synchronized from a
    /// repository is removed by removing it from the repository (400).
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
    public func delete(_ pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedPlugin {
        try await _delete(pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedPlugin> {
        try requireNonEmpty(pluginID, "plugin_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}", ["plugin_id": pluginID]), headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.delete", spanRoute: "/v1/organizations/plugins/{plugin_id}", spanAttributes: ["anthropic.organization.plugin.id": pluginID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedPlugin.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationPluginsResource

        public var versions: BetaOrganizationPluginsVersionsResource.WithRawResponse { resource.versions.withRawResponse }

        public var installationSettings: BetaOrganizationPluginsInstallationSettingsResource.WithRawResponse { resource.installationSettings.withRawResponse }

        public var shares: BetaOrganizationPluginsSharesResource.WithRawResponse { resource.shares.withRawResponse }

    /// Create an organization-owned Plugin and its first version by uploading the
    /// version's files.
    ///
    /// The upload is `multipart/form-data`: the version's files (`files`, each part
    /// sent as `files[]`), with an optional `marketplace_id` and `release_notes`. The
    /// manifest's `name` becomes the Plugin's `name`, and `display_name`, `description`
    /// and `manifest_version` come from the manifest too.
    ///
    /// `name` may contain lowercase letters (from any alphabet), digits, and hyphens,
    /// up to 64 characters. Uppercase letters, spaces, underscores, and other
    /// punctuation are rejected.
    ///
    /// The `name` must be unique within the marketplace: a name already taken returns a
    /// 409 with `error_code` `plugin_name_taken` and, when a Plugin holds it, that
    /// Plugin's ID in `details.plugin_id`. A Plugin going into the organization's
    /// library marketplace is also refused with a 409 when one of its skills has the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai): `error_code` `skill_name_taken`, with that name in
    /// `details.skill_name`; rename the skill, or remove the organization skill in
    /// claude.ai. A 503 with `error_code` `registration_pending` means the Plugin and
    /// its version were stored (their IDs are in `details`) but are not yet usable in
    /// claude.ai: do not retry the create (the retry would return `plugin_name_taken`);
    /// create a version on the stored Plugin instead, which completes it.
    ///
    /// For a worked example, see
    /// [Create a plugin](/docs/en/manage-claude/plugins-api#create-a-plugin) in the
    /// Plugins API guide.
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
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
    ///
    ///   marketplace_id: ID of the organization-owned plugin marketplace to create the Plugin in
    ///       (prefixed `marketplace_`). It must be a `manual` marketplace, one whose Plugins
    ///       are uploaded rather than synchronized from a repository. When omitted, the
    ///       Plugin is created in the organization's library marketplace, an
    ///       organization-owned `manual` marketplace created on first use.
    ///
    ///   release_notes: Release notes stored with the version and shown in its version history in
    ///       claude.ai; up to 5,000 characters.
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
        public func create(files: [FileUpload], marketplaceID: String? = nil, releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPlugin> {
            try await resource._create(files: files, marketplaceID: marketplaceID, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve a Plugin by ID.
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
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
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
        public func retrieve(_ pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPlugin> {
            try await resource._retrieve(pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Change which stored version of an organization-owned Plugin is served to
    /// members, for example to roll back to an earlier one. This pins the served
    /// version: later uploads are stored but no longer change what is served, and
    /// pinning cannot currently be undone, here or in claude.ai.
    ///
    /// Pass the version as `served_version_id`: an earlier one to roll back, a later
    /// one to start serving a version that was stored without being served, or the one
    /// already served to pin it without changing what is served. No new version is
    /// created.
    ///
    /// When the organization has content scanning enabled, a version whose
    /// `content_scan.status` is `processing` is refused with a 409 (`error_code`
    /// `scan_pending`; retry once the scan finishes). A version whose
    /// `content_scan.status` is `errored`, or whose `content_scan.assessment` is `fail`
    /// or `unknown`, is refused with a 400 (`error_code` `scan_failed`); a `warn` is
    /// accepted. If the scan outcome cannot be read at that moment, the request fails
    /// with a retryable 503 instead. When the Plugin is in the organization's library
    /// marketplace, a version other than the one served is also refused with a 409 when
    /// one of its skills has a name that an organization skill (one an administrator
    /// uploaded for the whole organization in claude.ai) has since taken: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A member-owned
    /// Plugin cannot be updated here (403).
    ///
    /// This endpoint does not write installation settings; they are written at
    /// `/v1/organizations/plugins/{plugin_id}/installation_settings/{target}`.
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
    ///   served_version_id: Serve this version of the Plugin (prefixed `pluginver_`) and pin the served
    ///       version to it; `latest` is not accepted.
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
        public func update(_ pluginID: String, servedVersionID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPlugin> {
            try await resource._update(pluginID, servedVersionID: servedVersionID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the Plugins created under the organization, newest first: those in the
    /// organization's own plugin marketplaces and those in members' personal plugin
    /// marketplaces.
    ///
    /// Plugins in members' personal marketplaces are listed with the same detail as the
    /// organization's own, and their files can be downloaded through the version
    /// archive endpoint, which records each such download on the Compliance API
    /// activity feed.
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
    ///   created_at_gt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_gte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   marketplace_id: Only Plugins in this plugin marketplace (prefixed `marketplace_`).
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   owner_type: `organization` for Plugins in the organization's plugin marketplaces, `user` for
    ///       Plugins in members' personal plugin marketplaces.
    ///
    ///   owner_user_id: Only Plugins in this member's personal plugin marketplaces (prefixed `user_`); a
    ///       removed member's ID is accepted.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
        public func list(createdAtGt: PluginListParams.CreatedAtGt?? = nil, createdAtGte: PluginListParams.CreatedAtGte?? = nil, createdAtLt: PluginListParams.CreatedAtLt?? = nil, createdAtLte: PluginListParams.CreatedAtLte?? = nil, limit: Int? = nil, marketplaceID: String?? = nil, organizationID: String?? = nil, ownerType: PluginListParams.OwnerType?? = nil, ownerUserID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaPlugin>> {
            try await resource._list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, marketplaceID: marketplaceID, organizationID: organizationID, ownerType: ownerType, ownerUserID: ownerUserID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Permanently delete a Plugin and every version it holds, exactly as when an
    /// administrator deletes it in claude.ai. The Plugin may belong to the organization
    /// or to a member, including a member who has since left the organization.
    ///
    /// An organization-owned Plugin's installation settings go with it; a member-owned
    /// Plugin's shares are withdrawn and its owner no longer has it.
    ///
    /// To take an organization-owned Plugin out of use reversibly, set its
    /// organization-wide installation setting to `not_available` instead (and remove or
    /// change any group settings, which override it for their members). Only a Plugin
    /// in a `manual` marketplace can be deleted here; one synchronized from a
    /// repository is removed by removing it from the repository (400).
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
        public func delete(_ pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedPlugin> {
            try await resource._delete(pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationPluginsResource

        public var versions: BetaOrganizationPluginsVersionsResource.WithStreamingResponse { resource.versions.withStreamingResponse }

        public var installationSettings: BetaOrganizationPluginsInstallationSettingsResource.WithStreamingResponse { resource.installationSettings.withStreamingResponse }

        public var shares: BetaOrganizationPluginsSharesResource.WithStreamingResponse { resource.shares.withStreamingResponse }

    /// Create an organization-owned Plugin and its first version by uploading the
    /// version's files.
    ///
    /// The upload is `multipart/form-data`: the version's files (`files`, each part
    /// sent as `files[]`), with an optional `marketplace_id` and `release_notes`. The
    /// manifest's `name` becomes the Plugin's `name`, and `display_name`, `description`
    /// and `manifest_version` come from the manifest too.
    ///
    /// `name` may contain lowercase letters (from any alphabet), digits, and hyphens,
    /// up to 64 characters. Uppercase letters, spaces, underscores, and other
    /// punctuation are rejected.
    ///
    /// The `name` must be unique within the marketplace: a name already taken returns a
    /// 409 with `error_code` `plugin_name_taken` and, when a Plugin holds it, that
    /// Plugin's ID in `details.plugin_id`. A Plugin going into the organization's
    /// library marketplace is also refused with a 409 when one of its skills has the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai): `error_code` `skill_name_taken`, with that name in
    /// `details.skill_name`; rename the skill, or remove the organization skill in
    /// claude.ai. A 503 with `error_code` `registration_pending` means the Plugin and
    /// its version were stored (their IDs are in `details`) but are not yet usable in
    /// claude.ai: do not retry the create (the retry would return `plugin_name_taken`);
    /// create a version on the stored Plugin instead, which completes it.
    ///
    /// For a worked example, see
    /// [Create a plugin](/docs/en/manage-claude/plugins-api#create-a-plugin) in the
    /// Plugins API guide.
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
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
    ///
    ///   marketplace_id: ID of the organization-owned plugin marketplace to create the Plugin in
    ///       (prefixed `marketplace_`). It must be a `manual` marketplace, one whose Plugins
    ///       are uploaded rather than synchronized from a repository. When omitted, the
    ///       Plugin is created in the organization's library marketplace, an
    ///       organization-owned `manual` marketplace created on first use.
    ///
    ///   release_notes: Release notes stored with the version and shown in its version history in
    ///       claude.ai; up to 5,000 characters.
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
        public func create<R: Sendable>(files: [FileUpload], marketplaceID: String? = nil, releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPlugin>) async throws -> R) async throws -> R {
            let response = try await resource._create(files: files, marketplaceID: marketplaceID, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve a Plugin by ID.
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
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
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
        public func retrieve<R: Sendable>(_ pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPlugin>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Change which stored version of an organization-owned Plugin is served to
    /// members, for example to roll back to an earlier one. This pins the served
    /// version: later uploads are stored but no longer change what is served, and
    /// pinning cannot currently be undone, here or in claude.ai.
    ///
    /// Pass the version as `served_version_id`: an earlier one to roll back, a later
    /// one to start serving a version that was stored without being served, or the one
    /// already served to pin it without changing what is served. No new version is
    /// created.
    ///
    /// When the organization has content scanning enabled, a version whose
    /// `content_scan.status` is `processing` is refused with a 409 (`error_code`
    /// `scan_pending`; retry once the scan finishes). A version whose
    /// `content_scan.status` is `errored`, or whose `content_scan.assessment` is `fail`
    /// or `unknown`, is refused with a 400 (`error_code` `scan_failed`); a `warn` is
    /// accepted. If the scan outcome cannot be read at that moment, the request fails
    /// with a retryable 503 instead. When the Plugin is in the organization's library
    /// marketplace, a version other than the one served is also refused with a 409 when
    /// one of its skills has a name that an organization skill (one an administrator
    /// uploaded for the whole organization in claude.ai) has since taken: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A member-owned
    /// Plugin cannot be updated here (403).
    ///
    /// This endpoint does not write installation settings; they are written at
    /// `/v1/organizations/plugins/{plugin_id}/installation_settings/{target}`.
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
    ///   served_version_id: Serve this version of the Plugin (prefixed `pluginver_`) and pin the served
    ///       version to it; `latest` is not accepted.
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
        public func update<R: Sendable>(_ pluginID: String, servedVersionID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPlugin>) async throws -> R) async throws -> R {
            let response = try await resource._update(pluginID, servedVersionID: servedVersionID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the Plugins created under the organization, newest first: those in the
    /// organization's own plugin marketplaces and those in members' personal plugin
    /// marketplaces.
    ///
    /// Plugins in members' personal marketplaces are listed with the same detail as the
    /// organization's own, and their files can be downloaded through the version
    /// archive endpoint, which records each such download on the Compliance API
    /// activity feed.
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
    ///   created_at_gt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_gte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lt: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   created_at_lte: RFC 3339 timestamp bound; combine [gte], [gt], [lte], [lt].
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `100`.
    ///
    ///   marketplace_id: Only Plugins in this plugin marketplace (prefixed `marketplace_`).
    ///
    ///   organization_id: For a `read:org_audit` or `read:compliance_org_data` key created for all of a
    ///       parent organization's linked organizations: a child organization of that parent
    ///       to read instead of the organization the key was created in, given as the
    ///       organization's UUID or its `org_`-prefixed ID. A value that is neither returns a
    ///       400; an organization that is not a child of the key's parent, or where the
    ///       Plugins API is not available, returns a 404. Any other key may pass only its own
    ///       organization's ID here; another organization returns a 404.
    ///
    ///   owner_type: `organization` for Plugins in the organization's plugin marketplaces, `user` for
    ///       Plugins in members' personal plugin marketplaces.
    ///
    ///   owner_user_id: Only Plugins in this member's personal plugin marketplaces (prefixed `user_`); a
    ///       removed member's ID is accepted.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
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
        public func list<R: Sendable>(createdAtGt: PluginListParams.CreatedAtGt?? = nil, createdAtGte: PluginListParams.CreatedAtGte?? = nil, createdAtLt: PluginListParams.CreatedAtLt?? = nil, createdAtLte: PluginListParams.CreatedAtLte?? = nil, limit: Int? = nil, marketplaceID: String?? = nil, organizationID: String?? = nil, ownerType: PluginListParams.OwnerType?? = nil, ownerUserID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaPlugin>>) async throws -> R) async throws -> R {
            let response = try await resource._list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, marketplaceID: marketplaceID, organizationID: organizationID, ownerType: ownerType, ownerUserID: ownerUserID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Permanently delete a Plugin and every version it holds, exactly as when an
    /// administrator deletes it in claude.ai. The Plugin may belong to the organization
    /// or to a member, including a member who has since left the organization.
    ///
    /// An organization-owned Plugin's installation settings go with it; a member-owned
    /// Plugin's shares are withdrawn and its owner no longer has it.
    ///
    /// To take an organization-owned Plugin out of use reversibly, set its
    /// organization-wide installation setting to `not_available` instead (and remove or
    /// change any group settings, which override it for their members). Only a Plugin
    /// in a `manual` marketplace can be deleted here; one synchronized from a
    /// repository is removed by removing it from the repository (400).
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
        public func delete<R: Sendable>(_ pluginID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedPlugin>) async throws -> R) async throws -> R {
            let response = try await resource._delete(pluginID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
