// Transformed from `tests/api_resources/beta/organization/plugins/test_shares.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationPluginsShares {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/shares", json: #"{"data": [{"granted_at": "2024-01-01T00:00:00Z", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_share"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.shares.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/shares", json: #"{"data": [{"granted_at": "2024-01-01T00:00:00Z", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_share"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.plugins.shares.list("plugin_id", limit: 1, organizationID: "organization_id", page: "page", targetType: "organization", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/shares", json: #"{"data": [{"granted_at": "2024-01-01T00:00:00Z", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_share"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.plugins.shares.withRawResponse.list("plugin_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/plugins/{plugin_id}/shares", json: #"{"data": [{"granted_at": "2024-01-01T00:00:00Z", "plugin_id": "string", "target": {"type": "organization"}, "type": "plugin_share"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.plugins.shares.withStreamingResponse.list("plugin_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `plugin_id` but received ''") { _ = try await client.beta.organization.plugins.shares.withRawResponse.list("") }
    }
}
