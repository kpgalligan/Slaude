import Foundation
import Testing
@testable import Anthropic

// Port of tests/lib/_parse/test_messages.py, tests/lib/_parse/test_beta_messages.py,
// tests/lib/test_output_format_helpers.py and tests/api_resources/beta/test_output_format_conversion.py.
// The upstream `http_snapshot` recordings are replayed from the fixtures.

struct OrderItem: StructuredOutput, Equatable {
    var productName: String
    var price: Double
    var quantity: Int

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case price, quantity
    }

    /// What pydantic's `TypeAdapter(OrderItem).json_schema()` produces.
    static let jsonSchema: JSONValue = [
        "type": "object", "title": "OrderItem",
        "properties": [
            "product_name": ["type": "string", "title": "Product Name"], "price": ["type": "number", "title": "Price"],
            "quantity": ["type": "integer", "title": "Quantity"],
        ],
        "required": ["product_name", "price", "quantity"],
    ]
}

struct OrderDetails: StructuredOutput {
    var items: [OrderItem]
    var total: Double

    static let jsonSchema: JSONValue = [
        "$defs": ["OrderItem": OrderItem.jsonSchema],
        "type": "object", "title": "OrderDetails",
        "properties": ["items": ["type": "array", "title": "Items", "items": ["$ref": "#/$defs/OrderItem"]], "total": ["type": "number", "title": "Total"]],
        "required": ["items", "total"],
    ]
}

struct User: StructuredOutput {
    var name: String
    var age: Int

    static let jsonSchema: JSONValue = [
        "type": "object", "title": "User",
        "properties": ["name": ["type": "string", "title": "Name"], "age": ["type": "integer", "title": "Age"]],
        "required": ["name", "age"],
    ]
}

struct Answer: StructuredOutput {
    var text: String
    static let jsonSchema: JSONValue = ["type": "object", "title": "Answer", "properties": ["text": ["type": "string", "title": "Text"]], "required": ["text"]]
}

/// A server replaying an upstream `http_snapshot` recording, and the request bodies it recorded.
func snapshotServer(_ name: String) throws -> (MockServer, [JSONValue]) {
    guard case .array(let entries) = try JSONValue.parse(fixture(name)) else { throw ValueError("bad snapshot") }
    var replies: [MockReply] = []
    var bodies: [JSONValue] = []
    for entry in entries {
        bodies.append(entry["request"]?["body"] ?? .null)
        let response = entry["response"] ?? .null
        let status = response["status_code"]?.intValue ?? 200
        var headers: [String: String] = [:]
        for (k, v) in response["headers"]?.objectValue ?? [:] { if let s = v.stringValue { headers[k] = s } }
        headers.removeValue(forKey: "content-length")
        headers.removeValue(forKey: "content-encoding")
        if case .string(let s) = response["body"] {
            replies.append(.sse(s, status: status, headers: headers))
        } else {
            replies.append(.json(response["body"] ?? .null, status: status, headers: headers))
        }
    }
    return (MockServer(replies), bodies)
}

func snapshotClient(_ server: MockServer) throws -> Anthropic {
    let client = try server.client(maxRetries: 2)
    client.sleeper = { _ in }
    return client
}

let speedMessage: JSONValue = [
    "id": "msg_01Speed", "type": "message", "role": "assistant", "model": "claude-sonnet-5-5", "content": [["type": "text", "text": "Hello there!"]],
    "stop_reason": "end_turn", "stop_sequence": nil, "usage": ["input_tokens": 10, "output_tokens": 5],
]

@Suite struct MessagesParseTests {
    @Test func parseWithStructuredOutputType() async throws {
        let (server, recorded) = try snapshotServer("924cfccc-c863-44ed-9838-c36b37416eaf.json")
        let response = try await snapshotClient(server).messages.parse(
            maxTokens: 1024, messages: [userMessage("Extract: I want to order 2 Green Tea at $5.50 each")], model: "claude-sonnet-5-5",
            outputFormat: OrderItem.self)
        #expect(response.parsedOutput == OrderItem(productName: "Green Tea", price: 5.5, quantity: 2))
        // the schema sent is the recorded one: the type's schema through `transformSchema`
        #expect(server.bodies.last?["output_config"] == recorded.last?["output_config"])
        #expect(server.requests.last?.headers["x-stainless-helper"] == "messages.parse")
    }

    @Test func parseWithNestedStructuredOutputType() async throws {
        let (server, recorded) = try snapshotServer("d743d628-16aa-4c9f-ae78-51deb578f746.json")
        let response = try await snapshotClient(server).messages.parse(
            maxTokens: 1024,
            messages: [userMessage("Extract order: 2 Green Tea at $5.50 and 1 Coffee at $3.00. Total $14.")], model: "claude-sonnet-5-5",
            outputFormat: OrderDetails.self)
        let output = try #require(response.parsedOutput)
        #expect(output.items.count == 2)
        #expect(output.items[0].productName == "Green Tea")
        #expect(output.total == 14.0)
        #expect(server.bodies.last?["output_config"] == recorded.last?["output_config"])
    }

