// Transformed from `tests/api_resources/beta/memory_stores/test_memories.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaMemoryStoresMemories {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#, validateBody: { try MockRoute.roundTrip(MemoryCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.create("memory_store_id", content: "content", path: "xx", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#, validateBody: { try MockRoute.roundTrip(MemoryCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.create("memory_store_id", content: "content", path: "xx", view: BetaManagedAgentsMemoryView(rawValue: "basic"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#, validateBody: { try MockRoute.roundTrip(MemoryCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.memoryStores.memories.withRawResponse.create("memory_store_id", content: "content", path: "xx", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#, validateBody: { try MockRoute.roundTrip(MemoryCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memories.withStreamingResponse.create("memory_store_id", content: "content", path: "xx", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCreate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.create("", content: "content", path: "xx") }
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.retrieve("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.retrieve("memory_id", memoryStoreID: "memory_store_id", view: BetaManagedAgentsMemoryView(rawValue: "basic"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memories.withRawResponse.retrieve("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memories.withStreamingResponse.retrieve("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.retrieve("memory_id", memoryStoreID: "") }
        try await expectValueError("Expected a non-empty value for `memory_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.retrieve("", memoryStoreID: "memory_store_id") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.update("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.update("memory_id", memoryStoreID: "memory_store_id", view: BetaManagedAgentsMemoryView(rawValue: "basic"), content: "content", path: "xx", precondition: BetaManagedAgentsPreconditionParam(type: "content_sha256", contentSha256: "content_sha256"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memories.withRawResponse.update("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memories.withStreamingResponse.update("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.update("memory_id", memoryStoreID: "") }
        try await expectValueError("Expected a non-empty value for `memory_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.update("", memoryStoreID: "memory_store_id") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"data": [{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.list("memory_store_id", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"data": [{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.list("memory_store_id", depth: 0, limit: 0, page: "page", pathPrefix: "path_prefix", view: BetaManagedAgentsMemoryView(rawValue: "basic"), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"data": [{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memories.withRawResponse.list("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}/memories", json: #"{"data": [{"id": "string", "content_sha256": "string", "content_size_bytes": 0, "created_at": "2024-01-01T00:00:00Z", "memory_store_id": "string", "memory_version_id": "string", "path": "string", "type": "memory", "updated_at": "2024-01-01T00:00:00Z", "content": "string"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memories.withStreamingResponse.list("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.list("") }
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "type": "memory_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.delete("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "type": "memory_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.memories.delete("memory_id", memoryStoreID: "memory_store_id", expectedContentSha256: "expected_content_sha256", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "type": "memory_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.memories.withRawResponse.delete("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}/memories/{memory_id}", json: #"{"id": "string", "type": "memory_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.memories.withStreamingResponse.delete("memory_id", memoryStoreID: "memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.delete("memory_id", memoryStoreID: "") }
        try await expectValueError("Expected a non-empty value for `memory_id` but received ''") { _ = try await client.beta.memoryStores.memories.withRawResponse.delete("", memoryStoreID: "memory_store_id") }
    }
}
