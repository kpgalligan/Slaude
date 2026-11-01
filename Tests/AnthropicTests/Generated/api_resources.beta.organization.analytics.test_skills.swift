// Transformed from `tests/api_resources/beta/organization/analytics/test_skills.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsSkills {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/skills", json: #"{"data": [{"chat_metrics": {"distinct_conversation_skill_used_count": 0}, "claude_code_metrics": {"distinct_session_skill_used_count": 0}, "cowork_metrics": {"distinct_session_skill_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "skill_name": "string", "attributed_list_price": "string", "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "currency": "string", "enable_count": 0, "estimated_overage_spend": "string", "invocation_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "share_status": "organization", "skill_display_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.skills.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/skills", json: #"{"data": [{"chat_metrics": {"distinct_conversation_skill_used_count": 0}, "claude_code_metrics": {"distinct_session_skill_used_count": 0}, "cowork_metrics": {"distinct_session_skill_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "skill_name": "string", "attributed_list_price": "string", "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "currency": "string", "enable_count": 0, "estimated_overage_spend": "string", "invocation_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "share_status": "organization", "skill_display_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.skills.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), endingDate: .date(ISODate(year: 2019, month: 12, day: 27)), filter: ["string"], groupBy: ["product"], limit: 1, order: "asc", orderBy: "order_by", page: "page", startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/skills", json: #"{"data": [{"chat_metrics": {"distinct_conversation_skill_used_count": 0}, "claude_code_metrics": {"distinct_session_skill_used_count": 0}, "cowork_metrics": {"distinct_session_skill_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "skill_name": "string", "attributed_list_price": "string", "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "currency": "string", "enable_count": 0, "estimated_overage_spend": "string", "invocation_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "share_status": "organization", "skill_display_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.skills.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/skills", json: #"{"data": [{"chat_metrics": {"distinct_conversation_skill_used_count": 0}, "claude_code_metrics": {"distinct_session_skill_used_count": 0}, "cowork_metrics": {"distinct_session_skill_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "skill_name": "string", "attributed_list_price": "string", "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "currency": "string", "enable_count": 0, "estimated_overage_spend": "string", "invocation_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "share_status": "organization", "skill_display_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.skills.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
