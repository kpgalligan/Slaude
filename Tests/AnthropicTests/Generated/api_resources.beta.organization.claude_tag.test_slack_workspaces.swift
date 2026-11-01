// Transformed from `tests/api_resources/beta/organization/claude_tag/test_slack_workspaces.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationClaudeTagSlackWorkspaces {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.retrieve("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.retrieve("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", includeInherited: true, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackWorkspaces.withRawResponse.retrieve("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackWorkspaces.withStreamingResponse.retrieve("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `id` but received ''") { _ = try await client.beta.organization.claudeTag.slackWorkspaces.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.update("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.update("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", settings: BetaClaudeTagSettingsUpdateParam(enabled: true, environmentID: "x", guestPolicy: BetaClaudeTagGuestPolicyParam.allow(BetaClaudeTagGuestPolicyAllowParam(type: "allow")), instructions: "instructions", model: "x"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackWorkspaces.withRawResponse.update("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_workspaces/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackWorkspaceUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackWorkspaces.withStreamingResponse.update("slws_01Hq8TzW5mKc2YbX7vNd4RfJ", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `id` but received ''") { _ = try await client.beta.organization.claudeTag.slackWorkspaces.withRawResponse.update("", settings: BetaClaudeTagSettingsUpdateParam()) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackWorkspaces.list(includeInherited: true, limit: 0, page: "page", slackWorkspaceID: "slack_workspace_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackWorkspaces.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_workspaces", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_workspace", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackWorkspaces.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
