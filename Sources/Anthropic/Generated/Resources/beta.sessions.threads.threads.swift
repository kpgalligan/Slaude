// Transformed from `anthropic.resources.beta.sessions.threads.threads` (threads.py).

import Foundation

public struct BetaSessionsThreadsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var events: BetaSessionsThreadsEventsResource { BetaSessionsThreadsEventsResource(client: client) }

    /// Get Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
    public func retrieve(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSessionThread {
        try await _retrieve(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSessionThread> {
        try requireNonEmpty(sessionID, "session_id")
        try requireNonEmpty(threadID, "thread_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/threads/{thread_id}", ["session_id": sessionID, "thread_id": threadID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.threads.retrieve")
        return try await client.requestResponse(BetaManagedAgentsSessionThread.self, options, stream: _mode == .stream)
    }

    /// List Session Threads
    ///
    /// Args:
    ///   limit: Maximum results per page.
    ///
    /// Defaults to 1000.
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`. Forward-only.
    ///
    ///   statuses: Return only threads that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return
    ///       threads of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
    public func list(_ sessionID: String, limit: Int? = nil, page: String? = nil, statuses: [BetaManagedAgentsSessionThreadStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsSessionThread> {
        try await _list(sessionID, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ sessionID: String, limit: Int? = nil, page: String? = nil, statuses: [BetaManagedAgentsSessionThreadStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionThread>> {
        try requireNonEmpty(sessionID, "session_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("statuses", statuses)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/threads", ["session_id": sessionID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.threads.list")
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsSessionThread>.self, options, stream: _mode == .stream)
    }

    /// Archive Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
    public func archive(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSessionThread {
        try await _archive(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSessionThread> {
        try requireNonEmpty(sessionID, "session_id")
        try requireNonEmpty(threadID, "thread_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/sessions/{session_id}/threads/{thread_id}/archive", ["session_id": sessionID, "thread_id": threadID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.threads.archive")
        return try await client.requestResponse(BetaManagedAgentsSessionThread.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaSessionsThreadsResource

        public var events: BetaSessionsThreadsEventsResource.WithRawResponse { resource.events.withRawResponse }

    /// Get Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func retrieve(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSessionThread> {
            try await resource._retrieve(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Session Threads
    ///
    /// Args:
    ///   limit: Maximum results per page.
    ///
    /// Defaults to 1000.
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`. Forward-only.
    ///
    ///   statuses: Return only threads that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return
    ///       threads of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func list(_ sessionID: String, limit: Int? = nil, page: String? = nil, statuses: [BetaManagedAgentsSessionThreadStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionThread>> {
            try await resource._list(sessionID, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func archive(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSessionThread> {
            try await resource._archive(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaSessionsThreadsResource

        public var events: BetaSessionsThreadsEventsResource.WithStreamingResponse { resource.events.withStreamingResponse }

    /// Get Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func retrieve<R: Sendable>(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSessionThread>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Session Threads
    ///
    /// Args:
    ///   limit: Maximum results per page.
    ///
    /// Defaults to 1000.
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`. Forward-only.
    ///
    ///   statuses: Return only threads that have one of these statuses.
    ///
    ///       Repeat the parameter to give more than one status. Leave it out to return
    ///       threads of every status.
    ///
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func list<R: Sendable>(_ sessionID: String, limit: Int? = nil, page: String? = nil, statuses: [BetaManagedAgentsSessionThreadStatus]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsSessionThread>>) async throws -> R) async throws -> R {
            let response = try await resource._list(sessionID, limit: limit, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive Session Thread
    ///
    /// Args:
    ///   betas: This endpoint is in beta: requests must send `managed-agents-2026-04-01` in this
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
        public func archive<R: Sendable>(_ threadID: String, sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSessionThread>) async throws -> R) async throws -> R {
            let response = try await resource._archive(threadID, sessionID: sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
