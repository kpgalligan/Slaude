// Transformed from `tests/api_resources/beta/sessions/test_threads.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSessionsThreads {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.retrieve("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.retrieve("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.threads.withRawResponse.retrieve("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.threads.withStreamingResponse.retrieve("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.threads.withRawResponse.retrieve("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `thread_id` but received ''") { _ = try await client.beta.sessions.threads.withRawResponse.retrieve("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads", json: #"{"data": [{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads", json: #"{"data": [{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.list("sesn_011CZkZAtmR3yMPDzynEDxu7", limit: 0, page: "page", statuses: [BetaManagedAgentsSessionThreadStatus(rawValue: "running")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads", json: #"{"data": [{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.threads.withRawResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads", json: #"{"data": [{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.threads.withStreamingResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.threads.withRawResponse.list("") }
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/threads/{thread_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.archive("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/threads/{thread_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.archive("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/threads/{thread_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.threads.withRawResponse.archive("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/threads/{thread_id}/archive", json: #"{"id": "string", "agent": {"id": "string", "description": "string", "execution_identity": {"role_arn": "string", "type": "aws_role"}, "mcp_servers": [{"name": "string", "type": "url", "url": "string"}], "model": {"id": "claude-haiku-5-5"}, "name": "string", "skills": [{"skill_id": "string", "type": "anthropic", "version": "string"}], "system": "string", "tools": [{"configs": [{"enabled": true, "name": "bash", "permission_policy": {"type": "always_allow"}, "type": "bash"}], "default_config": {"enabled": true, "permission_policy": {"type": "always_allow"}}, "type": "agent_toolset_20260401"}], "type": "agent", "version": 0}, "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "parent_thread_id": "string", "session_id": "string", "stats": {"active_seconds": 0, "duration_seconds": 0, "startup_seconds": 0}, "status": "running", "type": "session_thread", "updated_at": "2024-01-01T00:00:00Z", "usage": {"active_seconds": 0, "cache_creation": {}, "cache_read_input_tokens": 0, "input_tokens": 0, "list_cost": {"amount": "string", "currency": "USD"}, "output_tokens": 0, "server_tool_use": {}}, "workflow_run_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.threads.withStreamingResponse.archive("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.threads.withRawResponse.archive("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `thread_id` but received ''") { _ = try await client.beta.sessions.threads.withRawResponse.archive("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }
}
