// Transformed from `tests/api_resources/beta/organization/test_external_keys.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationExternalKeys {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig.aws(BetaAWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig.aws(BetaAWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws", region: "us-east-1", roleArn: "arn:aws:iam::111122223333:role/anthropic-cmek")), displayName: "x", geo: "us", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig.aws(BetaAWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.create(providerConfig: BetaOrganizationExternalKeyCreateParams.ProviderConfig.aws(BetaAWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.retrieve("external_key_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.retrieve("external_key_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.retrieve("external_key_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.beta.organization.externalKeys.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.update("external_key_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.update("external_key_id", displayName: "x", geo: "us", providerConfig: BetaOrganizationExternalKeyUpdateParams.ProviderConfig.aws(BetaAWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws", region: "us-east-1", roleArn: "arn:aws:iam::111122223333:role/anthropic-cmek")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.update("external_key_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.update("external_key_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.beta.organization.externalKeys.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.list(limit: 1, page: "page", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string", "role_arn": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "type": "external_key_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.delete("external_key_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "type": "external_key_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.delete("external_key_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "type": "external_key_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.delete("external_key_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.beta.organization.externalKeys.withRawResponse.delete("") }
    }

    @Test func methodValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.externalKeys.validate("external_key_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.externalKeys.withRawResponse.validate("external_key_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.externalKeys.withStreamingResponse.validate("external_key_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsValidate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.beta.organization.externalKeys.withRawResponse.validate("") }
    }
}