    @Test func parseForwardsSpeed() async throws {
        let server = MockServer([.json(speedMessage)])
        let message = try await server.client().messages.parse(maxTokens: 1024, messages: [userMessage("Say hello there!")],
                                                               model: "claude-sonnet-5-5", speed: .fast)
        #expect(server.bodies.last?["speed"] == "fast")
        #expect(message.parsedOutput == nil)
    }

    @Test func streamWithRawSchema() async throws {
        let (server, _) = try snapshotServer("a8b7dbb8-2321-4624-abdb-7ba2136b5c38.json")
        let stream = try await snapshotClient(server).messages.stream(
            maxTokens: 1024, messages: [userMessage("Extract order IDs from the following text:\n\nOrder 12345\nOrder 67890")],
            model: "claude-sonnet-5-5",
            outputConfig: OutputConfigParam(format: JSONOutputFormatParam(schema: ["type": "array", "items": ["type": "integer"]])))
        let response = try await stream.getFinalMessage()
        guard case .text(let block) = response.content[0] else {
            Issue.record("expected a text block")
            return
        }
        #expect(block.text == "[12345,67890]")
    }

    @Test func streamWithOutputFormatParsesTextBlocks() async throws {
        let (server, _) = try snapshotServer("9381e2b7-7fa1-46f7-9f78-46dc8431ea9d.json")
        struct OrderIDs: StructuredOutput {
            var ids: [Int]
            init(from decoder: Decoder) throws { ids = try decoder.singleValueContainer().decode([Int].self) }
            static let jsonSchema: JSONValue = ["type": "array", "items": ["type": "integer"]]
        }
        let stream = try await snapshotClient(server).messages.stream(
            maxTokens: 1024, messages: [userMessage("Extract order IDs")], model: "claude-sonnet-5-5", outputFormat: OrderIDs.self)
        let message = try await stream.getFinalMessage()
        #expect(message.parsedOutput?.ids == [12345, 67890])
        #expect(server.bodies.last?["output_config"]?["format"]?["schema"] == ["type": "array", "items": ["type": "integer"]])
    }
}

@Suite struct BetaMessagesParseTests {
    @Test func streamWithRawSchema() async throws {
        let (server, _) = try snapshotServer("9381e2b7-7fa1-46f7-9f78-46dc8431ea9d.json")
        let stream = try await snapshotClient(server).beta.messages.stream(
            maxTokens: 1024, messages: [betaUserMessage("Extract order IDs from the following text:\n\nOrder 12345\nOrder 67890")],
            model: "claude-sonnet-5-5",
            outputConfig: BetaOutputConfigParam(format: BetaJSONOutputFormatParam(schema: ["type": "array", "items": ["type": "integer"]])),
            betas: ["structured-outputs-2025-12-15"])
        let response = try await stream.getFinalMessage()
        guard case .text(let block) = response.content[0] else {
            Issue.record("expected a text block")
            return
        }
        #expect(block.text == "[12345,67890]")
    }

    @Test func parseUsesOutputConfig() async throws {
        let (server, recorded) = try snapshotServer("d7092a7d-b723-4470-8fb0-da138cd103a1.json")
        let response = try await snapshotClient(server).beta.withRawResponse.messages.parse(
            maxTokens: 1024,
            messages: [betaUserMessage("Extract the user's name and age from the following text:\n\nMy name is John Doe and I am 30 years old.")],
            model: "claude-sonnet-5-5", outputFormat: User.self)
        let requestJSON = try #require(try response.httpRequest.body.map { try JSONValue.parse($0) })
        var expected = try #require(recorded.first)
        expected["model"] = "claude-sonnet-5-5"
        #expect(requestJSON == expected)
        let parsed = try await response.parse()
        #expect(parsed.parsedOutput?.name == "John Doe")
        #expect(parsed.parsedOutput?.age == 30)
    }

    @Test func rejectsBothOutputFormatAndConfig() async throws {
        do {
            _ = try await mockClient().beta.messages.parse(
                maxTokens: 1024, messages: [betaUserMessage("Extract the user's name and age.")], model: "claude-sonnet-5-5",
                outputConfig: BetaOutputConfigParam(format: BetaJSONOutputFormatParam(schema: ["type": "object"])), outputFormat: User.self)
            Issue.record("expected an error")
        } catch let e as AnthropicError {
            #expect(e.message.contains("Both output_format and output_config.format were provided"))
        }
    }

