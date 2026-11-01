// Transformed from `tests/api_resources/beta/user_profiles/test_action_urls.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaUserProfilesActionURLs {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/action_urls", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "user_profile_action_url", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfilesActionURLCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.actionURLs.create("uprof_011CZkZCu8hGbp5mYRQgUmz9", action: BetaUserProfileEnrollEndUserActionParam(type: "enroll_end_user"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/action_urls", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "user_profile_action_url", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfilesActionURLCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.actionURLs.create("uprof_011CZkZCu8hGbp5mYRQgUmz9", action: BetaUserProfileEnrollEndUserActionParam(type: "enroll_end_user"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/action_urls", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "user_profile_action_url", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfilesActionURLCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.userProfiles.actionURLs.withRawResponse.create("uprof_011CZkZCu8hGbp5mYRQgUmz9", action: BetaUserProfileEnrollEndUserActionParam(type: "enroll_end_user"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/action_urls", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "user_profile_action_url", "url": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfilesActionURLCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.actionURLs.withStreamingResponse.create("uprof_011CZkZCu8hGbp5mYRQgUmz9", action: BetaUserProfileEnrollEndUserActionParam(type: "enroll_end_user"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.beta.userProfiles.actionURLs.withRawResponse.create("", action: BetaUserProfileEnrollEndUserActionParam(type: "enroll_end_user")) }
    }
}
