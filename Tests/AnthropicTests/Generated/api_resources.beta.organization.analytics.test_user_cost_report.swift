// Transformed from `tests/api_resources/beta/organization/analytics/test_user_cost_report.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsUserCostReport {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/user_cost_report", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "currency": "string", "ending_at": "2024-01-01T00:00:00Z", "inference_geo": "global", "list_amount": "string", "model": "string", "product": "string", "rbac_group_id": "string", "requests": 0, "slack_channel_id": "string", "speed": "fast", "starting_at": "2024-01-01T00:00:00Z", "token_type": "cache_creation.ephemeral_1h_input_tokens"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.userCostReport.list(startingAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/user_cost_report", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "currency": "string", "ending_at": "2024-01-01T00:00:00Z", "inference_geo": "global", "list_amount": "string", "model": "string", "product": "string", "rbac_group_id": "string", "requests": 0, "slack_channel_id": "string", "speed": "fast", "starting_at": "2024-01-01T00:00:00Z", "token_type": "cache_creation.ephemeral_1h_input_tokens"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.userCostReport.list(startingAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), bucketWidth: "1d", claudeTagCategories: [BetaAnalyticsClaudeTagCategory(rawValue: "engaged")], claudeTagUserIDs: ["U0123ABCDEF"], contextWindows: [BetaAnalyticsContextWindow(rawValue: "0-200k")], endingAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), excludeDeletedUsers: true, groupBy: ["claude_tag_category"], inferenceGeos: [BetaAnalyticsInferenceGeoFilter(rawValue: "global")], limit: 1, models: ["string"], order: "asc", orderBy: "amount", page: "page", products: [BetaAnalyticsProductFilter(rawValue: "chat")], rbacGroupIDs: ["rbac_group_012rppKaSVsmTo6NqRDXQXNF"], slackChannelIDs: ["C0123ABCDEF"], speeds: ["fast"], userIDs: ["user_01AbCdEfGhIjKlMnOpQrSt"], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/user_cost_report", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "currency": "string", "ending_at": "2024-01-01T00:00:00Z", "inference_geo": "global", "list_amount": "string", "model": "string", "product": "string", "rbac_group_id": "string", "requests": 0, "slack_channel_id": "string", "speed": "fast", "starting_at": "2024-01-01T00:00:00Z", "token_type": "cache_creation.ephemeral_1h_input_tokens"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.userCostReport.withRawResponse.list(startingAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/user_cost_report", json: #"{"data": [{"actor": {"deleted": true, "email_address": "string", "name": "string", "type": "user_actor", "user_id": "string"}, "amount": "string", "claude_tag_category": "dm", "claude_tag_user_id": "string", "context_window": "0-200k", "cost_type": "code_execution", "currency": "string", "ending_at": "2024-01-01T00:00:00Z", "inference_geo": "global", "list_amount": "string", "model": "string", "product": "string", "rbac_group_id": "string", "requests": 0, "slack_channel_id": "string", "speed": "fast", "starting_at": "2024-01-01T00:00:00Z", "token_type": "cache_creation.ephemeral_1h_input_tokens"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.userCostReport.withStreamingResponse.list(startingAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
