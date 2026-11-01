// Transformed from `tests/api_resources/beta/memory_stores/test_memory_versions.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaMemoryStoresMemoryVersions {
    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.retrieve("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.retrieve("memory_version_id", memoryStoreID: "memory_store_id", view: BetaManagedAgentsMemoryView(rawValue: "basic"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memoryVersions.withRawResponse.retrieve("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memoryVersions.withStreamingResponse.retrieve("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memoryVersions.withRawResponse.retrieve("memory_version_id", memoryStoreID: "") }
        try await expectValueError("Expected a non-empty value for `memory_version_id` but received ''") { _ = try await client.beta.memoryStores.memoryVersions.withRawResponse.retrieve("", memoryStoreID: "memory_store_id") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.list("memory_store_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.list("memory_store_id", apiKeyID: "api_key_id", createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), limit: 0, memoryID: "memory_id", operation: BetaManagedAgentsMemoryVersionOperation(rawValue: "created"), page: "page", serviceAccountID: "service_account_id", sessionID: "session_id", view: BetaManagedAgentsMemoryView(rawValue: "basic"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memoryVersions.withRawResponse.list("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memory_versions", json: #"{"data": [{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memoryVersions.withStreamingResponse.list("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memoryVersions.withRawResponse.list("") }
    }

    @Test func methodRedact() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}/redact", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.redact("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRedactWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}/redact", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memoryVersions.redact("memory_version_id", memoryStoreID: "memory_store_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRedact() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}/redact", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memoryVersions.withRawResponse.redact("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRedact() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memory_versions/{memory_version_id}/redact", json: #"{"id": "string", "created_at": "2024-01-01T00:00:00Z", "memory_id": "string", "memory_store_id": "string", "operation": "created", "type": "memory_version", "content": "string", "content_sha256": "string", "content_size_bytes": 0, "created_by": {"session_id": "string", "type": "session_actor"}, "path": "string", "redacted_at": "2024-01-01T00:00:00Z", "redacted_by": {"session_id": "string", "type": "session_actor"}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memoryVersions.withStreamingResponse.redact("memory_version_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRedact() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memoryVersions.withRawResponse.redact("memory_version_id", memoryStoreID: "") }
        try await expectValueError("Expected a non-empty value for `memory_version_id` but received ''") { _ = try await client.beta.memoryStores.memoryVersions.withRawResponse.redact("", memoryStoreID: "memory_store_id") }
    }
}
