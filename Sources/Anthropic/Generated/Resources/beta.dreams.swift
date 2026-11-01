// Transformed from `anthropic.resources.beta.dreams` (dreams.py).

import Foundation

public struct BetaDreamsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Start an asynchronous job that uses past sessions to produce a reorganized
    /// version of a memory store and get back the dream to poll for the result.
    ///
    /// By default the dream writes its result to a new memory store and doesn't change
    /// the input memory store. The response has `status` set to `pending` and an empty
    /// `outputs` array. Poll the dream until `status` is `completed`, `failed`, or
    /// `canceled`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#create-a-dream)
    /// to learn more about creating dreams.
    ///
    /// Args:
    ///   inputs: The memory store and sessions for the dream to read, as exactly one
    ///       `memory_store` entry and exactly one `sessions` entry.
    ///
    ///   model: The model that runs a dream, given as a model ID or as an object with `id` and
    ///       `speed`.
    ///
    ///       In the object form, `speed` can only be `standard`.
    ///
    ///       The
    ///       [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    ///       lists the supported models.
    ///
    ///   instructions: Guidance that steers how the dream reads the sessions and organizes the output
    ///       memory store, from 1 to 4,096 characters.
    ///
    ///       See the
    ///       [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#steer-with-instructions)
    ///       for what kinds of instructions work well.
    ///
    ///   output_behavior: Which memory store a dream writes its result to. Defaults to `create_new` when
    ///       left out of a create request.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func create(inputs: [BetaDreamInputParam], model: DreamCreateParams.Model, instructions: String?? = nil, outputBehavior: BetaOutputBehaviorParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDream {
        try await _create(inputs: inputs, model: model, instructions: instructions, outputBehavior: outputBehavior, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(inputs: [BetaDreamInputParam], model: DreamCreateParams.Model, instructions: String?? = nil, outputBehavior: BetaOutputBehaviorParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDream> {
        var body = ParamsBuilder()
        try body.set("inputs", inputs)
        try body.set("model", model)
        try body.set("instructions", instructions)
        try body.set("output_behavior", outputBehavior)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/dreams", body: body, headers: mergeHeaderLayers(["anthropic-beta": "dreaming-2026-04-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["dreaming-2026-04-21"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.dreams.create")
        return try await client.requestResponse(BetaDream.self, options, stream: _mode == .stream)
    }

    /// Get a dream by ID to check its status, output memory store, and token usage.
    ///
    /// Archived dreams are returned too.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#track-progress)
    /// for how to poll a dream and what each status means.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to get (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func retrieve(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDream {
        try await _retrieve(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDream> {
        try requireNonEmpty(dreamID, "dream_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/dreams/{dream_id}", ["dream_id": dreamID]), headers: mergeHeaderLayers(["anthropic-beta": "dreaming-2026-04-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["dreaming-2026-04-21"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.dreams.retrieve")
        return try await client.requestResponse(BetaDream.self, options, stream: _mode == .stream)
    }

    /// List the dreams in the workspace, newest first.
    ///
    /// Archived dreams are left out unless `include_archived` is `true`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#list-dreams)
    /// for how to page through dreams.
    ///
    /// Args:
    ///   created_at_gt: Return only dreams created after this time (exclusive), in RFC 3339.
    ///
    ///   created_at_lt: Return only dreams created before this time (exclusive), in RFC 3339.
    ///
    ///   include_archived: Whether to include archived dreams. Defaults to `false`.
    ///
    ///   limit: The maximum number of dreams to return, from 1 to 100. Defaults to 20.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   statuses: Return only dreams that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return dreams
    ///       of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(createdAtGt: DreamListParams.CreatedAtGt? = nil, createdAtLt: DreamListParams.CreatedAtLt? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, statuses: [BetaDreamStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaDream> {
        try await _list(createdAtGt: createdAtGt, createdAtLt: createdAtLt, includeArchived: includeArchived, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(createdAtGt: DreamListParams.CreatedAtGt? = nil, createdAtLt: DreamListParams.CreatedAtLt? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, statuses: [BetaDreamStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaDream>> {
        var query = ParamsBuilder()
        try query.set("created_at[gt]", createdAtGt)
        try query.set("created_at[lt]", createdAtLt)
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("statuses", statuses)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/dreams", query: query, headers: mergeHeaderLayers(["anthropic-beta": "dreaming-2026-04-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["dreaming-2026-04-21"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.dreams.list")
        return try await client.requestPageResponse(PageCursor<BetaDream>.self, options, stream: _mode == .stream)
    }

    /// Hide a `completed`, `failed`, or `canceled` dream from the default list of
    /// dreams.
    ///
    /// Archiving a `pending` or `running` dream returns a 400 error, so cancel it
    /// first. Archiving an archived dream returns it unchanged. An archived dream can
    /// still be fetched by ID. Archiving can't be undone.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#archive-a-dream)
    /// to learn more about archiving dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to archive (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func archive(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDream {
        try await _archive(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDream> {
        try requireNonEmpty(dreamID, "dream_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/dreams/{dream_id}/archive", ["dream_id": dreamID]), headers: mergeHeaderLayers(["anthropic-beta": "dreaming-2026-04-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["dreaming-2026-04-21"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.dreams.archive")
        return try await client.requestResponse(BetaDream.self, options, stream: _mode == .stream)
    }

    /// Stop a `pending` or `running` dream.
    ///
    /// The response shows `status` as `canceled`, unless the dream reached `completed`
    /// or `failed` first. `usage` can keep changing after the response. Canceling a
    /// `canceled` dream returns it unchanged. Canceling a `completed` or `failed` dream
    /// returns a 400 error.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#cancel-a-dream)
    /// to learn more about canceling dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to cancel (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func cancel(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDream {
        try await _cancel(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _cancel(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDream> {
        try requireNonEmpty(dreamID, "dream_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/dreams/{dream_id}/cancel", ["dream_id": dreamID]), headers: mergeHeaderLayers(["anthropic-beta": "dreaming-2026-04-21"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["dreaming-2026-04-21"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.dreams.cancel")
        return try await client.requestResponse(BetaDream.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaDreamsResource

    /// Start an asynchronous job that uses past sessions to produce a reorganized
    /// version of a memory store and get back the dream to poll for the result.
    ///
    /// By default the dream writes its result to a new memory store and doesn't change
    /// the input memory store. The response has `status` set to `pending` and an empty
    /// `outputs` array. Poll the dream until `status` is `completed`, `failed`, or
    /// `canceled`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#create-a-dream)
    /// to learn more about creating dreams.
    ///
    /// Args:
    ///   inputs: The memory store and sessions for the dream to read, as exactly one
    ///       `memory_store` entry and exactly one `sessions` entry.
    ///
    ///   model: The model that runs a dream, given as a model ID or as an object with `id` and
    ///       `speed`.
    ///
    ///       In the object form, `speed` can only be `standard`.
    ///
    ///       The
    ///       [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    ///       lists the supported models.
    ///
    ///   instructions: Guidance that steers how the dream reads the sessions and organizes the output
    ///       memory store, from 1 to 4,096 characters.
    ///
    ///       See the
    ///       [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#steer-with-instructions)
    ///       for what kinds of instructions work well.
    ///
    ///   output_behavior: Which memory store a dream writes its result to. Defaults to `create_new` when
    ///       left out of a create request.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create(inputs: [BetaDreamInputParam], model: DreamCreateParams.Model, instructions: String?? = nil, outputBehavior: BetaOutputBehaviorParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDream> {
            try await resource._create(inputs: inputs, model: model, instructions: instructions, outputBehavior: outputBehavior, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get a dream by ID to check its status, output memory store, and token usage.
    ///
    /// Archived dreams are returned too.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#track-progress)
    /// for how to poll a dream and what each status means.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to get (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDream> {
            try await resource._retrieve(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List the dreams in the workspace, newest first.
    ///
    /// Archived dreams are left out unless `include_archived` is `true`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#list-dreams)
    /// for how to page through dreams.
    ///
    /// Args:
    ///   created_at_gt: Return only dreams created after this time (exclusive), in RFC 3339.
    ///
    ///   created_at_lt: Return only dreams created before this time (exclusive), in RFC 3339.
    ///
    ///   include_archived: Whether to include archived dreams. Defaults to `false`.
    ///
    ///   limit: The maximum number of dreams to return, from 1 to 100. Defaults to 20.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   statuses: Return only dreams that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return dreams
    ///       of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(createdAtGt: DreamListParams.CreatedAtGt? = nil, createdAtLt: DreamListParams.CreatedAtLt? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, statuses: [BetaDreamStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaDream>> {
            try await resource._list(createdAtGt: createdAtGt, createdAtLt: createdAtLt, includeArchived: includeArchived, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Hide a `completed`, `failed`, or `canceled` dream from the default list of
    /// dreams.
    ///
    /// Archiving a `pending` or `running` dream returns a 400 error, so cancel it
    /// first. Archiving an archived dream returns it unchanged. An archived dream can
    /// still be fetched by ID. Archiving can't be undone.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#archive-a-dream)
    /// to learn more about archiving dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to archive (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDream> {
            try await resource._archive(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Stop a `pending` or `running` dream.
    ///
    /// The response shows `status` as `canceled`, unless the dream reached `completed`
    /// or `failed` first. `usage` can keep changing after the response. Canceling a
    /// `canceled` dream returns it unchanged. Canceling a `completed` or `failed` dream
    /// returns a 400 error.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#cancel-a-dream)
    /// to learn more about canceling dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to cancel (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func cancel(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDream> {
            try await resource._cancel(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaDreamsResource

    /// Start an asynchronous job that uses past sessions to produce a reorganized
    /// version of a memory store and get back the dream to poll for the result.
    ///
    /// By default the dream writes its result to a new memory store and doesn't change
    /// the input memory store. The response has `status` set to `pending` and an empty
    /// `outputs` array. Poll the dream until `status` is `completed`, `failed`, or
    /// `canceled`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#create-a-dream)
    /// to learn more about creating dreams.
    ///
    /// Args:
    ///   inputs: The memory store and sessions for the dream to read, as exactly one
    ///       `memory_store` entry and exactly one `sessions` entry.
    ///
    ///   model: The model that runs a dream, given as a model ID or as an object with `id` and
    ///       `speed`.
    ///
    ///       In the object form, `speed` can only be `standard`.
    ///
    ///       The
    ///       [limits table in the Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#limits)
    ///       lists the supported models.
    ///
    ///   instructions: Guidance that steers how the dream reads the sessions and organizes the output
    ///       memory store, from 1 to 4,096 characters.
    ///
    ///       See the
    ///       [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#steer-with-instructions)
    ///       for what kinds of instructions work well.
    ///
    ///   output_behavior: Which memory store a dream writes its result to. Defaults to `create_new` when
    ///       left out of a create request.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func create<R: Sendable>(inputs: [BetaDreamInputParam], model: DreamCreateParams.Model, instructions: String?? = nil, outputBehavior: BetaOutputBehaviorParam? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDream>) async throws -> R) async throws -> R {
            let response = try await resource._create(inputs: inputs, model: model, instructions: instructions, outputBehavior: outputBehavior, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get a dream by ID to check its status, output memory store, and token usage.
    ///
    /// Archived dreams are returned too.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#track-progress)
    /// for how to poll a dream and what each status means.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to get (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func retrieve<R: Sendable>(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDream>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List the dreams in the workspace, newest first.
    ///
    /// Archived dreams are left out unless `include_archived` is `true`.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#list-dreams)
    /// for how to page through dreams.
    ///
    /// Args:
    ///   created_at_gt: Return only dreams created after this time (exclusive), in RFC 3339.
    ///
    ///   created_at_lt: Return only dreams created before this time (exclusive), in RFC 3339.
    ///
    ///   include_archived: Whether to include archived dreams. Defaults to `false`.
    ///
    ///   limit: The maximum number of dreams to return, from 1 to 100. Defaults to 20.
    ///
    ///   page: The cursor for the page to return, taken from `next_page` in a previous
    ///       response.
    ///
    ///       Leave it out to get the first page.
    ///
    ///   statuses: Return only dreams that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return dreams
    ///       of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(createdAtGt: DreamListParams.CreatedAtGt? = nil, createdAtLt: DreamListParams.CreatedAtLt? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, statuses: [BetaDreamStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaDream>>) async throws -> R) async throws -> R {
            let response = try await resource._list(createdAtGt: createdAtGt, createdAtLt: createdAtLt, includeArchived: includeArchived, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Hide a `completed`, `failed`, or `canceled` dream from the default list of
    /// dreams.
    ///
    /// Archiving a `pending` or `running` dream returns a 400 error, so cancel it
    /// first. Archiving an archived dream returns it unchanged. An archived dream can
    /// still be fetched by ID. Archiving can't be undone.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#archive-a-dream)
    /// to learn more about archiving dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to archive (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func archive<R: Sendable>(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDream>) async throws -> R) async throws -> R {
            let response = try await resource._archive(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Stop a `pending` or `running` dream.
    ///
    /// The response shows `status` as `canceled`, unless the dream reached `completed`
    /// or `failed` first. `usage` can keep changing after the response. Canceling a
    /// `canceled` dream returns it unchanged. Canceling a `completed` or `failed` dream
    /// returns a 400 error.
    ///
    /// See the
    /// [Dreams guide](https://platform.claude.com/docs/en/managed-agents/dreams#cancel-a-dream)
    /// to learn more about canceling dreams.
    ///
    /// Args:
    ///   dream_id: The ID of the dream to cancel (`drm_...`).
    ///
    ///   betas: This endpoint is in beta: requests must send `dreaming-2026-04-21` in this
    ///       header.
    ///
    ///   workspace_id: Optional header to select the Workspace for this request. The value is a
    ///       Workspace ID (for example, `wrkspc_011CZkZaBF1tNoB5wlCeusgy`).
    ///
    ///       Only needed for credentials that can act on more than one Workspace. A
    ///       credential that belongs to a specific Workspace may omit it; if sent, it must
    ///       match that Workspace.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func cancel<R: Sendable>(_ dreamID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDream>) async throws -> R) async throws -> R {
            let response = try await resource._cancel(dreamID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
