// Transformed from `tests/api_resources/beta/organization/analytics/test_cost.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsCost {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/cost", json: #"{"data": [{"cost": {"amount": "string", "currency": "string", "list_amount": "string", "requests": 0}, "ending_at": "2024-01-01T00:00:00Z", "group": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "actor_type": "api_actor", "agent_id": "string", "api_key_id": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "deployment_id": "string", "environment_id": "string", "inference_geo": "global", "model": "string", "product": "string", "rbac_group_id": "string", "service_tier": "batch", "session_id": "string", "slack_channel_id": "string", "speed": "fast", "token_type": "cache_creation.ephemeral_1h_input_tokens", "user_profile_id": "string", "workspace_id": "string"}, "starting_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.cost.list(startingAt: .date(AnthropicJSON.parseISO8601("2026-09-01T00:00:00Z")!), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/cost", json: #"{"data": [{"cost": {"amount": "string", "currency": "string", "list_amount": "string", "requests": 0}, "ending_at": "2024-01-01T00:00:00Z", "group": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "actor_type": "api_actor", "agent_id": "string", "api_key_id": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "deployment_id": "string", "environment_id": "string", "inference_geo": "global", "model": "string", "product": "string", "rbac_group_id": "string", "service_tier": "batch", "session_id": "string", "slack_channel_id": "string", "speed": "fast", "token_type": "cache_creation.ephemeral_1h_input_tokens", "user_profile_id": "string", "workspace_id": "string"}, "starting_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.cost.list(startingAt: .date(AnthropicJSON.parseISO8601("2026-09-01T00:00:00Z")!), actorIDs: ["user_01WCz1FkmYMm4gnmykNKUu3Q"], actorTypes: [BetaAnalyticsActorType(rawValue: "service_account_actor")], agentIDs: ["agent_01VHd3EAGJ6PLkP9LM7DDu3f"], apiKeyIDs: ["apikey_01Rj2N8SVvo6BePZj99NhmiT"], claudeTagCategories: [BetaAnalyticsClaudeTagCategory(rawValue: "engaged")], claudeTagUserIDs: ["U0123ABCDEF"], contextWindows: [BetaAnalyticsContextWindow(rawValue: "0-200k")], deploymentIDs: ["depl_01JFC6ihzZHtAuyHsaENdJhY"], endingAt: .date(AnthropicJSON.parseISO8601("2026-10-01T00:00:00Z")!), environmentIDs: ["env_017oTjuGedHtjhJauVC5xGJD"], excludeDeletedUsers: true, groupBy: [BetaAnalyticsCostGroupBy(rawValue: "actor")], inferenceGeos: [BetaAnalyticsInferenceGeoFilter(rawValue: "global")], limit: 1, models: ["string"], order: BetaAnalyticsUsageCostSortOrder(rawValue: "asc"), orderBy: BetaAnalyticsCostOrderBy(rawValue: "amount"), page: "page", products: [BetaAnalyticsUsageCostProductFilter(rawValue: "chat")], rbacGroupIDs: ["rbac_group_012rppKaSVsmTo6NqRDXQXNF"], serviceTiers: [BetaAnalyticsServiceTier(rawValue: "batch")], sessionIDs: ["sesn_0187kPDyNCwibNNvfaPEApCJ"], slackChannelIDs: ["C0123ABCDEF"], speeds: [BetaAnalyticsSpeed(rawValue: "fast")], timeBucketWidth: BetaAnalyticsTimeBucketWidth(rawValue: "1d"), userProfileIDs: ["uprof_01M33NeYUQK2WV9PpYcsPHLi"], workspaceIDs: ["wrkspc_01JwQvzr7rXLA5AGx3HKfFUJ"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/cost", json: #"{"data": [{"cost": {"amount": "string", "currency": "string", "list_amount": "string", "requests": 0}, "ending_at": "2024-01-01T00:00:00Z", "group": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "actor_type": "api_actor", "agent_id": "string", "api_key_id": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "deployment_id": "string", "environment_id": "string", "inference_geo": "global", "model": "string", "product": "string", "rbac_group_id": "string", "service_tier": "batch", "session_id": "string", "slack_channel_id": "string", "speed": "fast", "token_type": "cache_creation.ephemeral_1h_input_tokens", "user_profile_id": "string", "workspace_id": "string"}, "starting_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.cost.withRawResponse.list(startingAt: .date(AnthropicJSON.parseISO8601("2026-09-01T00:00:00Z")!), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/cost", json: #"{"data": [{"cost": {"amount": "string", "currency": "string", "list_amount": "string", "requests": 0}, "ending_at": "2024-01-01T00:00:00Z", "group": {"actor": {"deleted": true, "type": "user_actor", "user_id": "string"}, "actor_type": "api_actor", "agent_id": "string", "api_key_id": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "deployment_id": "string", "environment_id": "string", "inference_geo": "global", "model": "string", "product": "string", "rbac_group_id": "string", "service_tier": "batch", "session_id": "string", "slack_channel_id": "string", "speed": "fast", "token_type": "cache_creation.ephemeral_1h_input_tokens", "user_profile_id": "string", "workspace_id": "string"}, "starting_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.cost.withStreamingResponse.list(startingAt: .date(AnthropicJSON.parseISO8601("2026-09-01T00:00:00Z")!), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
