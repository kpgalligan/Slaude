// Transformed from `anthropic.resources.beta.sessions.events` (events.py).

import Foundation

public struct BetaSessionsEventsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List Events
    ///
    /// Args:
    ///   created_at_gt: Return events created after this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_gte: Return events created at or after this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   created_at_lt: Return events created before this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_lte: Return events created at or before this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   order: Sort direction for results, ordered by the event's `processed_at`. Defaults to
    ///       `asc` (chronological).
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`.
    ///
    ///   types: Filter by event type. Values match the `type` field on returned events (for
    ///       example, `user.message` or `agent.tool_use`). Omit to return all event types.
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
    public func list(_ sessionID: String, createdAtGt: EventListParams.CreatedAtGt? = nil, createdAtGte: EventListParams.CreatedAtGte? = nil, createdAtLt: EventListParams.CreatedAtLt? = nil, createdAtLte: EventListParams.CreatedAtLte? = nil, limit: Int? = nil, order: EventListParams.Order? = nil, page: String? = nil, types: [BetaManagedAgentsSessionEventType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsSessionEvent> {
        try await _list(sessionID, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, order: order, page: page, types: types, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ sessionID: String, createdAtGt: EventListParams.CreatedAtGt? = nil, createdAtGte: EventListParams.CreatedAtGte? = nil, createdAtLt: EventListParams.CreatedAtLt? = nil, createdAtLte: EventListParams.CreatedAtLte? = nil, limit: Int? = nil, order: EventListParams.Order? = nil, page: String? = nil, types: [BetaManagedAgentsSessionEventType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionEvent>> {
        try requireNonEmpty(sessionID, "session_id")
        var query = ParamsBuilder()
        try query.set("created_at[gt]", createdAtGt)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lt]", createdAtLt)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("limit", limit)
        try query.set("order", order)
        try query.set("page", page)
        try query.set("types", types)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/events", ["session_id": sessionID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.events.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsSessionEvent>.self, options, stream: _mode == .stream)
    }

    /// Send Events
    ///
    /// Args:
    ///   events: Events to send to the `session`.
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
    public func send(_ sessionID: String, events: [BetaManagedAgentsEventParams], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSendSessionEvents {
        try await _send(sessionID, events: events, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _send(_ sessionID: String, events: [BetaManagedAgentsEventParams], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSendSessionEvents> {
        try requireNonEmpty(sessionID, "session_id")
        var body = ParamsBuilder()
        try body.set("events", events)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/sessions/{session_id}/events", ["session_id": sessionID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.events.send", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsSendSessionEvents.self, options, stream: _mode == .stream)
    }

    /// Stream Events
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
    public func stream(_ sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> Stream<BetaManagedAgentsStreamSessionEvents> {
        try await _stream(sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _stream(_ sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<Stream<BetaManagedAgentsStreamSessionEvents>> {
        try requireNonEmpty(sessionID, "session_id")
        var query = ParamsBuilder()
        try query.set("event_deltas", eventDeltas)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}/events/stream", ["session_id": sessionID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.events.stream", qualifiers: ["beta": "true"])
        return try await client.requestStreamResponse(BetaManagedAgentsStreamSessionEvents.self, options)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaSessionsEventsResource

    /// List Events
    ///
    /// Args:
    ///   created_at_gt: Return events created after this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_gte: Return events created at or after this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   created_at_lt: Return events created before this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_lte: Return events created at or before this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   order: Sort direction for results, ordered by the event's `processed_at`. Defaults to
    ///       `asc` (chronological).
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`.
    ///
    ///   types: Filter by event type. Values match the `type` field on returned events (for
    ///       example, `user.message` or `agent.tool_use`). Omit to return all event types.
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
        public func list(_ sessionID: String, createdAtGt: EventListParams.CreatedAtGt? = nil, createdAtGte: EventListParams.CreatedAtGte? = nil, createdAtLt: EventListParams.CreatedAtLt? = nil, createdAtLte: EventListParams.CreatedAtLte? = nil, limit: Int? = nil, order: EventListParams.Order? = nil, page: String? = nil, types: [BetaManagedAgentsSessionEventType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsSessionEvent>> {
            try await resource._list(sessionID, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, order: order, page: page, types: types, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Send Events
    ///
    /// Args:
    ///   events: Events to send to the `session`.
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
        public func send(_ sessionID: String, events: [BetaManagedAgentsEventParams], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSendSessionEvents> {
            try await resource._send(sessionID, events: events, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Stream Events
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
        public func stream(_ sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<Stream<BetaManagedAgentsStreamSessionEvents>> {
            try await resource._stream(sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaSessionsEventsResource

    /// List Events
    ///
    /// Args:
    ///   created_at_gt: Return events created after this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_gte: Return events created at or after this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   created_at_lt: Return events created before this time (exclusive). Compared against the event's
    ///       `processed_at` value.
    ///
    ///   created_at_lte: Return events created at or before this time (inclusive). Compared against the
    ///       event's `processed_at` value.
    ///
    ///   order: Sort direction for results, ordered by the event's `processed_at`. Defaults to
    ///       `asc` (chronological).
    ///
    ///   page: Opaque pagination cursor from a previous response's `next_page`.
    ///
    ///   types: Filter by event type. Values match the `type` field on returned events (for
    ///       example, `user.message` or `agent.tool_use`). Omit to return all event types.
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
        public func list<R: Sendable>(_ sessionID: String, createdAtGt: EventListParams.CreatedAtGt? = nil, createdAtGte: EventListParams.CreatedAtGte? = nil, createdAtLt: EventListParams.CreatedAtLt? = nil, createdAtLte: EventListParams.CreatedAtLte? = nil, limit: Int? = nil, order: EventListParams.Order? = nil, page: String? = nil, types: [BetaManagedAgentsSessionEventType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsSessionEvent>>) async throws -> R) async throws -> R {
            let response = try await resource._list(sessionID, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, limit: limit, order: order, page: page, types: types, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Send Events
    ///
    /// Args:
    ///   events: Events to send to the `session`.
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
        public func send<R: Sendable>(_ sessionID: String, events: [BetaManagedAgentsEventParams], betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSendSessionEvents>) async throws -> R) async throws -> R {
            let response = try await resource._send(sessionID, events: events, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Stream Events
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
        public func stream<R: Sendable>(_ sessionID: String, eventDeltas: [BetaManagedAgentsDeltaType]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<Stream<BetaManagedAgentsStreamSessionEvents>>) async throws -> R) async throws -> R {
            let response = try await resource._stream(sessionID, eventDeltas: eventDeltas, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
