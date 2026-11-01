// Transformed from `tests/api_resources/beta/organization/test_rate_limits.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationRateLimits {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rate_limits", json: #"{"data": [{"id": "string", "group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"type": "string", "value": 0}], "models": ["string"], "type": "rate_limit"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rateLimits.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rate_limits", json: #"{"data": [{"id": "string", "group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"type": "string", "value": 0}], "models": ["string"], "type": "rate_limit"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.rateLimits.list(groupType: "batch", limit: 1, model: "model", page: "page", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rate_limits", json: #"{"data": [{"id": "string", "group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"type": "string", "value": 0}], "models": ["string"], "type": "rate_limit"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.rateLimits.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/rate_limits", json: #"{"data": [{"id": "string", "group": {"id": "string", "display_name": "string", "type": "model_group"}, "limits": [{"type": "string", "value": 0}], "models": ["string"], "type": "rate_limit"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.rateLimits.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
