// Transformed from `tests/api_resources/beta/test_dreams.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaDreams {
    @Test func methodCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#, validateBody: { try MockRoute.roundTrip(DreamCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.dreams.create(inputs: [BetaDreamInputParam.memoryStore(BetaDreamMemoryStoreInputParam(memoryStoreID: "x", type: "memory_store"))], model: DreamCreateParams.Model.string("string"), extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCreateWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#, validateBody: { try MockRoute.roundTrip(DreamCreateParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.dreams.create(inputs: [BetaDreamInputParam.memoryStore(BetaDreamMemoryStoreInputParam(memoryStoreID: "x", type: "memory_store"))], model: DreamCreateParams.Model.string("string"), instructions: "x", outputBehavior: BetaOutputBehaviorParam.createNew(BetaOutputBehaviorCreateNewParam(type: "create_new")), betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#, validateBody: { try MockRoute.roundTrip(DreamCreateParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.dreams.withRawResponse.create(inputs: [BetaDreamInputParam.memoryStore(BetaDreamMemoryStoreInputParam(memoryStoreID: "x", type: "memory_store"))], model: DreamCreateParams.Model.string("string"), extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCreate() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#, validateBody: { try MockRoute.roundTrip(DreamCreateParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.dreams.withStreamingResponse.create(inputs: [BetaDreamInputParam.memoryStore(BetaDreamMemoryStoreInputParam(memoryStoreID: "x", type: "memory_store"))], model: DreamCreateParams.Model.string("string"), extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func methodRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams/{dream_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.retrieve("dream_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodRetrieveWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams/{dream_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.retrieve("dream_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams/{dream_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let response = try await client.beta.dreams.withRawResponse.retrieve("dream_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseRetrieve() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams/{dream_id}", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.dreams.withStreamingResponse.retrieve("dream_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsRetrieve() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `dream_id` but received ''") { _ = try await client.beta.dreams.withRawResponse.retrieve("") }
    }

    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.list(extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.list(createdAtGt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), includeArchived: true, limit: 0, page: "page", statuses: [BetaDreamStatus(rawValue: "pending")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.dreams.withRawResponse.list(extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/dreams", json: #"{"data": [{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.dreams.withStreamingResponse.list(extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func methodArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.archive("dream_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodArchiveWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.archive("dream_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let response = try await client.beta.dreams.withRawResponse.archive("dream_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseArchive() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/archive", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.dreams.withStreamingResponse.archive("dream_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsArchive() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `dream_id` but received ''") { _ = try await client.beta.dreams.withRawResponse.archive("") }
    }

    @Test func methodCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.cancel("dream_id", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodCancelWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let value = try await client.beta.dreams.cancel("dream_id", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let response = try await client.beta.dreams.withRawResponse.cancel("dream_id", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseCancel() async throws {
        let route = MockRoute(method: "POST", path: "/v1/dreams/{dream_id}/cancel", json: #"{"id": "string", "archived_at": "2024-01-01T00:00:00Z", "created_at": "2024-01-01T00:00:00Z", "ended_at": "2024-01-01T00:00:00Z", "error": {"message": "string", "type": "string"}, "inputs": [{"memory_store_id": "string", "type": "memory_store"}], "instructions": "string", "model": {"id": "string", "speed": "standard"}, "output_behavior": {"type": "create_new"}, "outputs": [{"memory_store_id": "string", "type": "memory_store"}], "session_id": "string", "status": "pending", "type": "dream", "usage": {"cache_creation_input_tokens": 0, "cache_read_input_tokens": 0, "input_tokens": 0, "output_tokens": 0}}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.dreams.withStreamingResponse.cancel("dream_id", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsCancel() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `dream_id` but received ''") { _ = try await client.beta.dreams.withRawResponse.cancel("") }
    }
}
