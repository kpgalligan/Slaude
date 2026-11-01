// Port of tests/lib/tools/test_functions.py.

import Foundation
import Testing
@testable import Anthropic

@Suite struct FunctionToolTests {
    struct Person: Decodable { var name: String; var age: Int }
    struct Numbers: Decodable { var a: Int; var b: Int }

    let addSchema: [String: JSONValue] = [
        "additionalProperties": false, "type": "object",
        "properties": ["a": ["title": "A", "type": "integer"], "b": ["title": "B", "type": "integer"]],
        "required": ["a", "b"],
    ]

    func addNumbers() -> BetaFunctionTool {
        BetaFunctionTool(name: "add_numbers", description: "Add two numbers together.", inputSchema: addSchema) {
            (input: Numbers) in .string(String(input.a + input.b))
        }
    }

    @Test func basicFunctionSchemaConversion() async throws {
        let schema: [String: JSONValue] = [
            "additionalProperties": false, "type": "object",
            "properties": [
                "location": ["title": "Location", "type": "string"],
                "unit": ["title": "Unit", "type": "string", "default": "celsius"],
            ],
            "required": ["location"],
        ]
        let tool = BetaFunctionTool(name: "get_weather", description: "Get the weather for a specific location.", inputSchema: schema) {
            input in
            let unit = input["unit"]?.stringValue ?? "celsius"
            return .string("Weather in \(input["location"]?.stringValue ?? "") is 20 degrees \(unit)")
        }
        #expect(tool.name == "get_weather")
        #expect(tool.description == "Get the weather for a specific location.")
        #expect(tool.inputSchema == schema)
        #expect(try await tool.call(["location": "CA"]) == "Weather in CA is 20 degrees celsius")
    }

    @Test func functionWithMultipleTypes() async throws {
        let schema: [String: JSONValue] = [
            "additionalProperties": false, "type": "object",
            "properties": ["name": ["title": "Name", "type": "string"], "age": ["title": "Age", "type": "integer"]],
            "required": ["name", "age"],
        ]
        let tool = BetaFunctionTool(name: "simple_function", description: "A simple function with basic parameter types.",
                                         inputSchema: schema) { (p: Person) in .string("Person: \(p.name), \(p.age) years old") }
        #expect(tool.name == "simple_function")
        #expect(tool.description == "A simple function with basic parameter types.")
        #expect(try await tool.call(["name": "John", "age": 25]) == "Person: John, 25 years old")
        #expect(tool.inputSchema == schema)
    }

    @Test func functionCallWithValidInput() async throws {
        #expect(try await addNumbers().call(["a": 5, "b": 3]) == "8")
    }

    @Test(arguments: [
        (JSONValue.object(["a": "not a number", "b": 3]), "ValueError", "Invalid arguments for function add_numbers"),
        (JSONValue.object(["b": 3]), "ValueError", "Invalid arguments for function add_numbers"),
        (JSONValue.null, "TypeError", "Input must be a dictionary, got NoneType"),
    ])
    func functionCallWithInvalidInput(input: JSONValue, errorType: String, message: String) async throws {
        do {
            _ = try await addNumbers().call(input)
            Issue.record("expected \(errorType)")
        } catch let e as ValueError {
            #expect(errorType == "ValueError")
            #expect(e.message.contains(message))
        } catch let e as ArgumentTypeError {
            #expect(errorType == "TypeError")
            #expect(e.message.contains(message))
        }
    }

    @Test func customNameAndDescription() {
        let tool = BetaFunctionTool(name: "custom_name", description: "Custom description",
                                         inputSchema: ["type": "object"]) { _ in "x" }
        #expect(tool.name == "custom_name")
        #expect(tool.description == "Custom description")
    }

