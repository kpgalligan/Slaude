// Transformed from `tests/api_resources/beta/test_user_profiles.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaUserProfiles {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.create(extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.create(accessType: "application", externalID: "x", externalUserDetails: BetaUserProfileExternalUserDetailsParams(accountStatus: "active", country: "US", emailHash: "x", entityType: "business", nameHash: "x", onboardedAt: .date(AnthropicJSON.parseISO8601("2024-11-02T08:15:00Z")!), referenceID: "user_12345"), externalUserOnboardedAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), metadata: [:], name: "Example User", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.create(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.create(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.beta.userProfiles.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.userProfiles.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", accessType: "application", externalID: "x", externalUserDetails: BetaUserProfileExternalUserDetailsParams(accountStatus: "suspended", country: "country", emailHash: "x", entityType: "individual", nameHash: "x", onboardedAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), referenceID: "x"), externalUserOnboardedAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), metadata: ["foo": "string"], name: "x", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaUserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.beta.userProfiles.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.list(limit: 0, order: "asc", orderBy: "created_at", page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "name": "string", "trust_grants": {"key": {"status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z", "access_type": "application", "external_id": "string", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "external_user_onboarded_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.beta.userProfiles.withRawResponse.delete("") }
    }

    @Test func methodCreateEnrollmentURL() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/enrollment_url", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "enrollment_url", "url": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.createEnrollmentURL("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateEnrollmentURLWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/enrollment_url", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "enrollment_url", "url": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.userProfiles.createEnrollmentURL("uprof_011CZkZCu8hGbp5mYRQgUmz9", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreateEnrollmentURL() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/enrollment_url", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "enrollment_url", "url": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.userProfiles.withRawResponse.createEnrollmentURL("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreateEnrollmentURL() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}/enrollment_url", json: #"{"expires_at": "2024-01-01T00:00:00Z", "type": "enrollment_url", "url": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.userProfiles.withStreamingResponse.createEnrollmentURL("uprof_011CZkZCu8hGbp5mYRQgUmz9", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreateEnrollmentURL() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.beta.userProfiles.withRawResponse.createEnrollmentURL("") }
    }
}
