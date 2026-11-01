// Transformed from `tests/api_resources/beta/sessions/test_events.py`.

import Foundation
import Testing
@testable import Anthropic

@Suite struct TestBetaSessionsEvents {
    @Test func methodList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.events.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func methodListWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let value = try await client.beta.sessions.events.list("sesn_011CZkZAtmR3yMPDzynEDxu7", createdAtGt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtGte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLt: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), createdAtLte: .date(AnthropicJSON.parseISO8601("2019-12-27T18:11:19.117Z")!), limit: 0, order: "asc", page: "page", types: [BetaManagedAgentsSessionEventType(rawValue: "user.message")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        #expect(value.items.count == 1)
    }

    @Test func rawResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let response = try await client.beta.sessions.events.withRawResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        #expect(value.items.count == 1)
    }

    @Test func streamingResponseList() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message", "processed_at": "2024-01-01T00:00:00Z"}], "has_more": false, "first_id": "first", "last_id": "last", "next_page": null, "prev_page": null}"#)
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.events.withStreamingResponse.list("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        #expect(value.items.count == 1)
        #expect(response.isClosed)
    }

    @Test func pathParamsList() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.events.withRawResponse.list("") }
    }

    @Test func methodSend() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message"}]}"#, validateBody: { try MockRoute.roundTrip(EventSendParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.sessions.events.send("sesn_011CZkZAtmR3yMPDzynEDxu7", events: [BetaManagedAgentsEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func methodSendWithAllParams() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message"}]}"#, validateBody: { try MockRoute.roundTrip(EventSendParams.self, $0) })
        let client = try route.client()
        let value = try await client.beta.sessions.events.send("sesn_011CZkZAtmR3yMPDzynEDxu7", events: [BetaManagedAgentsEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try route.verifyRoundTrip(value)
    }

    @Test func rawResponseSend() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message"}]}"#, validateBody: { try MockRoute.roundTrip(EventSendParams.self, $0) })
        let client = try route.client()
        let response = try await client.beta.sessions.events.withRawResponse.send("sesn_011CZkZAtmR3yMPDzynEDxu7", events: [BetaManagedAgentsEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], extraQuery: ["beta": "true"])
        #expect(response.isClosed == true)
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try route.verifyRoundTrip(value)
    }

    @Test func streamingResponseSend() async throws {
        let route = MockRoute(method: "POST", path: "/v1/sessions/{session_id}/events", json: #"{"data": [{"id": "string", "content": [{"text": "string", "type": "text"}], "type": "user.message"}]}"#, validateBody: { try MockRoute.roundTrip(EventSendParams.self, $0) })
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.events.withStreamingResponse.send("sesn_011CZkZAtmR3yMPDzynEDxu7", events: [BetaManagedAgentsEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))], extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try route.verifyRoundTrip(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsSend() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.events.withRawResponse.send("", events: [BetaManagedAgentsEventParams.userMessage(BetaManagedAgentsUserMessageEventParams(content: [BetaManagedAgentsUserMessageEventParams.Content.text(BetaManagedAgentsTextBlockParam(text: "Where is my order #1234?", type: "text"))], type: "user.message"))]) }
    }

    @Test func methodStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let value = try await client.beta.sessions.events.stream("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        try await route.drain(value)
    }

    @Test func methodStreamWithAllParams() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let value = try await client.beta.sessions.events.stream("sesn_011CZkZAtmR3yMPDzynEDxu7", eventDeltas: [BetaManagedAgentsDeltaType(rawValue: "agent.message")], betas: [AnthropicBetaParam(rawValue: "message-batches-2024-09-24")], workspaceID: "wrkspc_011CZkZaBF1tNoB5wlCeusgy", extraQuery: ["beta": "true"])
        try await route.drain(value)
    }

    @Test func rawResponseStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let response = try await client.beta.sessions.events.withRawResponse.stream("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"])
        #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
        let value = try await response.parse()
        try await route.drain(value)
    }

    @Test func streamingResponseStream() async throws {
        let route = MockRoute(method: "GET", path: "/v1/sessions/{session_id}/events/stream", sse: "event: user.message\ndata: {\"id\": \"string\", \"content\": [{\"text\": \"string\", \"type\": \"text\"}], \"type\": \"user.message\", \"processed_at\": \"2024-01-01T00:00:00Z\"}\n\n")
        let client = try route.client()
        let (response, value) = try await client.beta.sessions.events.withStreamingResponse.stream("sesn_011CZkZAtmR3yMPDzynEDxu7", extraQuery: ["beta": "true"], body: { response in
            #expect(!response.isClosed)
            #expect(response.httpRequest.headers["X-Stainless-Lang"] == "swift")
            return (response, try await response.parse())
        })
        try await route.drain(value)
        #expect(response.isClosed)
    }

    @Test func pathParamsStream() async throws {
        let client = try mockClient()
        try await expectValueError("Expected a non-empty value for `session_id` but received ''") { _ = try await client.beta.sessions.events.withRawResponse.stream("") }
    }
}
