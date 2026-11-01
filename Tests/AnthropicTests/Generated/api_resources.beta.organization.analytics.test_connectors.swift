// Transformed from `tests/api_resources/beta/organization/analytics/test_connectors.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsConnectors {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/connectors", json: #"{"data": [{"chat_metrics": {"distinct_conversation_connector_used_count": 0}, "claude_code_metrics": {"distinct_session_connector_used_count": 0}, "connector_name": "string", "cowork_metrics": {"distinct_session_connector_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "connector_display_name": "string", "individual_auth_distinct_user_count": 0, "managed_auth_distinct_user_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "read_call_count": 0, "unclassified_call_count": 0, "user_id": "string", "write_call_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.connectors.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/connectors", json: #"{"data": [{"chat_metrics": {"distinct_conversation_connector_used_count": 0}, "claude_code_metrics": {"distinct_session_connector_used_count": 0}, "connector_name": "string", "cowork_metrics": {"distinct_session_connector_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "connector_display_name": "string", "individual_auth_distinct_user_count": 0, "managed_auth_distinct_user_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "read_call_count": 0, "unclassified_call_count": 0, "user_id": "string", "write_call_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.connectors.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), endingDate: .date(ISODate(year: 2019, month: 12, day: 27)), filter: ["string"], groupBy: ["product"], limit: 1, order: "asc", orderBy: "order_by", page: "page", startingDate: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/connectors", json: #"{"data": [{"chat_metrics": {"distinct_conversation_connector_used_count": 0}, "claude_code_metrics": {"distinct_session_connector_used_count": 0}, "connector_name": "string", "cowork_metrics": {"distinct_session_connector_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "connector_display_name": "string", "individual_auth_distinct_user_count": 0, "managed_auth_distinct_user_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "read_call_count": 0, "unclassified_call_count": 0, "user_id": "string", "write_call_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.connectors.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/connectors", json: #"{"data": [{"chat_metrics": {"distinct_conversation_connector_used_count": 0}, "claude_code_metrics": {"distinct_session_connector_used_count": 0}, "connector_name": "string", "cowork_metrics": {"distinct_session_connector_used_count": 0}, "distinct_user_count": 0, "office_metrics": {"excel": {}, "outlook": {}, "powerpoint": {}, "word": {}}, "chat_cowork_unified_metrics": {"chat": {}, "sessions": {}}, "connector_display_name": "string", "individual_auth_distinct_user_count": 0, "managed_auth_distinct_user_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "read_call_count": 0, "unclassified_call_count": 0, "user_id": "string", "write_call_count": 0}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.connectors.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
