// Transformed from `tests/api_resources/beta/organization/rbac_roles/test_permissions.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationRbacRolesPermissions {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}/permissions", json: #"{"data": [{"action": "string", "resource": {"organization_id": "string", "type": "organization"}, "type": "rbac_role_permission"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacRoles.permissions.list("rbac_role_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}/permissions", json: #"{"data": [{"action": "string", "resource": {"organization_id": "string", "type": "organization"}, "type": "rbac_role_permission"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rbacRoles.permissions.list("rbac_role_id", limit: 1, page: "eyJjdXJzb3IiOiAicmJhY19yb2xlXzAxIn0", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}/permissions", json: #"{"data": [{"action": "string", "resource": {"organization_id": "string", "type": "organization"}, "type": "rbac_role_permission"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rbacRoles.permissions.withRawResponse.list("rbac_role_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rbac_roles/{rbac_role_id}/permissions", json: #"{"data": [{"action": "string", "resource": {"organization_id": "string", "type": "organization"}, "type": "rbac_role_permission"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rbacRoles.permissions.withStreamingResponse.list("rbac_role_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `rbac_role_id` but received ''") { _ = try await client.beta.organization.rbacRoles.permissions.withRawResponse.list("") }
    }
}
