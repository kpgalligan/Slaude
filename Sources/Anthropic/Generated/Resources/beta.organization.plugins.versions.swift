// Transformed from `anthropic.resources.beta.organization.plugins.versions` (versions.py).

import Foundation

public struct BetaOrganizationPluginsVersionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Add a version to an organization-owned Plugin by uploading the new version's
    /// files; it becomes the version served to members unless the Plugin's served
    /// version has been pinned.
    ///
    /// The upload is the same `multipart/form-data` as creating a Plugin: the version's
    /// files (`files`, each part sent as `files[]`) and optional `release_notes`. The
    /// uploaded manifest's `name` must equal the Plugin's `name`. Returns the stored
    /// version; read the Plugin back to see which version it serves.
    ///
    /// Only a Plugin in a `manual` marketplace takes uploads; a Plugin synchronized
    /// from a repository gets its versions from the repository. When the Plugin is in
    /// the organization's library marketplace, a version that adds a skill with the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai) is refused with a 409: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A 503 with
    /// `error_code` `registration_pending` means the version was stored but is not yet
    /// usable; a later version create on the Plugin completes it.
    ///
    /// For a worked example, see
    /// [Create a version](/docs/en/manage-claude/plugins-api#create-a-version) in the
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
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
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
    public func create(_ pluginID: String, files: [FileUpload], releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginVersion {
        try await _create(pluginID, files: files, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(_ pluginID: String, files: [FileUpload], releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginVersion> {
        try requireNonEmpty(pluginID, "plugin_id")
        var body = ParamsBuilder()
        body.setFiles("files", files)
        try body.set("release_notes", releaseNotes)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/versions", ["plugin_id": pluginID]), body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.versions.create", spanRoute: "/v1/organizations/plugins/{plugin_id}/versions", spanAttributes: ["anthropic.organization.plugin.id": pluginID], spanCreatedID: SpanCreatedID("anthropic.organization.plugin.version.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginVersion.self, options, stream: _mode == .stream)
    }

    /// Retrieve one version of a Plugin by its ID, or the Plugin's newest version.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`), or `latest` for the newest
    ///       one.
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
    public func retrieve(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginVersion {
        try await _retrieve(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginVersion> {
        try requireNonEmpty(pluginID, "plugin_id")
        try requireNonEmpty(version, "version")
        var query = ParamsBuilder()
        try query.set("organization_id", organizationID)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/versions/{version}", ["plugin_id": pluginID, "version": version]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.versions.retrieve", spanRoute: "/v1/organizations/plugins/{plugin_id}/versions/{version}", spanAttributes: ["anthropic.organization.plugin.id": pluginID, "anthropic.organization.plugin.version.id": version], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginVersion.self, options, stream: _mode == .stream)
    }

    /// List a Plugin's versions, newest first.
    ///
    /// The first item of the first page is the version the Plugin's `latest_version_id`
    /// refers to.
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
    ///       Defaults to `20`. Ranges from `1` to `1000`.
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
    public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaPluginVersion> {
        try await _list(pluginID, limit: limit, organizationID: organizationID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaPluginVersion>> {
        try requireNonEmpty(pluginID, "plugin_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("organization_id", organizationID)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/versions", ["plugin_id": pluginID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.versions.list", spanRoute: "/v1/organizations/plugins/{plugin_id}/versions", spanAttributes: ["anthropic.organization.plugin.id": pluginID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaPluginVersion>.self, options, stream: _mode == .stream)
    }

    /// Download one version's `.zip` archive, exactly as stored.
    ///
    /// Each download of a
    /// Plugin from a member's personal plugin marketplace is recorded on the Compliance
    /// API activity feed.
    ///
    /// The response body is the archive (`Content-Type: application/zip`), sent as an
    /// attachment whose filename is derived from the Plugin's name; name saved files
    /// from the IDs in the request path, since that filename is not unique.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every read scope above (`read:plugins`, `read:org_audit`, and
    /// `read:compliance_org_data`) can download the files of plugins in members'
    /// personal marketplaces, including files that claude.ai's admin settings do not
    /// show, and a `read:org_audit` or `read:compliance_org_data` key created for all
    /// of your parent organization's linked organizations can do this in any
    /// organization under it that has access to this API, by passing `organization_id`.
    /// Each such download records a `claude_plugin_archive_accessed` event on the
    /// Compliance API activity feed, identifying the key, the plugin, the version, and
    /// the member. Downloads of organization-owned plugins are not recorded.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`). `latest` is not accepted here.
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
    public func download(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BinaryResponse {
        try await _download(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _download(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BinaryResponse> {
        try requireNonEmpty(pluginID, "plugin_id")
        try requireNonEmpty(version, "version")
        var query = ParamsBuilder()
        try query.set("organization_id", organizationID)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugins/{plugin_id}/versions/{version}/content", ["plugin_id": pluginID, "version": version]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), mergeHeaderLayers(["Accept": "application/binary"], extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugins.versions.download", spanRoute: "/v1/organizations/plugins/{plugin_id}/versions/{version}/content", spanAttributes: ["anthropic.organization.plugin.id": pluginID, "anthropic.organization.plugin.version.id": version], qualifiers: ["beta": "true"])
        return try await client.requestBinaryResponse(options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationPluginsVersionsResource

    /// Add a version to an organization-owned Plugin by uploading the new version's
    /// files; it becomes the version served to members unless the Plugin's served
    /// version has been pinned.
    ///
    /// The upload is the same `multipart/form-data` as creating a Plugin: the version's
    /// files (`files`, each part sent as `files[]`) and optional `release_notes`. The
    /// uploaded manifest's `name` must equal the Plugin's `name`. Returns the stored
    /// version; read the Plugin back to see which version it serves.
    ///
    /// Only a Plugin in a `manual` marketplace takes uploads; a Plugin synchronized
    /// from a repository gets its versions from the repository. When the Plugin is in
    /// the organization's library marketplace, a version that adds a skill with the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai) is refused with a 409: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A 503 with
    /// `error_code` `registration_pending` means the version was stored but is not yet
    /// usable; a later version create on the Plugin completes it.
    ///
    /// For a worked example, see
    /// [Create a version](/docs/en/manage-claude/plugins-api#create-a-version) in the
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
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
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
        public func create(_ pluginID: String, files: [FileUpload], releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginVersion> {
            try await resource._create(pluginID, files: files, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Retrieve one version of a Plugin by its ID, or the Plugin's newest version.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`), or `latest` for the newest
    ///       one.
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
        public func retrieve(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginVersion> {
            try await resource._retrieve(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List a Plugin's versions, newest first.
    ///
    /// The first item of the first page is the version the Plugin's `latest_version_id`
    /// refers to.
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
    ///       Defaults to `20`. Ranges from `1` to `1000`.
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
        public func list(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaPluginVersion>> {
            try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Download one version's `.zip` archive, exactly as stored.
    ///
    /// Each download of a
    /// Plugin from a member's personal plugin marketplace is recorded on the Compliance
    /// API activity feed.
    ///
    /// The response body is the archive (`Content-Type: application/zip`), sent as an
    /// attachment whose filename is derived from the Plugin's name; name saved files
    /// from the IDs in the request path, since that filename is not unique.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every read scope above (`read:plugins`, `read:org_audit`, and
    /// `read:compliance_org_data`) can download the files of plugins in members'
    /// personal marketplaces, including files that claude.ai's admin settings do not
    /// show, and a `read:org_audit` or `read:compliance_org_data` key created for all
    /// of your parent organization's linked organizations can do this in any
    /// organization under it that has access to this API, by passing `organization_id`.
    /// Each such download records a `claude_plugin_archive_accessed` event on the
    /// Compliance API activity feed, identifying the key, the plugin, the version, and
    /// the member. Downloads of organization-owned plugins are not recorded.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`). `latest` is not accepted here.
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
        public func download(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BinaryResponse> {
            try await resource._download(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationPluginsVersionsResource

    /// Add a version to an organization-owned Plugin by uploading the new version's
    /// files; it becomes the version served to members unless the Plugin's served
    /// version has been pinned.
    ///
    /// The upload is the same `multipart/form-data` as creating a Plugin: the version's
    /// files (`files`, each part sent as `files[]`) and optional `release_notes`. The
    /// uploaded manifest's `name` must equal the Plugin's `name`. Returns the stored
    /// version; read the Plugin back to see which version it serves.
    ///
    /// Only a Plugin in a `manual` marketplace takes uploads; a Plugin synchronized
    /// from a repository gets its versions from the repository. When the Plugin is in
    /// the organization's library marketplace, a version that adds a skill with the
    /// name of an organization skill (a skill an administrator uploaded for the whole
    /// organization in claude.ai) is refused with a 409: `error_code`
    /// `skill_name_taken`, with that name in `details.skill_name`. A 503 with
    /// `error_code` `registration_pending` means the version was stored but is not yet
    /// usable; a later version create on the Plugin completes it.
    ///
    /// For a worked example, see
    /// [Create a version](/docs/en/manage-claude/plugins-api#create-a-version) in the
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
    ///   plugin_id: ID of the Plugin (prefixed `plugin_`).
    ///
    ///   files: The version's files: one part per file, the part's filename being the file's
    ///       path within the Plugin (for example `skills/review-pr/SKILL.md`), or a single
    ///       `.zip` or `.plugin` archive holding them all. On the wire each part is named
    ///       `files[]`, and a part named plain `files` is not read; with cURL,
    ///       `-F 'files[]=@SKILL.md;filename=skills/review-pr/SKILL.md'`. The files must
    ///       include the manifest, `.claude-plugin/plugin.json`.
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
        public func create<R: Sendable>(_ pluginID: String, files: [FileUpload], releaseNotes: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginVersion>) async throws -> R) async throws -> R {
            let response = try await resource._create(pluginID, files: files, releaseNotes: releaseNotes, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Retrieve one version of a Plugin by its ID, or the Plugin's newest version.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`), or `latest` for the newest
    ///       one.
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
        public func retrieve<R: Sendable>(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginVersion>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List a Plugin's versions, newest first.
    ///
    /// The first item of the first page is the version the Plugin's `latest_version_id`
    /// refers to.
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
    ///       Defaults to `20`. Ranges from `1` to `1000`.
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
        public func list<R: Sendable>(_ pluginID: String, limit: Int? = nil, organizationID: String?? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaPluginVersion>>) async throws -> R) async throws -> R {
            let response = try await resource._list(pluginID, limit: limit, organizationID: organizationID, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Download one version's `.zip` archive, exactly as stored.
    ///
    /// Each download of a
    /// Plugin from a member's personal plugin marketplace is recorded on the Compliance
    /// API activity feed.
    ///
    /// The response body is the archive (`Content-Type: application/zip`), sent as an
    /// attachment whose filename is derived from the Plugin's name; name saved files
    /// from the IDs in the request path, since that filename is not unique.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `read:org_audit` scope, or a Compliance Access Key with the
    /// `read:compliance_org_data` scope.
    ///
    /// Every read scope above (`read:plugins`, `read:org_audit`, and
    /// `read:compliance_org_data`) can download the files of plugins in members'
    /// personal marketplaces, including files that claude.ai's admin settings do not
    /// show, and a `read:org_audit` or `read:compliance_org_data` key created for all
    /// of your parent organization's linked organizations can do this in any
    /// organization under it that has access to this API, by passing `organization_id`.
    /// Each such download records a `claude_plugin_archive_accessed` event on the
    /// Compliance API activity feed, identifying the key, the plugin, the version, and
    /// the member. Downloads of organization-owned plugins are not recorded.
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
    ///   version: ID of the Plugin Version (prefixed `pluginver_`). `latest` is not accepted here.
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
        public func download<R: Sendable>(_ version: String, pluginID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BinaryResponse>) async throws -> R) async throws -> R {
            let response = try await resource._download(version, pluginID: pluginID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
