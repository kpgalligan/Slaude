// Transformed from `tests/api_resources/beta/test_agents.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaAgents {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.agents.create(model: AgentCreateParams.Model.betaManagedAgentsModelParam(BetaManagedAgentsModelParam(rawValue: "claude-opus-5-5")), name: "My First Agent", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.agents.create(model: AgentCreateParams.Model.betaManagedAgentsModelParam(BetaManagedAgentsModelParam(rawValue: "claude-opus-5-5")), name: "My First Agent", description: "A general-purpose starter agent.", executionIdentity: BetaManagedAgentsExecutionIdentityParams.awsRole(BetaManagedAgentsAWSRoleExecutionIdentityParams(roleArn: "role_arn", type: "aws_role")), mcpServers: [BetaManagedAgentsURLMCPServerParams(name: "example-mcp", type: "url", url: "https://example-server.modelcontextprotocol.io/sse")], metadata: ["foo": "bar"], multiagent: BetaManagedAgentsMultiagentParams.coordinator(BetaManagedAgentsMultiagentCoordinatorParams(agents: [BetaManagedAgentsMultiagentRosterEntryParams.string("agent_011CZkYqphY8vELVzwCUpqiQ"), BetaManagedAgentsMultiagentRosterEntryParams.betaManagedAgentsMultiagentSelfParams(BetaManagedAgentsMultiagentSelfParams(type: "self"))], type: "coordinator")), skills: [BetaManagedAgentsSkillParams.anthropic(BetaManagedAgentsAnthropicSkillParams(skillID: "xlsx", type: "anthropic", version: "1"))], system: "You are a general-purpose agent that can research, write code, run commands, and use connected tools to complete the user's task end to end.", tools: [AgentCreateParams.Tool.agentToolset20260401(BetaManagedAgentsAgentToolset20260401Params(type: "agent_toolset_20260401", configs: [BetaManagedAgentsAgentToolConfigParams.bash(BetaManagedAgentsBashToolConfigParams(name: "bash", enabled: true, permissionPolicy: BetaManagedAgentsBashToolConfigParams.PermissionPolicy.alwaysAllow(BetaManagedAgentsAlwaysAllowPolicyParam(type: "always_allow")), type: "bash"))], defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfigParams(enabled: true, permissionPolicy: BetaManagedAgentsAgentToolsetDefaultConfigParams.PermissionPolicy.alwaysAllow(BetaManagedAgentsAlwaysAllowPolicyParam(type: "always_allow")))))], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.agents.withRawResponse.create(model: AgentCreateParams.Model.betaManagedAgentsModelParam(BetaManagedAgentsModelParam(rawValue: "claude-opus-5-5")), name: "My First Agent", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.agents.withStreamingResponse.create(model: AgentCreateParams.Model.betaManagedAgentsModelParam(BetaManagedAgentsModelParam(rawValue: "claude-opus-5-5")), name: "My First Agent", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let value = try await client.beta.agents.retrieve("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let value = try await client.beta.agents.retrieve("agent_011CZkYpogX7uDKUyvBTophP", version: 0, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let response = try await client.beta.agents.withRawResponse.retrieve("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.agents.withStreamingResponse.retrieve("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `agent_id` but received ''") { _ = try await client.beta.agents.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.agents.update("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.agents.update("agent_011CZkYpogX7uDKUyvBTophP", description: "updated", executionIdentity: BetaManagedAgentsExecutionIdentityParams.awsRole(BetaManagedAgentsAWSRoleExecutionIdentityParams(roleArn: "role_arn", type: "aws_role")), mcpServers: [BetaManagedAgentsURLMCPServerParams(name: "example-mcp", type: "url", url: "https://example-server.modelcontextprotocol.io/sse")], metadata: ["foo": "string"], model: AgentUpdateParams.Model.betaManagedAgentsModelConfigParams(BetaManagedAgentsModelConfigParams(id: BetaManagedAgentsModelParam(rawValue: "claude-opus-5-5"), effort: BetaManagedAgentsModelConfigParams.Effort.literal("low"), inferenceGeo: "inference_geo", speed: "standard")), multiagent: BetaManagedAgentsMultiagentParams.coordinator(BetaManagedAgentsMultiagentCoordinatorParams(agents: [BetaManagedAgentsMultiagentRosterEntryParams.string("agent_011CZkYqphY8vELVzwCUpqiQ"), BetaManagedAgentsMultiagentRosterEntryParams.betaManagedAgentsMultiagentSelfParams(BetaManagedAgentsMultiagentSelfParams(type: "self"))], type: "coordinator")), name: "name", skills: [BetaManagedAgentsSkillParams.anthropic(BetaManagedAgentsAnthropicSkillParams(skillID: "xlsx", type: "anthropic", version: "1"))], system: "You are a general-purpose agent that can research, write code, run commands, and use connected tools to complete the user's task end to end.", tools: [AgentUpdateParams.Tool.agentToolset20260401(BetaManagedAgentsAgentToolset20260401Params(type: "agent_toolset_20260401", configs: [BetaManagedAgentsAgentToolConfigParams.bash(BetaManagedAgentsBashToolConfigParams(name: "bash", enabled: true, permissionPolicy: BetaManagedAgentsBashToolConfigParams.PermissionPolicy.alwaysAllow(BetaManagedAgentsAlwaysAllowPolicyParam(type: "always_allow")), type: "bash"))], defaultConfig: BetaManagedAgentsAgentToolsetDefaultConfigParams(enabled: true, permissionPolicy: BetaManagedAgentsAgentToolsetDefaultConfigParams.PermissionPolicy.alwaysAllow(BetaManagedAgentsAlwaysAllowPolicyParam(type: "always_allow")))))], version: 1, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.agents.withRawResponse.update("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#, validateBody: { try MockRoute.roundTrip(AgentUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.agents.withStreamingResponse.update("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `agent_id` but received ''") { _ = try await client.beta.agents.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.agents.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.agents.list(createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), includeArchived: true, limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.agents.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.agents.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let value = try await client.beta.agents.archive("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let value = try await client.beta.agents.archive("agent_011CZkYpogX7uDKUyvBTophP", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let response = try await client.beta.agents.withRawResponse.archive("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/agents/{agent_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.agents.withStreamingResponse.archive("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `agent_id` but received ''") { _ = try await client.beta.agents.withRawResponse.archive("") }
    }
}
