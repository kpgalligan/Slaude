// Transformed from `anthropic.resources.beta.agents.versions` (versions.py).

import Foundation

public struct BetaAgentsVersionsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// List Agent Versions
    ///
    /// Args:
    ///   agent_id: Agent ID to list versions for.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
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
    public func list(_ agentID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsAgent> {
        try await _list(agentID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(_ agentID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsAgent>> {
        try requireNonEmpty(agentID, "agent_id")
        var query = ParamsBuilder()
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/agents/{agent_id}/versions", ["agent_id": agentID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.versions.list")
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsAgent>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaAgentsVersionsResource

    /// List Agent Versions
    ///
    /// Args:
    ///   agent_id: Agent ID to list versions for.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
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
        public func list(_ agentID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsAgent>> {
            try await resource._list(agentID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaAgentsVersionsResource

    /// List Agent Versions
    ///
    /// Args:
    ///   agent_id: Agent ID to list versions for.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
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
        public func list<R: Sendable>(_ agentID: String, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsAgent>>) async throws -> R) async throws -> R {
            let response = try await resource._list(agentID, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
