// Transformed from `tests/api_resources/beta/agents/test_versions.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaAgentsVersions {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}/versions", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.agents.versions.list("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}/versions", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.agents.versions.list("agent_011CZkYpogX7uDKUyvBTophP", limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}/versions", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.agents.versions.withRawResponse.list("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/agents/{agent_id}/versions", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "metadata": {"key": "string"}, "model": {"id": "claude-haiku-5-5", "effort": {"type": "low"}, "inference_geo": "string", "speed": "standard"}, "multiagent": {"agents": [{"id": "string", "type": "agent", "version": 0}], "type": "coordinator"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "updated_at": "2024-01-01T00:00:00Z", "version": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.agents.versions.withStreamingResponse.list("agent_011CZkYpogX7uDKUyvBTophP", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `agent_id` but received ''") { _ = try await client.beta.agents.versions.withRawResponse.list("") }
    }
}
