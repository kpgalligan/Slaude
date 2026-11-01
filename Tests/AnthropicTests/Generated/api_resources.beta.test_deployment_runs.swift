// Transformed from `tests/api_resources/beta/test_deployment_runs.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaDeploymentRuns {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs/{deployment_run_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let value = try await client.beta.deploymentRuns.retrieve("deployment_run_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs/{deployment_run_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let value = try await client.beta.deploymentRuns.retrieve("deployment_run_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs/{deployment_run_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let response = try await client.beta.deploymentRuns.withRawResponse.retrieve("deployment_run_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs/{deployment_run_id}", json: #"{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deploymentRuns.withStreamingResponse.retrieve("deployment_run_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `deployment_run_id` but received ''") { _ = try await client.beta.deploymentRuns.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.deploymentRuns.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.deploymentRuns.list(createdAtGt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), deploymentID: "deployment_id", hasError: true, limit: 0, page: "page", triggerType: BetaManagedAgentsTriggerType(rawValue: "schedule"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.deploymentRuns.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/deployment_runs", json: #"{"data": [{"id": "string", "agent": {"id": "string", "type": "agent", "version": 0}, "created_at": "2024-01-01T00:00:00Z", "deployment_id": "string", "error": {"message": "string", "type": "environment_archived_error"}, "session_id": "string", "trigger_context": {"scheduled_at": "2024-01-01T00:00:00Z", "type": "schedule"}, "type": "deployment_run"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.deploymentRuns.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
