// Transformed from `tests/api_resources/organization/test_api_keys.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationAPIKeys {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#)
        let client = try route.client()
        let value = try await client.organization.apiKeys.retrieve("api_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#)
        let client = try route.client()
        let response = try await client.organization.apiKeys.withRawResponse.retrieve("api_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.apiKeys.withStreamingResponse.retrieve("api_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `api_key_id` but received ''") { _ = try await client.organization.apiKeys.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#, validateBody: { try MockRoute.roundTrip(APIKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.apiKeys.update("api_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#, validateBody: { try MockRoute.roundTrip(APIKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.apiKeys.update("api_key_id", name: "x", status: "active")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#, validateBody: { try MockRoute.roundTrip(APIKeyUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.apiKeys.withRawResponse.update("api_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/api_keys/{api_key_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}"#, validateBody: { try MockRoute.roundTrip(APIKeyUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.apiKeys.withStreamingResponse.update("api_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `api_key_id` but received ''") { _ = try await client.organization.apiKeys.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.apiKeys.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.apiKeys.list(afterID: "after_id", beforeID: "before_id", createdByUserID: "created_by_user_id", limit: 1, status: "active", workspaceID: "workspace_id")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.apiKeys.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/api_keys", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "created_by": {"id": "string", "type": "service_account"}, "expires_at": "2024-01-01T00:00:00Z", "name": "string", "partial_key_hint": "string", "principal": {"type": "user_actor", "user_id": "string"}, "scope": {"type": "organization"}, "status": "active", "type": "api_key"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.apiKeys.withStreamingResponse.list(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
