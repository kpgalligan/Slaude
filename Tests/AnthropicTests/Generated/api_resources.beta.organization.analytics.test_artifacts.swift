// Transformed from `tests/api_resources/beta/organization/analytics/test_artifacts.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationAnalyticsArtifacts {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/artifacts", json: #"{"data": [{"artifact_type": "string", "artifacts_created_count": 0, "distinct_user_count": 0, "is_shared": true, "published_artifacts_created_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.artifacts.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/artifacts", json: #"{"data": [{"artifact_type": "string", "artifacts_created_count": 0, "distinct_user_count": 0, "is_shared": true, "published_artifacts_created_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.analytics.artifacts.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), filter: ["string"], groupBy: ["product"], limit: 1, page: "page", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/artifacts", json: #"{"data": [{"artifact_type": "string", "artifacts_created_count": 0, "distinct_user_count": 0, "is_shared": true, "published_artifacts_created_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.analytics.artifacts.withRawResponse.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/analytics/artifacts", json: #"{"data": [{"artifact_type": "string", "artifacts_created_count": 0, "distinct_user_count": 0, "is_shared": true, "published_artifacts_created_count": 0, "product": "string", "rbac_group_id": "string", "rbac_group_name": "string", "user_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.analytics.artifacts.withStreamingResponse.list(date: .date(ISODate(year: 2019, month: 12, day: 27)), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }
}
