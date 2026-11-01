// Transformed from `tests/api_resources/beta/organization/claude_tag/bundles/test_targets.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationClaudeTagBundlesTargets {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#, validateBody: { try MockRoute.roundTrip(BetaClaudeTagBundleTargetCreateParam.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.create("capp_011CZkZjLP1cWxj5EtMmdgbq", target: BetaClaudeTagBundleTargetCreateParam.slackChannel(BetaClaudeTagSlackChannelBundleTargetCreateParam(slackChannelID: "xxxxxxxx", type: "slack_channel")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#, validateBody: { try MockRoute.roundTrip(BetaClaudeTagBundleTargetCreateParam.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.create("capp_011CZkZjLP1cWxj5EtMmdgbq", target: BetaClaudeTagBundleTargetCreateParam.slackChannel(BetaClaudeTagSlackChannelBundleTargetCreateParam(slackChannelID: "xxxxxxxx", type: "slack_channel")), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#, validateBody: { try MockRoute.roundTrip(BetaClaudeTagBundleTargetCreateParam.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.create("capp_011CZkZjLP1cWxj5EtMmdgbq", target: BetaClaudeTagBundleTargetCreateParam.slackChannel(BetaClaudeTagSlackChannelBundleTargetCreateParam(slackChannelID: "xxxxxxxx", type: "slack_channel")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#, validateBody: { try MockRoute.roundTrip(BetaClaudeTagBundleTargetCreateParam.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.targets.withStreamingResponse.create("capp_011CZkZjLP1cWxj5EtMmdgbq", target: BetaClaudeTagBundleTargetCreateParam.slackChannel(BetaClaudeTagSlackChannelBundleTargetCreateParam(slackChannelID: "xxxxxxxx", type: "slack_channel")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `bundle_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.create("", target: BetaClaudeTagBundleTargetCreateParam.slackChannel(BetaClaudeTagSlackChannelBundleTargetCreateParam(slackChannelID: "xxxxxxxx", type: "slack_channel"))) }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.retrieve("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.retrieve("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.retrieve("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.targets.withStreamingResponse.retrieve("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `bundle_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.retrieve("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "") }
        try await expectValueError("Expected a non-empty value for `target_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.retrieve("", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.list("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.list("capp_011CZkZjLP1cWxj5EtMmdgbq", limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.list("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "slack_channel_id": "string", "type": "slack_channel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.targets.withStreamingResponse.list("capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `bundle_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.list("") }
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "type": "bundle_target_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.delete("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "type": "bundle_target_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.bundles.targets.delete("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "type": "bundle_target_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.delete("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/bundles/{bundle_id}/targets/{target_id}", json: #"{"id": "string", "type": "bundle_target_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.bundles.targets.withStreamingResponse.delete("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `bundle_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.delete("btgt_01SvpyRQK3nN6eH9uhRA7n1qHq8TzW5mKc2YbX7vNd4RfJ", bundleID: "") }
        try await expectValueError("Expected a non-empty value for `target_id` but received ''") { _ = try await client.beta.organization.claudeTag.bundles.targets.withRawResponse.delete("", bundleID: "capp_011CZkZjLP1cWxj5EtMmdgbq") }
    }
}
