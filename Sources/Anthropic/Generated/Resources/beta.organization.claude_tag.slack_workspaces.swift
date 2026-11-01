// Transformed from `anthropic.resources.beta.organization.claude_tag.slack_workspaces` (slack_workspaces.py).

import Foundation

public struct BetaOrganizationClaudeTagSlackWorkspacesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get one Slack workspace and its settings.
    ///
    /// By default `settings` holds what the
    /// workspace itself stores: a setting that is null there is not set on the
    /// workspace and is inherited. With `include_inherited=true`, `settings` holds what
    /// applies in the workspace once the organization's Slack defaults are taken into
    /// account, and the request fails with 503 rather than resolve against a settings
    /// level that could not be read. Either way `sources` names the settings level each
    /// value comes from.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what the workspace itself stores.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagSlackWorkspace {
        try await _retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagSlackWorkspace> {
        try requireNonEmpty(id, "id")
        var query = ParamsBuilder()
        try query.set("include_inherited", includeInherited)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/claude_tag/slack_workspaces/{id}", ["id": id]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_workspaces.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagSlackWorkspace.self, options, stream: _mode == .stream)
    }

    /// Change the settings a Slack workspace stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the workspace
    /// inherits it. If any value is refused, no setting in the request is stored.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   settings: The settings to change.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagSlackWorkspace {
        try await _update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagSlackWorkspace> {
        try requireNonEmpty(id, "id")
        var body = ParamsBuilder()
        try body.set("settings", settings)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/claude_tag/slack_workspaces/{id}", ["id": id]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_workspaces.update", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagSlackWorkspace.self, options, stream: _mode == .stream)
    }

    /// List the set-up Slack workspaces the organization owns, newest first by
    /// `created_at`. Pass `slack_workspace_id` to look one workspace up by its Slack
    /// identifier: `data` then holds that workspace, or is empty when it is not set up.
    /// A workspace of a Slack Enterprise Grid the organization has connected returns
    /// 404 until it is set up. With `include_inherited=true` each workspace's
    /// `settings` holds what applies in it, and the request fails with 503 rather than
    /// resolve against a settings level that could not be read. A `page` cursor resumes
    /// only a request with the same `include_inherited`.
    ///
    /// Args:
    ///   include_inherited: When `true`, `settings` holds what applies in each workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what each workspace itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_workspace_id: Slack's identifier for one workspace, as in the workspace object's
    ///       `slack.workspace_id`, not its `id`. With it `data` holds that workspace alone,
    ///       or nothing when it is not set up.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackWorkspaceID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaClaudeTagSlackWorkspace> {
        try await _list(includeInherited: includeInherited, limit: limit, page: page, slackWorkspaceID: slackWorkspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackWorkspaceID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaClaudeTagSlackWorkspace>> {
        var query = ParamsBuilder()
        try query.set("include_inherited", includeInherited)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("slack_workspace_id", slackWorkspaceID)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/claude_tag/slack_workspaces", query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_workspaces.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaClaudeTagSlackWorkspace>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationClaudeTagSlackWorkspacesResource

    /// Get one Slack workspace and its settings.
    ///
    /// By default `settings` holds what the
    /// workspace itself stores: a setting that is null there is not set on the
    /// workspace and is inherited. With `include_inherited=true`, `settings` holds what
    /// applies in the workspace once the organization's Slack defaults are taken into
    /// account, and the request fails with 503 rather than resolve against a settings
    /// level that could not be read. Either way `sources` names the settings level each
    /// value comes from.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what the workspace itself stores.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagSlackWorkspace> {
            try await resource._retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Change the settings a Slack workspace stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the workspace
    /// inherits it. If any value is refused, no setting in the request is stored.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   settings: The settings to change.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagSlackWorkspace> {
            try await resource._update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the set-up Slack workspaces the organization owns, newest first by
    /// `created_at`. Pass `slack_workspace_id` to look one workspace up by its Slack
    /// identifier: `data` then holds that workspace, or is empty when it is not set up.
    /// A workspace of a Slack Enterprise Grid the organization has connected returns
    /// 404 until it is set up. With `include_inherited=true` each workspace's
    /// `settings` holds what applies in it, and the request fails with 503 rather than
    /// resolve against a settings level that could not be read. A `page` cursor resumes
    /// only a request with the same `include_inherited`.
    ///
    /// Args:
    ///   include_inherited: When `true`, `settings` holds what applies in each workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what each workspace itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_workspace_id: Slack's identifier for one workspace, as in the workspace object's
    ///       `slack.workspace_id`, not its `id`. With it `data` holds that workspace alone,
    ///       or nothing when it is not set up.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackWorkspaceID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaClaudeTagSlackWorkspace>> {
            try await resource._list(includeInherited: includeInherited, limit: limit, page: page, slackWorkspaceID: slackWorkspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationClaudeTagSlackWorkspacesResource

    /// Get one Slack workspace and its settings.
    ///
    /// By default `settings` holds what the
    /// workspace itself stores: a setting that is null there is not set on the
    /// workspace and is inherited. With `include_inherited=true`, `settings` holds what
    /// applies in the workspace once the organization's Slack defaults are taken into
    /// account, and the request fails with 503 rather than resolve against a settings
    /// level that could not be read. Either way `sources` names the settings level each
    /// value comes from.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what the workspace itself stores.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagSlackWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Change the settings a Slack workspace stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the workspace
    /// inherits it. If any value is refused, no setting in the request is stored.
    ///
    /// Args:
    ///   id: The workspace's identifier, starting with `slws_`.
    ///
    ///   settings: The settings to change.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func update<R: Sendable>(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagSlackWorkspace>) async throws -> R) async throws -> R {
            let response = try await resource._update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the set-up Slack workspaces the organization owns, newest first by
    /// `created_at`. Pass `slack_workspace_id` to look one workspace up by its Slack
    /// identifier: `data` then holds that workspace, or is empty when it is not set up.
    /// A workspace of a Slack Enterprise Grid the organization has connected returns
    /// 404 until it is set up. With `include_inherited=true` each workspace's
    /// `settings` holds what applies in it, and the request fails with 503 rather than
    /// resolve against a settings level that could not be read. A `page` cursor resumes
    /// only a request with the same `include_inherited`.
    ///
    /// Args:
    ///   include_inherited: When `true`, `settings` holds what applies in each workspace once the
    ///       organization's Slack defaults are taken into account, and every member of
    ///       `sources` names the level a value comes from. When `false` or left out,
    ///       `settings` holds what each workspace itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_workspace_id: Slack's identifier for one workspace, as in the workspace object's
    ///       `slack.workspace_id`, not its `id`. With it `data` holds that workspace alone,
    ///       or nothing when it is not set up.
    ///
    ///   betas: This endpoint is in beta: requests must send
    ///       `experimental-claude-tag-2026-10-21` in this header.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackWorkspaceID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaClaudeTagSlackWorkspace>>) async throws -> R) async throws -> R {
            let response = try await resource._list(includeInherited: includeInherited, limit: limit, page: page, slackWorkspaceID: slackWorkspaceID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
