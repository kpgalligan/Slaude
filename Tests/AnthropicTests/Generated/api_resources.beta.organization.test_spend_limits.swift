// Transformed from `tests/api_resources/beta/organization/test_spend_limits.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationSpendLimits {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.retrieve("spend_limit_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.withRawResponse.retrieve("spend_limit_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.withStreamingResponse.retrieve("spend_limit_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `spend_limit_id` but received ''") { _ = try await client.beta.organization.spendLimits.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits", json: #"{"data": [{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits", json: #"{"data": [{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.list(limit: 1, page: "page", scopeType: ["organization"], workspaceID: "workspace_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits", json: #"{"data": [{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits", json: #"{"data": [{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "type": "spend_limit_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.delete("spend_limit_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "type": "spend_limit_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.withRawResponse.delete("spend_limit_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/spend_limits/{spend_limit_id}", json: #"{"id": "string", "type": "spend_limit_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.withStreamingResponse.delete("spend_limit_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `spend_limit_id` but received ''") { _ = try await client.beta.organization.spendLimits.withRawResponse.delete("") }
    }

    @Test func methodSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limits", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SpendLimitSetParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.set(amount: "50000", scope: SpendLimitSetParams.Scope.user(BetaSpendLimitUserScopeParam(type: "user", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodSetWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limits", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SpendLimitSetParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.set(amount: "50000", scope: SpendLimitSetParams.Scope.user(BetaSpendLimitUserScopeParam(type: "user", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q")), period: BetaSpendLimitPeriod(rawValue: "monthly"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limits", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SpendLimitSetParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.withRawResponse.set(amount: "50000", scope: SpendLimitSetParams.Scope.user(BetaSpendLimitUserScopeParam(type: "user", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseSet() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limits", json: #"{"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SpendLimitSetParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.withStreamingResponse.set(amount: "50000", scope: SpendLimitSetParams.Scope.user(BetaSpendLimitUserScopeParam(type: "user", userID: "user_01WCz1FkmYMm4gnmykNKUu3Q")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
