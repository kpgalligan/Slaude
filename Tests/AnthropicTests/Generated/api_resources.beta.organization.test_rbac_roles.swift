// Transformed from `tests/api_resources/beta/organization/test_rbac_roles.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationRBACRoles {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacRoles.retrieve("rbac_role_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacRoles.withRawResponse.retrieve("rbac_role_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacRoles.withStreamingResponse.retrieve("rbac_role_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_role_id` but received ''") { _ = try await client.beta.organization.rbacRoles.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacRoles.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacRoles.list(limit: 1, page: "eyJjdXJzb3IiOiAicmJhY19yb2xlXzAxIn0", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacRoles.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "type": "rbac_role", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacRoles.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
