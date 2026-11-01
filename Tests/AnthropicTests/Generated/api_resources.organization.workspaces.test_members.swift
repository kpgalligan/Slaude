// Transformed from `tests/api_resources/organization/workspaces/test_members.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationWorkspacesMembers {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.members.retrieve("user_id", workspaceID: "workspace_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.members.withRawResponse.retrieve("user_id", workspaceID: "workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.members.withStreamingResponse.retrieve("user_id", workspaceID: "workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.retrieve("user_id", workspaceID: "") }
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.retrieve("", workspaceID: "workspace_id") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.members.update("user_id", workspaceID: "workspace_id", workspaceRole: WorkspaceRole(rawValue: "workspace_admin"))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.members.withRawResponse.update("user_id", workspaceID: "workspace_id", workspaceRole: WorkspaceRole(rawValue: "workspace_admin"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.members.withStreamingResponse.update("user_id", workspaceID: "workspace_id", workspaceRole: WorkspaceRole(rawValue: "workspace_admin"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.update("user_id", workspaceID: "", workspaceRole: WorkspaceRole(rawValue: "workspace_admin")) }
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.update("", workspaceID: "workspace_id", workspaceRole: WorkspaceRole(rawValue: "workspace_admin")) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"data": [{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.members.list("workspace_id")
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"data": [{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.members.list("workspace_id", afterID: "after_id", beforeID: "before_id", limit: 1)
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"data": [{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.members.withRawResponse.list("workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"data": [{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.members.withStreamingResponse.list("workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(MemberAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.workspaces.members.add("workspace_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(MemberAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.workspaces.members.withRawResponse.add("workspace_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/workspaces/{workspace_id}/members", json: #"{"type": "workspace_member", "user_id": "string", "workspace_id": "string", "workspace_role": "workspace_admin"}"#, validateBody: { try MockRoute.roundTrip(MemberAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.members.withStreamingResponse.add("workspace_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.add("", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", workspaceRole: NoBillingWorkspaceRole(rawValue: "workspace_admin")) }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member_deleted", "user_id": "string", "workspace_id": "string"}"#)
        let client = try route.client()
        let value = try await client.organization.workspaces.members.remove("user_id", workspaceID: "workspace_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member_deleted", "user_id": "string", "workspace_id": "string"}"#)
        let client = try route.client()
        let response = try await client.organization.workspaces.members.withRawResponse.remove("user_id", workspaceID: "workspace_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/workspaces/{workspace_id}/members/{user_id}", json: #"{"type": "workspace_member_deleted", "user_id": "string", "workspace_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.workspaces.members.withStreamingResponse.remove("user_id", workspaceID: "workspace_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `workspace_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.remove("user_id", workspaceID: "") }
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.organization.workspaces.members.withRawResponse.remove("", workspaceID: "workspace_id") }
    }
}
