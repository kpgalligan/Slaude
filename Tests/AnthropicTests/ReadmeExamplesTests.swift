import Foundation
import Testing
@testable import Anthropic

/// Keeps the README's examples compiling and behaving as described.
@Suite struct ReadmeExamplesTests {
    static let messageJSON = #"{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[{"type":"text","text":"Hi!"}],"stop_reason":"end_turn","usage":{"input_tokens":1,"output_tokens":2}}"#

    func client(_ handler: @escaping MockTransport.Handler) throws -> Anthropic {
        try Anthropic(apiKey: "sk-test", baseURL: "http://localhost", maxRetries: 0, transport: MockTransport(handler), environment: [:])
    }

    @Test func gettingStarted() async throws {
        let client = try client { request in
            #expect(request.url.path == "/v1/messages")
            let body = try #require(request.jsonBody)
            #expect(body["messages"] == [["role": "user", "content": "Hello, Claude"]])
            #expect(body["max_tokens"] == 1024)
            #expect(request.headers["anthropic-version"] == ANTHROPIC_API_VERSION)
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Data(Self.messageJSON.utf8), request: request)
        }
        let message = try await client.messages.create(
            maxTokens: 1024,
            messages: [.user(UserMessageParam(content: "Hello, Claude"))],
            model: "claude-opus-5-5"
        )
        var texts: [String] = []
        for block in message.content {
            if case .text(let text) = block { texts.append(text.text) }
        }
        #expect(texts == ["Hi!"])
        #expect(message.stopReason == .endTurn)
    }

    @Test func streaming() async throws {
        let sse = [
            #"event: message_start"#, #"data: {"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[],"usage":{"input_tokens":1,"output_tokens":0}}}"#, "",
            #"event: content_block_delta"#, #"data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}"#, "",
            #"event: ping"#, #"data: {"type":"ping"}"#, "",
            #"event: content_block_delta"#, #"data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":" world"}}"#, "",
            #"event: message_stop"#, #"data: {"type":"message_stop"}"#, "", "",
        ].joined(separator: "\n")
        let client = try client { request in
            #expect(request.jsonBody?["stream"] == true)
            return HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(sse.utf8), size: 13), request: request)
        }
        let stream = try await client.messages.createStreaming(
            maxTokens: 1024,
            messages: [.user(UserMessageParam(content: "Write a haiku"))],
            model: "claude-opus-5-5"
        )
        var text = ""
        for try await event in stream {
            if case .contentBlockDelta(let e) = event, case .textDelta(let d) = e.delta {
                text += d.text
            }
        }
        #expect(text == "Hello world")
    }

    @Test func pagination() async throws {
        let client = try client { request in
            let after = request.query("after_id")
            let body: JSONValue = after == nil
                ? ["data": [["id": "m1", "type": "model", "display_name": "One", "lifecycle": "active", "created_at": "2024-01-01T00:00:00Z"]], "has_more": true, "first_id": "m1", "last_id": "m1"]
                : ["data": [["id": "m2", "type": "model", "display_name": "Two", "lifecycle": "active", "created_at": "2024-01-01T00:00:00Z"]], "has_more": false, "first_id": "m2", "last_id": "m2"]
            return HTTPResponse.json(body, for: request)
        }
        var ids: [String] = []
        for try await model in try await client.models.list(limit: 1) { ids.append(model.id) }
        #expect(ids == ["m1", "m2"])
        let page = try await client.models.list()
        #expect(page.hasNextPage())
        let next = try await page.getNextPage()
        #expect(next.data.map(\.id) == ["m2"])
    }

    @Test func rawResponseAndErrors() async throws {
        let client = try client { request in
            if request.url.path == "/v1/models" {
                return HTTPResponse.json(["error": ["type": "rate_limit_error", "message": "slow down"]], status: 429, headers: ["request-id": "req_1"], for: request)
            }
            return HTTPResponse(statusCode: 200, headers: ["request-id": "req_2", "content-type": "application/json"], body: Data(Self.messageJSON.utf8), request: request)
        }
        let response = try await client.messages.withRawResponse.create(
            maxTokens: 1024, messages: [.user(UserMessageParam(content: "Hi"))], model: "claude-opus-5-5")
        #expect(response.headers["request-id"] == "req_2")
        #expect(try await response.parse().id == "msg_1")

        do {
            _ = try await client.models.list()
            Issue.record("expected an error")
        } catch let error as RateLimitError {
            #expect(error.statusCode == 429)
            #expect(error.requestID == "req_1")
            #expect(error.type == .rateLimitError)
        }
    }
}
