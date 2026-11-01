// Transformed from `anthropic.resources.beta.sessions.threads.events` (events.py).

import Foundation

public struct BetaSessionsThreadsEventsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List Session Thread Events
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
    public func list(_ threadID: String, sessionID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsSessionEvent> {
        try await _list(threadID, sessionID: sessionID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ threadID: String, sessionID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionEvent>> {
        try requireNonEmpty(sessionID, "session_id")
        try requireNonEmpty(threadID, "thread_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/threads/{thread_id}/events", ["session_id": sessionID, "thread_id": threadID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.threads.events.list", spanRoute: "/v1/sessions/{session_id}/threads/{thread_id}/events", spanAttributes: ["anthropic.session.id": sessionID, "anthropic.session.thread.id": threadID], qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsSessionEvent>.self, options, stream: _mode == .stream)
    }

    /// Stream Session Thread Events
    ///
    /// Args:
    ///   event_deltas: When set, this connection also receives streaming deltas (`event_start`,
    ///       `event_delta`) while an event is being produced, before the event itself
    ///       arrives. Deltas are best-effort; when the final event is produced it carries the
    ///       complete content. A model request that ends early (an error or interrupt)
    ///       produces no final event — its terminal `span.model_request_end` closes the
    ///       preview. Accepts one or more event types to preview and may be repeated:
    ///       `agent.message` streams `content_delta` fragments; `agent.thinking` is
    ///       start-only — a signal that the agent has begun extended thinking, concluded by
    ///       the `agent.thinking` event itself. Only previews of the requested event types
    ///       are sent.
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
    public func stream(_ threadID: String, sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Stream<BetaManagedAgentsStreamSessionThreadEvents> {
        try await _stream(threadID, sessionID: sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _stream(_ threadID: String, sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Stream<BetaManagedAgentsStreamSessionThreadEvents>> {
        try requireNonEmpty(sessionID, "session_id")
        try requireNonEmpty(threadID, "thread_id")
        var query = ParamsBuilder()
        try query.set("event_deltas", eventDeltas)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/threads/{thread_id}/stream", ["session_id": sessionID, "thread_id": threadID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.threads.events.stream", spanRoute: "/v1/sessions/{session_id}/threads/{thread_id}/stream", spanAttributes: ["anthropic.session.id": sessionID, "anthropic.session.thread.id": threadID], qualifiers: ["beta": "true"])
        return try await client.requestStreamResponse(BetaManagedAgentsStreamSessionThreadEvents.self, options)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaSessionsThreadsEventsResource

    /// List Session Thread Events
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
        public func list(_ threadID: String, sessionID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionEvent>> {
            try await resource._list(threadID, sessionID: sessionID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Stream Session Thread Events
    ///
    /// Args:
    ///   event_deltas: When set, this connection also receives streaming deltas (`event_start`,
    ///       `event_delta`) while an event is being produced, before the event itself
    ///       arrives. Deltas are best-effort; when the final event is produced it carries the
    ///       complete content. A model request that ends early (an error or interrupt)
    ///       produces no final event — its terminal `span.model_request_end` closes the
    ///       preview. Accepts one or more event types to preview and may be repeated:
    ///       `agent.message` streams `content_delta` fragments; `agent.thinking` is
    ///       start-only — a signal that the agent has begun extended thinking, concluded by
    ///       the `agent.thinking` event itself. Only previews of the requested event types
    ///       are sent.
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
        public func stream(_ threadID: String, sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Stream<BetaManagedAgentsStreamSessionThreadEvents>> {
            try await resource._stream(threadID, sessionID: sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaSessionsThreadsEventsResource

    /// List Session Thread Events
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
        public func list<R: Sendable>(_ threadID: String, sessionID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsSessionEvent>>) async throws -> R) async throws -> R {
            let response = try await resource._list(threadID, sessionID: sessionID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Stream Session Thread Events
    ///
    /// Args:
    ///   event_deltas: When set, this connection also receives streaming deltas (`event_start`,
    ///       `event_delta`) while an event is being produced, before the event itself
    ///       arrives. Deltas are best-effort; when the final event is produced it carries the
    ///       complete content. A model request that ends early (an error or interrupt)
    ///       produces no final event — its terminal `span.model_request_end` closes the
    ///       preview. Accepts one or more event types to preview and may be repeated:
    ///       `agent.message` streams `content_delta` fragments; `agent.thinking` is
    ///       start-only — a signal that the agent has begun extended thinking, concluded by
    ///       the `agent.thinking` event itself. Only previews of the requested event types
    ///       are sent.
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
        public func stream<R: Sendable>(_ threadID: String, sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Stream<BetaManagedAgentsStreamSessionThreadEvents>>) async throws -> R) async throws -> R {
            let response = try await resource._stream(threadID, sessionID: sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
