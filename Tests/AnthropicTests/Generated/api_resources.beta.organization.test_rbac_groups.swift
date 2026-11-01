// Transformed from `tests/api_resources/beta/organization/test_rbac_groups.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationRBACGroups {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.create(name: "Engineering", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.withRawResponse.create(name: "Engineering", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.withStreamingResponse.create(name: "Engineering", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.retrieve("rbac_group_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.withRawResponse.retrieve("rbac_group_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.withStreamingResponse.retrieve("rbac_group_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.update("rbac_group_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.update("rbac_group_id", name: "Engineering", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.withRawResponse.update("rbac_group_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(RBACGroupUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.withStreamingResponse.update("rbac_group_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.list(limit: 1, page: "eyJjdXJzb3IiOiAicmJhY19ncm91cF8wMSJ9", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_groups", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "name": "string", "role_ids": ["string"], "source_type": "direct", "type": "rbac_group", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "type": "rbac_group_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacGroups.delete("rbac_group_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "type": "rbac_group_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacGroups.withRawResponse.delete("rbac_group_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/rbac_groups/{rbac_group_id}", json: #"{"id": "string", "type": "rbac_group_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacGroups.withStreamingResponse.delete("rbac_group_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_group_id` but received ''") { _ = try await client.beta.organization.rbacGroups.withRawResponse.delete("") }
    }
}