    /// `test_output_format_conversion.py::test_parse_converts_pydantic_to_output_config`.
    @Test func parseConvertsTheTypeToOutputConfig() async throws {
        let server = MockServer([.json([
            "id": "msg_123", "type": "message", "role": "assistant", "model": "claude-sonnet-4-5",
            "content": [["text": #"{"name": "John", "age": 30}"#, "type": "text"]], "stop_reason": "end_turn",
            "usage": ["input_tokens": 10, "output_tokens": 20],
        ])])
        let message = try await server.client().beta.messages.parse(maxTokens: 1024, messages: [betaUserMessage("Test")], model: "claude-sonnet-5-5",
                                                                    outputFormat: User.self)
        #expect(server.requests.last?.url.query == nil)
        let body = try #require(server.bodies.last)
        #expect(body["output_config"]?["format"]?["type"] == "json_schema")
        #expect(body["output_config"]?["format"]?["schema"]?["properties"]?["name"] != nil)
        #expect(body["output_config"]?["format"]?["schema"]?["properties"]?["age"] != nil)
        #expect(body["output_format"] == nil)
        #expect(message.parsedOutput?.name == "John")
        #expect(server.requests.last?.headers["x-stainless-helper"] == "beta.messages.parse")
    }

    @Test func streamWithOutputFormatDoesNotWarn() async throws {
        let server = MockServer([.sse(getResponse("basic_response.txt"))])
        let warnings = try await recordingWarnings {
            _ = try await server.client().beta.messages.stream(maxTokens: 1024, messages: [betaUserMessage("Test")], model: "claude-sonnet-5-5",
                                                               outputFormat: Answer.self)
        }
        #expect(!warnings.contains { $0.contains("output_format") })
        #expect(server.bodies.last?["output_config"]?["format"]?["type"] == "json_schema")
    }
}

/// `test_output_format_conversion.py::TestStructuredOutputsBetaHeader`: `.parse()` sends the
/// caller's betas and adds none of its own.
@Suite struct StructuredOutputsBetaHeaderTests {
    func parse(betas: [AnthropicBetaParam]?) async throws -> MockServer {
        let server = MockServer([.json([
            "id": "msg_123", "type": "message", "role": "assistant", "model": "claude-sonnet-4-5",
            "content": [["text": #"{"name": "John", "age": 30}"#, "type": "text"]], "stop_reason": "end_turn",
            "usage": ["input_tokens": 10, "output_tokens": 20],
        ])])
        _ = try await server.client().beta.messages.parse(maxTokens: 1024, messages: [betaUserMessage("Test")], model: "claude-sonnet-5-5",
                                                          outputFormat: User.self, betas: betas)
        return server
    }

    @Test func parseDoesNotAddBetaHeader() async throws {
        #expect(try await parse(betas: nil).header("anthropic-beta") == [nil])
    }

    @Test func parseSendsCallerBetasUnchanged() async throws {
        #expect(try await parse(betas: ["some-other-beta-feature"]).header("anthropic-beta") == ["some-other-beta-feature"])
    }

    @Test func parseSendsExplicitStructuredOutputsBetaOnce() async throws {
        #expect(try await parse(betas: ["structured-outputs-2025-12-15"]).header("anthropic-beta") == ["structured-outputs-2025-12-15"])
    }
}

// Port of tests/lib/test_output_format_helpers.py (the typed `outputFormat:` of count_tokens).
@Suite struct OutputFormatHelpersTests {
    func countServer() -> MockServer { MockServer([.json(["input_tokens": 7])]) }

    @Test func countTokensAcceptsAType() async throws {
        let server = countServer()
        _ = try await server.client().messages.countTokens(messages: [userMessage("hi")], model: "claude-sonnet-5-5", outputFormat: Answer.self)
        let body = try #require(server.bodies.last)
        #expect(body["output_format"] == nil)
        #expect(body["output_config"]?["format"]?["type"] == "json_schema")
        #expect(body["output_config"]?["format"]?["schema"]?["properties"]?["text"]?["type"] == "string")
    }

    @Test func countTokensMergesTheTypeIntoAnExistingOutputConfig() async throws {
        let server = countServer()
        _ = try await server.client().messages.countTokens(messages: [userMessage("hi")], model: "claude-sonnet-5-5",
                                                           outputConfig: OutputConfigParam(effort: .high), outputFormat: Answer.self)
        let config = server.bodies.last?["output_config"]
        #expect(config?["effort"] == "high")
        #expect(config?["format"]?["type"] == "json_schema")
    }

    @Test func countTokensOutputConfigStillWorks() async throws {
        let server = countServer()
        _ = try await server.client().messages.countTokens(
            messages: [userMessage("hi")], model: "claude-sonnet-5-5",
            outputConfig: OutputConfigParam(format: JSONOutputFormatParam(schema: ["type": "object"])))
        #expect(server.bodies.last?["output_config"] == ["format": ["type": "json_schema", "schema": ["type": "object"]]])
    }
}
