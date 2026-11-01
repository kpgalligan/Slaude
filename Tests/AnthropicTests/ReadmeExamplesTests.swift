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

/// README "Helpers" section.
struct ReadmePerson: StructuredOutput {
    let name: String
    static let jsonSchema: JSONValue = ["type": "object", "properties": ["name": ["type": "string"]], "required": ["name"]]
}

@Suite struct ReadmeHelperExamplesTests {
    static func reply(_ text: String, stop: String = "end_turn", content: JSONValue? = nil) -> Data {
        let body: JSONValue = ["id": "msg_1", "type": "message", "role": "assistant", "model": "claude-opus-5-5",
                               "content": content ?? [["type": "text", "text": .string(text)]], "stop_reason": .string(stop),
                               "usage": ["input_tokens": 1, "output_tokens": 1]]
        return try! JSONValue.serialize(body)
    }

    @Test func streamHelper() async throws {
        let sse = [
            #"event: message_start"#, #"data: {"type":"message_start","message":{"id":"msg_1","type":"message","role":"assistant","model":"claude-opus-5-5","content":[],"usage":{"input_tokens":1,"output_tokens":0}}}"#, "",
            #"event: content_block_start"#, #"data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}"#, "",
            #"event: content_block_delta"#, #"data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hi"}}"#, "",
            #"event: content_block_stop"#, #"data: {"type":"content_block_stop","index":0}"#, "",
            #"event: message_delta"#, #"data: {"type":"message_delta","delta":{"stop_reason":"end_turn"},"usage":{"output_tokens":1}}"#, "",
            #"event: message_stop"#, #"data: {"type":"message_stop"}"#, "", "",
        ].joined(separator: "\n")
        let client = try Anthropic(apiKey: "k", baseURL: "http://localhost", maxRetries: 0, transport: MockTransport { request in
            HTTPResponse(statusCode: 200, headers: ["content-type": "text/event-stream"], stream: chunked(Data(sse.utf8)), request: request)
        }, environment: [:])
        let messages: [MessageParam] = [.user(UserMessageParam(content: "Hi"))]
        let stream = try await client.messages.stream(maxTokens: 1024, messages: messages, model: "claude-opus-5-5")
        var text = ""
        for try await t in stream.textStream { text += t }
        let final = try await stream.getFinalMessage()
        #expect(text == "Hi")
        #expect(final.stopReason == .endTurn)
    }

    @Test func parseHelper() async throws {
        let client = try Anthropic(apiKey: "k", baseURL: "http://localhost", maxRetries: 0, transport: MockTransport { request in
            #expect(request.jsonBody?["output_config"]?["format"]?["type"] == "json_schema")
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Self.reply(#"{"name": "Ada"}"#), request: request)
        }, environment: [:])
        let messages: [MessageParam] = [.user(UserMessageParam(content: "Who?"))]
        let parsed = try await client.messages.parse(maxTokens: 1024, messages: messages, model: "claude-opus-5-5", outputFormat: ReadmePerson.self)
        #expect(parsed.parsedOutput?.name == "Ada")
    }

    @Test func toolRunner() async throws {
        let calls = ReadmeCallCounter()
        let client = try Anthropic(apiKey: "k", baseURL: "http://localhost", maxRetries: 0, transport: MockTransport { request in
            if calls.next() == 0 {
                let content: JSONValue = [["type": "tool_use", "id": "tu_1", "name": "get_weather", "input": ["city": "Paris"]]]
                return HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Self.reply("", stop: "tool_use", content: content), request: request)
            }
            let last = request.jsonBody?["messages"]?.arrayValue?.last
            #expect(last?["content"]?[0]?["content"] == "Sunny in Paris" || last?["content"]?[0]?["content"]?[0]?["text"] == "Sunny in Paris")
            return HTTPResponse(statusCode: 200, headers: ["content-type": "application/json"], body: Self.reply("Done"), request: request)
        }, environment: [:])
        let betaMessages: [BetaMessageParam] = try JSONValue.array([["role": "user", "content": "Weather in Paris?"]]).decode()
        let weather = BetaFunctionTool(name: "get_weather", description: "Current weather",
                                       inputSchema: ["type": "object", "properties": ["city": ["type": "string"]]]) { (input: BetaToolInput) in
            .string("Sunny in \(input["city"]?.stringValue ?? "?")")
        }
        let runner = try client.beta.messages.toolRunner(maxTokens: 1024, messages: betaMessages, model: "claude-opus-5-5",
                                                          tools: [weather], thread: false)
        let last = try await runner.untilDone()
        #expect(last.stopReason == .endTurn)
    }
}

final class ReadmeCallCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var n = 0
    func next() -> Int { lock.withLock { defer { n += 1 }; return n } }
}
