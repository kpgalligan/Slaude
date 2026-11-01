// Transformed from `tests/api_resources/beta/organization/test_users.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationUsers {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.users.retrieve("user_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.users.withRawResponse.retrieve("user_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.users.withStreamingResponse.retrieve("user_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.beta.organization.users.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationUserUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.users.update("user_id", role: "user", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationUserUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.users.withRawResponse.update("user_id", role: "user", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationUserUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.users.withStreamingResponse.update("user_id", role: "user", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.beta.organization.users.withRawResponse.update("", role: "user") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users", json: #"{"data": [{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.users.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users", json: #"{"data": [{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.users.list(afterID: "after_id", beforeID: "before_id", email: "dev@stainless.com", limit: 1, roles: ["string"], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users", json: #"{"data": [{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.users.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/users", json: #"{"data": [{"id": "string", "added_at": "2024-01-01T00:00:00Z", "email": "string", "name": "string", "role": "admin", "type": "user"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.users.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "type": "user_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.users.remove("user_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "type": "user_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.users.withRawResponse.remove("user_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRemove() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/users/{user_id}", json: #"{"id": "string", "type": "user_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.users.withStreamingResponse.remove("user_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRemove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_id` but received ''") { _ = try await client.beta.organization.users.withRawResponse.remove("") }
    }
}
