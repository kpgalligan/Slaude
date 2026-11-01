// Transformed from `tests/api_resources/organization/service_accounts/test_workspaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationServiceAccountsWorkspaces {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.serviceAccounts.workspaces.list("service_account_id")
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.serviceAccounts.workspaces.list("service_account_id", limit: 1, page: "page")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.serviceAccounts.workspaces.withRawResponse.list("service_account_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.serviceAccounts.workspaces.withStreamingResponse.list("service_account_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.serviceAccounts.workspaces.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(WorkspaceAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.serviceAccounts.workspaces.add("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(WorkspaceAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.serviceAccounts.workspaces.withRawResponse.add("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(WorkspaceAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.serviceAccounts.workspaces.withStreamingResponse.add("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.serviceAccounts.workspaces.withRawResponse.add("", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin")) }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces/{workspace_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.organization.serviceAccounts.workspaces.remove("workspace_id", serviceAccountID: "service_account_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces/{workspace_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.organization.serviceAccounts.workspaces.withRawResponse.remove("workspace_id", serviceAccountID: "service_account_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/service_accounts/{service_account_id}/workspaces/{workspace_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.serviceAccounts.workspaces.withStreamingResponse.remove("workspace_id", serviceAccountID: "service_account_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.serviceAccounts.workspaces.withRawResponse.remove("workspace_id", serviceAccountID: "") }
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.serviceAccounts.workspaces.withRawResponse.remove("", serviceAccountID: "service_account_id") }
    }
}
