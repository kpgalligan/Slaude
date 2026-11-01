// Transformed from `tests/api_resources/beta/organization/spend_limits/test_effective.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationSpendLimitsEffective {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/effective", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.effective.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/effective", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.spendLimits.effective.list(limit: 1, page: "page", period: ["daily"], userIDs: ["string"], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/effective", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.spendLimits.effective.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/spend_limits/effective", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "currency": "string", "period": "daily", "period_to_date_spend": "string", "scope": {"type": "user", "user_id": "string"}, "source": {"type": "user", "user_id": "string"}, "spend_limit_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.spendLimits.effective.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
