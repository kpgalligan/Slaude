// Transformed from `tests/api_resources/organization/federation/rules/test_workspaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationFederationRulesWorkspaces {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.federation.rules.workspaces.list("federation_rule_id")
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.federation.rules.workspaces.list("federation_rule_id", limit: 1, page: "page")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.federation.rules.workspaces.withRawResponse.list("federation_rule_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.federation.rules.workspaces.withStreamingResponse.list("federation_rule_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.organization.federation.rules.workspaces.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}"#, validateBody: { try MockRoute.roundTrip(OrganizationFederationRulesWorkspaceAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.federation.rules.workspaces.add("federation_rule_id", workspaceID: "workspace_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}"#, validateBody: { try MockRoute.roundTrip(OrganizationFederationRulesWorkspaceAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.federation.rules.workspaces.withRawResponse.add("federation_rule_id", workspaceID: "workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces", json: #"{"created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "federation_rule_id": "string", "type": "federation_rule_workspace", "workspace_id": "string", "workspace_name": "string"}"#, validateBody: { try MockRoute.roundTrip(OrganizationFederationRulesWorkspaceAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.federation.rules.workspaces.withStreamingResponse.add("federation_rule_id", workspaceID: "workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.organization.federation.rules.workspaces.withRawResponse.add("", workspaceID: "workspace_id") }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces/{workspace_id}", json: #"{"federation_rule_id": "string", "type": "federation_rule_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.organization.federation.rules.workspaces.remove("workspace_id", federationRuleID: "federation_rule_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces/{workspace_id}", json: #"{"federation_rule_id": "string", "type": "federation_rule_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.organization.federation.rules.workspaces.withRawResponse.remove("workspace_id", federationRuleID: "federation_rule_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/federation_rules/{federation_rule_id}/workspaces/{workspace_id}", json: #"{"federation_rule_id": "string", "type": "federation_rule_workspace_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.federation.rules.workspaces.withStreamingResponse.remove("workspace_id", federationRuleID: "federation_rule_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_rule_id` but received ''") { _ = try await client.organization.federation.rules.workspaces.withRawResponse.remove("workspace_id", federationRuleID: "") }
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.federation.rules.workspaces.withRawResponse.remove("", federationRuleID: "federation_rule_id") }
    }
}
