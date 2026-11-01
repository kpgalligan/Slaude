// Transformed from `anthropic.resources.beta.deployments` (deployments.py).

import Foundation

public struct BetaDeploymentsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    /// Create Deployment
    ///
    /// Args:
    ///   agent: Agent to deploy.
    ///
    /// Accepts the `agent` ID string, which pins the latest version,
    ///       or an `agent` object with both id and version specified. The agent must exist
    ///       and not be archived.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for sessions
    ///       created from this deployment.
    ///
    ///   initial_events: Events to send to each session immediately after creation. At least 1,
    ///       maximum 50.
    ///
    ///   name: Human-readable name for the deployment.
    ///
    ///   budget: Enforced spend ceiling stamped onto each session created from this deployment,
    ///       copied at session-creation time. Omit to leave sessions uncapped. The deployment
    ///       agent's model must have a public list price, or the request is rejected; a
    ///       multiagent roster is re-validated in full when each fire copies the cap, which
    ///       fails closed the same way.
    ///
    ///   description: Description of what the deployment does.
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into each session's container.
    ///       Maximum 500.
    ///
    ///   schedule: Optional recurring cron schedule. When present, the deployment fires
    ///       automatically. Both expression and timezone are required when schedule is set.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during sessions created from
    ///       this deployment. Maximum 50.
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
    public func create(agent: DeploymentCreateParams.Agent, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams], name: String, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, metadata: [String: String]? = nil, resources: [DeploymentCreateParams.Resource]? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _create(agent: agent, environmentID: environmentID, initialEvents: initialEvents, name: name, budget: budget, description: description, metadata: metadata, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(agent: DeploymentCreateParams.Agent, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams], name: String, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, metadata: [String: String]? = nil, resources: [DeploymentCreateParams.Resource]? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        var body = ParamsBuilder()
        try body.set("agent", agent)
        try body.set("environment_id", environmentID)
        try body.set("initial_events", initialEvents)
        try body.set("name", name)
        try body.set("budget", budget)
        try body.set("description", description)
        try body.set("metadata", metadata)
        try body.set("resources", resources)
        try body.set("schedule", schedule)
        try body.set("vault_ids", vaultIDs)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/deployments", body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.create", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    /// Get Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment.
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
    public func retrieve(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _retrieve(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        try requireNonEmpty(deploymentID, "deployment_id")
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/deployments/{deployment_id}", ["deployment_id": deploymentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.retrieve", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    /// Update Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to update.
    ///
    ///   agent: Agent to deploy. Accepts the `agent` ID string, which re-pins to the latest
    ///       version, or an `agent` object with both id and version specified. Omit to
    ///       preserve. Cannot be cleared.
    ///
    ///   budget: Spend ceiling for future sessions. Full replacement. Omit to preserve; send null
    ///       to clear (sessions created afterwards are uncapped). The deployment agent's
    ///       model must have a public list price, or the request is rejected; a multiagent
    ///       roster is re-validated in full when each fire copies the cap, which fails closed
    ///       the same way.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   environment_id: ID of the `environment` where sessions run. Omit to preserve. Cannot be cleared.
    ///
    ///   initial_events: Initial events. Full replacement. Omit to preserve. Cannot be cleared. At least
    ///       1, maximum 50.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   resources: Session resources. Full replacement. Omit to preserve; send empty array or null
    ///       to clear. Maximum 500.
    ///
    ///   schedule: Cron schedule. Full replacement. Omit to preserve; send null to clear (revert to
    ///       manual-only).
    ///
    ///   vault_ids: Vault IDs. Full replacement. Omit to preserve; send empty array or null to
    ///       clear. Maximum 50.
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
    public func update(_ deploymentID: String, agent: DeploymentUpdateParams.Agent? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, environmentID: String? = nil, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]? = nil, metadata: [String: String?]?? = nil, name: String? = nil, resources: [DeploymentUpdateParams.Resource]?? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _update(deploymentID, agent: agent, budget: budget, description: description, environmentID: environmentID, initialEvents: initialEvents, metadata: metadata, name: name, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ deploymentID: String, agent: DeploymentUpdateParams.Agent? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, environmentID: String? = nil, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]? = nil, metadata: [String: String?]?? = nil, name: String? = nil, resources: [DeploymentUpdateParams.Resource]?? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        try requireNonEmpty(deploymentID, "deployment_id")
        var body = ParamsBuilder()
        try body.set("agent", agent)
        try body.set("budget", budget)
        try body.set("description", description)
        try body.set("environment_id", environmentID)
        try body.set("initial_events", initialEvents)
        try body.set("metadata", metadata)
        try body.set("name", name)
        try body.set("resources", resources)
        try body.set("schedule", schedule)
        try body.set("vault_ids", vaultIDs)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/deployments/{deployment_id}", ["deployment_id": deploymentID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.update", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    /// List Deployments
    ///
    /// Args:
    ///   agent_id: Filter by agent ID.
    ///
    ///   created_at_gte: Return deployments created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return deployments created at or before this time (inclusive).
    ///
    ///   include_archived: When true, includes archived deployments. Default: false (exclude archived).
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
    ///
    ///   status: Filter by status: `active` or `paused`. Omit for both. To include archived
    ///       deployments, use `include_archived` instead; the two cannot be combined.
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
    public func list(agentID: String? = nil, createdAtGte: DeploymentListParams.CreatedAtGte? = nil, createdAtLte: DeploymentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, status: BetaManagedAgentsDeploymentStatus? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsDeployment> {
        try await _list(agentID: agentID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, status: status, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(agentID: String? = nil, createdAtGte: DeploymentListParams.CreatedAtGte? = nil, createdAtLte: DeploymentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, status: BetaManagedAgentsDeploymentStatus? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsDeployment>> {
        var query = ParamsBuilder()
        try query.set("agent_id", agentID)
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        try query.set("status", status)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/deployments", query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.list", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsDeployment>.self, options, stream: _mode == .stream)
    }

    /// Archive Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to archive.
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
    public func archive(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _archive(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        try requireNonEmpty(deploymentID, "deployment_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/deployments/{deployment_id}/archive", ["deployment_id": deploymentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.archive", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    /// Pause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to pause.
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
    public func pause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _pause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _pause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        try requireNonEmpty(deploymentID, "deployment_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/deployments/{deployment_id}/pause", ["deployment_id": deploymentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.pause", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    /// Run Deployment Now
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to run.
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
    public func run(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeploymentRun {
        try await _run(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _run(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeploymentRun> {
        try requireNonEmpty(deploymentID, "deployment_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/deployments/{deployment_id}/run", ["deployment_id": deploymentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.run", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeploymentRun.self, options, stream: _mode == .stream)
    }

    /// Unpause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to unpause.
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
    public func unpause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsDeployment {
        try await _unpause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _unpause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsDeployment> {
        try requireNonEmpty(deploymentID, "deployment_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/deployments/{deployment_id}/unpause", ["deployment_id": deploymentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.deployments.unpause", qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsDeployment.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaDeploymentsResource

    /// Create Deployment
    ///
    /// Args:
    ///   agent: Agent to deploy.
    ///
    /// Accepts the `agent` ID string, which pins the latest version,
    ///       or an `agent` object with both id and version specified. The agent must exist
    ///       and not be archived.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for sessions
    ///       created from this deployment.
    ///
    ///   initial_events: Events to send to each session immediately after creation. At least 1,
    ///       maximum 50.
    ///
    ///   name: Human-readable name for the deployment.
    ///
    ///   budget: Enforced spend ceiling stamped onto each session created from this deployment,
    ///       copied at session-creation time. Omit to leave sessions uncapped. The deployment
    ///       agent's model must have a public list price, or the request is rejected; a
    ///       multiagent roster is re-validated in full when each fire copies the cap, which
    ///       fails closed the same way.
    ///
    ///   description: Description of what the deployment does.
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into each session's container.
    ///       Maximum 500.
    ///
    ///   schedule: Optional recurring cron schedule. When present, the deployment fires
    ///       automatically. Both expression and timezone are required when schedule is set.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during sessions created from
    ///       this deployment. Maximum 50.
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
        public func create(agent: DeploymentCreateParams.Agent, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams], name: String, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, metadata: [String: String]? = nil, resources: [DeploymentCreateParams.Resource]? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._create(agent: agent, environmentID: environmentID, initialEvents: initialEvents, name: name, budget: budget, description: description, metadata: metadata, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment.
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
        public func retrieve(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._retrieve(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to update.
    ///
    ///   agent: Agent to deploy. Accepts the `agent` ID string, which re-pins to the latest
    ///       version, or an `agent` object with both id and version specified. Omit to
    ///       preserve. Cannot be cleared.
    ///
    ///   budget: Spend ceiling for future sessions. Full replacement. Omit to preserve; send null
    ///       to clear (sessions created afterwards are uncapped). The deployment agent's
    ///       model must have a public list price, or the request is rejected; a multiagent
    ///       roster is re-validated in full when each fire copies the cap, which fails closed
    ///       the same way.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   environment_id: ID of the `environment` where sessions run. Omit to preserve. Cannot be cleared.
    ///
    ///   initial_events: Initial events. Full replacement. Omit to preserve. Cannot be cleared. At least
    ///       1, maximum 50.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   resources: Session resources. Full replacement. Omit to preserve; send empty array or null
    ///       to clear. Maximum 500.
    ///
    ///   schedule: Cron schedule. Full replacement. Omit to preserve; send null to clear (revert to
    ///       manual-only).
    ///
    ///   vault_ids: Vault IDs. Full replacement. Omit to preserve; send empty array or null to
    ///       clear. Maximum 50.
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
        public func update(_ deploymentID: String, agent: DeploymentUpdateParams.Agent? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, environmentID: String? = nil, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]? = nil, metadata: [String: String?]?? = nil, name: String? = nil, resources: [DeploymentUpdateParams.Resource]?? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._update(deploymentID, agent: agent, budget: budget, description: description, environmentID: environmentID, initialEvents: initialEvents, metadata: metadata, name: name, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Deployments
    ///
    /// Args:
    ///   agent_id: Filter by agent ID.
    ///
    ///   created_at_gte: Return deployments created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return deployments created at or before this time (inclusive).
    ///
    ///   include_archived: When true, includes archived deployments. Default: false (exclude archived).
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
    ///
    ///   status: Filter by status: `active` or `paused`. Omit for both. To include archived
    ///       deployments, use `include_archived` instead; the two cannot be combined.
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
        public func list(agentID: String? = nil, createdAtGte: DeploymentListParams.CreatedAtGte? = nil, createdAtLte: DeploymentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, status: BetaManagedAgentsDeploymentStatus? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsDeployment>> {
            try await resource._list(agentID: agentID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, status: status, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to archive.
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
        public func archive(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._archive(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Pause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to pause.
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
        public func pause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._pause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Run Deployment Now
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to run.
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
        public func run(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeploymentRun> {
            try await resource._run(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Unpause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to unpause.
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
        public func unpause(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsDeployment> {
            try await resource._unpause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaDeploymentsResource

    /// Create Deployment
    ///
    /// Args:
    ///   agent: Agent to deploy.
    ///
    /// Accepts the `agent` ID string, which pins the latest version,
    ///       or an `agent` object with both id and version specified. The agent must exist
    ///       and not be archived.
    ///
    ///   environment_id: ID of the `environment` defining the container configuration for sessions
    ///       created from this deployment.
    ///
    ///   initial_events: Events to send to each session immediately after creation. At least 1,
    ///       maximum 50.
    ///
    ///   name: Human-readable name for the deployment.
    ///
    ///   budget: Enforced spend ceiling stamped onto each session created from this deployment,
    ///       copied at session-creation time. Omit to leave sessions uncapped. The deployment
    ///       agent's model must have a public list price, or the request is rejected; a
    ///       multiagent roster is re-validated in full when each fire copies the cap, which
    ///       fails closed the same way.
    ///
    ///   description: Description of what the deployment does.
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   resources: Resources (e.g. repositories, files) to mount into each session's container.
    ///       Maximum 500.
    ///
    ///   schedule: Optional recurring cron schedule. When present, the deployment fires
    ///       automatically. Both expression and timezone are required when schedule is set.
    ///
    ///   vault_ids: Vault IDs for stored credentials the agent can use during sessions created from
    ///       this deployment. Maximum 50.
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
        public func create<R: Sendable>(agent: DeploymentCreateParams.Agent, environmentID: String, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams], name: String, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, metadata: [String: String]? = nil, resources: [DeploymentCreateParams.Resource]? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._create(agent: agent, environmentID: environmentID, initialEvents: initialEvents, name: name, budget: budget, description: description, metadata: metadata, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment.
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
        public func retrieve<R: Sendable>(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to update.
    ///
    ///   agent: Agent to deploy. Accepts the `agent` ID string, which re-pins to the latest
    ///       version, or an `agent` object with both id and version specified. Omit to
    ///       preserve. Cannot be cleared.
    ///
    ///   budget: Spend ceiling for future sessions. Full replacement. Omit to preserve; send null
    ///       to clear (sessions created afterwards are uncapped). The deployment agent's
    ///       model must have a public list price, or the request is rejected; a multiagent
    ///       roster is re-validated in full when each fire copies the cap, which fails closed
    ///       the same way.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   environment_id: ID of the `environment` where sessions run. Omit to preserve. Cannot be cleared.
    ///
    ///   initial_events: Initial events. Full replacement. Omit to preserve. Cannot be cleared. At least
    ///       1, maximum 50.
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   resources: Session resources. Full replacement. Omit to preserve; send empty array or null
    ///       to clear. Maximum 500.
    ///
    ///   schedule: Cron schedule. Full replacement. Omit to preserve; send null to clear (revert to
    ///       manual-only).
    ///
    ///   vault_ids: Vault IDs. Full replacement. Omit to preserve; send empty array or null to
    ///       clear. Maximum 50.
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
        public func update<R: Sendable>(_ deploymentID: String, agent: DeploymentUpdateParams.Agent? = nil, budget: BetaManagedAgentsBudgetLimitParam?? = nil, description: String?? = nil, environmentID: String? = nil, initialEvents: [BetaManagedAgentsDeploymentInitialEventParams]? = nil, metadata: [String: String?]?? = nil, name: String? = nil, resources: [DeploymentUpdateParams.Resource]?? = nil, schedule: BetaManagedAgentsScheduleParams?? = nil, vaultIDs: [String]?? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._update(deploymentID, agent: agent, budget: budget, description: description, environmentID: environmentID, initialEvents: initialEvents, metadata: metadata, name: name, resources: resources, schedule: schedule, vaultIDs: vaultIDs, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Deployments
    ///
    /// Args:
    ///   agent_id: Filter by agent ID.
    ///
    ///   created_at_gte: Return deployments created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return deployments created at or before this time (inclusive).
    ///
    ///   include_archived: When true, includes archived deployments. Default: false (exclude archived).
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor.
    ///
    ///   status: Filter by status: `active` or `paused`. Omit for both. To include archived
    ///       deployments, use `include_archived` instead; the two cannot be combined.
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
        public func list<R: Sendable>(agentID: String? = nil, createdAtGte: DeploymentListParams.CreatedAtGte? = nil, createdAtLte: DeploymentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, status: BetaManagedAgentsDeploymentStatus? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsDeployment>>) async throws -> R) async throws -> R {
            let response = try await resource._list(agentID: agentID, createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, status: status, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to archive.
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
        public func archive<R: Sendable>(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._archive(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Pause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to pause.
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
        public func pause<R: Sendable>(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._pause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Run Deployment Now
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to run.
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
        public func run<R: Sendable>(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeploymentRun>) async throws -> R) async throws -> R {
            let response = try await resource._run(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Unpause Deployment
    ///
    /// Args:
    ///   deployment_id: Unique identifier of the deployment to unpause.
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
        public func unpause<R: Sendable>(_ deploymentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsDeployment>) async throws -> R) async throws -> R {
            let response = try await resource._unpause(deploymentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
