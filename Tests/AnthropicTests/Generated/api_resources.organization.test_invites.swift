// Transformed from `tests/api_resources/organization/test_invites.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationInvites {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/invites", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#, validateBody: { try MockRoute.roundTrip(InviteCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.invites.create(email: "user@emaildomain.com", role: "user")
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/invites", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#, validateBody: { try MockRoute.roundTrip(InviteCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.invites.create(email: "user@emaildomain.com", role: "user", rbacGroupIDs: ["string"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/invites", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#, validateBody: { try MockRoute.roundTrip(InviteCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.invites.withRawResponse.create(email: "user@emaildomain.com", role: "user")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/invites", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#, validateBody: { try MockRoute.roundTrip(InviteCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.invites.withStreamingResponse.create(email: "user@emaildomain.com", role: "user", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#)
        let client = try route.client()
        let value = try await client.organization.invites.retrieve("invite_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#)
        let client = try route.client()
        let response = try await client.organization.invites.withRawResponse.retrieve("invite_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.invites.withStreamingResponse.retrieve("invite_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `invite_id` but received ''") { _ = try await client.organization.invites.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites", json: #"{"data": [{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.invites.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites", json: #"{"data": [{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.invites.list(afterID: "after_id", beforeID: "before_id", email: "dev@stainless.com", limit: 1, roles: ["string"], statuses: ["accepted"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites", json: #"{"data": [{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.invites.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/invites", json: #"{"data": [{"id": "string", "accepted_at": "2024-01-01T00:00:00Z", "email": "string", "expires_at": "2024-01-01T00:00:00Z", "invited_at": "2024-01-01T00:00:00Z", "rbac_group_ids": ["string"], "role": "admin", "status": "accepted", "type": "invite"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.invites.withStreamingResponse.list(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "type": "invite_deleted"}"#)
        let client = try route.client()
        let value = try await client.organization.invites.delete("invite_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "type": "invite_deleted"}"#)
        let client = try route.client()
        let response = try await client.organization.invites.withRawResponse.delete("invite_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/invites/{invite_id}", json: #"{"id": "string", "type": "invite_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.invites.withStreamingResponse.delete("invite_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `invite_id` but received ''") { _ = try await client.organization.invites.withRawResponse.delete("") }
    }
}
