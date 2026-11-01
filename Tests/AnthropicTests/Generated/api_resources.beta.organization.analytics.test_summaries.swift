// Transformed from `tests/api_resources/beta/organization/analytics/test_summaries.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsSummaries {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/summaries", json: #"{"data": [{"assigned_seat_count": 0, "cowork_daily_active_user_count": 0, "cowork_monthly_active_user_count": 0, "cowork_weekly_active_user_count": 0, "daily_active_user_count": 0, "daily_adoption_rate": 0, "ending_at": "2024-01-01T00:00:00Z", "monthly_active_user_count": 0, "monthly_adoption_rate": 0, "pending_invite_count": 0, "starting_at": "2024-01-01T00:00:00Z", "weekly_active_user_count": 0, "weekly_adoption_rate": 0, "chat_cowork_unified_daily_active_user_count": 0, "chat_cowork_unified_monthly_active_user_count": 0, "chat_cowork_unified_weekly_active_user_count": 0, "chat_daily_active_user_count": 0, "chat_monthly_active_user_count": 0, "chat_weekly_active_user_count": 0, "claude_code_daily_active_user_count": 0, "claude_code_monthly_active_user_count": 0, "claude_code_weekly_active_user_count": 0, "claude_design_daily_active_user_count": 0, "claude_design_monthly_active_user_count": 0, "claude_design_weekly_active_user_count": 0, "office_agent_daily_active_user_count": 0, "office_agent_monthly_active_user_count": 0, "office_agent_weekly_active_user_count": 0, "science_daily_active_user_count": 0, "science_entitled_user_count": 0, "science_monthly_active_user_count": 0, "science_weekly_active_user_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.summaries.list(startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/summaries", json: #"{"data": [{"assigned_seat_count": 0, "cowork_daily_active_user_count": 0, "cowork_monthly_active_user_count": 0, "cowork_weekly_active_user_count": 0, "daily_active_user_count": 0, "daily_adoption_rate": 0, "ending_at": "2024-01-01T00:00:00Z", "monthly_active_user_count": 0, "monthly_adoption_rate": 0, "pending_invite_count": 0, "starting_at": "2024-01-01T00:00:00Z", "weekly_active_user_count": 0, "weekly_adoption_rate": 0, "chat_cowork_unified_daily_active_user_count": 0, "chat_cowork_unified_monthly_active_user_count": 0, "chat_cowork_unified_weekly_active_user_count": 0, "chat_daily_active_user_count": 0, "chat_monthly_active_user_count": 0, "chat_weekly_active_user_count": 0, "claude_code_daily_active_user_count": 0, "claude_code_monthly_active_user_count": 0, "claude_code_weekly_active_user_count": 0, "claude_design_daily_active_user_count": 0, "claude_design_monthly_active_user_count": 0, "claude_design_weekly_active_user_count": 0, "office_agent_daily_active_user_count": 0, "office_agent_monthly_active_user_count": 0, "office_agent_weekly_active_user_count": 0, "science_daily_active_user_count": 0, "science_entitled_user_count": 0, "science_monthly_active_user_count": 0, "science_weekly_active_user_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.summaries.list(startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), endingDate: .date(ISODate(year: 2019, month: 12, day: 27)), filter: ["string"], limit: 1, page: "page", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/summaries", json: #"{"data": [{"assigned_seat_count": 0, "cowork_daily_active_user_count": 0, "cowork_monthly_active_user_count": 0, "cowork_weekly_active_user_count": 0, "daily_active_user_count": 0, "daily_adoption_rate": 0, "ending_at": "2024-01-01T00:00:00Z", "monthly_active_user_count": 0, "monthly_adoption_rate": 0, "pending_invite_count": 0, "starting_at": "2024-01-01T00:00:00Z", "weekly_active_user_count": 0, "weekly_adoption_rate": 0, "chat_cowork_unified_daily_active_user_count": 0, "chat_cowork_unified_monthly_active_user_count": 0, "chat_cowork_unified_weekly_active_user_count": 0, "chat_daily_active_user_count": 0, "chat_monthly_active_user_count": 0, "chat_weekly_active_user_count": 0, "claude_code_daily_active_user_count": 0, "claude_code_monthly_active_user_count": 0, "claude_code_weekly_active_user_count": 0, "claude_design_daily_active_user_count": 0, "claude_design_monthly_active_user_count": 0, "claude_design_weekly_active_user_count": 0, "office_agent_daily_active_user_count": 0, "office_agent_monthly_active_user_count": 0, "office_agent_weekly_active_user_count": 0, "science_daily_active_user_count": 0, "science_entitled_user_count": 0, "science_monthly_active_user_count": 0, "science_weekly_active_user_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.summaries.withRawResponse.list(startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/summaries", json: #"{"data": [{"assigned_seat_count": 0, "cowork_daily_active_user_count": 0, "cowork_monthly_active_user_count": 0, "cowork_weekly_active_user_count": 0, "daily_active_user_count": 0, "daily_adoption_rate": 0, "ending_at": "2024-01-01T00:00:00Z", "monthly_active_user_count": 0, "monthly_adoption_rate": 0, "pending_invite_count": 0, "starting_at": "2024-01-01T00:00:00Z", "weekly_active_user_count": 0, "weekly_adoption_rate": 0, "chat_cowork_unified_daily_active_user_count": 0, "chat_cowork_unified_monthly_active_user_count": 0, "chat_cowork_unified_weekly_active_user_count": 0, "chat_daily_active_user_count": 0, "chat_monthly_active_user_count": 0, "chat_weekly_active_user_count": 0, "claude_code_daily_active_user_count": 0, "claude_code_monthly_active_user_count": 0, "claude_code_weekly_active_user_count": 0, "claude_design_daily_active_user_count": 0, "claude_design_monthly_active_user_count": 0, "claude_design_weekly_active_user_count": 0, "office_agent_daily_active_user_count": 0, "office_agent_monthly_active_user_count": 0, "office_agent_weekly_active_user_count": 0, "science_daily_active_user_count": 0, "science_entitled_user_count": 0, "science_monthly_active_user_count": 0, "science_weekly_active_user_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.summaries.withStreamingResponse.list(startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
