// Transformed from `tests/api_resources/beta/sessions/threads/test_events.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSessionsThreadsEvents {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.events.list("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.threads.events.list("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", limit: 0, page: "page", betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.threads.events.withRawResponse.list("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.threads.events.withStreamingResponse.list("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.threads.events.withRawResponse.list("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `thread_id` but received ''") { _ = try await client.beta.sessions.threads.events.withRawResponse.list("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }

    @Test func methodStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let value = try await client.beta.sessions.threads.events.stream("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try await route.drain(value)
    }

    @Test func methodStreamWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let value = try await client.beta.sessions.threads.events.stream("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", eventDeltas: [BetaManagedAgentsDeltaType(rawValue: "agent.message")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try await route.drain(value)
    }

    @Test func rawResponseStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let response = try await client.beta.sessions.threads.events.withRawResponse.stream("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try await route.drain(value)
    }

    @Test func streamingResponseStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/threads/{thread_id}/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.threads.events.withStreamingResponse.stream("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try await route.drain(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsStream() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.threads.events.withRawResponse.stream("sthr_011CZkZVWa6oJjw1rgXZpnBt", sessionID: "") }
        try await expectValueError("Expected a non-empty value for `thread_id` but received ''") { _ = try await client.beta.sessions.threads.events.withRawResponse.stream("", sessionID: "sesn_011CZkZAtmR3yMPDzynEDxu7") }
    }
}
