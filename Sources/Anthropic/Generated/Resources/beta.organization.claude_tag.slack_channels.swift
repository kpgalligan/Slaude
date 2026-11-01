// Transformed from `anthropic.resources.beta.organization.claude_tag.slack_channels` (slack_channels.py).

import Foundation

public struct BetaOrganizationClaudeTagSlackChannelsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Set a Slack channel up for Claude Tag and return it with its identifier.
    ///
    /// If the
    /// channel is already set up, whether in claude.ai, by Claude's first use in it or
    /// by an earlier request, the existing channel is returned, so the request can be
    /// repeated. `settings`, when sent, is applied as an update applies it. Before a
    /// channel is set up, Claude's Slack app confirms with Slack that the channel is in
    /// the workspace, is not archived and is visible to the app; a channel that fails
    /// the confirmation returns 404. Setting the channel up and applying `settings` are
    /// two steps: when the second is refused, the response is the refusal, the channel
    /// stays set up with every setting unset, and the error's
    /// `details.slack_channel_id` holds the channel's identifier.
    ///
    /// Args:
    ///   slack: Slack's own identifiers for the channel to set up. The organization must own the
    ///       workspace.
    ///
    ///   settings: Settings to store on the channel, applied as Update Slack Channel applies them.
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
    public func create(slack: BetaClaudeTagSlackChannelIdentifiersParam, settings: BetaClaudeTagSettingsCreateParam? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagSlackChannel {
        try await _create(slack: slack, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(slack: BetaClaudeTagSlackChannelIdentifiersParam, settings: BetaClaudeTagSettingsCreateParam? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
        var body = ParamsBuilder()
        try body.set("slack", slack)
        try body.set("settings", settings)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/organizations/claude_tag/slack_channels", body: body, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_channels.create", spanRoute: "/v1/organizations/claude_tag/slack_channels", spanCreatedID: SpanCreatedID("anthropic.organization.claude_tag.slack_channel.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagSlackChannel.self, options, stream: _mode == .stream)
    }

    /// Get one Slack channel and its settings.
    ///
    /// By default `settings` holds what the
    /// channel itself stores: a setting that is null there is not set on the channel
    /// and is inherited. With `include_inherited=true`, `settings` holds what applies
    /// in the channel once the settings levels above it are taken into account, and the
    /// request fails with 503 rather than resolve against a settings level that could
    /// not be read. Either way `sources` names the settings level each value comes
    /// from, so a caller tells the channel's own value from an inherited one by its
    /// source, not by whether it is null.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what the
    ///       channel itself stores.
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
    public func retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagSlackChannel {
        try await _retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
        try requireNonEmpty(id, "id")
        var query = ParamsBuilder()
        try query.set("include_inherited", includeInherited)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/organizations/claude_tag/slack_channels/{id}", ["id": id]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_channels.retrieve", spanRoute: "/v1/organizations/claude_tag/slack_channels/{id}", spanAttributes: ["anthropic.organization.claude_tag.slack_channel.id": id], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagSlackChannel.self, options, stream: _mode == .stream)
    }

    /// Change the settings a Slack channel stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the channel
    /// inherits it. If any value is refused, no setting in the request is stored. A
    /// group direct message takes no settings and returns 400.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
    public func update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagSlackChannel {
        try await _update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
        try requireNonEmpty(id, "id")
        var body = ParamsBuilder()
        try body.set("settings", settings)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/organizations/claude_tag/slack_channels/{id}", ["id": id]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_channels.update", spanRoute: "/v1/organizations/claude_tag/slack_channels/{id}", spanAttributes: ["anthropic.organization.claude_tag.slack_channel.id": id], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagSlackChannel.self, options, stream: _mode == .stream)
    }

    /// List the set-up Slack channels of one Slack workspace, newest first by
    /// `created_at`. A channel that is not set up is not listed: Slack holds the full
    /// list of a workspace's channels. Pass `slack_channel_id` as well to look one
    /// channel up by its Slack identifiers: `data` then holds that channel, or is empty
    /// when it is not set up, and `limit` and `page` are ignored. A workspace that the
    /// organization owns only through a Slack Enterprise Grid returns 404 until it is
    /// set up. With `include_inherited=true` each channel's `settings` holds what
    /// applies in it, and the request fails with 503 rather than resolve against a
    /// settings level that could not be read. A `page` cursor resumes only a request
    /// with the same `include_inherited`.
    ///
    /// Args:
    ///   slack_workspace_id: The Slack workspace whose channels to list: Slack's identifier for it, as in the
    ///       channel object's `slack.workspace_id`, not the workspace object's `id`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in each channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what each
    ///       channel itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_channel_id: Slack's identifier for one channel of that workspace, as in the channel object's
    ///       `slack.channel_id`. It is not the channel object's `id`. With it `data` holds
    ///       that channel alone, or nothing when the channel is not set up.
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
    public func list(slackWorkspaceID: String, includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackChannelID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaClaudeTagSlackChannel> {
        try await _list(slackWorkspaceID: slackWorkspaceID, includeInherited: includeInherited, limit: limit, page: page, slackChannelID: slackChannelID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(slackWorkspaceID: String, includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackChannelID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaClaudeTagSlackChannel>> {
        var query = ParamsBuilder()
        try query.set("slack_workspace_id", slackWorkspaceID)
        try query.set("include_inherited", includeInherited)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("slack_channel_id", slackChannelID)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/organizations/claude_tag/slack_channels", query: query, headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_channels.list", spanRoute: "/v1/organizations/claude_tag/slack_channels", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaClaudeTagSlackChannel>.self, options, stream: _mode == .stream)
    }

    /// Remove a Slack channel from Claude Tag.
    ///
    /// This deletes the channel's stored
    /// settings and its Bundle Targets at once, and then, in the background, the
    /// channel's sessions and their transcripts, its memory, its routines and the
    /// artifacts published from it. None of it can be restored. The channel in Slack
    /// and its messages are unchanged. The request is refused with 400 and
    /// `error.details.error_code` `slack_channel_enabled` while `enabled` resolves to
    /// `true` for the channel, as a read with `include_inherited=true` returns it: set
    /// `enabled` to `false` on the channel first. This guards against removing a
    /// channel in use by mistake; it is not a way to keep Claude out, because the
    /// removal deletes the channel's own `enabled: false` with its other settings,
    /// after which the channel inherits again and Claude's next use of it can set it up
    /// anew with a new identifier. The identifier returns 404 as soon as the request
    /// returns, so a repeated removal returns 404. A group direct message returns 400,
    /// and so does a channel that holds configuration this API does not manage.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
    public func delete(_ id: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaClaudeTagDeletedSlackChannel {
        try await _delete(id, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ id: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaClaudeTagDeletedSlackChannel> {
        try requireNonEmpty(id, "id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/organizations/claude_tag/slack_channels/{id}", ["id": id]), headers: mergeHeaderLayers(["anthropic-beta": "experimental-claude-tag-2026-10-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["experimental-claude-tag-2026-10-21"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.organization.claude_tag.slack_channels.delete", spanRoute: "/v1/organizations/claude_tag/slack_channels/{id}", spanAttributes: ["anthropic.organization.claude_tag.slack_channel.id": id], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaClaudeTagDeletedSlackChannel.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaOrganizationClaudeTagSlackChannelsResource

    /// Set a Slack channel up for Claude Tag and return it with its identifier.
    ///
    /// If the
    /// channel is already set up, whether in claude.ai, by Claude's first use in it or
    /// by an earlier request, the existing channel is returned, so the request can be
    /// repeated. `settings`, when sent, is applied as an update applies it. Before a
    /// channel is set up, Claude's Slack app confirms with Slack that the channel is in
    /// the workspace, is not archived and is visible to the app; a channel that fails
    /// the confirmation returns 404. Setting the channel up and applying `settings` are
    /// two steps: when the second is refused, the response is the refusal, the channel
    /// stays set up with every setting unset, and the error's
    /// `details.slack_channel_id` holds the channel's identifier.
    ///
    /// Args:
    ///   slack: Slack's own identifiers for the channel to set up. The organization must own the
    ///       workspace.
    ///
    ///   settings: Settings to store on the channel, applied as Update Slack Channel applies them.
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
        public func create(slack: BetaClaudeTagSlackChannelIdentifiersParam, settings: BetaClaudeTagSettingsCreateParam? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
            try await resource._create(slack: slack, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get one Slack channel and its settings.
    ///
    /// By default `settings` holds what the
    /// channel itself stores: a setting that is null there is not set on the channel
    /// and is inherited. With `include_inherited=true`, `settings` holds what applies
    /// in the channel once the settings levels above it are taken into account, and the
    /// request fails with 503 rather than resolve against a settings level that could
    /// not be read. Either way `sources` names the settings level each value comes
    /// from, so a caller tells the channel's own value from an inherited one by its
    /// source, not by whether it is null.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what the
    ///       channel itself stores.
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
        public func retrieve(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
            try await resource._retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Change the settings a Slack channel stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the channel
    /// inherits it. If any value is refused, no setting in the request is stored. A
    /// group direct message takes no settings and returns 400.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
        public func update(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagSlackChannel> {
            try await resource._update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the set-up Slack channels of one Slack workspace, newest first by
    /// `created_at`. A channel that is not set up is not listed: Slack holds the full
    /// list of a workspace's channels. Pass `slack_channel_id` as well to look one
    /// channel up by its Slack identifiers: `data` then holds that channel, or is empty
    /// when it is not set up, and `limit` and `page` are ignored. A workspace that the
    /// organization owns only through a Slack Enterprise Grid returns 404 until it is
    /// set up. With `include_inherited=true` each channel's `settings` holds what
    /// applies in it, and the request fails with 503 rather than resolve against a
    /// settings level that could not be read. A `page` cursor resumes only a request
    /// with the same `include_inherited`.
    ///
    /// Args:
    ///   slack_workspace_id: The Slack workspace whose channels to list: Slack's identifier for it, as in the
    ///       channel object's `slack.workspace_id`, not the workspace object's `id`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in each channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what each
    ///       channel itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_channel_id: Slack's identifier for one channel of that workspace, as in the channel object's
    ///       `slack.channel_id`. It is not the channel object's `id`. With it `data` holds
    ///       that channel alone, or nothing when the channel is not set up.
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
        public func list(slackWorkspaceID: String, includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackChannelID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaClaudeTagSlackChannel>> {
            try await resource._list(slackWorkspaceID: slackWorkspaceID, includeInherited: includeInherited, limit: limit, page: page, slackChannelID: slackChannelID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Remove a Slack channel from Claude Tag.
    ///
    /// This deletes the channel's stored
    /// settings and its Bundle Targets at once, and then, in the background, the
    /// channel's sessions and their transcripts, its memory, its routines and the
    /// artifacts published from it. None of it can be restored. The channel in Slack
    /// and its messages are unchanged. The request is refused with 400 and
    /// `error.details.error_code` `slack_channel_enabled` while `enabled` resolves to
    /// `true` for the channel, as a read with `include_inherited=true` returns it: set
    /// `enabled` to `false` on the channel first. This guards against removing a
    /// channel in use by mistake; it is not a way to keep Claude out, because the
    /// removal deletes the channel's own `enabled: false` with its other settings,
    /// after which the channel inherits again and Claude's next use of it can set it up
    /// anew with a new identifier. The identifier returns 404 as soon as the request
    /// returns, so a repeated removal returns 404. A group direct message returns 400,
    /// and so does a channel that holds configuration this API does not manage.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
        public func delete(_ id: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaClaudeTagDeletedSlackChannel> {
            try await resource._delete(id, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaOrganizationClaudeTagSlackChannelsResource

    /// Set a Slack channel up for Claude Tag and return it with its identifier.
    ///
    /// If the
    /// channel is already set up, whether in claude.ai, by Claude's first use in it or
    /// by an earlier request, the existing channel is returned, so the request can be
    /// repeated. `settings`, when sent, is applied as an update applies it. Before a
    /// channel is set up, Claude's Slack app confirms with Slack that the channel is in
    /// the workspace, is not archived and is visible to the app; a channel that fails
    /// the confirmation returns 404. Setting the channel up and applying `settings` are
    /// two steps: when the second is refused, the response is the refusal, the channel
    /// stays set up with every setting unset, and the error's
    /// `details.slack_channel_id` holds the channel's identifier.
    ///
    /// Args:
    ///   slack: Slack's own identifiers for the channel to set up. The organization must own the
    ///       workspace.
    ///
    ///   settings: Settings to store on the channel, applied as Update Slack Channel applies them.
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
        public func create<R: Sendable>(slack: BetaClaudeTagSlackChannelIdentifiersParam, settings: BetaClaudeTagSettingsCreateParam? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagSlackChannel>) async throws -> R) async throws -> R {
            let response = try await resource._create(slack: slack, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get one Slack channel and its settings.
    ///
    /// By default `settings` holds what the
    /// channel itself stores: a setting that is null there is not set on the channel
    /// and is inherited. With `include_inherited=true`, `settings` holds what applies
    /// in the channel once the settings levels above it are taken into account, and the
    /// request fails with 503 rather than resolve against a settings level that could
    /// not be read. Either way `sources` names the settings level each value comes
    /// from, so a caller tells the channel's own value from an inherited one by its
    /// source, not by whether it is null.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in the channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what the
    ///       channel itself stores.
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
        public func retrieve<R: Sendable>(_ id: String, includeInherited: Bool? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagSlackChannel>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(id, includeInherited: includeInherited, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Change the settings a Slack channel stores.
    ///
    /// The update is partial: a setting
    /// left out is unchanged, and a setting sent as null is cleared, so the channel
    /// inherits it. If any value is refused, no setting in the request is stored. A
    /// group direct message takes no settings and returns 400.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
        public func update<R: Sendable>(_ id: String, settings: BetaClaudeTagSettingsUpdateParam, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagSlackChannel>) async throws -> R) async throws -> R {
            let response = try await resource._update(id, settings: settings, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the set-up Slack channels of one Slack workspace, newest first by
    /// `created_at`. A channel that is not set up is not listed: Slack holds the full
    /// list of a workspace's channels. Pass `slack_channel_id` as well to look one
    /// channel up by its Slack identifiers: `data` then holds that channel, or is empty
    /// when it is not set up, and `limit` and `page` are ignored. A workspace that the
    /// organization owns only through a Slack Enterprise Grid returns 404 until it is
    /// set up. With `include_inherited=true` each channel's `settings` holds what
    /// applies in it, and the request fails with 503 rather than resolve against a
    /// settings level that could not be read. A `page` cursor resumes only a request
    /// with the same `include_inherited`.
    ///
    /// Args:
    ///   slack_workspace_id: The Slack workspace whose channels to list: Slack's identifier for it, as in the
    ///       channel object's `slack.workspace_id`, not the workspace object's `id`.
    ///
    ///   include_inherited: When `true`, `settings` holds what applies in each channel once the settings
    ///       levels above it are taken into account, and every member of `sources` names the
    ///       level a value comes from. When `false` or left out, `settings` holds what each
    ///       channel itself stores.
    ///
    ///   limit: Number of items to return per page, between 1 and 100. Defaults to 20.
    ///
    ///   page: Opaque cursor from a previous response's `next_page`.
    ///
    ///   slack_channel_id: Slack's identifier for one channel of that workspace, as in the channel object's
    ///       `slack.channel_id`. It is not the channel object's `id`. With it `data` holds
    ///       that channel alone, or nothing when the channel is not set up.
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
        public func list<R: Sendable>(slackWorkspaceID: String, includeInherited: Bool? = nil, limit: Int? = nil, page: String? = nil, slackChannelID: String? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaClaudeTagSlackChannel>>) async throws -> R) async throws -> R {
            let response = try await resource._list(slackWorkspaceID: slackWorkspaceID, includeInherited: includeInherited, limit: limit, page: page, slackChannelID: slackChannelID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Remove a Slack channel from Claude Tag.
    ///
    /// This deletes the channel's stored
    /// settings and its Bundle Targets at once, and then, in the background, the
    /// channel's sessions and their transcripts, its memory, its routines and the
    /// artifacts published from it. None of it can be restored. The channel in Slack
    /// and its messages are unchanged. The request is refused with 400 and
    /// `error.details.error_code` `slack_channel_enabled` while `enabled` resolves to
    /// `true` for the channel, as a read with `include_inherited=true` returns it: set
    /// `enabled` to `false` on the channel first. This guards against removing a
    /// channel in use by mistake; it is not a way to keep Claude out, because the
    /// removal deletes the channel's own `enabled: false` with its other settings,
    /// after which the channel inherits again and Claude's next use of it can set it up
    /// anew with a new identifier. The identifier returns 404 as soon as the request
    /// returns, so a repeated removal returns 404. A group direct message returns 400,
    /// and so does a channel that holds configuration this API does not manage.
    ///
    /// Args:
    ///   id: The channel's identifier, starting with `slch_`.
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
        public func delete<R: Sendable>(_ id: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaClaudeTagDeletedSlackChannel>) async throws -> R) async throws -> R {
            let response = try await resource._delete(id, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
