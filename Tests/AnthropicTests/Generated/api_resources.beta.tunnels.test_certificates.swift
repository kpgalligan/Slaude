// Transformed from `tests/api_resources/beta/tunnels/test_certificates.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaTunnelsCertificates {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#, validateBody: { try MockRoute.roundTrip(CertificateCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.create("tunnel_id", caCertificatePem: "ca_certificate_pem", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#, validateBody: { try MockRoute.roundTrip(CertificateCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.create("tunnel_id", caCertificatePem: "ca_certificate_pem", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#, validateBody: { try MockRoute.roundTrip(CertificateCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.tunnels.certificates.withRawResponse.create("tunnel_id", caCertificatePem: "ca_certificate_pem", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#, validateBody: { try MockRoute.roundTrip(CertificateCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.certificates.withStreamingResponse.create("tunnel_id", caCertificatePem: "ca_certificate_pem", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.create("", caCertificatePem: "ca_certificate_pem") }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.retrieve("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.retrieve("certificate_id", tunnelID: "tunnel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.certificates.withRawResponse.retrieve("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.certificates.withStreamingResponse.retrieve("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.retrieve("certificate_id", tunnelID: "") }
        try await expectValueError("Expected a non-empty value for `certificate_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.retrieve("", tunnelID: "tunnel_id") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.list("tunnel_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.list("tunnel_id", includeArchived: true, limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.certificates.withRawResponse.list("tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}/certificates", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.certificates.withStreamingResponse.list("tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.list("") }
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.archive("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.certificates.archive("certificate_id", tunnelID: "tunnel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.certificates.withRawResponse.archive("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/certificates/{certificate_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "expires_at": "2024-01-01T00:00:00Z", "fingerprint": "string", "tunnel_id": "string", "type": "tunnel_certificate"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.certificates.withStreamingResponse.archive("certificate_id", tunnelID: "tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.archive("certificate_id", tunnelID: "") }
        try await expectValueError("Expected a non-empty value for `certificate_id` but received ''") { _ = try await client.beta.tunnels.certificates.withRawResponse.archive("", tunnelID: "tunnel_id") }
    }
}
