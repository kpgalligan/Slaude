// Transformed from `tests/api_resources/beta/test_memory_stores.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaMemoryStores {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.create(name: "x", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.create(name: "x", description: "description", metadata: ["foo": "string"], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.create(name: "x", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.create(name: "x", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.retrieve("memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.retrieve("memory_store_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.retrieve("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.retrieve("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.withRawResponse.retrieve("") }
    }

    @Test func methodUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.update("memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodUpdateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreUpdateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.memoryStores.update("memory_store_id", description: "description", metadata: ["foo": "string"], name: "x", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreUpdateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.update("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseUpdate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#, validateBody: { try MockRoute.roundTrip(MemoryStoreUpdateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.update("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsUpdate() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.withRawResponse.update("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.list(createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), includeArchived: true, limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/memory_stores", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "type": "memory_store_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.delete("memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodDeleteWithAllParams() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "type": "memory_store_deleted"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.delete("memory_store_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "type": "memory_store_deleted"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.delete("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseDelete() async throws {
        let route = MockRoute(method: "DELETE", path: "/v1/memory_stores/{memory_store_id}", json: #"{"id": "string", "type": "memory_store_deleted"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.delete("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsDelete() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.withRawResponse.delete("") }
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.archive("memory_store_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let value = try await client.beta.memoryStores.archive("memory_store_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let response = try await client.beta.memoryStores.withRawResponse.archive("memory_store_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/memory_stores/{memory_store_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "description": "string", "metadata": {"key": "string"}, "name": "string", "type": "memory_store", "updated_at": "2024-01-01T00:00:00Z"}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.memoryStores.withStreamingResponse.archive("memory_store_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `memory_store_id` but received ''") { _ = try await client.beta.memoryStores.withRawResponse.archive("") }
    }
}
