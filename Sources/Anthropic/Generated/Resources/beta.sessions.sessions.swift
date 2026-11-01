// Transformed from `anthropic.resources.beta.sessions.sessions` (sessions.py).

import Foundation

public struct BetaSessionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var events: BetaSessionsEventsResource { BetaSessionsEventsResource(client: client) }

    public var resources: BetaSessionsResourcesResource { BetaSessionsResourcesResource(client: client) }

    public var threads: BetaSessionsThreadsResource { BetaSessionsThreadsResource(client: client) }

    /// Create Session
    ///
    /// Args:
    ///   agent: Agent identifier.
    ///
    /// Accepts the `agent` ID string, which pins the latest version
    ///       for the session, or an `agent` object with both id and version specified.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for this session.
    ///
    ///   budget: Enforced spend ceiling for the session. Omit to create an uncapped session.
    ///       Every model the session can run — the agent's model and each callable agent's
    ///       model — must have a public list price, or the request is rejected with reason
    ///       `model_not_budgetable`.
    ///
    ///   initial_events: Initial events to send to the `session` at creation, processed in order.
    ///       Supports `user.message` and `user.define_outcome` events. Maximum 50 events.
    ///
    ///   metadata: Arbitrary key-value metadata attached to the session. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into the session's container.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during the session.
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
    public func create(agent: SessionCreateParams.Agent, environmentID: String, budget: BetaManagedAgentsBudgetLimitParam? = nil, initialEvents: [SessionCreateParams.InitialEvent]? = nil, metadata: [String: String]? = nil, resources: [SessionCreateParams.Resource]? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSession {
        try await _create(agent: agent, environmentID: environmentID, budget: budget, initialEvents: initialEvents, metadata: metadata, resources: resources, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(agent: SessionCreateParams.Agent, environmentID: String, budget: BetaManagedAgentsBudgetLimitParam? = nil, initialEvents: [SessionCreateParams.InitialEvent]? = nil, metadata: [String: String]? = nil, resources: [SessionCreateParams.Resource]? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSession> {
        var body = ParamsBuilder()
        try body.set("agent", agent)
        try body.set("environment_id", environmentID)
        try body.set("budget", budget)
        try body.set("initial_events", initialEvents)
        try body.set("metadata", metadata)
        try body.set("resources", resources)
        try body.set("title", title)
        try body.set("vault_ids", vaultIDs)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/sessions", body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.create", spanRoute: "/v1/sessions", spanBodyAttributes: sessionsCreateRequestAttributes, spanCreatedID: SpanCreatedID("anthropic.session.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsSession.self, options, stream: _mode == .stream)
    }

    /// Get Session
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
    public func retrieve(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSession {
        try await _retrieve(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSession> {
        try requireNonEmpty(sessionID, "session_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/sessions/{session_id}", ["session_id": sessionID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.retrieve", spanRoute: "/v1/sessions/{session_id}", spanAttributes: ["anthropic.session.id": sessionID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsSession.self, options, stream: _mode == .stream)
    }

    /// Update Session
    ///
    /// Args:
    ///   agent: Agent configuration update.
    ///
    /// Only `tools` and `mcp_servers` are updatable
    ///       mid-session. Only valid for sessions created from an agent or deployment
    ///       reference. The session must not be running.
    ///
    ///   budget: Enforced spend ceiling for the session. Set an object to replace the budget of a
    ///       session that was created with one, or `null` to remove it; omit to preserve. A
    ///       budget cannot be added to a session created without one (rejected with reason
    ///       `budget_create_only`), and a removed budget cannot be re-added. Allowed in any
    ///       non-terminated status. Lowering `max_list_cost` to at or below the session's
    ///       consumed list cost is rejected with reason `budget_not_raised`, and every model
    ///       the session can run must have a public list price or the request is rejected
    ///       with reason `model_not_budgetable`.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs (`vlt_*`) to attach to the session. Not yet supported; requests
    ///       setting this field are rejected. Reserved for future use.
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
    public func update(_ sessionID: String, agent: BetaManagedAgentsSessionAgentUpdateParam? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, metadata: [String: String?]?? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSession {
        try await _update(sessionID, agent: agent, budget: budget, metadata: metadata, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ sessionID: String, agent: BetaManagedAgentsSessionAgentUpdateParam? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, metadata: [String: String?]?? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSession> {
        try requireNonEmpty(sessionID, "session_id")
        var body = ParamsBuilder()
        try body.set("agent", agent)
        try body.set("budget", budget)
        try body.set("metadata", metadata)
        try body.set("title", title)
        try body.set("vault_ids", vaultIDs)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/sessions/{session_id}", ["session_id": sessionID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.update", spanRoute: "/v1/sessions/{session_id}", spanAttributes: ["anthropic.session.id": sessionID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsSession.self, options, stream: _mode == .stream)
    }

    /// List Sessions
    ///
    /// Args:
    ///   agent_id: Filter sessions created with this agent ID.
    ///
    ///   agent_version: Filter by agent version. Only applies when `agent_id` is also set.
    ///
    ///   created_at_gt: Return sessions created after this time (exclusive).
    ///
    ///   created_at_gte: Return sessions created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return sessions created before this time (exclusive).
    ///
    ///   created_at_lte: Return sessions created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter sessions created by this deployment ID.
    ///
    ///   include_archived: When true, includes archived sessions. Default: false (exclude archived).
    ///
    ///   limit: Maximum number of results to return.
    ///
    ///   memory_store_id: Filter sessions whose resources contain a `memory_store` with this memory store
    ///       ID.
    ///
    ///   order: Sort direction for results, ordered by `created_at`. Defaults to `desc` (newest
    ///       first).
    ///
    ///   page: Opaque pagination cursor from a previous response.
    ///
    ///   statuses: Filter by session status. Repeat the parameter to match any of multiple
    ///       statuses.
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
    public func list(agentID: String? = nil, agentVersion: Int? = nil, createdAtGt: SessionListParams.CreatedAtGt? = nil, createdAtGte: SessionListParams.CreatedAtGte? = nil, createdAtLt: SessionListParams.CreatedAtLt? = nil, createdAtLte: SessionListParams.CreatedAtLte? = nil, deploymentID: String? = nil, includeArchived: Bool? = nil, limit: Int? = nil, memoryStoreID: String? = nil, order: SessionListParams.Order? = nil, page: String? = nil, statuses: [SessionListParams.Statuses]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BidirectionalPageCursor<BetaManagedAgentsSession> {
        try await _list(agentID: agentID, agentVersion: agentVersion, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, includeArchived: includeArchived, limit: limit, memoryStoreID: memoryStoreID, order: order, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(agentID: String? = nil, agentVersion: Int? = nil, createdAtGt: SessionListParams.CreatedAtGt? = nil, createdAtGte: SessionListParams.CreatedAtGte? = nil, createdAtLt: SessionListParams.CreatedAtLt? = nil, createdAtLte: SessionListParams.CreatedAtLte? = nil, deploymentID: String? = nil, includeArchived: Bool? = nil, limit: Int? = nil, memoryStoreID: String? = nil, order: SessionListParams.Order? = nil, page: String? = nil, statuses: [SessionListParams.Statuses]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BidirectionalPageCursor<BetaManagedAgentsSession>> {
        var query = ParamsBuilder()
        try query.set("agent_id", agentID)
        try query.set("agent_version", agentVersion)
        try query.set("created_at[gt]", createdAtGt)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lt]", createdAtLt)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("deployment_id", deploymentID)
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("memory_store_id", memoryStoreID)
        try query.set("order", order)
        try query.set("page", page)
        try query.set("statuses", statuses)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/sessions", query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.list", spanRoute: "/v1/sessions", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(BidirectionalPageCursor<BetaManagedAgentsSession>.self, options, stream: _mode == .stream)
    }

    /// Delete Session
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
    public func delete(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeletedSession {
        try await _delete(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _delete(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeletedSession> {
        try requireNonEmpty(sessionID, "session_id")
        let options = try client.makeRequestOptions(method: "delete", url: try pathTemplate("/v1/sessions/{session_id}", ["session_id": sessionID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.delete", spanRoute: "/v1/sessions/{session_id}", spanAttributes: ["anthropic.session.id": sessionID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeletedSession.self, options, stream: _mode == .stream)
    }

    /// Archive Session
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
    public func archive(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsSession {
        try await _archive(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsSession> {
        try requireNonEmpty(sessionID, "session_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/sessions/{session_id}/archive", ["session_id": sessionID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.sessions.archive", spanRoute: "/v1/sessions/{session_id}/archive", spanAttributes: ["anthropic.session.id": sessionID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsSession.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaSessionsResource

        public var events: BetaSessionsEventsResource.WithRawResponse { resource.events.withRawResponse }

        public var resources: BetaSessionsResourcesResource.WithRawResponse { resource.resources.withRawResponse }

        public var threads: BetaSessionsThreadsResource.WithRawResponse { resource.threads.withRawResponse }

    /// Create Session
    ///
    /// Args:
    ///   agent: Agent identifier.
    ///
    /// Accepts the `agent` ID string, which pins the latest version
    ///       for the session, or an `agent` object with both id and version specified.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for this session.
    ///
    ///   budget: Enforced spend ceiling for the session. Omit to create an uncapped session.
    ///       Every model the session can run — the agent's model and each callable agent's
    ///       model — must have a public list price, or the request is rejected with reason
    ///       `model_not_budgetable`.
    ///
    ///   initial_events: Initial events to send to the `session` at creation, processed in order.
    ///       Supports `user.message` and `user.define_outcome` events. Maximum 50 events.
    ///
    ///   metadata: Arbitrary key-value metadata attached to the session. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into the session's container.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during the session.
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
        public func create(agent: SessionCreateParams.Agent, environmentID: String, budget: BetaManagedAgentsBudgetLimitParam? = nil, initialEvents: [SessionCreateParams.InitialEvent]? = nil, metadata: [String: String]? = nil, resources: [SessionCreateParams.Resource]? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSession> {
            try await resource._create(agent: agent, environmentID: environmentID, budget: budget, initialEvents: initialEvents, metadata: metadata, resources: resources, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Session
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
        public func retrieve(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSession> {
            try await resource._retrieve(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update Session
    ///
    /// Args:
    ///   agent: Agent configuration update.
    ///
    /// Only `tools` and `mcp_servers` are updatable
    ///       mid-session. Only valid for sessions created from an agent or deployment
    ///       reference. The session must not be running.
    ///
    ///   budget: Enforced spend ceiling for the session. Set an object to replace the budget of a
    ///       session that was created with one, or `null` to remove it; omit to preserve. A
    ///       budget cannot be added to a session created without one (rejected with reason
    ///       `budget_create_only`), and a removed budget cannot be re-added. Allowed in any
    ///       non-terminated status. Lowering `max_list_cost` to at or below the session's
    ///       consumed list cost is rejected with reason `budget_not_raised`, and every model
    ///       the session can run must have a public list price or the request is rejected
    ///       with reason `model_not_budgetable`.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs (`vlt_*`) to attach to the session. Not yet supported; requests
    ///       setting this field are rejected. Reserved for future use.
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
        public func update(_ sessionID: String, agent: BetaManagedAgentsSessionAgentUpdateParam? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, metadata: [String: String?]?? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSession> {
            try await resource._update(sessionID, agent: agent, budget: budget, metadata: metadata, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Sessions
    ///
    /// Args:
    ///   agent_id: Filter sessions created with this agent ID.
    ///
    ///   agent_version: Filter by agent version. Only applies when `agent_id` is also set.
    ///
    ///   created_at_gt: Return sessions created after this time (exclusive).
    ///
    ///   created_at_gte: Return sessions created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return sessions created before this time (exclusive).
    ///
    ///   created_at_lte: Return sessions created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter sessions created by this deployment ID.
    ///
    ///   include_archived: When true, includes archived sessions. Default: false (exclude archived).
    ///
    ///   limit: Maximum number of results to return.
    ///
    ///   memory_store_id: Filter sessions whose resources contain a `memory_store` with this memory store
    ///       ID.
    ///
    ///   order: Sort direction for results, ordered by `created_at`. Defaults to `desc` (newest
    ///       first).
    ///
    ///   page: Opaque pagination cursor from a previous response.
    ///
    ///   statuses: Filter by session status. Repeat the parameter to match any of multiple
    ///       statuses.
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
        public func list(agentID: String? = nil, agentVersion: Int? = nil, createdAtGt: SessionListParams.CreatedAtGt? = nil, createdAtGte: SessionListParams.CreatedAtGte? = nil, createdAtLt: SessionListParams.CreatedAtLt? = nil, createdAtLte: SessionListParams.CreatedAtLte? = nil, deploymentID: String? = nil, includeArchived: Bool? = nil, limit: Int? = nil, memoryStoreID: String? = nil, order: SessionListParams.Order? = nil, page: String? = nil, statuses: [SessionListParams.Statuses]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BidirectionalPageCursor<BetaManagedAgentsSession>> {
            try await resource._list(agentID: agentID, agentVersion: agentVersion, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, includeArchived: includeArchived, limit: limit, memoryStoreID: memoryStoreID, order: order, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Delete Session
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
        public func delete(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeletedSession> {
            try await resource._delete(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive Session
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
        public func archive(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsSession> {
            try await resource._archive(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaSessionsResource

        public var events: BetaSessionsEventsResource.WithStreamingResponse { resource.events.withStreamingResponse }

        public var resources: BetaSessionsResourcesResource.WithStreamingResponse { resource.resources.withStreamingResponse }

        public var threads: BetaSessionsThreadsResource.WithStreamingResponse { resource.threads.withStreamingResponse }

    /// Create Session
    ///
    /// Args:
    ///   agent: Agent identifier.
    ///
    /// Accepts the `agent` ID string, which pins the latest version
    ///       for the session, or an `agent` object with both id and version specified.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for this session.
    ///
    ///   budget: Enforced spend ceiling for the session. Omit to create an uncapped session.
    ///       Every model the session can run — the agent's model and each callable agent's
    ///       model — must have a public list price, or the request is rejected with reason
    ///       `model_not_budgetable`.
    ///
    ///   initial_events: Initial events to send to the `session` at creation, processed in order.
    ///       Supports `user.message` and `user.define_outcome` events. Maximum 50 events.
    ///
    ///   metadata: Arbitrary key-value metadata attached to the session. Maximum 16 pairs, keys up
    ///       to 64 chars, values up to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into the session's container.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during the session.
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
        public func create<R: Sendable>(agent: SessionCreateParams.Agent, environmentID: String, budget: BetaManagedAgentsBudgetLimitParam? = nil, initialEvents: [SessionCreateParams.InitialEvent]? = nil, metadata: [String: String]? = nil, resources: [SessionCreateParams.Resource]? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSession>) async throws -> R) async throws -> R {
            let response = try await resource._create(agent: agent, environmentID: environmentID, budget: budget, initialEvents: initialEvents, metadata: metadata, resources: resources, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Session
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
        public func retrieve<R: Sendable>(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSession>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update Session
    ///
    /// Args:
    ///   agent: Agent configuration update.
    ///
    /// Only `tools` and `mcp_servers` are updatable
    ///       mid-session. Only valid for sessions created from an agent or deployment
    ///       reference. The session must not be running.
    ///
    ///   budget: Enforced spend ceiling for the session. Set an object to replace the budget of a
    ///       session that was created with one, or `null` to remove it; omit to preserve. A
    ///       budget cannot be added to a session created without one (rejected with reason
    ///       `budget_create_only`), and a removed budget cannot be re-added. Allowed in any
    ///       non-terminated status. Lowering `max_list_cost` to at or below the session's
    ///       consumed list cost is rejected with reason `budget_not_raised`, and every model
    ///       the session can run must have a public list price or the request is rejected
    ///       with reason `model_not_budgetable`.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve.
    ///
    ///   title: Human-readable session title.
    ///
    ///   vault_ids: Vault IDs (`vlt_*`) to attach to the session. Not yet supported; requests
    ///       setting this field are rejected. Reserved for future use.
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
        public func update<R: Sendable>(_ sessionID: String, agent: BetaManagedAgentsSessionAgentUpdateParam? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, metadata: [String: String?]?? = nil, title: String?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSession>) async throws -> R) async throws -> R {
            let response = try await resource._update(sessionID, agent: agent, budget: budget, metadata: metadata, title: title, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Sessions
    ///
    /// Args:
    ///   agent_id: Filter sessions created with this agent ID.
    ///
    ///   agent_version: Filter by agent version. Only applies when `agent_id` is also set.
    ///
    ///   created_at_gt: Return sessions created after this time (exclusive).
    ///
    ///   created_at_gte: Return sessions created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return sessions created before this time (exclusive).
    ///
    ///   created_at_lte: Return sessions created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter sessions created by this deployment ID.
    ///
    ///   include_archived: When true, includes archived sessions. Default: false (exclude archived).
    ///
    ///   limit: Maximum number of results to return.
    ///
    ///   memory_store_id: Filter sessions whose resources contain a `memory_store` with this memory store
    ///       ID.
    ///
    ///   order: Sort direction for results, ordered by `created_at`. Defaults to `desc` (newest
    ///       first).
    ///
    ///   page: Opaque pagination cursor from a previous response.
    ///
    ///   statuses: Filter by session status. Repeat the parameter to match any of multiple
    ///       statuses.
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
        public func list<R: Sendable>(agentID: String? = nil, agentVersion: Int? = nil, createdAtGt: SessionListParams.CreatedAtGt? = nil, createdAtGte: SessionListParams.CreatedAtGte? = nil, createdAtLt: SessionListParams.CreatedAtLt? = nil, createdAtLte: SessionListParams.CreatedAtLte? = nil, deploymentID: String? = nil, includeArchived: Bool? = nil, limit: Int? = nil, memoryStoreID: String? = nil, order: SessionListParams.Order? = nil, page: String? = nil, statuses: [SessionListParams.Statuses]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BidirectionalPageCursor<BetaManagedAgentsSession>>) async throws -> R) async throws -> R {
            let response = try await resource._list(agentID: agentID, agentVersion: agentVersion, createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, includeArchived: includeArchived, limit: limit, memoryStoreID: memoryStoreID, order: order, page: page, statuses: statuses, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Delete Session
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
        public func delete<R: Sendable>(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeletedSession>) async throws -> R) async throws -> R {
            let response = try await resource._delete(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive Session
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
        public func archive<R: Sendable>(_ sessionID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsSession>) async throws -> R) async throws -> R {
            let response = try await resource._archive(sessionID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
