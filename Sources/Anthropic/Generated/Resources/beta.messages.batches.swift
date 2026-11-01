// Transformed from `anthropic.resources.beta.messages.batches` (batches.py).

import Foundation

public struct BetaMessagesBatchesResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Send a batch of Message creation requests.
    ///
    /// The Message Batches API can be used to process multiple Messages API requests at
    /// once. Once a Message Batch is created, it begins processing immediately. Batches
    /// can take up to 24 hours to complete.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   requests: List of requests for prompt completion. Each is an individual request to create
    ///       a Message.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute the requests in this batch to. Use when acting
    ///       on behalf of a party other than your organization. Applies to every request in
    ///       the batch; an individual request whose `user_profile_id` body field conflicts
    ///       with this header is errored.
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
    public func create(requests: [BetaMessagesBatchCreateParams.Request], betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaMessageBatch {
        try await _create(requests: requests, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(requests: [BetaMessagesBatchCreateParams.Request], betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaMessageBatch> {
        var body = ParamsBuilder()
        try body.set("requests", requests)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/messages/batches", body: body, headers: mergeHeaderLayers(["anthropic-beta": "message-batches-2024-09-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"], separator: ",")), ("anthropic-user-profile-id", userProfileID), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.create", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaMessageBatch.self, options, stream: _mode == .stream)
    }

    /// This endpoint is idempotent and can be used to poll for Message Batch
    /// completion.
    ///
    /// To access the results of a Message Batch, make a request to the
    /// `results_url` field in the response.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func retrieve(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaMessageBatch {
        try await _retrieve(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaMessageBatch> {
        try requireNonEmpty(messageBatchID, "message_batch_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/messages/batches/{message_batch_id}", ["message_batch_id": messageBatchID]), headers: mergeHeaderLayers(["anthropic-beta": "message-batches-2024-09-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaMessageBatch.self, options, stream: _mode == .stream)
    }

    /// List all Message Batches within a Workspace.
    ///
    /// Most recently created batches are
    /// returned first.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func list(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Page<BetaMessageBatch> {
        try await _list(afterID: afterID, beforeID: beforeID, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Page<BetaMessageBatch>> {
        var query = ParamsBuilder()
        try query.set("after_id", afterID)
        try query.set("before_id", beforeID)
        try query.set("limit", limit)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/messages/batches", query: query, headers: mergeHeaderLayers(["anthropic-beta": "message-batches-2024-09-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(Page<BetaMessageBatch>.self, options, stream: _mode == .stream)
    }

    /// Delete a Message Batch.
    ///
    /// Message Batches can only be deleted once they've finished processing. If you'd
    /// like to delete an in-progress batch, you must first cancel it.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func delete(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaDeletedMessageBatch {
        try await _delete(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaDeletedMessageBatch> {
        try requireNonEmpty(messageBatchID, "message_batch_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/messages/batches/{message_batch_id}", ["message_batch_id": messageBatchID]), headers: mergeHeaderLayers(["anthropic-beta": "message-batches-2024-09-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.delete", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaDeletedMessageBatch.self, options, stream: _mode == .stream)
    }

    /// Batches may be canceled any time before processing ends.
    ///
    /// Once cancellation is
    /// initiated, the batch enters a `canceling` state, at which time the system may
    /// complete any in-progress, non-interruptible requests before finalizing
    /// cancellation.
    ///
    /// The number of canceled requests is specified in `request_counts`. To determine
    /// which requests were canceled, check the individual results within the batch.
    /// Note that cancellation may not result in any canceled requests if they were
    /// non-interruptible.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
    public func cancel(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaMessageBatch {
        try await _cancel(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _cancel(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaMessageBatch> {
        try requireNonEmpty(messageBatchID, "message_batch_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/messages/batches/{message_batch_id}/cancel", ["message_batch_id": messageBatchID]), headers: mergeHeaderLayers(["anthropic-beta": "message-batches-2024-09-24"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["message-batches-2024-09-24"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.messages.batches.cancel", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaMessageBatch.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaMessagesBatchesResource

    /// Send a batch of Message creation requests.
    ///
    /// The Message Batches API can be used to process multiple Messages API requests at
    /// once. Once a Message Batch is created, it begins processing immediately. Batches
    /// can take up to 24 hours to complete.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   requests: List of requests for prompt completion. Each is an individual request to create
    ///       a Message.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute the requests in this batch to. Use when acting
    ///       on behalf of a party other than your organization. Applies to every request in
    ///       the batch; an individual request whose `user_profile_id` body field conflicts
    ///       with this header is errored.
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
        public func create(requests: [BetaMessagesBatchCreateParams.Request], betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaMessageBatch> {
            try await resource._create(requests: requests, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// This endpoint is idempotent and can be used to poll for Message Batch
    /// completion.
    ///
    /// To access the results of a Message Batch, make a request to the
    /// `results_url` field in the response.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func retrieve(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaMessageBatch> {
            try await resource._retrieve(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List all Message Batches within a Workspace.
    ///
    /// Most recently created batches are
    /// returned first.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func list(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Page<BetaMessageBatch>> {
            try await resource._list(afterID: afterID, beforeID: beforeID, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete a Message Batch.
    ///
    /// Message Batches can only be deleted once they've finished processing. If you'd
    /// like to delete an in-progress batch, you must first cancel it.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func delete(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaDeletedMessageBatch> {
            try await resource._delete(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Batches may be canceled any time before processing ends.
    ///
    /// Once cancellation is
    /// initiated, the batch enters a `canceling` state, at which time the system may
    /// complete any in-progress, non-interruptible requests before finalizing
    /// cancellation.
    ///
    /// The number of canceled requests is specified in `request_counts`. To determine
    /// which requests were canceled, check the individual results within the batch.
    /// Note that cancellation may not result in any canceled requests if they were
    /// non-interruptible.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func cancel(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaMessageBatch> {
            try await resource._cancel(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaMessagesBatchesResource

    /// Send a batch of Message creation requests.
    ///
    /// The Message Batches API can be used to process multiple Messages API requests at
    /// once. Once a Message Batch is created, it begins processing immediately. Batches
    /// can take up to 24 hours to complete.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   requests: List of requests for prompt completion. Each is an individual request to create
    ///       a Message.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   user_profile_id: The user profile ID to attribute the requests in this batch to. Use when acting
    ///       on behalf of a party other than your organization. Applies to every request in
    ///       the batch; an individual request whose `user_profile_id` body field conflicts
    ///       with this header is errored.
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
        public func create<R: Sendable>(requests: [BetaMessagesBatchCreateParams.Request], betas: [AnthropicBetaParam]? = nil, userProfileID: String? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaMessageBatch>) async throws -> R) async throws -> R {
            let response = try await resource._create(requests: requests, betas: betas, userProfileID: userProfileID, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// This endpoint is idempotent and can be used to poll for Message Batch
    /// completion.
    ///
    /// To access the results of a Message Batch, make a request to the
    /// `results_url` field in the response.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func retrieve<R: Sendable>(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaMessageBatch>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List all Message Batches within a Workspace.
    ///
    /// Most recently created batches are
    /// returned first.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   after_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately after this object.
    ///
    ///   before_id: ID of the object to use as a cursor for pagination. When provided, returns the
    ///       page of results immediately before this object.
    ///
    ///   limit: Number of items to return per page.
    ///
    ///       Defaults to `20`. Ranges from `1` to `1000`.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func list<R: Sendable>(afterID: String? = nil, beforeID: String? = nil, limit: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Page<BetaMessageBatch>>) async throws -> R) async throws -> R {
            let response = try await resource._list(afterID: afterID, beforeID: beforeID, limit: limit, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete a Message Batch.
    ///
    /// Message Batches can only be deleted once they've finished processing. If you'd
    /// like to delete an in-progress batch, you must first cancel it.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func delete<R: Sendable>(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaDeletedMessageBatch>) async throws -> R) async throws -> R {
            let response = try await resource._delete(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Batches may be canceled any time before processing ends.
    ///
    /// Once cancellation is
    /// initiated, the batch enters a `canceling` state, at which time the system may
    /// complete any in-progress, non-interruptible requests before finalizing
    /// cancellation.
    ///
    /// The number of canceled requests is specified in `request_counts`. To determine
    /// which requests were canceled, check the individual results within the batch.
    /// Note that cancellation may not result in any canceled requests if they were
    /// non-interruptible.
    ///
    /// Learn more about the Message Batches API in our
    /// [user guide](https://platform.claude.com/docs/en/build-with-claude/batch-processing)
    ///
    /// Args:
    ///   message_batch_id: ID of the Message Batch.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
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
        public func cancel<R: Sendable>(_ messageBatchID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaMessageBatch>) async throws -> R) async throws -> R {
            let response = try await resource._cancel(messageBatchID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
