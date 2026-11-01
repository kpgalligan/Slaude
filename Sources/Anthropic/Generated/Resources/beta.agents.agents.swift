// Transformed from `anthropic.resources.beta.agents.agents` (agents.py).

import Foundation

public struct BetaAgentsResource: Sendable {
    public let client: BaseClient

    public init(client: BaseClient) { self.client = client }

    /// Prefix a method call with this to get the raw response (headers, status) instead of the parsed content.
    public var withRawResponse: WithRawResponse { WithRawResponse(resource: self) }

    /// Like `withRawResponse`, but the body is not read eagerly; the response is scoped to a closure.
    public var withStreamingResponse: WithStreamingResponse { WithStreamingResponse(resource: self) }

    public var versions: BetaAgentsVersionsResource { BetaAgentsVersionsResource(client: client) }

    /// Create Agent
    ///
    /// Args:
    ///   model: Model identifier.
    ///
    /// Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control
    ///
    ///   name: Human-readable name for the agent.
    ///
    ///   description: Description of what the agent does.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Omitting it, sending null, or
    ///       sending `{"type": "service_account"}` stores the default.
    ///
    ///   mcp_servers: MCP servers this agent connects to. Maximum 20. Names must be unique within the
    ///       array. Every server must be referenced by an `mcp_toolset` in `tools`;
    ///       unreferenced servers are rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   multiagent: Multiagent orchestration configuration.
    ///
    ///   skills: Skills available to the agent.
    ///
    ///   system: System prompt for the agent.
    ///
    ///   tools: Tool configurations available to the agent. Maximum of 256 tools across all
    ///       toolsets allowed.
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
    public func create(model: AgentCreateParams.Model, name: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, metadata: [String: String]? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [AgentCreateParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsAgent {
        try await _create(model: model, name: name, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, multiagent: multiagent, skills: skills, system: system, tools: tools, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _create(model: AgentCreateParams.Model, name: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, metadata: [String: String]? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [AgentCreateParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsAgent> {
        var body = ParamsBuilder()
        try body.set("model", model)
        try body.set("name", name)
        try body.set("description", description)
        try body.set("execution_identity", executionIdentity)
        try body.set("mcp_servers", mcpServers)
        try body.set("metadata", metadata)
        try body.set("multiagent", multiagent)
        try body.set("skills", skills)
        try body.set("system", system)
        try body.set("tools", tools)
        let options = try client.makeRequestOptions(method: "post", url: "/v1/agents", body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.create", spanRoute: "/v1/agents", spanCreatedID: SpanCreatedID("gen_ai.agent.id"), qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsAgent.self, options, stream: _mode == .stream)
    }

    /// Get Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to retrieve.
    ///
    ///   version: Agent version. Omit for the most recent version. Must be at least 1 if
    ///       specified.
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
    public func retrieve(_ agentID: String, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsAgent {
        try await _retrieve(agentID, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _retrieve(_ agentID: String, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsAgent> {
        try requireNonEmpty(agentID, "agent_id")
        var query = ParamsBuilder()
        try query.set("version", version)
        let options = try client.makeRequestOptions(method: "get", url: try pathTemplate("/v1/agents/{agent_id}", ["agent_id": agentID]), query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.retrieve", spanRoute: "/v1/agents/{agent_id}", spanAttributes: ["gen_ai.agent.id": agentID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsAgent.self, options, stream: _mode == .stream)
    }

    /// Update Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to update.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Full replacement. Omit to preserve;
    ///       send null or `{"type": "service_account"}` to restore the default.
    ///
    ///   mcp_servers: MCP servers. Full replacement. Omit to preserve; send empty array or `null` to
    ///       clear. Names must be unique. Maximum 20. Every server must be referenced by an
    ///       `mcp_toolset` in the agent's resulting `tools`; unreferenced servers are
    ///       rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   model: Model identifier. Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control. Omit to preserve. Cannot be cleared.
    ///
    ///   multiagent: Multiagent orchestration configuration. Full replacement. Omit to preserve; send
    ///       null to clear.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   skills: Skills. Full replacement. Omit to preserve; send empty array or null to clear.
    ///
    ///   system: System prompt. Omit to preserve; send empty string or null to clear.
    ///
    ///   tools: Tool configurations available to the agent. Full replacement. Omit to preserve;
    ///       send empty array or null to clear. Maximum of 256 tools across all toolsets
    ///       allowed.
    ///
    ///   version: The agent's current version, used to prevent concurrent overwrites. Obtain this
    ///       value from a create or retrieve response. Must be at least 1 if specified. When
    ///       supplied, the request fails if it does not match the server's current version;
    ///       omit to apply the update unconditionally.
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
    public func update(_ agentID: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]?? = nil, metadata: [String: String?]?? = nil, model: AgentUpdateParams.Model? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, name: String? = nil, skills: [BetaManagedAgentsSkillParams]?? = nil, system: String?? = nil, tools: [AgentUpdateParams.Tool]?? = nil, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsAgent {
        try await _update(agentID, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, model: model, multiagent: multiagent, name: name, skills: skills, system: system, tools: tools, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _update(_ agentID: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]?? = nil, metadata: [String: String?]?? = nil, model: AgentUpdateParams.Model? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, name: String? = nil, skills: [BetaManagedAgentsSkillParams]?? = nil, system: String?? = nil, tools: [AgentUpdateParams.Tool]?? = nil, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsAgent> {
        try requireNonEmpty(agentID, "agent_id")
        var body = ParamsBuilder()
        try body.set("description", description)
        try body.set("execution_identity", executionIdentity)
        try body.set("mcp_servers", mcpServers)
        try body.set("metadata", metadata)
        try body.set("model", model)
        try body.set("multiagent", multiagent)
        try body.set("name", name)
        try body.set("skills", skills)
        try body.set("system", system)
        try body.set("tools", tools)
        try body.set("version", version)
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/agents/{agent_id}", ["agent_id": agentID]), body: body, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.update", spanRoute: "/v1/agents/{agent_id}", spanAttributes: ["gen_ai.agent.id": agentID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsAgent.self, options, stream: _mode == .stream)
    }

    /// List Agents
    ///
    /// Args:
    ///   created_at_gte: Return agents created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return agents created at or before this time (inclusive).
    ///
    ///   include_archived: Include archived agents in results. Defaults to false.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor from a previous response.
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
    public func list(createdAtGte: AgentListParams.CreatedAtGte? = nil, createdAtLte: AgentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> PageCursor<BetaManagedAgentsAgent> {
        try await _list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _list(createdAtGte: AgentListParams.CreatedAtGte? = nil, createdAtLte: AgentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<PageCursor<BetaManagedAgentsAgent>> {
        var query = ParamsBuilder()
        try query.set("created_at[gte]", createdAtGte)
        try query.set("created_at[lte]", createdAtLte)
        try query.set("include_archived", includeArchived)
        try query.set("limit", limit)
        try query.set("page", page)
        let options = try client.makeRequestOptions(method: "get", url: "/v1/agents", query: query, headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.list", spanRoute: "/v1/agents", qualifiers: ["beta": "true"])
        return try await client.requestPageResponse(PageCursor<BetaManagedAgentsAgent>.self, options, stream: _mode == .stream)
    }

    /// Archive Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to archive.
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
    public func archive(_ agentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> BetaManagedAgentsAgent {
        try await _archive(agentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .parsed).parse()
    }

    func _archive(_ agentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, _mode: ResponseMode) async throws -> APIResponse<BetaManagedAgentsAgent> {
        try requireNonEmpty(agentID, "agent_id")
        let options = try client.makeRequestOptions(method: "post", url: try pathTemplate("/v1/agents/{agent_id}/archive", ["agent_id": agentID]), headers: mergeHeaderLayers(["anthropic-beta": "managed-agents-2026-04-01"], mergeHeaderLayers(stripNotGiven([("anthropic-beta", joinHeaderValues(betas, extra: ["managed-agents-2026-04-01"], separator: ",")), ("anthropic-workspace-id", workspaceID)]), extraHeaders)), extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, mode: _mode, spanName: "anthropic.agents.archive", spanRoute: "/v1/agents/{agent_id}/archive", spanAttributes: ["gen_ai.agent.id": agentID], qualifiers: ["beta": "true"])
        return try await client.requestResponse(BetaManagedAgentsAgent.self, options, stream: _mode == .stream)
    }

    public struct WithRawResponse: Sendable {
        let resource: BetaAgentsResource

        public var versions: BetaAgentsVersionsResource.WithRawResponse { resource.versions.withRawResponse }

    /// Create Agent
    ///
    /// Args:
    ///   model: Model identifier.
    ///
    /// Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control
    ///
    ///   name: Human-readable name for the agent.
    ///
    ///   description: Description of what the agent does.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Omitting it, sending null, or
    ///       sending `{"type": "service_account"}` stores the default.
    ///
    ///   mcp_servers: MCP servers this agent connects to. Maximum 20. Names must be unique within the
    ///       array. Every server must be referenced by an `mcp_toolset` in `tools`;
    ///       unreferenced servers are rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   multiagent: Multiagent orchestration configuration.
    ///
    ///   skills: Skills available to the agent.
    ///
    ///   system: System prompt for the agent.
    ///
    ///   tools: Tool configurations available to the agent. Maximum of 256 tools across all
    ///       toolsets allowed.
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
        public func create(model: AgentCreateParams.Model, name: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, metadata: [String: String]? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [AgentCreateParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsAgent> {
            try await resource._create(model: model, name: name, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, multiagent: multiagent, skills: skills, system: system, tools: tools, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Get Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to retrieve.
    ///
    ///   version: Agent version. Omit for the most recent version. Must be at least 1 if
    ///       specified.
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
        public func retrieve(_ agentID: String, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsAgent> {
            try await resource._retrieve(agentID, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Update Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to update.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Full replacement. Omit to preserve;
    ///       send null or `{"type": "service_account"}` to restore the default.
    ///
    ///   mcp_servers: MCP servers. Full replacement. Omit to preserve; send empty array or `null` to
    ///       clear. Names must be unique. Maximum 20. Every server must be referenced by an
    ///       `mcp_toolset` in the agent's resulting `tools`; unreferenced servers are
    ///       rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   model: Model identifier. Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control. Omit to preserve. Cannot be cleared.
    ///
    ///   multiagent: Multiagent orchestration configuration. Full replacement. Omit to preserve; send
    ///       null to clear.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   skills: Skills. Full replacement. Omit to preserve; send empty array or null to clear.
    ///
    ///   system: System prompt. Omit to preserve; send empty string or null to clear.
    ///
    ///   tools: Tool configurations available to the agent. Full replacement. Omit to preserve;
    ///       send empty array or null to clear. Maximum of 256 tools across all toolsets
    ///       allowed.
    ///
    ///   version: The agent's current version, used to prevent concurrent overwrites. Obtain this
    ///       value from a create or retrieve response. Must be at least 1 if specified. When
    ///       supplied, the request fails if it does not match the server's current version;
    ///       omit to apply the update unconditionally.
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
        public func update(_ agentID: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]?? = nil, metadata: [String: String?]?? = nil, model: AgentUpdateParams.Model? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, name: String? = nil, skills: [BetaManagedAgentsSkillParams]?? = nil, system: String?? = nil, tools: [AgentUpdateParams.Tool]?? = nil, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsAgent> {
            try await resource._update(agentID, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, model: model, multiagent: multiagent, name: name, skills: skills, system: system, tools: tools, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// List Agents
    ///
    /// Args:
    ///   created_at_gte: Return agents created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return agents created at or before this time (inclusive).
    ///
    ///   include_archived: Include archived agents in results. Defaults to false.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor from a previous response.
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
        public func list(createdAtGte: AgentListParams.CreatedAtGte? = nil, createdAtLte: AgentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<PageCursor<BetaManagedAgentsAgent>> {
            try await resource._list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }

    /// Archive Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to archive.
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
        public func archive(_ agentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil) async throws -> APIResponse<BetaManagedAgentsAgent> {
            try await resource._archive(agentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .raw)
        }
    }

    public struct WithStreamingResponse: Sendable {
        let resource: BetaAgentsResource

        public var versions: BetaAgentsVersionsResource.WithStreamingResponse { resource.versions.withStreamingResponse }

    /// Create Agent
    ///
    /// Args:
    ///   model: Model identifier.
    ///
    /// Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control
    ///
    ///   name: Human-readable name for the agent.
    ///
    ///   description: Description of what the agent does.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Omitting it, sending null, or
    ///       sending `{"type": "service_account"}` stores the default.
    ///
    ///   mcp_servers: MCP servers this agent connects to. Maximum 20. Names must be unique within the
    ///       array. Every server must be referenced by an `mcp_toolset` in `tools`;
    ///       unreferenced servers are rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Arbitrary key-value metadata. Maximum 16 pairs, keys up to 64 chars, values up
    ///       to 512 chars.
    ///
    ///   multiagent: Multiagent orchestration configuration.
    ///
    ///   skills: Skills available to the agent.
    ///
    ///   system: System prompt for the agent.
    ///
    ///   tools: Tool configurations available to the agent. Maximum of 256 tools across all
    ///       toolsets allowed.
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
        public func create<R: Sendable>(model: AgentCreateParams.Model, name: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]? = nil, metadata: [String: String]? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, skills: [BetaManagedAgentsSkillParams]? = nil, system: String?? = nil, tools: [AgentCreateParams.Tool]? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsAgent>) async throws -> R) async throws -> R {
            let response = try await resource._create(model: model, name: name, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, multiagent: multiagent, skills: skills, system: system, tools: tools, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Get Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to retrieve.
    ///
    ///   version: Agent version. Omit for the most recent version. Must be at least 1 if
    ///       specified.
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
        public func retrieve<R: Sendable>(_ agentID: String, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsAgent>) async throws -> R) async throws -> R {
            let response = try await resource._retrieve(agentID, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Update Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to update.
    ///
    ///   description: Description. Omit to preserve; send empty string or null to clear.
    ///
    ///   execution_identity: Execution principal for runs of this agent. Full replacement. Omit to preserve;
    ///       send null or `{"type": "service_account"}` to restore the default.
    ///
    ///   mcp_servers: MCP servers. Full replacement. Omit to preserve; send empty array or `null` to
    ///       clear. Names must be unique. Maximum 20. Every server must be referenced by an
    ///       `mcp_toolset` in the agent's resulting `tools`; unreferenced servers are
    ///       rejected. See the
    ///       [MCP connector guide](https://platform.claude.com/docs/en/managed-agents/mcp-connector).
    ///
    ///   metadata: Metadata patch. Set a key to a string to upsert it, or to null to delete it.
    ///       Omit the field to preserve. The stored bag is limited to 16 keys (up to 64 chars
    ///       each) with values up to 512 chars.
    ///
    ///   model: Model identifier. Accepts the
    ///       [model string](https://platform.claude.com/docs/en/about-claude/models/overview#latest-models-comparison),
    ///       e.g. `claude-opus-5-5`, or a `model_config` object for additional configuration
    ///       control. Omit to preserve. Cannot be cleared.
    ///
    ///   multiagent: Multiagent orchestration configuration. Full replacement. Omit to preserve; send
    ///       null to clear.
    ///
    ///   name: Human-readable name. Must be non-empty. Omit to preserve. Cannot be cleared.
    ///
    ///   skills: Skills. Full replacement. Omit to preserve; send empty array or null to clear.
    ///
    ///   system: System prompt. Omit to preserve; send empty string or null to clear.
    ///
    ///   tools: Tool configurations available to the agent. Full replacement. Omit to preserve;
    ///       send empty array or null to clear. Maximum of 256 tools across all toolsets
    ///       allowed.
    ///
    ///   version: The agent's current version, used to prevent concurrent overwrites. Obtain this
    ///       value from a create or retrieve response. Must be at least 1 if specified. When
    ///       supplied, the request fails if it does not match the server's current version;
    ///       omit to apply the update unconditionally.
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
        public func update<R: Sendable>(_ agentID: String, description: String?? = nil, executionIdentity: BetaManagedAgentsExecutionIdentityParams?? = nil, mcpServers: [BetaManagedAgentsURLMCPServerParams]?? = nil, metadata: [String: String?]?? = nil, model: AgentUpdateParams.Model? = nil, multiagent: BetaManagedAgentsMultiagentParams?? = nil, name: String? = nil, skills: [BetaManagedAgentsSkillParams]?? = nil, system: String?? = nil, tools: [AgentUpdateParams.Tool]?? = nil, version: Int? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsAgent>) async throws -> R) async throws -> R {
            let response = try await resource._update(agentID, description: description, executionIdentity: executionIdentity, mcpServers: mcpServers, metadata: metadata, model: model, multiagent: multiagent, name: name, skills: skills, system: system, tools: tools, version: version, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// List Agents
    ///
    /// Args:
    ///   created_at_gte: Return agents created at or after this time (inclusive).
    ///
    ///   created_at_lte: Return agents created at or before this time (inclusive).
    ///
    ///   include_archived: Include archived agents in results. Defaults to false.
    ///
    ///   limit: Maximum results per page. Default 20, maximum 100.
    ///
    ///   page: Opaque pagination cursor from a previous response.
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
        public func list<R: Sendable>(createdAtGte: AgentListParams.CreatedAtGte? = nil, createdAtLte: AgentListParams.CreatedAtLte? = nil, includeArchived: Bool? = nil, limit: Int? = nil, page: String? = nil, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<PageCursor<BetaManagedAgentsAgent>>) async throws -> R) async throws -> R {
            let response = try await resource._list(createdAtGte: createdAtGte, createdAtLte: createdAtLte, includeArchived: includeArchived, limit: limit, page: page, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }

    /// Archive Agent
    ///
    /// Args:
    ///   agent_id: Unique identifier of the agent to archive.
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
        public func archive<R: Sendable>(_ agentID: String, betas: [AnthropicBetaParam]? = nil, workspaceID: String? = nil, extraHeaders: Headers? = nil, extraQuery: Query? = nil, extraBody: Body? = nil, timeout: Timeout? = nil, body: (APIResponse<BetaManagedAgentsAgent>) async throws -> R) async throws -> R {
            let response = try await resource._archive(agentID, betas: betas, workspaceID: workspaceID, extraHeaders: extraHeaders, extraQuery: extraQuery, extraBody: extraBody, timeout: timeout, _mode: .stream)
            defer { response.close() }
            return try await body(response)
        }
    }
}
