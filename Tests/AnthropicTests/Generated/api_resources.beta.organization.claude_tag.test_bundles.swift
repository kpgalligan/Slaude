// Transformed from `tests/api_resources/beta/organization/claude_tag/test_bundles.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationClaudeTagBundles {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.retrieve("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.retrieve("capp_011CZkZjLP1cWxj5EtMmdgbq", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.withRawResponse.retrieve("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.withStreamingResponse.retrieve("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `bundle_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.list(limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "description": "string", "display_name": "string", "type": "bundle", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
