// Transformed from `tests/api_resources/beta/test_files.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaFiles {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.files.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.files.list(ids: ["string"], limit: 1, page: "page", scopeID: "scope_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.files.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.files.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.files.delete("file_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.files.delete("file_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.files.withRawResponse.delete("file_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.files.withStreamingResponse.delete("file_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `file_id` but received ''") { _ = try await client.beta.files.withRawResponse.delete("") }
    }

    @Test func methodRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let value = try await client.beta.files.retrieveMetadata("file_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveMetadataWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let value = try await client.beta.files.retrieveMetadata("file_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let response = try await client.beta.files.withRawResponse.retrieveMetadata("file_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.files.withStreamingResponse.retrieveMetadata("file_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieveMetadata() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `file_id` but received ''") { _ = try await client.beta.files.withRawResponse.retrieveMetadata("") }
    }

    @Test func methodUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let value = try await client.beta.files.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUploadWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let value = try await client.beta.files.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), expiresInSeconds: 3600, betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let response = try await client.beta.files.withRawResponse.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z", "scope": {"id": "string", "type": "session"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.files.withStreamingResponse.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
