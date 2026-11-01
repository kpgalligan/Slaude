// Transformed from `anthropic.resources.beta.organization.plugin_marketplaces` (plugin_marketplaces.py).

import Foundation

public struct BetaOrganizationPluginMarketplacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Retrieve a plugin marketplace by ID.
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
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
    public func retrieve(_ marketplaceID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginMarketplace {
        try await _retrieve(marketplaceID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ marketplaceID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginMarketplace> {
        try requireNonEmpty(marketplaceID, "marketplace_id")
        var query = ParamsBuilder()
        try query.set("organization_id", organizationID)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/plugin_marketplaces/{marketplace_id}", ["marketplace_id": marketplaceID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugin_marketplaces.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginMarketplace.self, options, stream: _mode == .stream)
    }

    /// Set the default installation setting of one of the organization's own plugin
    /// marketplaces. Every Plugin in it without a setting of its own gets this default
    /// as its organization-wide setting, including Plugins added later.
    ///
    /// Pass it as `default_installation_preference`. A member's personal marketplace
    /// cannot be updated here (403).
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
    ///
    ///   default_installation_preference: The organization-wide installation setting every Plugin in the marketplace
    ///       without one of its own gets: one of `required`, `auto_install`, `available`,
    ///       `not_available`. Once set it can be changed but not removed.
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
    public func update(_ marketplaceID: String, defaultInstallationPreference: PluginMarketplaceUpdateParams.DefaultInstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginMarketplace {
        try await _update(marketplaceID, defaultInstallationPreference: defaultInstallationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ marketplaceID: String, defaultInstallationPreference: PluginMarketplaceUpdateParams.DefaultInstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginMarketplace> {
        try requireNonEmpty(marketplaceID, "marketplace_id")
        var body = ParamsBuilder()
        try body.set("default_installation_preference", defaultInstallationPreference)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/plugin_marketplaces/{marketplace_id}", ["marketplace_id": marketplaceID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugin_marketplaces.update", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginMarketplace.self, options, stream: _mode == .stream)
    }

    /// List the plugin marketplaces Plugins live in, newest first: the organization's
    /// own and its members' personal ones.
    ///
    /// Plugin marketplaces are created, connected to a repository and deleted in
    /// claude.ai, not through this API. The organization's library marketplace, the
    /// organization-owned `manual` marketplace that uploads go to when no marketplace
    /// is named, is created the first time something is put in it and is listed from
    /// then on.
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
    ///   owner_type: `organization` for the organization's plugin marketplaces, `user` for members'
    ///       personal plugin marketplaces.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   source: Only plugin marketplaces with this `source`: `manual` for those whose Plugins
    ///       are uploaded; `github`, `gitlab` or `public_git` for those synchronized from a
    ///       Git repository. `directory` (Anthropic's catalog) is never listed here.
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
    public func list(limit: Int? = nil, organizationID: String?? = nil, ownerType: PluginMarketplaceListParams.OwnerType?? = nil, page: String?? = nil, source: PluginMarketplaceListParams.Source?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaPluginMarketplace> {
        try await _list(limit: limit, organizationID: organizationID, ownerType: ownerType, page: page, source: source, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(limit: Int? = nil, organizationID: String?? = nil, ownerType: PluginMarketplaceListParams.OwnerType?? = nil, page: String?? = nil, source: PluginMarketplaceListParams.Source?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaPluginMarketplace>> {
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("organization_id", organizationID)
        try query.set("owner_type", ownerType)
        try query.set("page", page)
        try query.set("source", source)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/plugin_marketplaces", query: query, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugin_marketplaces.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaPluginMarketplace>.self, options, stream: _mode == .stream)
    }

    /// Check whether a plugin marketplace, uploaded as a `.zip` of the marketplace
    /// directory, would synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a public GitHub repository instead, use Validate Plugin Marketplace
    /// Repository.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. An archive that cannot be read as a marketplace
    /// is reported, not refused: the response is a report with `valid: false`. Plugin
    /// sources outside the marketplace are fetched anonymously from GitHub, so a
    /// private one is reported as not found or as needing a GitHub sign-in; a source on
    /// any other host is not fetched here, and the report notes that it will be checked
    /// when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   archive: A .zip of the marketplace directory (its contents at the root, or wrapped in one
    ///       folder as a Git host's download produces), sent as a file part with a filename;
    ///       DEFLATE- or STORE-compressed, at most 32 MB. A part sent without a filename, a
    ///       second archive part, or any other form field is a 400; a larger archive is
    ///       a 413.
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
    public func validateArchive(archive: FileUpload, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginMarketplaceValidationReport {
        try await _validateArchive(archive: archive, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _validateArchive(archive: FileUpload, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginMarketplaceValidationReport> {
        var body = ParamsBuilder()
        body.setFile("archive", archive)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/plugin_marketplaces/validate_archive", body: body, headers: mergeHeaderLayers(["Content-Type": "multipart/form-data"], mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders))), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugin_marketplaces.validate_archive", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginMarketplaceValidationReport.self, options, stream: _mode == .stream)
    }

    /// Check whether a plugin marketplace held in a public GitHub repository would
    /// synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a `.zip` of the marketplace directory instead, use Validate Plugin
    /// Marketplace Archive.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. A repository that is missing, private, or has no
    /// such branch or commit is reported, not refused: the response is a report with
    /// `valid: false`. Plugin sources outside the marketplace are fetched anonymously
    /// from GitHub, so a private one is reported as not found or as needing a GitHub
    /// sign-in; a source on any other host is not fetched here, and the report notes
    /// that it will be checked when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   repository_url: The `https://` URL of a public repository on github.com that holds the
    ///       marketplace. A URL longer than 2,048 characters, on any other host or scheme,
    ///       with a port other than 443 or 80, with credentials in it, or that does not name
    ///       exactly `owner/repo` (a trailing `.git` or `/` is accepted) is a 400. A private
    ///       or missing repository is reported in the response, not refused.
    ///
    ///   ref: The branch to validate the tip of, or the full 40-character SHA of the commit to
    ///       validate. When omitted, the branch a synchronization would read (usually the
    ///       repository's default branch); if that is not the default branch, the report's
    ///       `ref` says which branch was read. An empty string, a value longer than 255
    ///       characters, or one that contains `..` or a character other than ASCII letters,
    ///       digits, `.`, `_`, `-`, `+`, and `/`, is a 400. Any other value that is not a
    ///       40-character SHA is read as a branch name; if the repository has no such branch,
    ///       the response is a report with `valid: false`, not a 400.
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
    public func validateRepository(repositoryURL: String, ref: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaPluginMarketplaceValidationReport {
        try await _validateRepository(repositoryURL: repositoryURL, ref: ref, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _validateRepository(repositoryURL: String, ref: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaPluginMarketplaceValidationReport> {
        var body = ParamsBuilder()
        try body.set("repository_url", repositoryURL)
        try body.set("ref", ref)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/plugin_marketplaces/validate_repository", body: body, headers: mergeHeaderLayers(["anthropic-beta": "ce-plugins-2026-09-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["ce-plugins-2026-09-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.plugin_marketplaces.validate_repository", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaPluginMarketplaceValidationReport.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationPluginMarketplacesResource

    /// Retrieve a plugin marketplace by ID.
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
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
        public func retrieve(_ marketplaceID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginMarketplace> {
            try await resource._retrieve(marketplaceID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Set the default installation setting of one of the organization's own plugin
    /// marketplaces. Every Plugin in it without a setting of its own gets this default
    /// as its organization-wide setting, including Plugins added later.
    ///
    /// Pass it as `default_installation_preference`. A member's personal marketplace
    /// cannot be updated here (403).
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
    ///
    ///   default_installation_preference: The organization-wide installation setting every Plugin in the marketplace
    ///       without one of its own gets: one of `required`, `auto_install`, `available`,
    ///       `not_available`. Once set it can be changed but not removed.
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
        public func update(_ marketplaceID: String, defaultInstallationPreference: PluginMarketplaceUpdateParams.DefaultInstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginMarketplace> {
            try await resource._update(marketplaceID, defaultInstallationPreference: defaultInstallationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the plugin marketplaces Plugins live in, newest first: the organization's
    /// own and its members' personal ones.
    ///
    /// Plugin marketplaces are created, connected to a repository and deleted in
    /// claude.ai, not through this API. The organization's library marketplace, the
    /// organization-owned `manual` marketplace that uploads go to when no marketplace
    /// is named, is created the first time something is put in it and is listed from
    /// then on.
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
    ///   owner_type: `organization` for the organization's plugin marketplaces, `user` for members'
    ///       personal plugin marketplaces.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   source: Only plugin marketplaces with this `source`: `manual` for those whose Plugins
    ///       are uploaded; `github`, `gitlab` or `public_git` for those synchronized from a
    ///       Git repository. `directory` (Anthropic's catalog) is never listed here.
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
        public func list(limit: Int? = nil, organizationID: String?? = nil, ownerType: PluginMarketplaceListParams.OwnerType?? = nil, page: String?? = nil, source: PluginMarketplaceListParams.Source?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaPluginMarketplace>> {
            try await resource._list(limit: limit, organizationID: organizationID, ownerType: ownerType, page: page, source: source, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Check whether a plugin marketplace, uploaded as a `.zip` of the marketplace
    /// directory, would synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a public GitHub repository instead, use Validate Plugin Marketplace
    /// Repository.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. An archive that cannot be read as a marketplace
    /// is reported, not refused: the response is a report with `valid: false`. Plugin
    /// sources outside the marketplace are fetched anonymously from GitHub, so a
    /// private one is reported as not found or as needing a GitHub sign-in; a source on
    /// any other host is not fetched here, and the report notes that it will be checked
    /// when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   archive: A .zip of the marketplace directory (its contents at the root, or wrapped in one
    ///       folder as a Git host's download produces), sent as a file part with a filename;
    ///       DEFLATE- or STORE-compressed, at most 32 MB. A part sent without a filename, a
    ///       second archive part, or any other form field is a 400; a larger archive is
    ///       a 413.
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
        public func validateArchive(archive: FileUpload, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginMarketplaceValidationReport> {
            try await resource._validateArchive(archive: archive, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Check whether a plugin marketplace held in a public GitHub repository would
    /// synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a `.zip` of the marketplace directory instead, use Validate Plugin
    /// Marketplace Archive.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. A repository that is missing, private, or has no
    /// such branch or commit is reported, not refused: the response is a report with
    /// `valid: false`. Plugin sources outside the marketplace are fetched anonymously
    /// from GitHub, so a private one is reported as not found or as needing a GitHub
    /// sign-in; a source on any other host is not fetched here, and the report notes
    /// that it will be checked when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   repository_url: The `https://` URL of a public repository on github.com that holds the
    ///       marketplace. A URL longer than 2,048 characters, on any other host or scheme,
    ///       with a port other than 443 or 80, with credentials in it, or that does not name
    ///       exactly `owner/repo` (a trailing `.git` or `/` is accepted) is a 400. A private
    ///       or missing repository is reported in the response, not refused.
    ///
    ///   ref: The branch to validate the tip of, or the full 40-character SHA of the commit to
    ///       validate. When omitted, the branch a synchronization would read (usually the
    ///       repository's default branch); if that is not the default branch, the report's
    ///       `ref` says which branch was read. An empty string, a value longer than 255
    ///       characters, or one that contains `..` or a character other than ASCII letters,
    ///       digits, `.`, `_`, `-`, `+`, and `/`, is a 400. Any other value that is not a
    ///       40-character SHA is read as a branch name; if the repository has no such branch,
    ///       the response is a report with `valid: false`, not a 400.
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
        public func validateRepository(repositoryURL: String, ref: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaPluginMarketplaceValidationReport> {
            try await resource._validateRepository(repositoryURL: repositoryURL, ref: ref, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationPluginMarketplacesResource

    /// Retrieve a plugin marketplace by ID.
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
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
        public func retrieve<R: Sendable>(_ marketplaceID: String, organizationID: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginMarketplace>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(marketplaceID, organizationID: organizationID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Set the default installation setting of one of the organization's own plugin
    /// marketplaces. Every Plugin in it without a setting of its own gets this default
    /// as its organization-wide setting, including Plugins added later.
    ///
    /// Pass it as `default_installation_preference`. A member's personal marketplace
    /// cannot be updated here (403).
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
    ///   marketplace_id: ID of the plugin marketplace (prefixed `marketplace_`).
    ///
    ///   default_installation_preference: The organization-wide installation setting every Plugin in the marketplace
    ///       without one of its own gets: one of `required`, `auto_install`, `available`,
    ///       `not_available`. Once set it can be changed but not removed.
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
        public func update<R: Sendable>(_ marketplaceID: String, defaultInstallationPreference: PluginMarketplaceUpdateParams.DefaultInstallationPreference, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginMarketplace>) async throws -> R) async throws -> R {
            let response = try await resource._update(marketplaceID, defaultInstallationPreference: defaultInstallationPreference, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the plugin marketplaces Plugins live in, newest first: the organization's
    /// own and its members' personal ones.
    ///
    /// Plugin marketplaces are created, connected to a repository and deleted in
    /// claude.ai, not through this API. The organization's library marketplace, the
    /// organization-owned `manual` marketplace that uploads go to when no marketplace
    /// is named, is created the first time something is put in it and is listed from
    /// then on.
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
    ///   owner_type: `organization` for the organization's plugin marketplaces, `user` for members'
    ///       personal plugin marketplaces.
    ///
    ///   page: Optionally set to the `next_page` token from the previous response.
    ///
    ///   source: Only plugin marketplaces with this `source`: `manual` for those whose Plugins
    ///       are uploaded; `github`, `gitlab` or `public_git` for those synchronized from a
    ///       Git repository. `directory` (Anthropic's catalog) is never listed here.
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
        public func list<R: Sendable>(limit: Int? = nil, organizationID: String?? = nil, ownerType: PluginMarketplaceListParams.OwnerType?? = nil, page: String?? = nil, source: PluginMarketplaceListParams.Source?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaPluginMarketplace>>) async throws -> R) async throws -> R {
            let response = try await resource._list(limit: limit, organizationID: organizationID, ownerType: ownerType, page: page, source: source, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Check whether a plugin marketplace, uploaded as a `.zip` of the marketplace
    /// directory, would synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a public GitHub repository instead, use Validate Plugin Marketplace
    /// Repository.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. An archive that cannot be read as a marketplace
    /// is reported, not refused: the response is a report with `valid: false`. Plugin
    /// sources outside the marketplace are fetched anonymously from GitHub, so a
    /// private one is reported as not found or as needing a GitHub sign-in; a source on
    /// any other host is not fetched here, and the report notes that it will be checked
    /// when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   archive: A .zip of the marketplace directory (its contents at the root, or wrapped in one
    ///       folder as a Git host's download produces), sent as a file part with a filename;
    ///       DEFLATE- or STORE-compressed, at most 32 MB. A part sent without a filename, a
    ///       second archive part, or any other form field is a 400; a larger archive is
    ///       a 413.
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
        public func validateArchive<R: Sendable>(archive: FileUpload, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginMarketplaceValidationReport>) async throws -> R) async throws -> R {
            let response = try await resource._validateArchive(archive: archive, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Check whether a plugin marketplace held in a public GitHub repository would
    /// synchronize into claude.ai, without connecting or storing it.
    ///
    /// To check a `.zip` of the marketplace directory instead, use Validate Plugin
    /// Marketplace Archive.
    ///
    /// The report says whether `marketplace.json` is well-formed, which plugins a
    /// synchronization would skip and why, and which plugins would synchronize only in
    /// part, with some files left out. A repository that is missing, private, or has no
    /// such branch or commit is reported, not refused: the response is a report with
    /// `valid: false`. Plugin sources outside the marketplace are fetched anonymously
    /// from GitHub, so a private one is reported as not found or as needing a GitHub
    /// sign-in; a source on any other host is not fetched here, and the report notes
    /// that it will be checked when the marketplace actually synchronizes.
    ///
    /// Nothing is recorded on the Compliance API activity feed.
    ///
    /// For a worked example, see
    /// [Validate marketplace content](/docs/en/manage-claude/plugins-api#validate-marketplace-content)
    /// in the Plugins API guide.
    ///
    /// **Accepted credentials:** an Admin API key with the `read:plugins` or
    /// `write:plugins` scope; `read:org_audit` and `read:compliance_org_data` do not
    /// grant it.
    ///
    /// Every request must include the beta header
    /// `anthropic-beta: ce-plugins-2026-09-01`. A request without it returns `404`,
    /// exactly as if the endpoint did not exist. The Plugins API is in beta and is
    /// available to Claude Enterprise organizations only. It is not available to Claude
    /// Platform (Claude Console) organizations, or to organizations with HIPAA
    /// readiness enabled.
    ///
    /// Args:
    ///   repository_url: The `https://` URL of a public repository on github.com that holds the
    ///       marketplace. A URL longer than 2,048 characters, on any other host or scheme,
    ///       with a port other than 443 or 80, with credentials in it, or that does not name
    ///       exactly `owner/repo` (a trailing `.git` or `/` is accepted) is a 400. A private
    ///       or missing repository is reported in the response, not refused.
    ///
    ///   ref: The branch to validate the tip of, or the full 40-character SHA of the commit to
    ///       validate. When omitted, the branch a synchronization would read (usually the
    ///       repository's default branch); if that is not the default branch, the report's
    ///       `ref` says which branch was read. An empty string, a value longer than 255
    ///       characters, or one that contains `..` or a character other than ASCII letters,
    ///       digits, `.`, `_`, `-`, `+`, and `/`, is a 400. Any other value that is not a
    ///       40-character SHA is read as a branch name; if the repository has no such branch,
    ///       the response is a report with `valid: false`, not a 400.
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
        public func validateRepository<R: Sendable>(repositoryURL: String, ref: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaPluginMarketplaceValidationReport>) async throws -> R) async throws -> R {
            let response = try await resource._validateRepository(repositoryURL: repositoryURL, ref: ref, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
