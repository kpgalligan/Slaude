// Transformed from `anthropic.resources.beta.deployment_runs` (deployment_runs.py).

import Foundation

public struct BetaDeploymentRunsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Get Deployment Run
    ///
    /// Args:
    ///   deployment_run_id: Unique identifier of the deployment run.
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
    public func retrieve(_ deploymentRunID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeploymentRun {
        try await _retrieve(deploymentRunID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ deploymentRunID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeploymentRun> {
        try requireNonEmpty(deploymentRunID, "deployment_run_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/deployment_runs/{deployment_run_id}", ["deployment_run_id": deploymentRunID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployment_runs.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeploymentRun.self, options, stream: _mode == .stream)
    }

    /// List Deployment Runs
    ///
    /// Args:
    ///   created_at_gt: Return runs created strictly after this time (exclusive).
    ///
    ///   created_at_gte: Return runs created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return runs created strictly before this time (exclusive).
    ///
    ///   created_at_lte: Return runs created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter to a specific deployment. Omit to list across all deployments in the
    ///       workspace. Filtering by a non-existent `deployment_id` returns 200 with empty
    ///       data.
    ///
    ///   has_error: Filter: true for runs with non-null `error`, false for runs with non-null
    ///       `session_id`. Omit for all.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor. Pass `next_page` from the previous response. Invalid
    ///       or expired cursors return 400.
    ///
    ///   trigger_type: Filter runs by what triggered them. Omit to return all runs.
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
    public func list(createdAtGt: DeploymentRunListParams.CreatedAtGt? = nil, createdAtGte: DeploymentRunListParams.CreatedAtGte? = nil, createdAtLt: DeploymentRunListParams.CreatedAtLt? = nil, createdAtLte: DeploymentRunListParams.CreatedAtLte? = nil, deploymentID: String? = nil, hasError: Bool? = nil, limit: Int? = nil, page: String? = nil, triggerType: BetaManagedAgentsTriggerType? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsDeploymentRun> {
        try await _list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, hasError: hasError, limit: limit, page: page, triggerType: triggerType, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(createdAtGt: DeploymentRunListParams.CreatedAtGt? = nil, createdAtGte: DeploymentRunListParams.CreatedAtGte? = nil, createdAtLt: DeploymentRunListParams.CreatedAtLt? = nil, createdAtLte: DeploymentRunListParams.CreatedAtLte? = nil, deploymentID: String? = nil, hasError: Bool? = nil, limit: Int? = nil, page: String? = nil, triggerType: BetaManagedAgentsTriggerType? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsDeploymentRun>> {
        var query = ParamsBuilder()
        try query.set("created_at[gt]", createdAtGt)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lt]", createdAtLt)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("deployment_id", deploymentID)
        try query.set("has_error", hasError)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("trigger_type", triggerType)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/deployment_runs", query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployment_runs.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsDeploymentRun>.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaDeploymentRunsResource

    /// Get Deployment Run
    ///
    /// Args:
    ///   deployment_run_id: Unique identifier of the deployment run.
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
        public func retrieve(_ deploymentRunID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeploymentRun> {
            try await resource._retrieve(deploymentRunID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Deployment Runs
    ///
    /// Args:
    ///   created_at_gt: Return runs created strictly after this time (exclusive).
    ///
    ///   created_at_gte: Return runs created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return runs created strictly before this time (exclusive).
    ///
    ///   created_at_lte: Return runs created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter to a specific deployment. Omit to list across all deployments in the
    ///       workspace. Filtering by a non-existent `deployment_id` returns 200 with empty
    ///       data.
    ///
    ///   has_error: Filter: true for runs with non-null `error`, false for runs with non-null
    ///       `session_id`. Omit for all.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor. Pass `next_page` from the previous response. Invalid
    ///       or expired cursors return 400.
    ///
    ///   trigger_type: Filter runs by what triggered them. Omit to return all runs.
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
        public func list(createdAtGt: DeploymentRunListParams.CreatedAtGt? = nil, createdAtGte: DeploymentRunListParams.CreatedAtGte? = nil, createdAtLt: DeploymentRunListParams.CreatedAtLt? = nil, createdAtLte: DeploymentRunListParams.CreatedAtLte? = nil, deploymentID: String? = nil, hasError: Bool? = nil, limit: Int? = nil, page: String? = nil, triggerType: BetaManagedAgentsTriggerType? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsDeploymentRun>> {
            try await resource._list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, hasError: hasError, limit: limit, page: page, triggerType: triggerType, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaDeploymentRunsResource

    /// Get Deployment Run
    ///
    /// Args:
    ///   deployment_run_id: Unique identifier of the deployment run.
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
        public func retrieve<R: Sendable>(_ deploymentRunID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeploymentRun>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(deploymentRunID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Deployment Runs
    ///
    /// Args:
    ///   created_at_gt: Return runs created strictly after this time (exclusive).
    ///
    ///   created_at_gte: Return runs created at or after this time (inclusive).
    ///
    ///   created_at_lt: Return runs created strictly before this time (exclusive).
    ///
    ///   created_at_lte: Return runs created at or before this time (inclusive).
    ///
    ///   deployment_id: Filter to a specific deployment. Omit to list across all deployments in the
    ///       workspace. Filtering by a non-existent `deployment_id` returns 200 with empty
    ///       data.
    ///
    ///   has_error: Filter: true for runs with non-null `error`, false for runs with non-null
    ///       `session_id`. Omit for all.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 1000.
    ///
    ///   page: Opaque pagination cursor. Pass `next_page` from the previous response. Invalid
    ///       or expired cursors return 400.
    ///
    ///   trigger_type: Filter runs by what triggered them. Omit to return all runs.
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
        public func list<R: Sendable>(createdAtGt: DeploymentRunListParams.CreatedAtGt? = nil, createdAtGte: DeploymentRunListParams.CreatedAtGte? = nil, createdAtLt: DeploymentRunListParams.CreatedAtLt? = nil, createdAtLte: DeploymentRunListParams.CreatedAtLte? = nil, deploymentID: String? = nil, hasError: Bool? = nil, limit: Int? = nil, page: String? = nil, triggerType: BetaManagedAgentsTriggerType? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsDeploymentRun>>) async throws -> R) async throws -> R {
            let response = try await resource._list(createdAtGt: createdAtGt, createdAtGte: createdAtGte, createdAtLt: createdAtLt, createdAtLte: createdAtLte, deploymentID: deploymentID, hasError: hasError, limit: limit, page: page, triggerType: triggerType, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
