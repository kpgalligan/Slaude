// Transformed from `tests/api_resources/organization/test_external_keys.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestOrganizationExternalKeys {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.externalKeys.create(providerConfig: ExternalKeyCreateParams.ProviderConfig.aws(AWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")))
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.externalKeys.create(providerConfig: ExternalKeyCreateParams.ProviderConfig.aws(AWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws", region: "us-east-1")), displayName: "x", geo: "us")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.create(providerConfig: ExternalKeyCreateParams.ProviderConfig.aws(AWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.create(providerConfig: ExternalKeyCreateParams.ProviderConfig.aws(AWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws")), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.organization.externalKeys.retrieve("external_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.retrieve("external_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.retrieve("external_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.organization.externalKeys.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.externalKeys.update("external_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.organization.externalKeys.update("external_key_id", displayName: "x", geo: "us", providerConfig: ExternalKeyUpdateParams.ProviderConfig.aws(AWSExternalKeyConfigParam(kmsArn: "arn:aws:kms:us-east-1:111122223333:key/abcd1234-5678-90ab-cdef-000011112222", type: "aws", region: "us-east-1")))
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.update("external_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ExternalKeyUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.update("external_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.organization.externalKeys.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.externalKeys.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.organization.externalKeys.list(limit: 1, page: "page")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/external_keys", json: #"{"data": [{"id": "string", "attachment": {"type": "attached"}, "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "geo": "string", "provider_config": {"kms_arn": "string", "type": "aws", "region": "string"}, "type": "external_key", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.list(body: { response in
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
        let value = try await client.organization.externalKeys.delete("external_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "type": "external_key_deleted"}"#)
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.delete("external_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/organizations/external_keys/{external_key_id}", json: #"{"id": "string", "type": "external_key_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.delete("external_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.organization.externalKeys.withRawResponse.delete("") }
    }

    @Test func methodValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let value = try await client.organization.externalKeys.validate("external_key_id")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let response = try await client.organization.externalKeys.withRawResponse.validate("external_key_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/external_keys/{external_key_id}/validate", json: #"{"error": "string", "status": "failure", "type": "external_key_validation"}"#)
        let client = try route.client()
        let (response, value) = try await client.organization.externalKeys.withStreamingResponse.validate("external_key_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsValidate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `external_key_id` but received ''") { _ = try await client.organization.externalKeys.withRawResponse.validate("") }
    }
}
