// Transformed from `tests/api_resources/test_files.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestFiles {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.files.list()
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.files.list(ids: ["string"], limit: 1, page: "page", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.files.withRawResponse.list()
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.files.withStreamingResponse.list(body: { response in
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
        let value = try await client.files.delete("file_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let value = try await client.files.delete("file_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let response = try await client.files.withRawResponse.delete("file_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/files/{file_id}", json: #"{"id": "string", "type": "file_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.files.withStreamingResponse.delete("file_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `file_id` but received ''") { _ = try await client.files.withRawResponse.delete("") }
    }

    @Test func methodRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.files.retrieveMetadata("file_id")
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveMetadataWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.files.retrieveMetadata("file_id", workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.files.withRawResponse.retrieveMetadata("file_id")
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieveMetadata() async throws {
        let route = MockRoute(method: "GET", path: "/v1/files/{file_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.files.withStreamingResponse.retrieveMetadata("file_id", body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieveMetadata() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `file_id` but received ''") { _ = try await client.files.withRawResponse.retrieveMetadata("") }
    }

    @Test func methodUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.files.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"))
        try route.verifyRoundTrip(value)
    }

    @Test func methodUploadWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.files.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), expiresInSeconds: 3600, workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy")
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.files.withRawResponse.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"))
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpload() async throws {
        let route = MockRoute(method: "POST", path: "/v1/files", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "filename": "string", "mime_type": "string", "size_bytes": 0, "type": "file", "downloadable": true, "expires_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.files.withStreamingResponse.upload(file: FileUpload(data: Data("Example data".utf8), filename: "upload"), body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }
}
