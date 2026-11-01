// Transformed from `tests/api_resources/organization/workspaces/test_service_accounts.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationWorkspacesServiceAccounts {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.retrieve("service_account_id", workspaceID: "workspace_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.serviceAccounts.withRawResponse.retrieve("service_account_id", workspaceID: "workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.serviceAccounts.withStreamingResponse.retrieve("service_account_id", workspaceID: "workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.retrieve("service_account_id", workspaceID: "") }
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.retrieve("", workspaceID: "workspace_id") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.update("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.serviceAccounts.withRawResponse.update("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.serviceAccounts.withStreamingResponse.update("service_account_id", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.update("service_account_id", workspaceID: "", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin")) }
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.update("", workspaceID: "workspace_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin")) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.list("workspace_id")
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.list("workspace_id", limit: 1, page: "page")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.serviceAccounts.withRawResponse.list("workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"data": [{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.serviceAccounts.withStreamingResponse.list("workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(ServiceAccountAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.add("workspace_id", serviceAccountID: "service_account_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(ServiceAccountAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.workspaces.serviceAccounts.withRawResponse.add("workspace_id", serviceAccountID: "service_account_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts", json: #"{"created_by_actor_id": "string", "implicit": true, "service_account_id": "string", "type": "service_account_workspace_member", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(ServiceAccountAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.serviceAccounts.withStreamingResponse.add("workspace_id", serviceAccountID: "service_account_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.add("", serviceAccountID: "service_account_id", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin")) }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.serviceAccounts.remove("service_account_id", workspaceID: "workspace_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.serviceAccounts.withRawResponse.remove("service_account_id", workspaceID: "workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/service_accounts/{service_account_id}", json: #"{"service_account_id": "string", "type": "service_account_workspace_member_deleted", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.serviceAccounts.withStreamingResponse.remove("service_account_id", workspaceID: "workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.remove("service_account_id", workspaceID: "") }
        try await expectValueError("Expected a non-empty value for `service_account_id` but received ''") { _ = try await client.organization.workspaces.serviceAccounts.withRawResponse.remove("", workspaceID: "workspace_id") }
    }
}
