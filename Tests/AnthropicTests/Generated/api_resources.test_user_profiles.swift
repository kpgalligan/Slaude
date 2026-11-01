// Transformed from `tests/api_resources/test_user_profiles.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestUserProfiles {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.userProfiles.create()
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.userProfiles.create(accessType: UserProfileAccessType(rawValue: "application"), externalUserDetails: UserProfileExternalUserDetailsParams(accountStatus: UserProfileExternalUserAccountStatus(rawValue: "active"), country: "US", emailHash: "x", entityType: UserProfileExternalUserEntityType(rawValue: "business"), nameHash: "x", onboardedAt: .date(AnthropicJSON.parseISO8601("2024-11-02T08:15:00Z")!), referenceID: "user_12345"), metadata: [:], name: "Example User", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.userProfiles.withRawResponse.create()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.userProfiles.withStreamingResponse.create(body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.userProfiles.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.userProfiles.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.userProfiles.withRawResponse.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.userProfiles.withStreamingResponse.retrieve("uprof_011CZkZCu8hGbp5mYRQgUmz9", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.userProfiles.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.userProfiles.update("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.userProfiles.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", accessType: UserProfileAccessType(rawValue: "application"), externalUserDetails: UserProfileExternalUserDetailsParams(accountStatus: UserProfileExternalUserAccountStatus(rawValue: "suspended"), country: "country", emailHash: "x", entityType: UserProfileExternalUserEntityType(rawValue: "individual"), nameHash: "x", onboardedAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), referenceID: "x"), metadata: ["foo": "string"], name: "x", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.userProfiles.withRawResponse.update("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(UserProfileUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.userProfiles.withStreamingResponse.update("uprof_011CZkZCu8hGbp5mYRQgUmz9", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.userProfiles.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.userProfiles.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.userProfiles.list(enforcementStatus: [UserProfileEnforcementStatus(rawValue: "unrestricted")], limit: 0, order: UserProfileListOrder(rawValue: "asc"), orderBy: UserProfileListOrderBy(rawValue: "created_at"), page: "page", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.userProfiles.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/user_profiles", json: #"{"data": [{"id": "string", "access_type": "application", "created_at": "2024-01-01T00:00:00Z", "enforcement_actions": [{"id": "string", "opened_at": "2024-01-01T00:00:00Z", "reason": "unsupported_region", "type": "restriction"}], "enforcement_status": "unrestricted", "external_user_details": {"account_status": "active", "country": "string", "email_hash": "string", "entity_type": "individual", "name_hash": "string", "onboarded_at": "2024-01-01T00:00:00Z", "reference_id": "string"}, "metadata": {"key": "string"}, "name": "string", "programs": {"cyber": {"status": "active", "tiers": {"key": {"status": "active"}}}, "efs": {"features": {"key": {"status": "active"}}, "status": "active"}}, "type": "user_profile", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.userProfiles.withStreamingResponse.list(body: { response in
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
        let value = try await client.userProfiles.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let value = try await client.userProfiles.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let response = try await client.userProfiles.withRawResponse.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/user_profiles/{user_profile_id}", json: #"{"id": "string", "type": "user_profile_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.userProfiles.withStreamingResponse.delete("uprof_011CZkZCu8hGbp5mYRQgUmz9", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `user_profile_id` but received ''") { _ = try await client.userProfiles.withRawResponse.delete("") }
    }
}
