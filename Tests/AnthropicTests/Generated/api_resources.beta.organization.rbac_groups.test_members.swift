// Transformed from `tests/api_resources/beta/organization/rbac_groups/test_members.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationRbacGroupsMembers {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.members.list("rbac_group_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.members.list("rbac_group_id", limit: 1, page: "eyJjdXJzb3IiOiAicmJhY19ncm91cF8wMSJ9", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.members.withRawResponse.list("rbac_group_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"data": [{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.members.withStreamingResponse.list("rbac_group_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.members.withRawResponse.list("") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationRbacGroupsMemberAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.members.add("rbac_group_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationRbacGroupsMemberAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.members.withRawResponse.add("rbac_group_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members", json: #"{"created_at": "2024-01-01T00:00:00Z", "email": "string", "rbac_group_id": "string", "type": "rbac_group_member", "user_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationRbacGroupsMemberAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.members.withStreamingResponse.add("rbac_group_id", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.members.withRawResponse.add("", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q") }
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members/{user_id}", json: #"{"rbac_group_id": "string", "type": "rbac_group_member_deleted", "user_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.members.remove("user_id", rbacGroupID: "rbac_group_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members/{user_id}", json: #"{"rbac_group_id": "string", "type": "rbac_group_member_deleted", "user_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.members.withRawResponse.remove("user_id", rbacGroupID: "rbac_group_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}/members/{user_id}", json: #"{"rbac_group_id": "string", "type": "rbac_group_member_deleted", "user_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.members.withStreamingResponse.remove("user_id", rbacGroupID: "rbac_group_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.members.withRawResponse.remove("user_id", rbacGroupID: "") }
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.beta.organization.rbacGroups.members.withRawResponse.remove("", rbacGroupID: "rbac_group_id") }
    }
}
