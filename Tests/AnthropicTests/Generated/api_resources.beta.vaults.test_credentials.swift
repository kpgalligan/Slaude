// Transformed from `tests/api_resources/beta/vaults/test_credentials.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaVaultsCredentials {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#, validateBody: { try MockRoute.roundTrip(CredentialCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.create("vlt_011CZkZDLs7fYzm1hXNPeRjv", auth: CredentialCreateParams.Auth.staticBearer(BetaManagedAgentsStaticBearerCreateParams(token: "bearer_exampletoken", mcpServerURL: "https://example-server.modelcontextprotocol.io/sse", type: "static_bearer")), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#, validateBody: { try MockRoute.roundTrip(CredentialCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.create("vlt_011CZkZDLs7fYzm1hXNPeRjv", auth: CredentialCreateParams.Auth.staticBearer(BetaManagedAgentsStaticBearerCreateParams(token: "bearer_exampletoken", mcpServerURL: "https://example-server.modelcontextprotocol.io/sse", type: "static_bearer")), displayName: "Example credential", metadata: ["environment": "production"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#, validateBody: { try MockRoute.roundTrip(CredentialCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.create("vlt_011CZkZDLs7fYzm1hXNPeRjv", auth: CredentialCreateParams.Auth.staticBearer(BetaManagedAgentsStaticBearerCreateParams(token: "bearer_exampletoken", mcpServerURL: "https://example-server.modelcontextprotocol.io/sse", type: "static_bearer")), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#, validateBody: { try MockRoute.roundTrip(CredentialCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.create("vlt_011CZkZDLs7fYzm1hXNPeRjv", auth: CredentialCreateParams.Auth.staticBearer(BetaManagedAgentsStaticBearerCreateParams(token: "bearer_exampletoken", mcpServerURL: "https://example-server.modelcontextprotocol.io/sse", type: "static_bearer")), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.create("", auth: CredentialCreateParams.Auth.staticBearer(BetaManagedAgentsStaticBearerCreateParams(token: "bearer_exampletoken", mcpServerURL: "https://example-server.modelcontextprotocol.io/sse", type: "static_bearer"))) }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.retrieve("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.retrieve("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.retrieve("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.retrieve("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.retrieve("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "") }
        try await expectValueError("Expected a non-empty value for `credential_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.retrieve("", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.update("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.update("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", auth: CredentialUpdateParams.Auth.mcpOauth(BetaManagedAgentsMCPOAuthUpdateParams(type: "mcp_oauth", accessToken: "x", expiresAt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), refresh: BetaManagedAgentsMCPOAuthRefreshUpdateParams(refreshToken: "x", scope: "scope", tokenEndpointAuth: BetaManagedAgentsMCPOAuthRefreshUpdateParams.TokenEndpointAuth.clientSecretBasic(BetaManagedAgentsTokenEndpointAuthBasicUpdateParam(type: "client_secret_basic", clientSecret: "x"))))), displayName: "Example credential", metadata: ["environment": "production"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.update("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.update("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.update("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "") }
        try await expectValueError("Expected a non-empty value for `credential_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.update("", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.list("vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.list("vlt_011CZkZDLs7fYzm1hXNPeRjv", includeArchived: true, limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.list("vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/vaults/{vault_id}/credentials", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.list("vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.list("") }
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "type": "vault_credential_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.delete("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "type": "vault_credential_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.delete("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "type": "vault_credential_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.delete("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/vaults/{vault_id}/credentials/{credential_id}", json: #"{"id": "string", "type": "vault_credential_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.delete("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.delete("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "") }
        try await expectValueError("Expected a non-empty value for `credential_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.delete("", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv") }
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.archive("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.archive("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.archive("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "auth": {"mcp_server_url": "string", "type": "mcp_oauth", "expires_at": "2024-01-01T00:00:00Z", "refresh": {"client_id": "string", "token_endpoint": "string", "token_endpoint_auth": {"type": "none"}}}, "created_at": "2024-01-01T00:00:00Z", "metadata": {"key": "string"}, "type": "vault_credential", "updated_at": "2024-01-01T00:00:00Z", "vault_id": "string", "display_name": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.archive("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.archive("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "") }
        try await expectValueError("Expected a non-empty value for `credential_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.archive("", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv") }
    }

    @Test func methodMCPOauthValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate", json: #"{"credential_id": "string", "has_refresh_token": true, "mcp_probe": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "method": "string"}, "refresh": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "status": "succeeded"}, "status": "valid", "type": "vault_credential_validation", "validated_at": "2024-01-01T00:00:00Z", "vault_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.mcpOauthValidate("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodMCPOauthValidateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate", json: #"{"credential_id": "string", "has_refresh_token": true, "mcp_probe": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "method": "string"}, "refresh": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "status": "succeeded"}, "status": "valid", "type": "vault_credential_validation", "validated_at": "2024-01-01T00:00:00Z", "vault_id": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.vaults.credentials.mcpOauthValidate("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseMCPOauthValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate", json: #"{"credential_id": "string", "has_refresh_token": true, "mcp_probe": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "method": "string"}, "refresh": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "status": "succeeded"}, "status": "valid", "type": "vault_credential_validation", "validated_at": "2024-01-01T00:00:00Z", "vault_id": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.vaults.credentials.withRawResponse.mcpOauthValidate("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseMCPOauthValidate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/vaults/{vault_id}/credentials/{credential_id}/mcp_oauth_validate", json: #"{"credential_id": "string", "has_refresh_token": true, "mcp_probe": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "method": "string"}, "refresh": {"http_response": {"body": "string", "body_truncated": true, "content_type": "string", "status_code": 0}, "status": "succeeded"}, "status": "valid", "type": "vault_credential_validation", "validated_at": "2024-01-01T00:00:00Z", "vault_id": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.vaults.credentials.withStreamingResponse.mcpOauthValidate("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsMCPOauthValidate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `vault_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.mcpOauthValidate("vcrd_011CZkZEMt8gZan2iYPQfSkw", vaultID: "") }
        try await expectValueError("Expected a non-empty value for `credential_id` but received ''") { _ = try await client.beta.vaults.credentials.withRawResponse.mcpOauthValidate("", vaultID: "vlt_011CZkZDLs7fYzm1hXNPeRjv") }
    }
}
