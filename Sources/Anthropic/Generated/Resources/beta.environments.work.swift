// Transformed from `anthropic.resources.beta.environments.work` (work.py).

import Foundation

public struct BetaEnvironmentsWorkResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Retrieve detailed information about a specific work item.
    ///
    /// Args:
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
    public func retrieve(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWork {
        try await _retrieve(workID, environmentID: environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWork> {
        try requireNonEmpty(environmentID, "environment_id")
        try requireNonEmpty(workID, "work_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/environments/{environment_id}/work/{work_id}", ["environment_id": environmentID, "work_id": workID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.retrieve", spanRoute: "/v1/environments/{environment_id}/work/{work_id}", spanAttributes: ["anthropic.environment.id": environmentID, "anthropic.environment.work.id": workID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWork.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Update work item metadata with merge semantics.
    ///
    /// Args:
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve existing metadata.
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
    public func update(_ workID: String, environmentID: String, metadata: [String: String?], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWork {
        try await _update(workID, environmentID: environmentID, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ workID: String, environmentID: String, metadata: [String: String?], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWork> {
        try requireNonEmpty(environmentID, "environment_id")
        try requireNonEmpty(workID, "work_id")
        var body = ParamsBuilder()
        try body.set("metadata", metadata)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/environments/{environment_id}/work/{work_id}", ["environment_id": environmentID, "work_id": workID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.update", spanRoute: "/v1/environments/{environment_id}/work/{work_id}", spanAttributes: ["anthropic.environment.id": environmentID, "anthropic.environment.work.id": workID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWork.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// List work items in an environment.
    ///
    /// Args:
    ///   limit: Maximum number of work items to return
    ///
    ///   page: Opaque cursor from previous response for pagination
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func list(_ environmentID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaSelfHostedWork> {
        try await _list(environmentID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ environmentID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaSelfHostedWork>> {
        try requireNonEmpty(environmentID, "environment_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/environments/{environment_id}/work", ["environment_id": environmentID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.list", spanRoute: "/v1/environments/{environment_id}/work", spanAttributes: ["anthropic.environment.id": environmentID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaSelfHostedWork>.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Acknowledge receipt of a work item, transitioning it from 'queued' to 'starting'
    /// and removing it from the queue.
    ///
    /// Args:
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func ack(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWork {
        try await _ack(workID, environmentID: environmentID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _ack(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWork> {
        try requireNonEmpty(environmentID, "environment_id")
        try requireNonEmpty(workID, "work_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/environments/{environment_id}/work/{work_id}/ack", ["environment_id": environmentID, "work_id": workID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.ack", spanRoute: "/v1/environments/{environment_id}/work/{work_id}/ack", spanAttributes: ["anthropic.environment.id": environmentID, "anthropic.environment.work.id": workID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWork.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Record a heartbeat for a work item to maintain the lease.
    ///
    /// Args:
    ///   desired_ttl_seconds: Desired TTL in seconds
    ///
    ///   expected_last_heartbeat: Expected last_heartbeat for conditional update (optimistic concurrency). Use
    ///       literal 'NO_HEARTBEAT' to claim an unclaimed lease (first heartbeat). For
    ///       subsequent heartbeats, echo the server's previous last_heartbeat value exactly.
    ///       Returns 412 Precondition Failed if the actual value doesn't match.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func heartbeat(_ workID: String, environmentID: String, desiredTtlSeconds: Int?? = nil, expectedLastHeartbeat: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWorkHeartbeatResponse {
        try await _heartbeat(workID, environmentID: environmentID, desiredTtlSeconds: desiredTtlSeconds, expectedLastHeartbeat: expectedLastHeartbeat, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _heartbeat(_ workID: String, environmentID: String, desiredTtlSeconds: Int?? = nil, expectedLastHeartbeat: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWorkHeartbeatResponse> {
        try requireNonEmpty(environmentID, "environment_id")
        try requireNonEmpty(workID, "work_id")
        var query = ParamsBuilder()
        try query.set("desired_ttl_seconds", desiredTtlSeconds)
        try query.set("expected_last_heartbeat", expectedLastHeartbeat)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/environments/{environment_id}/work/{work_id}/heartbeat", ["environment_id": environmentID, "work_id": workID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ","))]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.heartbeat", spanRoute: "/v1/environments/{environment_id}/work/{work_id}/heartbeat", spanAttributes: ["anthropic.environment.id": environmentID, "anthropic.environment.work.id": workID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWorkHeartbeatResponse.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Long poll for work items in the queue.
    ///
    /// Args:
    ///   block_ms: How long to wait for work to arrive before returning. Must be 1-999 in
    ///       milliseconds. Defaults to non-blocking (returns immediately if no work is
    ///       available).
    ///
    ///   reclaim_older_than_ms: Reclaim unacknowledged work items older than this many milliseconds. If omitted,
    ///       uses the default (5000ms).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   anthropic_worker_id: Unique identifier for the specific worker polling, used to track aggregated
    ///       environment-level work metrics in Console
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
    public func poll(_ environmentID: String, blockMs: Int?? = nil, reclaimOlderThanMs: Int?? = nil, betas: [AnthropicBetaParam]? = nil, anthropicWorkerID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWork {
        try await _poll(environmentID, blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, betas: betas, anthropicWorkerID: anthropicWorkerID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _poll(_ environmentID: String, blockMs: Int?? = nil, reclaimOlderThanMs: Int?? = nil, betas: [AnthropicBetaParam]? = nil, anthropicWorkerID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWork> {
        try requireNonEmpty(environmentID, "environment_id")
        var query = ParamsBuilder()
        try query.set("block_ms", blockMs)
        try query.set("reclaim_older_than_ms", reclaimOlderThanMs)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/environments/{environment_id}/work/poll", ["environment_id": environmentID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("Anthropic-Worker-ID", anthropicWorkerID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.poll", spanRoute: "/v1/environments/{environment_id}/work/poll", spanAttributes: ["anthropic.environment.id": environmentID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWork.self, options, stream: _mode == .stream)
    }

    /// Get statistics about the work queue for an environment.
    ///
    /// Args:
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
    public func stats(_ environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWorkQueueStats {
        try await _stats(environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _stats(_ environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWorkQueueStats> {
        try requireNonEmpty(environmentID, "environment_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/environments/{environment_id}/work/stats", ["environment_id": environmentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.stats", spanRoute: "/v1/environments/{environment_id}/work/stats", spanAttributes: ["anthropic.environment.id": environmentID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWorkQueueStats.self, options, stream: _mode == .stream)
    }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Stop a work item, initiating graceful or forced shutdown.
    ///
    /// Args:
    ///   force: If true, immediately stop work without graceful shutdown
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
    public func stop(_ workID: String, environmentID: String, force: Bool? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaSelfHostedWork {
        try await _stop(workID, environmentID: environmentID, force: force, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _stop(_ workID: String, environmentID: String, force: Bool? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaSelfHostedWork> {
        try requireNonEmpty(environmentID, "environment_id")
        try requireNonEmpty(workID, "work_id")
        var body = ParamsBuilder()
        try body.set("force", force)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/environments/{environment_id}/work/{work_id}/stop", ["environment_id": environmentID, "work_id": workID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.environments.work.stop", spanRoute: "/v1/environments/{environment_id}/work/{work_id}/stop", spanAttributes: ["anthropic.environment.id": environmentID, "anthropic.environment.work.id": workID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaSelfHostedWork.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaEnvironmentsWorkResource

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Retrieve detailed information about a specific work item.
    ///
    /// Args:
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
        public func retrieve(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWork> {
            try await resource._retrieve(workID, environmentID: environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Update work item metadata with merge semantics.
    ///
    /// Args:
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve existing metadata.
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
        public func update(_ workID: String, environmentID: String, metadata: [String: String?], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWork> {
            try await resource._update(workID, environmentID: environmentID, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// List work items in an environment.
    ///
    /// Args:
    ///   limit: Maximum number of work items to return
    ///
    ///   page: Opaque cursor from previous response for pagination
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list(_ environmentID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaSelfHostedWork>> {
            try await resource._list(environmentID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Acknowledge receipt of a work item, transitioning it from 'queued' to 'starting'
    /// and removing it from the queue.
    ///
    /// Args:
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func ack(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWork> {
            try await resource._ack(workID, environmentID: environmentID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Record a heartbeat for a work item to maintain the lease.
    ///
    /// Args:
    ///   desired_ttl_seconds: Desired TTL in seconds
    ///
    ///   expected_last_heartbeat: Expected last_heartbeat for conditional update (optimistic concurrency). Use
    ///       literal 'NO_HEARTBEAT' to claim an unclaimed lease (first heartbeat). For
    ///       subsequent heartbeats, echo the server's previous last_heartbeat value exactly.
    ///       Returns 412 Precondition Failed if the actual value doesn't match.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func heartbeat(_ workID: String, environmentID: String, desiredTtlSeconds: Int?? = nil, expectedLastHeartbeat: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWorkHeartbeatResponse> {
            try await resource._heartbeat(workID, environmentID: environmentID, desiredTtlSeconds: desiredTtlSeconds, expectedLastHeartbeat: expectedLastHeartbeat, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Long poll for work items in the queue.
    ///
    /// Args:
    ///   block_ms: How long to wait for work to arrive before returning. Must be 1-999 in
    ///       milliseconds. Defaults to non-blocking (returns immediately if no work is
    ///       available).
    ///
    ///   reclaim_older_than_ms: Reclaim unacknowledged work items older than this many milliseconds. If omitted,
    ///       uses the default (5000ms).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   anthropic_worker_id: Unique identifier for the specific worker polling, used to track aggregated
    ///       environment-level work metrics in Console
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func poll(_ environmentID: String, blockMs: Int?? = nil, reclaimOlderThanMs: Int?? = nil, betas: [AnthropicBetaParam]? = nil, anthropicWorkerID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWork> {
            try await resource._poll(environmentID, blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, betas: betas, anthropicWorkerID: anthropicWorkerID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get statistics about the work queue for an environment.
    ///
    /// Args:
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
        public func stats(_ environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWorkQueueStats> {
            try await resource._stats(environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Stop a work item, initiating graceful or forced shutdown.
    ///
    /// Args:
    ///   force: If true, immediately stop work without graceful shutdown
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
        public func stop(_ workID: String, environmentID: String, force: Bool? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaSelfHostedWork> {
            try await resource._stop(workID, environmentID: environmentID, force: force, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaEnvironmentsWorkResource

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Retrieve detailed information about a specific work item.
    ///
    /// Args:
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
        public func retrieve<R: Sendable>(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWork>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(workID, environmentID: environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Update work item metadata with merge semantics.
    ///
    /// Args:
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve existing metadata.
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
        public func update<R: Sendable>(_ workID: String, environmentID: String, metadata: [String: String?], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWork>) async throws -> R) async throws -> R {
            let response = try await resource._update(workID, environmentID: environmentID, metadata: metadata, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// List work items in an environment.
    ///
    /// Args:
    ///   limit: Maximum number of work items to return
    ///
    ///   page: Opaque cursor from previous response for pagination
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func list<R: Sendable>(_ environmentID: String, limit: Int? = nil, page: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaSelfHostedWork>>) async throws -> R) async throws -> R {
            let response = try await resource._list(environmentID, limit: limit, page: page, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Acknowledge receipt of a work item, transitioning it from 'queued' to 'starting'
    /// and removing it from the queue.
    ///
    /// Args:
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func ack<R: Sendable>(_ workID: String, environmentID: String, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWork>) async throws -> R) async throws -> R {
            let response = try await resource._ack(workID, environmentID: environmentID, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Record a heartbeat for a work item to maintain the lease.
    ///
    /// Args:
    ///   desired_ttl_seconds: Desired TTL in seconds
    ///
    ///   expected_last_heartbeat: Expected last_heartbeat for conditional update (optimistic concurrency). Use
    ///       literal 'NO_HEARTBEAT' to claim an unclaimed lease (first heartbeat). For
    ///       subsequent heartbeats, echo the server's previous last_heartbeat value exactly.
    ///       Returns 412 Precondition Failed if the actual value doesn't match.
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func heartbeat<R: Sendable>(_ workID: String, environmentID: String, desiredTtlSeconds: Int?? = nil, expectedLastHeartbeat: String?? = nil, betas: [AnthropicBetaParam]? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWorkHeartbeatResponse>) async throws -> R) async throws -> R {
            let response = try await resource._heartbeat(workID, environmentID: environmentID, desiredTtlSeconds: desiredTtlSeconds, expectedLastHeartbeat: expectedLastHeartbeat, betas: betas, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Long poll for work items in the queue.
    ///
    /// Args:
    ///   block_ms: How long to wait for work to arrive before returning. Must be 1-999 in
    ///       milliseconds. Defaults to non-blocking (returns immediately if no work is
    ///       available).
    ///
    ///   reclaim_older_than_ms: Reclaim unacknowledged work items older than this many milliseconds. If omitted,
    ///       uses the default (5000ms).
    ///
    ///   betas: Optional header to specify the beta version(s) you want to use.
    ///
    ///   anthropic_worker_id: Unique identifier for the specific worker polling, used to track aggregated
    ///       environment-level work metrics in Console
    ///
    ///   extra_headers: Send extra headers
    ///
    ///   extra_query: Add additional query parameters to the request
    ///
    ///   extra_body: Add additional JSON properties to the request
    ///
    ///   timeout: Override the client-level default timeout for this request, in seconds
        public func poll<R: Sendable>(_ environmentID: String, blockMs: Int?? = nil, reclaimOlderThanMs: Int?? = nil, betas: [AnthropicBetaParam]? = nil, anthropicWorkerID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWork>) async throws -> R) async throws -> R {
            let response = try await resource._poll(environmentID, blockMs: blockMs, reclaimOlderThanMs: reclaimOlderThanMs, betas: betas, anthropicWorkerID: anthropicWorkerID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get statistics about the work queue for an environment.
    ///
    /// Args:
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
        public func stats<R: Sendable>(_ environmentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWorkQueueStats>) async throws -> R) async throws -> R {
            let response = try await resource._stats(environmentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Note: these endpoints are called automatically by the pre-built environment
    /// worker provided in the SDKs and CLI, for orchestrating sessions with self-hosted
    /// sandbox environments. They are included here as a reference; you do not need to
    /// invoke them directly.
    ///
    /// Stop a work item, initiating graceful or forced shutdown.
    ///
    /// Args:
    ///   force: If true, immediately stop work without graceful shutdown
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
        public func stop<R: Sendable>(_ workID: String, environmentID: String, force: Bool? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaSelfHostedWork>) async throws -> R) async throws -> R {
            let response = try await resource._stop(workID, environmentID: environmentID, force: force, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
