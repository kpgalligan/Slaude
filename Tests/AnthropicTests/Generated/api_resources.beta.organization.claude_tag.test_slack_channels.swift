// Transformed from `tests/api_resources/beta/organization/claude_tag/test_slack_channels.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationClaudeTagSlackChannels {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.create(slack: BetaClaudeTagSlackChannelIdentifiersParam(channelID: "xx", workspaceID: "xx"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.create(slack: BetaClaudeTagSlackChannelIdentifiersParam(channelID: "xx", workspaceID: "xx"), settings: BetaClaudeTagSettingsCreateParam(enabled: true, environmentID: "x", guestPolicy: BetaClaudeTagGuestPolicyParam.allow(BetaClaudeTagGuestPolicyAllowParam(type: "allow")), instructions: "instructions", model: "x"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.create(slack: BetaClaudeTagSlackChannelIdentifiersParam(channelID: "xx", workspaceID: "xx"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackChannels.withStreamingResponse.create(slack: BetaClaudeTagSlackChannelIdentifiersParam(channelID: "xx", workspaceID: "xx"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.retrieve("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.retrieve("slch_01SvpyRQK3nN6eH9uhRA7n1q", includeInherited: true, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.retrieve("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackChannels.withStreamingResponse.retrieve("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `id` but received ''") { _ = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.update("slch_01SvpyRQK3nN6eH9uhRA7n1q", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.update("slch_01SvpyRQK3nN6eH9uhRA7n1q", settings: BetaClaudeTagSettingsUpdateParam(enabled: true, environmentID: "x", guestPolicy: BetaClaudeTagGuestPolicyParam.allow(BetaClaudeTagGuestPolicyAllowParam(type: "allow")), instructions: "instructions", model: "x"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.update("slch_01SvpyRQK3nN6eH9uhRA7n1q", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(SlackChannelUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackChannels.withStreamingResponse.update("slch_01SvpyRQK3nN6eH9uhRA7n1q", settings: BetaClaudeTagSettingsUpdateParam(), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `id` but received ''") { _ = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.update("", settings: BetaClaudeTagSettingsUpdateParam()) }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.list(slackWorkspaceID: "slack_workspace_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.list(slackWorkspaceID: "slack_workspace_id", includeInherited: true, limit: 0, page: "page", slackChannelID: "slack_channel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.list(slackWorkspaceID: "slack_workspace_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/claude_tag/slack_channels", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "settings": {"enabled": true, "environment_id": "string", "guest_policy": {"type": "allow"}, "instructions": "string", "model": "string"}, "slack": {"channel_id": "string", "workspace_id": "string"}, "sources": {"enabled": {"slack_channel_id": "string", "type": "slack_channel"}, "environment_id": {"slack_channel_id": "string", "type": "slack_channel"}, "guest_policy": {"slack_channel_id": "string", "type": "slack_channel"}, "instructions": [{"slack_channel_id": "string", "type": "slack_channel"}], "model": {"slack_channel_id": "string", "type": "slack_channel"}}, "type": "slack_channel", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackChannels.withStreamingResponse.list(slackWorkspaceID: "slack_workspace_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "type": "slack_channel_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.delete("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "type": "slack_channel_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.claudeTag.slackChannels.delete("slch_01SvpyRQK3nN6eH9uhRA7n1q", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "type": "slack_channel_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.delete("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/claude_tag/slack_channels/{id}", json: #"{"id": "string", "type": "slack_channel_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.claudeTag.slackChannels.withStreamingResponse.delete("slch_01SvpyRQK3nN6eH9uhRA7n1q", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `id` but received ''") { _ = try await client.beta.organization.claudeTag.slackChannels.withRawResponse.delete("") }
    }
}
