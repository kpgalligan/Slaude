// Transformed from `tests/api_resources/beta/test_tunnels.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaTunnels {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#, validateBody: { try MockRoute.roundTrip(TunnelCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.create(extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#, validateBody: { try MockRoute.roundTrip(TunnelCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.create(displayName: "x", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#, validateBody: { try MockRoute.roundTrip(TunnelCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.create(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#, validateBody: { try MockRoute.roundTrip(TunnelCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.create(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.retrieve("tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.retrieve("tunnel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.retrieve("tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels/{tunnel_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.retrieve("tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.list(includeArchived: true, limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/tunnels", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.archive("tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.archive("tunnel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.archive("tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "display_name": "string", "domain": "string", "type": "tunnel"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.archive("tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.withRawResponse.archive("") }
    }

    @Test func methodRevealToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/reveal_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.revealToken("tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRevealTokenWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/reveal_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#)
        let client = try route.client()
        let value = try await client.beta.tunnels.revealToken("tunnel_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRevealToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/reveal_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#)
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.revealToken("tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRevealToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/reveal_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.revealToken("tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRevealToken() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.withRawResponse.revealToken("") }
    }

    @Test func methodRotateToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/rotate_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#, validateBody: { try MockRoute.roundTrip(TunnelRotateTokenParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.rotateToken("tunnel_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRotateTokenWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/rotate_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#, validateBody: { try MockRoute.roundTrip(TunnelRotateTokenParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.tunnels.rotateToken("tunnel_id", reason: "reason", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRotateToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/rotate_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#, validateBody: { try MockRoute.roundTrip(TunnelRotateTokenParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.tunnels.withRawResponse.rotateToken("tunnel_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRotateToken() async throws {
        let route = MockRoute(method: "POST", path: "/v1/tunnels/{tunnel_id}/rotate_token", json: #"{"id": "string", "tunnel_token": "string", "type": "tunnel_token"}"#, validateBody: { try MockRoute.roundTrip(TunnelRotateTokenParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.tunnels.withStreamingResponse.rotateToken("tunnel_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRotateToken() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `tunnel_id` but received ''") { _ = try await client.beta.tunnels.withRawResponse.rotateToken("") }
    }
}
