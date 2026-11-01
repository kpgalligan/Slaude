// Transformed from `tests/api_resources/beta/organization/spend_limits/test_increase_requests.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationSpendLimitsIncreaseRequests {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.retrieve("spend_limit_increase_request_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.retrieve("spend_limit_increase_request_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.increaseRequests.withStreamingResponse.retrieve("spend_limit_increase_request_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `spend_limit_increase_request_id` but received ''") { _ = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests", json: #"{"data": [{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests", json: #"{"data": [{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.list(actorIDs: ["string"], limit: 1, page: "page", status: [BetaSpendLimitIncreaseRequestStatus(rawValue: "approved")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests", json: #"{"data": [{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limit_increase_requests", json: #"{"data": [{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.increaseRequests.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodApprove() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_limit": {"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestApproveParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.approve("spend_limit_increase_request_id", amount: "50000", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodApproveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_limit": {"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestApproveParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.approve("spend_limit_increase_request_id", amount: "50000", period: BetaSpendLimitPeriod(rawValue: "monthly"), suppressNotification: true, extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseApprove() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_limit": {"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestApproveParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.approve("spend_limit_increase_request_id", amount: "50000", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseApprove() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/approve", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_limit": {"id": "string", "amount": "string", "created_at": "2024-01-01T00:00:00Z", "currency": "string", "is_enabled": true, "period": "daily", "scope": {"type": "user", "user_id": "string"}, "type": "spend_limit", "updated_at": "2024-01-01T00:00:00Z"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestApproveParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.increaseRequests.withStreamingResponse.approve("spend_limit_increase_request_id", amount: "50000", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsApprove() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `spend_limit_increase_request_id` but received ''") { _ = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.approve("", amount: "50000") }
    }

    @Test func methodDeny() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestDenyParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.deny("spend_limit_increase_request_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDenyWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestDenyParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.increaseRequests.deny("spend_limit_increase_request_id", suppressNotification: true, extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDeny() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestDenyParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.deny("spend_limit_increase_request_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDeny() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/spend_limit_increase_requests/{spend_limit_increase_request_id}/deny", json: #"{"id": "string", "actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "created_at": "2024-01-01T00:00:00Z", "period": "daily", "resolved_at": "2024-01-01T00:00:00Z", "resolved_by": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "spend_summary": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}, "status": "approved", "type": "spend_limit_increase_request"}"#, validateBody: { try MockRoute.roundTrip(IncreaseRequestDenyParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.increaseRequests.withStreamingResponse.deny("spend_limit_increase_request_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDeny() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `spend_limit_increase_request_id` but received ''") { _ = try await client.beta.organization.spendLimits.increaseRequests.withRawResponse.deny("") }
    }
}
