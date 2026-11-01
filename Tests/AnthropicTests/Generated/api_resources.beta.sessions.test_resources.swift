// Transformed from `tests/api_resources/beta/sessions/test_resources.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSessionsResources {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.retrieve("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.retrieve("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.resources.withRawResponse.retrieve("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.resources.withStreamingResponse.retrieve("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.retrieve("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `resource_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.retrieve("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.update("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", authorizationToken: "ghp_exampletoken", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.update("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", authorizationToken: "ghp_exampletoken", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.resources.withRawResponse.update("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", authorizationToken: "ghp_exampletoken", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.resources.withStreamingResponse.update("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", authorizationToken: "ghp_exampletoken", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.update("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "", authorizationToken: "ghp_exampletoken") }
        try await expectValueError("Expected a non-empty value for `resource_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.update("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", authorizationToken: "ghp_exampletoken") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.list("sesn_011CZkZAtmR3yMPDzynEDxu7", limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.resources.withRawResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/resources", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "mount_path": "string", "type": "github_repository", "updated_at": "2024-01-01T00:00:00Z", "url": "string", "checkout": {"name": "string", "type": "branch"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.resources.withStreamingResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.list("") }
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "type": "session_resource_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.delete("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "type": "session_resource_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.resources.delete("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "type": "session_resource_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.resources.withRawResponse.delete("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/sessions/{session_id}/resources/{resource_id}", json: #"{"id": "string", "type": "session_resource_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.resources.withStreamingResponse.delete("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.delete("sesrsc_011CZkZBJq5dWxk9fVLNcPht", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `resource_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.delete("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }

    @Test func methodAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "file_id": "string", "mount_path": "string", "type": "file", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ResourceAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.sessions.resources.add("sesn_011CZkZAtmR3yMPDzynEDxu7", fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodAddWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "file_id": "string", "mount_path": "string", "type": "file", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ResourceAddParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.sessions.resources.add("sesn_011CZkZAtmR3yMPDzynEDxu7", fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", mountPath: "/uploads/receipt.pdf", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "file_id": "string", "mount_path": "string", "type": "file", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ResourceAddParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.sessions.resources.withRawResponse.add("sesn_011CZkZAtmR3yMPDzynEDxu7", fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseAdd() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/resources", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "file_id": "string", "mount_path": "string", "type": "file", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(ResourceAddParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.resources.withStreamingResponse.add("sesn_011CZkZAtmR3yMPDzynEDxu7", fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsAdd() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.resources.withRawResponse.add("", fileID: "file_011CNha8iCJcU1wXNR6q4V8w", type: "file") }
    }
}