    @Test func customInputSchemaWithDict() {
        let schema: [String: JSONValue] = [
            "additionalProperties": false, "type": "object",
            "properties": ["x": ["type": "number", "description": "A number to double"]], "required": ["x"],
        ]
        let tool = BetaFunctionTool(name: "some_function", inputSchema: schema) { _ in "x" }
        #expect(tool.inputSchema == schema)
    }

    @Test func toDictMethod() throws {
        let schema: [String: JSONValue] = [
            "additionalProperties": false, "type": "object",
            "properties": ["message": ["title": "Message", "type": "string"]], "required": ["message"],
        ]
        let tool = BetaFunctionTool(name: "simple_func", description: "A simple function.", inputSchema: schema) { input in
            .string(input["message"]?.stringValue ?? "")
        }
        #expect(try JSONValue.from(tool.toDict()) == [
            "name": "simple_func", "description": "A simple function.", "input_schema": .object(schema),
        ])
        #expect(try tool.toToolParam() == JSONValue.from(tool.toDict()))
    }

    @Test func toDictCarriesTheOptionalFields() throws {
        let tool = BetaFunctionTool(
            name: "t", description: "d", inputSchema: ["type": "object"], deferLoading: true,
            cacheControl: BetaCacheControlEphemeralParam(), allowedCallers: [.direct], eagerInputStreaming: false,
            inputExamples: [["a": 1]], strict: true) { _ in nil }
        #expect(try tool.toToolParam() == [
            "name": "t", "description": "d", "input_schema": ["type": "object"], "defer_loading": true,
            "cache_control": ["type": "ephemeral"], "allowed_callers": ["direct"], "eager_input_streaming": false,
            "input_examples": [["a": 1]], "strict": true,
        ])
    }

    @Test func functionWithoutDocstring() {
        let tool = BetaFunctionTool(name: "no_docs", inputSchema: ["type": "object"]) { _ in "" }
        #expect(tool.description == "")
    }
}

@Suite struct ContextManagerToolTests {
    @Test func asyncContextManagerToolLazyEnterAndCleanup() async throws {
        let seen = Box<[String]>([])
        let schema: [String: JSONValue] = ["type": "object", "properties": ["value": ["type": "string"]], "required": ["value"]]
        let echo = BetaFunctionTool(name: "echo", description: "Echo the value.", inputSchema: schema, enter: {
            seen.mutate { $0.append("enter") }
            let function: BetaFunctionTool.Function = { input in .string("echo:\(input["value"]?.stringValue ?? "")") }
            return (function, { seen.mutate { $0.append("exit") } })
        })

        // Name/description/schema are available without entering.
        #expect(echo.name == "echo")
        #expect(echo.description == "Echo the value.")
        #expect(try echo.toToolParam()["input_schema"] == .object(schema))
        #expect(seen.value == [])

        #expect(try await echo.call(["value": "hi"]) == "echo:hi")
        #expect(seen.value == ["enter"])
        #expect(try await echo.call(["value": "again"]) == "echo:again")
        #expect(seen.value == ["enter"])

        await acloseRunnableTool(echo)
        #expect(seen.value == ["enter", "exit"])
    }

    @Test func closeHookRuns() async throws {
        let closed = Box(false)
        let tool = BetaFunctionTool(name: "t", inputSchema: ["type": "object"], close: { closed.value = true }) { _ in nil }
        await acloseRunnableTool(tool)
        #expect(closed.value)
    }
}

@Suite struct ToolErrorTests {
    @Test func messageFromContentBlocks() throws {
        let content: BetaFunctionToolResult = try JSONValue.array([
            ["type": "text", "text": "Error details here"],
            ["type": "image", "source": ["type": "base64", "data": "abc", "media_type": "image/png"]],
        ]).decode()
        #expect(ToolError(content).message == "Error details here [image]")
        #expect(ToolError(.contents([])).message == "Tool error")
        #expect(ToolError("plain").message == "plain")
        #expect(ToolError("plain").pythonRepr == "ToolError('plain')")
    }
}
