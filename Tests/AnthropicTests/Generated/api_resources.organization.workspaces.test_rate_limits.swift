// Transformed from `tests/api_resources/organization/workspaces/test_rate_limits.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationWorkspacesRateLimits {
    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits/{rate_limit_id}", json: #"{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.rateLimits.update("rate_limit_id", workspaceID: "workspace_id", limits: [WorkspaceRateLimitUpdateValueParam(type: WorkspaceRateLimitType(rawValue: "fast_itpmca"), value: 0)])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits/{rate_limit_id}", json: #"{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.rateLimits.withRawResponse.update("rate_limit_id", workspaceID: "workspace_id", limits: [WorkspaceRateLimitUpdateValueParam(type: WorkspaceRateLimitType(rawValue: "fast_itpmca"), value: 0)])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits/{rate_limit_id}", json: #"{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.rateLimits.withStreamingResponse.update("rate_limit_id", workspaceID: "workspace_id", limits: [WorkspaceRateLimitUpdateValueParam(type: WorkspaceRateLimitType(rawValue: "fast_itpmca"), value: 0)], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.rateLimits.withRawResponse.update("rate_limit_id", workspaceID: "", limits: [WorkspaceRateLimitUpdateValueParam(type: WorkspaceRateLimitType(rawValue: "fast_itpmca"), value: 0)]) }
        try await expectValueError("Expected a non-empty value for `rate_limit_id` but received ''") { _ = try await client.organization.workspaces.rateLimits.withRawResponse.update("", workspaceID: "workspace_id", limits: [WorkspaceRateLimitUpdateValueParam(type: WorkspaceRateLimitType(rawValue: "fast_itpmca"), value: 0)]) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits", json: #"{"data": [{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.rateLimits.list("workspace_id")
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits", json: #"{"data": [{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.rateLimits.list("workspace_id", groupType: "batch", includeInherited: true, limit: 1, page: "page")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits", json: #"{"data": [{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.rateLimits.withRawResponse.list("workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/rate_limits", json: #"{"data": [{"group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"source": {"type": "workspace"}, "type": "string", "value": 0}], "models": ["string"], "rate_limit_id": "string", "type": "workspace_rate_limit", "workspace_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.rateLimits.withStreamingResponse.list("workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.rateLimits.withRawResponse.list("") }
    }
}
