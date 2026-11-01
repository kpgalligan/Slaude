// Transformed from `tests/api_resources/beta/organization/federation/test_issuers.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaOrganizationFederationIssuers {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.create(issuerURL: "x", name: "x", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.create(issuerURL: "x", name: "x", checkJti: true, jwks: BetaOrganizationFederationIssuerCreateParams.JWKS.discovery(BetaJWKSDiscoveryParam(type: "discovery", caCertPem: "ca_cert_pem", discoveryBase: "discovery_base")), maxJwtLifetimeSeconds: 1, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.federation.issuers.withRawResponse.create(issuerURL: "x", name: "x", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.issuers.withStreamingResponse.create(issuerURL: "x", name: "x", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.retrieve("federation_issuer_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.retrieve("federation_issuer_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.issuers.withRawResponse.retrieve("federation_issuer_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.issuers.withStreamingResponse.retrieve("federation_issuer_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_issuer_id` but received ''") { _ = try await client.beta.organization.federation.issuers.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.update("federation_issuer_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.update("federation_issuer_id", checkJti: true, issuerURL: "x", jwks: BetaOrganizationFederationIssuerUpdateParams.JWKS.discovery(BetaJWKSDiscoveryParam(type: "discovery", caCertPem: "ca_cert_pem", discoveryBase: "discovery_base")), jwksPollingDisabled: true, maxJwtLifetimeSeconds: 1, name: "x", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.organization.federation.issuers.withRawResponse.update("federation_issuer_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#, validateBody: { try MockRoute.roundTrip(BetaOrganizationFederationIssuerUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.issuers.withStreamingResponse.update("federation_issuer_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_issuer_id` but received ''") { _ = try await client.beta.organization.federation.issuers.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.list(includeArchived: true, limit: 1, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.issuers.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/organizations/federation_issuers", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.issuers.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.archive("federation_issuer_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.organization.federation.issuers.archive("federation_issuer_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.organization.federation.issuers.withRawResponse.archive("federation_issuer_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/organizations/federation_issuers/{federation_issuer_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "archived_by_actor_id": "string", "check_jti": true, "created_at": "2024-01-01T00:00:00Z", "created_by_actor_id": "string", "issuer_url": "string", "jwks": {"type": "discovery", "ca_cert_pem": "string", "discovery_base": "string"}, "jwks_polling_disabled_at": "2024-01-01T00:00:00Z", "max_jwt_lifetime_seconds": 0, "name": "string", "poll_status": {"consecutive_failures": 0, "last_fetched_at": "2024-01-01T00:00:00Z", "next_poll_at": "2024-01-01T00:00:00Z"}, "type": "federation_issuer", "updated_at": "2024-01-01T00:00:00Z", "updated_by_actor_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.organization.federation.issuers.withStreamingResponse.archive("federation_issuer_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `federation_issuer_id` but received ''") { _ = try await client.beta.organization.federation.issuers.withRawResponse.archive("") }
    }
}
