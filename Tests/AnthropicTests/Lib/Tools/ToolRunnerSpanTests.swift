// Port of tests/lib/tools/test_open_telemetry.py, `TestToolRunnerSpans`: the spans of the Messages tool runner's
// loops and of the tools and toolset members that it runs.
//
// Only the async runner exists in Swift, so a sync test and its async twin are one test here, and a sync-only test
// runs the async runner. `instrument` (monkeypatching the runner's private methods) has no counterpart.

import Foundation
import Testing
@testable import Anthropic

@Suite struct ToolRunnerSpanTests {
    let content = OpenTelemetryTraces(contentMode: .content)

    // MARK: The loop and its tools

    @Test func toolRunnerAndToolSpans() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let client = try tracingClient(spans, router)

        let appSpan = try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { app in
            _ = try await toolSpanRun(client, conversationID: "conv_1").untilDone()
            return app.context.spanID
        }

        let runner = try spans.one("anthropic.messages.tool_runner")
        #expect(runner.kind == .internal)
        #expect(runner.statusCode == .ok)
        #expect(toolSpanParent(runner) == appSpan)
        #expect(runner.attributes == ["gen_ai.operation.name": "invoke_agent", "gen_ai.provider.name": "anthropic",
                                      "gen_ai.request.model": "claude-test", "gen_ai.conversation.id": "conv_1"])

        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        for call in calls {
            #expect(toolSpanParent(call) == runner.spanID)
            #expect(call["gen_ai.conversation.id"] == "conv_1")
        }
        // Each request has its own response's stop reason; the tool runner span, above, has none.
        #expect(calls.map { $0["anthropic.message.stop_reason"] } == ["tool_use", "end_turn"])

        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(tool.kind == .internal)
        #expect(tool.statusCode == .ok)
        #expect(toolSpanParent(tool) == runner.spanID)
        #expect(tool.attributes == [
            "gen_ai.operation.name": "execute_tool", "gen_ai.provider.name": "anthropic", "gen_ai.tool.name": "get_weather",
            // The description is metadata, so the span has it without content mode.
            "gen_ai.tool.description": "The weather in a city.", "gen_ai.tool.call.id": "toolu_SF",
            "gen_ai.conversation.id": "conv_1", "gen_ai.tool.type": "function",
        ])
        let firstEnd = try #require(calls[0].endTime)
        let toolEnd = try #require(tool.endTime)
        #expect(firstEnd <= tool.startTime && tool.startTime <= toolEnd && toolEnd <= calls[1].startTime)
    }

    @Test func toolError() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = toolSpanMessages(router, [toolSpanToolUseMessage("Atlantis"), toolSpanFinal])
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: content))

        _ = try await ToolDiagnostics.capture { try await toolSpanRun(client).untilDone() }

        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(tool.statusCode == .error)
        #expect(tool["error.type"] == "tool_error")
        #expect(tool.json("gen_ai.tool.call.arguments") == ["city": "Atlantis"])
        // The content of the error result that the runner made of the tool's error.
        let sent = try #require(toolSpanSent(route).first)
        #expect(sent["is_error"] == true)
        #expect(tool.json("anthropic.tool_result.content") == [["type": "text", "text": sent["content"] ?? nil]])
        #expect(tool["gen_ai.tool.call.result"] == nil)
        #expect(try spans.one("anthropic.messages.tool_runner").statusCode == .ok)
    }

    @Test func toolResultContent() async throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: content))
        let text: JSONValue = [
            "type": "text", "text": "It is sunny.",
            "citations": [
                ["type": "char_location", "cited_text": "sunny", "document_index": 0, "document_title": "Weather",
                 "start_char_index": 0, "end_char_index": 5],
                ["type": "web_search_result_location", "cited_text": "sunny", "encrypted_index": "encrypted_0", "title": "Weather",
                 "url": "https://example.com/weather"],
            ],
            "cache_control": ["type": "ephemeral"],
        ]
        let searchResult: JSONValue = [
            "type": "search_result", "source": "https://example.com/weather", "title": "Weather",
            "content": [["type": "text", "text": "sunny"]], "citations": ["enabled": true],
        ]
        let functions: [@Sendable (String) async throws -> BetaFunctionToolResult?] = [
            { .string(try toolSpanGetWeather($0)) },
            { city in
                let image: JSONValue = ["type": "image", "source": ["type": "url", "url": .string("https://example.com/\(city).png")]]
                return try JSONValue.array([text, searchResult, image]).decode(as: BetaFunctionToolResult.self)
            },
            { _ in nil },
        ]
        for function in functions {
            let router = TracingRouter()
            toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
            let routed = try client.copy(transport: router.transport)
            _ = try await toolSpanRun(routed, tools: [toolSpanWeatherTool(function)]).untilDone()
        }

        let named = spans.named("anthropic.custom_tool_use get_weather")
        try #require(named.count == 3)
        let (string, listed, none) = (named[0], named[1], named[2])
        #expect(string.json("anthropic.tool_result.content") == [["type": "text", "text": #"{"city": "SF", "weather": "sunny"}"#]])
        // A text block and a search result keep all of their fields but one whose name starts with `encrypted_`. Any
        // other block is its type, with no prefix.
        let citations = text["citations"]!.arrayValue!
        #expect(listed.json("anthropic.tool_result.content") == [
            text.with("citations", [citations[0], citations[1].without("encrypted_index")]), searchResult, ["type": "image"],
        ])
        #expect(listed["anthropic.tool_result.content"]?.stringValue?.contains("encrypted_0") == false)
        #expect(none.json("anthropic.tool_result.content") == [])
        for span in named { #expect(span["gen_ai.tool.call.result"] == nil) }
    }

    @Test(arguments: [false, true]) func toolResultWithoutContentHasAnEmptyList(emptyList: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let cities = ToolsBox<[String]>([])
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: content))

        _ = try await toolSpanRun(client, tools: [toolSpanWeatherTool { city in
            cities.mutate { $0.append(city) }
            return emptyList ? .contents([]) : nil
        }]).untilDone()

        // The JSON of a list, as it is with content, and neither `null` nor an object.
        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(cities.value == ["SF"])
        #expect(tool.statusCode == .ok)
        #expect(tool["anthropic.tool_result.content"] == "[]")
    }

    @Test func toolResultContentLosesItsLastBlocksOverTheContentLimit() async throws {
        let spans = TracingSpans()
        let half = String(repeating: "x", count: CONTENT_LIMIT / 2)
        let blocks: @Sendable (String) async throws -> BetaFunctionToolResult? = { city in
            .contents(try [city + half, half, "last"].map { try JSONValue.object(["type": "text", "text": .string($0)]).decode(as: BetaToolResultBlockParam.Content.self) })
        }
        let string: @Sendable (String) async throws -> BetaFunctionToolResult? = { .string($0 + half + half) }
        let runs: [(OpenTelemetryOptions, (@Sendable (String) async throws -> BetaFunctionToolResult?)?)] = [
            (spans.option(traces: content), blocks), (spans.option(traces: content), string), (spans.option(traces: content), nil),
            (spans.option(), string),
        ]
        for (option, function) in runs {
            let router = TracingRouter()
            toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
            let client = try tracingClient(spans, router, openTelemetry: option)
            _ = try await toolSpanRun(client, tools: [toolSpanWeatherTool(function)]).untilDone()
        }

        let named = spans.named("anthropic.custom_tool_use get_weather")
        try #require(named.count == 4)
        let (listed, single, under, off) = (named[0], named[1], named[2], named[3])
        // The second block does not fit beside the first, so it goes, and so does the one after it, which would fit.
        #expect(listed.json("anthropic.tool_result.content") == [["type": "text", "text": .string("SF" + half)]])
        // A string is one block, so the list is left empty.
        #expect(single.json("anthropic.tool_result.content") == [])
        for tool in [listed, single] {
            #expect(tool["anthropic.content.truncated"] == true)
            let arguments = try #require(tool[toolSpanContentAttributes.0]?.stringValue)
            let result = try #require(tool[toolSpanContentAttributes.1]?.stringValue)
            #expect(try JSONValue.parse(arguments) == ["city": "SF"])
            #expect((arguments + result).utf8.count <= CONTENT_LIMIT)
        }
        #expect(under.json("anthropic.tool_result.content") == [["type": "text", "text": #"{"city": "SF", "weather": "sunny"}"#]])
        #expect(under["anthropic.content.truncated"] == nil)
        for name in [toolSpanContentAttributes.0, toolSpanContentAttributes.1, "anthropic.content.truncated"] {
            #expect(off[name] == nil)
        }
    }

    @Test func toolResultContentIsWithinTheClientsMaxContentBytes() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let traces = OpenTelemetryTraces(contentMode: .content, maxContentBytes: 200)
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: traces))

        _ = try await toolSpanRun(client, tools: [toolSpanWeatherTool { city in
            .contents(try [city + String(repeating: "x", count: 100), String(repeating: "y", count: 100), "last"].map {
                try JSONValue.object(["type": "text", "text": .string($0)]).decode(as: BetaToolResultBlockParam.Content.self)
            })
        }]).untilDone()

        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        let arguments = try #require(tool[toolSpanContentAttributes.0]?.stringValue)
        let result = try #require(tool[toolSpanContentAttributes.1]?.stringValue)
        #expect(try JSONValue.parse(result) == [["type": "text", "text": .string("SF" + String(repeating: "x", count: 100))]])
        #expect(tool["anthropic.content.truncated"] == true)
        #expect((arguments + result).utf8.count <= 200 && 200 < CONTENT_LIMIT)
    }

    struct SizeBoundCase: Sendable, CustomTestStringConvertible {
        let id: String
        let limit: Int
        let arguments: JSONValue
        let result: JSONValue
        let expectedArguments: JSONValue?
        let expected: JSONValue
        let sizes: (Int, Int)
        var testDescription: String { id }
    }

    static let sizeBoundCases: [SizeBoundCase] = [
        // Blocks go from the end, the last one first, whole. The arguments fit, so they stay whole and count.
        SizeBoundCase(
            id: "tool_span_blocks_go_from_the_end", limit: 152, arguments: ["city": "Paris"],
            result: [
                ["type": "text", "text": "first 111111111111111111111111111111"], ["type": "text", "text": "second 222222222222222222222222222222"],
                ["type": "image"], ["type": "text", "text": "fourth 444444444444444444444444444444"],
            ],
            expectedArguments: ["city": "Paris"],
            expected: [["type": "text", "text": "first 111111111111111111111111111111"],
                       ["type": "text", "text": "second 222222222222222222222222222222"]],
            sizes: (222, 142)),
        // The arguments exceed the limit by themselves: they go whole, and the result has the whole limit.
        SizeBoundCase(
            id: "tool_span_arguments_alone_over_the_bound", limit: 100, arguments: ["text": .string(String(repeating: "w", count: 150))],
            result: [["type": "text", "text": "ok"]], expectedArguments: nil, expected: [["type": "text", "text": "ok"]], sizes: (190, 29)),
    ]

    @Test(arguments: ToolRunnerSpanTests.sizeBoundCases) func sizeBoundCasesOfAToolSpan(_ c: SizeBoundCase) throws {
        let spans = TracingSpans()
        let (argumentsName, resultName) = toolSpanContentAttributes
        let given: [String: OrderedJSON?] = [argumentsName: OrderedJSON(c.arguments), resultName: OrderedJSON(c.result)]
        let span = spans.provider.tracer("test", version: nil).startSpan("anthropic.custom_tool_use f")

        #expect(given.values.reduce(0) { $0 + ($1?.json.utf8.count ?? 0) } == c.sizes.0)

        setContentAttributes(span, given, limit: c.limit)
        span.end()

        let data = try spans.one("anthropic.custom_tool_use f")
        var values: [String: String] = [:]
        for name in [argumentsName, resultName] { if let v = data[name]?.stringValue { values[name] = v } }
        var expected: [String: JSONValue] = [resultName: c.expected]
        if let a = c.expectedArguments { expected[argumentsName] = a }
        #expect(try values.mapValues { try JSONValue.parse($0) } == expected)
        #expect(data["anthropic.content.truncated"] == true)
        #expect(values.values.reduce(0) { $0 + $1.utf8.count } == c.sizes.1)
    }

    @Test func toolArgumentsExactlyAtTheBoundStayAndOneOverAreRemovedWhole() {
        let (argumentsName, resultName) = toolSpanContentAttributes
        let arguments = OrderedJSON(["text": .string(String(repeating: "w", count: 89))])
        let result = OrderedJSON([["type": "text", "text": "ok"]])
        #expect(arguments.json.count == 100)

        // They leave no room for any block, so the list is emptied, and the values stay over the limit.
        var fitted = fitContent([argumentsName: arguments, resultName: result], limit: 100)
        #expect(fitted.0 == [argumentsName: arguments.json, resultName: "[]"] && fitted.1)
        fitted = fitContent([argumentsName: arguments, resultName: result], limit: 99)
        #expect(fitted.0 == [resultName: result.json] && fitted.1)
        // A run that was interrupted has no result, and one whose arguments fit is not marked.
        fitted = fitContent([argumentsName: arguments, resultName: nil], limit: 100)
        #expect(fitted.0 == [argumentsName: arguments.json] && !fitted.1)
        fitted = fitContent([argumentsName: arguments, resultName: nil], limit: 99)
        #expect(fitted.0 == [:] && fitted.1)
    }

    // The second city has one character of two bytes, so its arguments are 17 characters and 18 bytes.
    @Test(arguments: [("SF", 13), ("Z\u{00fc}rich", 18)])
    func toolArgumentsAloneOverTheBoundAreRemovedWhole(city: String, size: Int) async throws {
        let spans = TracingSpans()
        #expect(OrderedJSON(["city": .string(city)]).json.utf8.count == size)
        for maxContentBytes in [size, size - 1] {
            let router = TracingRouter()
            toolSpanMessages(router, [toolSpanToolUseMessage(city), toolSpanFinal])
            let traces = OpenTelemetryTraces(contentMode: .content, maxContentBytes: maxContentBytes)
            let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: traces))
            _ = try await toolSpanRun(client, tools: [toolSpanWeatherTool { .string("sunny in " + $0) }]).untilDone()
        }

        let (argumentsName, resultName) = toolSpanContentAttributes
        let named = spans.named("anthropic.custom_tool_use get_weather")
        try #require(named.count == 2)
        #expect(named[0].json(argumentsName) == ["city": .string(city)])
        #expect(named[1][argumentsName] == nil)
        for tool in named {
            // The result does not fit either way: the emptied list stays.
            #expect(tool[resultName] == "[]")
            #expect(tool["anthropic.content.truncated"] == true)
        }
    }

    @Test func contentIsOffByDefault() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])

        _ = try await toolSpanRun(try tracingClient(spans, router)).untilDone()

        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(tool["gen_ai.tool.call.arguments"] == nil)
        #expect(tool["anthropic.tool_result.content"] == nil)
        #expect(tool["gen_ai.tool.description"] == "The weather in a city.")
        // The application set no conversation ID, and a Messages tool runner has no Session.
        for name in ["gen_ai.conversation.id", "anthropic.session.id", "anthropic.session.thread.id"] { #expect(tool[name] == nil) }
        for call in spans.named("anthropic.messages.create") { #expect(call["gen_ai.conversation.id"] == nil) }
    }

    // MARK: Tools that the application runs

    @Test func toolThatTheApplicationRunsBetweenItemsHasTheConversationID() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router), conversationID: "conv_1")

        _ = try await runner.next()
        // The runner executes the tool here, outside its loop's own code.
        #expect(try await runner.generateToolCallResponse() != nil)
        #expect(try spans.one("anthropic.custom_tool_use get_weather")["gen_ai.conversation.id"] == "conv_1")
        _ = try await runner.untilDone()

        // The loop uses that result, so the tool ran once.
        #expect(spans.named("anthropic.custom_tool_use get_weather").count == 1)
    }

    @Test func toolThatTheApplicationRunsIsAChildOfTheApplicationsSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router))

        _ = try await runner.next()
        // The tool runner span is open here, but it is not current in the application's code.
        let app = try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { app in
            let response = try await runner.generateToolCallResponse()
            #expect(response != nil)
            return app.context.spanID
        }
        _ = try await runner.untilDone()
        await runner.close()

        #expect(toolSpanParent(try spans.one("anthropic.custom_tool_use get_weather")) == app)
    }

    @Test func toolThatTheApplicationRunsWithNoCurrentSpanIsARootSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router))

        _ = try await runner.next()
        #expect(try await runner.generateToolCallResponse() != nil)
        _ = try await runner.untilDone()

        #expect(try spans.one("anthropic.custom_tool_use get_weather").parent == nil)
    }

    /// A builtin tool that is its own definition (`GetWeather`).
    final class DefinedWeather: BetaBuiltinFunctionTool, @unchecked Sendable {
        override func toDict() throws -> JSONValue {
            ["name": "get_weather", "description": "From the definition", "input_schema": ["type": "object"]]
        }

        override func call(_ input: JSONValue) async throws -> BetaFunctionToolResult? { .string("sunny: \(input)") }
    }

    @Test func toolDescription() async throws {
        let spans = TracingSpans()
        let client = try tracingClient(spans, TracingRouter(), openTelemetry: spans.option(traces: content))
        let tools: [any BetaRunnableTool] = [
            // The description that the application gave.
            toolSpanWeatherTool(description: "Given by the application"),
            // No description.
            toolSpanWeatherTool(description: "") { .string("sunny in \($0)") },
            // A tool that is its own definition.
            DefinedWeather(),
        ]
        for tool in tools {
            let router = TracingRouter()
            toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
            _ = try await toolSpanRun(try client.copy(transport: router.transport), tools: [tool]).untilDone()
        }

        let named = spans.named("anthropic.custom_tool_use get_weather")
        try #require(named.count == 3)
        #expect(named[0]["gen_ai.tool.description"] == "Given by the application")
        #expect(named[1]["gen_ai.tool.description"] == nil)
        #expect(named[2]["gen_ai.tool.description"] == "From the definition")
    }

    // MARK: How the loop ends

    static let rateLimited: TracingReply = .json(["type": "error", "error": ["type": "rate_limit_error", "message": "slow down"]], status: 429)

    @Test(arguments: [false, true]) func failedCallEndsTheLoopWithItsError(streamed: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        router.route("POST", "/v1/messages", Self.rateLimited)
        let client = try tracingClient(spans, router, maxRetries: 0)

        // A streamed request is sent when the loop opens the stream, before the application reads it.
        await #expect(throws: RateLimitError.self) {
            if streamed {
                for try await stream in try toolSpanStreamingRun(client) {
                    for try await _ in stream {}
                }
            } else {
                _ = try await toolSpanRun(client).untilDone()
            }
        }

        let runner = try spans.one("anthropic.messages.tool_runner")
        #expect(runner.statusCode == .error)
        #expect(runner["error.type"] == "rate_limit_error")
        #expect(try spans.one("anthropic.messages.create")["error.type"] == "rate_limit_error")
    }

    @Test func resumingAfterABreakContinuesTheSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router))

        for try await _ in runner { break }
        #expect(spans.named("anthropic.messages.tool_runner").isEmpty)
        #expect(try await runner.untilDone().id == "msg_final")
        // Closing a runner that is done has no effect.
        await runner.close()

        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .ok)
        #expect(spans.named("anthropic.messages.create").count == 2)
        #expect(toolSpanParent(try spans.one("anthropic.custom_tool_use get_weather")) == span.spanID)
    }

    @Test func closingTheRunnerEndsTheSpanUnset() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router))

        for try await _ in runner { break }
        await runner.close()

        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(spans.named("anthropic.custom_tool_use get_weather").isEmpty)
        var rest = 0
        for try await _ in runner { rest += 1 }
        #expect(rest == 0)
        #expect(try await runner.untilDone().id == "msg_SF")
        #expect(spans.named("anthropic.messages.create").count == 1)
        #expect(spans.named("anthropic.messages.tool_runner").count == 1)
    }

    struct Weather: StructuredOutput, Equatable {
        var weather: String
        static let jsonSchema: JSONValue = ["type": "object", "properties": ["weather": ["type": "string"]], "required": ["weather"]]
    }

    @Test func outputTypeIsJSONWhenTheRunnerSetsAJSONOutputFormat() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let weather = toolSpanFinal.with("content", [["type": "text", "text": #"{"weather": "sunny"}"#]])
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal, toolSpanFinal, weather, toolSpanFinal])
        let client = try tracingClient(spans, router)
        let schema: [String: JSONValue] = ["type": "object", "properties": ["weather": ["type": "string"]]]

        _ = try await toolSpanRun(client, outputConfig: BetaOutputConfigParam(format: .some(BetaJSONOutputFormatParam(schema: schema)))).untilDone()
        _ = try await toolSpanRun(client).untilDone()

        var runners = spans.named("anthropic.messages.tool_runner")
        try #require(runners.count == 2)
        #expect(runners[0]["gen_ai.output.type"] == "json")
        #expect(runners[1]["gen_ai.output.type"] == nil)
        // Each request of the loop sets the format, so each of its spans has the attribute too.
        let calls = spans.named("anthropic.messages.create").filter { toolSpanParent($0) == runners[0].spanID }
        #expect(calls.map { $0["gen_ai.output.type"] } == ["json", "json"])

        // The output format of the runner is a type.
        let parsed = try await client.beta.messages.toolRunner(
            maxTokens: 1024, messages: [toolSpanQuestion], model: "claude-test", tools: [toolSpanWeatherTool()], outputFormat: Weather.self
        ).untilDone()
        #expect(parsed.parsedOutput == Weather(weather: "sunny"))
        runners = spans.named("anthropic.messages.tool_runner")
        #expect(runners[2]["gen_ai.output.type"] == "json")

        // Another type of format (the Swift param has a schema whatever its type).
        _ = try await toolSpanRun(client, outputConfig: BetaOutputConfigParam(format: .some(BetaJSONOutputFormatParam(schema: [:], type: "other"))))
            .untilDone()
        #expect(spans.named("anthropic.messages.tool_runner")[3]["gen_ai.output.type"] == nil)
    }

    @Test func toolRunnerSpanHasItsAttributesFromItsStart() async throws {
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanFinal])
        let sampler = TracingStartAttributes()
        let client = try tracingClient(nil, router, openTelemetry: OpenTelemetryOptions(tracerProvider: SDKTracerProvider(sampler: sampler)))
        let schema: [String: JSONValue] = ["type": "object", "properties": ["weather": ["type": "string"]]]

        _ = try await toolSpanRun(client, conversationID: "conv_1",
                                  outputConfig: BetaOutputConfigParam(format: .some(BetaJSONOutputFormatParam(schema: schema)))).untilDone()

        #expect(sampler.startedWith("anthropic.messages.tool_runner") == [
            "gen_ai.operation.name": "invoke_agent", "gen_ai.provider.name": "anthropic", "gen_ai.request.model": "claude-test",
            "gen_ai.conversation.id": "conv_1", "gen_ai.output.type": "json",
        ])
    }

    @Test func spansThatAToolStartsAreChildrenOfItsToolSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let tracer = spans.provider.tracer("app", version: nil)

        _ = try await toolSpanRun(try tracingClient(spans, router), tools: [toolSpanWeatherTool { city in
            await tracer.withActiveSpan("app.lookup") { _ in
                await Task.yield()
                return .string(city)
            }
        }]).untilDone()

        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(toolSpanParent(try spans.one("app.lookup")) == tool.spanID)
        #expect(toolSpanParent(tool) == (try spans.one("anthropic.messages.tool_runner")).spanID)
        #expect(!TracingContext.currentSpan.context.isValid)
    }

    @Test func closingTheRunnerFromAToolStopsTheLoop() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let box = ToolsBox<BetaToolRunner?>(nil)
        // The loop is running here, as it is for another task that closes the runner during a request.
        let runner = try toolSpanRun(try tracingClient(spans, router), tools: [toolSpanWeatherTool { city in
            await box.value?.close()
            return .string(city)
        }])
        box.value = runner

        var ids: [String] = []
        for try await message in runner { ids.append(message.id) }
        #expect(ids == ["msg_SF"])

        #expect(try spans.one("anthropic.messages.tool_runner").statusCode == .unset)
        #expect(try spans.one("anthropic.custom_tool_use get_weather").statusCode == .ok)
        #expect(spans.named("anthropic.messages.create").count == 1)
        box.value = nil
    }

    @Test func closingTheStreamingRunnerFromAnotherTaskEndsItsLoop() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: true)
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router))
        let inBody = EnvEvent()
        let closing = EnvEvent()

        let driver = Task {
            var items = 0
            for try await _ in runner {
                items += 1
                inBody.set()
                await closing.wait()
            }
            return items
        }
        await inBody.wait()
        // The close runs while the driver is in its loop body, and the driver asks for the next item after it.
        await runner.close()
        closing.set()

        #expect(try await driver.value == 1)
        var rest = 0
        for try await _ in runner { rest += 1 }
        #expect(rest == 0)
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    @Test func closingTheStreamingRunnerTwiceAtOnceClosesItOnce() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: true)
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router))

        for try await _ in runner { break }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await runner.close() }
            group.addTask { await runner.close() }
        }

        #expect(try spans.one("anthropic.messages.tool_runner").statusCode == .unset)
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    @Test func aCompactionRequestIsAChildOfTheToolRunnerSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        // The response to a compaction request has its tokens in an entry of `usage.iterations` only.
        let compaction: JSONValue = ["type": "compaction", "input_tokens": 100, "output_tokens": 20, "cache_read_input_tokens": 10,
                                     "cache_creation_input_tokens": 5]
        let usage: JSONValue = ["input_tokens": 0, "output_tokens": 0, "iterations": [compaction]]
        let route = toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanCompaction.with("usage", usage), toolSpanFinal])
        let runner = try toolSpanRun(try tracingClient(spans, router), conversationID: "conv_1")

        var stopReasons: [BetaStopReason?] = []
        for try await message in runner {
            stopReasons.append(message.stopReason)
            if message.stopReason == .toolUse { try await runner.compactBeforeNextTurn() }
        }

        #expect(stopReasons == [.toolUse, .compaction, .endTurn])
        #expect(route.requests[1].jsonBody?["compaction"] != nil)
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .ok)
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 3)
        for call in calls {
            #expect(toolSpanParent(call) == span.spanID)
            #expect(call["gen_ai.conversation.id"] == "conv_1")
        }
        // Only the span of the compaction request has the tokens of the compaction.
        #expect(calls.map { $0["anthropic.usage.compaction.input_tokens"] } == [nil, 115, nil])
        #expect(calls.map { $0["anthropic.usage.compaction.output_tokens"] } == [nil, 20, nil])
        #expect(calls[1]["gen_ai.usage.input_tokens"] == 0)
        #expect(calls[1]["gen_ai.usage.output_tokens"] == 0)
    }

    /// The application resumes the runner from a context of its own each time: here each step runs in a task of its
    /// own, in a span of its own.
    @Test(arguments: [false, true]) func allOfTheRunnersCodeRunsInTheToolRunnerSpan(stream: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanCompaction, toolSpanFinal], stream: stream)
        let client = try tracingClient(spans, router)
        let tracer = spans.provider.tracer("app", version: nil)
        let messages = stream ? nil : try toolSpanRun(client)
        let streams = stream ? try toolSpanStreamingRun(client) : nil

        var steps = 0
        while true {
            let number = steps
            let more = try await Task {
                try await tracer.withActiveSpan("app.step_\(number)") { app in
                    let got: Bool
                    if let messages {
                        got = try await messages.next() != nil
                        if got && number == 0 { try await messages.compactBeforeNextTurn() }
                    } else {
                        got = try await streams!.next() != nil
                        if got && number == 0 { try await streams!.compactBeforeNextTurn() }
                    }
                    #expect(TracingContext.currentSpan.context.spanID == app.context.spanID)
                    return got
                }
            }.value
            if !more { break }
            steps += 1
        }
        #expect(steps == 3)

        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .ok)
        #expect(toolSpanParent(span) == (try spans.one("app.step_0")).spanID)
        #expect(spans.named("anthropic.messages.create").map(toolSpanParent) == [SpanID?](repeating: span.spanID, count: 3))
        #expect(toolSpanParent(try spans.one("anthropic.custom_tool_use get_weather")) == span.spanID)
        #expect(!TracingContext.currentSpan.context.isValid)
    }

    @Test func theApplicationsCodeBetweenItemsKeepsItsOwnContext() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: true)
        let client = try tracingClient(spans, router)
        let tracer = spans.provider.tracer("app", version: nil)

        let app = try await tracer.withActiveSpan("app") { app in
            for try await stream in try toolSpanStreamingRun(client) {
                // The tool runner span is open here, and it is not the current one.
                #expect(TracingContext.currentSpan.context.spanID == app.context.spanID)
                try await tracer.withActiveSpan("app.handle") { _ in try await stream.untilDone() }
            }
            return app.context.spanID
        }

        let span = try spans.one("anthropic.messages.tool_runner")
        let handled = spans.named("app.handle")
        #expect(handled.map(toolSpanParent) == [app, app])
        let end = try #require(span.endTime)
        #expect(handled.allSatisfy { ($0.endTime ?? .distantFuture) <= end })
    }

    /// Python's event loop closes the generators of runners left open when it ends; a Swift runner that is dropped
    /// while open ends its span the same way, with no status.
    @Test func streamingRunnersThatAreDroppedWhileOpenHaveNoStatus() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage()], stream: true)
        let client = try tracingClient(spans, router)

        do {
            var runners: [BetaStreamingToolRunner<Never>] = []
            for _ in 0..<8 { runners.append(try toolSpanStreamingRun(client)) }
            for runner in runners {
                for try await _ in runner { break }
            }
            #expect(spans.named("anthropic.messages.tool_runner").isEmpty)
        }

        // The last references go once the streams that were handed out end.
        let deadline = Date().addingTimeInterval(30)
        while spans.named("anthropic.messages.tool_runner").count < 8 && Date() < deadline {
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        #expect(spans.named("anthropic.messages.tool_runner").map(\.statusCode) == Array(repeating: .unset, count: 8))
    }

    @Test func closingTheStreamingRunnerDuringACompactionClosesItsStream() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        // The close leaves the compaction response unread, so any body will do for it.
        let route = toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: true)
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router))

        var items = 0
        for try await _ in runner {
            items += 1
            if items == 2 { break }
            try await runner.compactBeforeNextTurn()
        }
        #expect(route.requests[1].jsonBody?["compaction"] != nil)
        await runner.close()

        // The stream of the compaction request is closed when `close()` returns, before the tool runner span ends.
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .unset)
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls.allSatisfy { toolSpanParent($0) == span.spanID })
        let end = try #require(span.endTime)
        #expect(calls.allSatisfy { ($0.endTime ?? .distantFuture) <= end })
    }

    @Test func cancelingAToolRunLeavesItsSpanAndTheToolRunnerSpanUnset() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let started = EnvEvent()
        // The application cancels the task that drives the loop while the tool is running.
        let runner = try toolSpanRun(try tracingClient(spans, router, openTelemetry: spans.option(traces: content)),
                                     tools: [toolSpanWeatherTool { city in
                                         started.set()
                                         try await Task.sleep(nanoseconds: 60_000_000_000)
                                         return .string(city)
                                     }])

        let task = Task { try await runner.untilDone() }
        await started.wait()
        task.cancel()
        await #expect(throws: CancellationError.self) { _ = try await task.value }

        // A cancellation is the application stopping the run, which is no failure of the tool or the loop.
        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        #expect(tool.statusCode == .unset)
        #expect(tool["error.type"] == nil)
        // The runner made no result of the run.
        #expect(tool.json("gen_ai.tool.call.arguments") == ["city": "SF"])
        #expect(tool["anthropic.tool_result.content"] == nil)
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    // MARK: Streams

    @Test func streamingRunner() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: true)
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: content))

        for try await stream in try toolSpanStreamingRun(client) {
            for try await _ in stream {}
        }

        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .ok)
        let calls = spans.named("anthropic.messages.create")
        try #require(calls.count == 2)
        #expect(calls.allSatisfy { toolSpanParent($0) == span.spanID })
        #expect(calls.allSatisfy { $0.statusCode == .ok })
        // The runner streams with the stream helper, whose snapshot gives each call's output content.
        #expect(calls.map { $0.json("gen_ai.output.messages")?[0]?["parts"] } == [
            [["type": "tool_call", "id": "toolu_SF", "name": "get_weather", "arguments": ["city": "SF"]]],
            [["type": "text", "content": "It is sunny."]],
        ])
        #expect(toolSpanParent(try spans.one("anthropic.custom_tool_use get_weather")) == span.spanID)
    }

    @Test(arguments: ["SF", "Atlantis"]) func toolThatRunsWhileTheReplyStreamsHasItsSpan(city: String) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let route = toolSpanMessages(router, [toolSpanToolUseMessage(city), toolSpanFinal], stream: true)
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: content))

        var toolSpansAtTheEndOfEachReply: [Int] = []
        _ = try await ToolDiagnostics.capture {
            try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { _ in
                for try await stream in try toolSpanStreamingRun(client, eager: true) {
                    for try await event in stream {
                        if case .messageStop = event {
                            toolSpansAtTheEndOfEachReply.append(spans.named("anthropic.custom_tool_use get_weather").count)
                        }
                    }
                }
            }
        }

        // The tool ran, in its span, before the application had read the whole reply that called it, and the result
        // that the runner kept from that run did not start a second span when it sent the result.
        #expect(toolSpansAtTheEndOfEachReply == [1, 1])
        let tool = try spans.one("anthropic.custom_tool_use get_weather")
        let span = try spans.one("anthropic.messages.tool_runner")
        // The runner ran the tool, so the span is a child of its span, not of the span that the application read from.
        #expect(toolSpanParent(tool) == span.spanID)
        #expect(tool["gen_ai.tool.call.id"] == .string("toolu_\(city)"))
        #expect(tool.json("gen_ai.tool.call.arguments") == ["city": .string(city)])
        if city == "Atlantis" {
            #expect(tool.statusCode == .error)
            #expect(tool["error.type"] == "tool_error")
        } else {
            #expect(tool.statusCode == .ok)
            #expect(tool["error.type"] == nil)
        }
        #expect(span.statusCode == .ok)
        #expect(toolSpanSent(route).map { $0["tool_use_id"] } == [.string("toolu_\(city)")])
    }

    @Test func toolCallThatTheApplicationHoldsHasOneSpanWhenItRuns() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        var reply = toolSpanToolUseMessage()
        reply["content"] = .array(reply["content"]!.arrayValue! + [["type": "tool_use", "id": "toolu_LA", "name": "get_weather", "input": ["city": "LA"]]])
        toolSpanMessages(router, [reply, toolSpanFinal], stream: true)
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router), eager: true)

        var callsWithASpanAtTheEndOfEachReply: [[String]] = []
        for try await stream in runner {
            for try await event in stream {
                if case .contentBlockStart(let start) = event, case .toolUse(let call) = start.contentBlock, call.id == "toolu_LA" {
                    await runner.deferToolCall(call)
                }
            }
            callsWithASpanAtTheEndOfEachReply.append(spans.named("anthropic.custom_tool_use get_weather").compactMap { $0["gen_ai.tool.call.id"]?.stringValue })
        }

        // The held call ran after the application was done with the reply, and each call has one span.
        #expect(callsWithASpanAtTheEndOfEachReply == [["toolu_SF"], ["toolu_SF", "toolu_LA"]])
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(spans.named("anthropic.custom_tool_use get_weather").allSatisfy { toolSpanParent($0) == span.spanID })
    }

    enum Reader: String, CaseIterable, Sendable { case application, untilDone = "until_done", loop }

    /// The checks of a runner that a tool or toolset member closed while it ran inside a read of the reply.
    func expectClosedFromAnEagerTool(_ spans: TracingSpans, _ tools: [SpanData], ids: [String]) throws {
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .unset)
        #expect(span["error.type"] == nil)
        #expect(tools.compactMap { $0["gen_ai.tool.call.id"]?.stringValue } == ids)
        #expect(tools.allSatisfy { $0.statusCode == .ok })
        #expect(tools.allSatisfy { toolSpanParent($0) == span.spanID })
        // The close ended nothing while a tool ran, so the runner's span outlasted the tools' spans.
        let end = try #require(span.endTime)
        #expect(tools.allSatisfy { ($0.endTime ?? .distantFuture) <= end })
        #expect(spans.named("anthropic.messages.create").count == 1)
    }

    /// Reads `runner` as `reader` does, and returns the types of the events that the application read.
    func read(_ runner: BetaStreamingToolRunner<Never>, _ reader: Reader) async throws -> [String] {
        var events: [String] = []
        if reader == .untilDone {
            #expect(try await runner.untilDone().id == "msg_SF")
        } else {
            var streams = 0
            for try await stream in runner {
                streams += 1
                if reader == .application {
                    events = []
                    for try await event in stream {
                        if case .messageStop = event { events.append("message_stop") } else { events.append("other") }
                    }
                }
            }
            #expect(streams == 1)
        }
        if reader == .application { #expect(events.last == "message_stop") }
        var rest = 0
        for try await _ in runner { rest += 1 }
        #expect(rest == 0)
        return events
    }

    @Test(arguments: Reader.allCases) func closingTheRunnerFromAToolThatRunsWhileTheReplyStreamsStopsTheLoop(reader: Reader) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        var reply = toolSpanToolUseMessage()
        reply["content"] = .array(reply["content"]!.arrayValue! + [["type": "tool_use", "id": "toolu_LA", "name": "get_weather", "input": ["city": "LA"]]])
        toolSpanMessages(router, [reply, toolSpanFinal], stream: true)
        let cities = ToolsBox<[String]>([])
        let box = ToolsBox<BetaStreamingToolRunner<Never>?>(nil)
        let tool = toolSpanWeatherTool { city in
            cities.mutate { $0.append(city) }
            await box.value?.close()
            return .string(city)
        }
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router), eager: true, tools: [tool],
                                              messages: [.user(BetaUserMessageParam(content: .string("What is the weather in SF and in LA?")))])
        box.value = runner

        // The tool runs inside a read of the reply, by the application or by the loop, which the close must not break:
        // it closes nothing while the tool runs, and the loop stops at its next step, as it does for any other tool.
        _ = try await read(runner, reader)
        box.value = nil

        #expect(cities.value == ["SF", "LA"])
        try expectClosedFromAnEagerTool(spans, spans.named("anthropic.custom_tool_use get_weather"), ids: ["toolu_SF", "toolu_LA"])
    }

    /// A toolset whose members close the runner (`ClosingToolset`).
    final class ClosingToolset: ToolsetEchoBrowser, @unchecked Sendable {
        let runner = ToolsBox<BetaStreamingToolRunner<Never>?>(nil)

        override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
            await runner.value?.close()
            return try await super.call(context: context, name: name, input: input)
        }
    }

    @Test(arguments: Reader.allCases)
    func closingTheRunnerFromAToolsetMemberThatRunsWhileTheReplyStreamsStopsTheLoop(reader: Reader) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let reply = toolSpanMemberCalls(("toolu_1", "navigate", "browser"), ("toolu_2", "screenshot", "browser"))
        toolSpanMessages(router, [reply, toolSpanFinal], stream: true)
        let toolset = ClosingToolset()
        let runner = try toolSpanStreamingRun(try tracingClient(spans, router), eager: true, tools: [toolset],
                                              messages: [.user(BetaUserMessageParam(content: .string("Open the page.")))])
        toolset.runner.value = runner

        // As for a tool, the close closes nothing while the member runs inside a read of the reply.
        _ = try await read(runner, reader)
        toolset.runner.value = nil

        #expect(toolset.calls.map { $0.0 } == ["navigate", "screenshot"])
        try expectClosedFromAnEagerTool(spans, toolSpanToolSpans(spans), ids: ["toolu_1", "toolu_2"])
    }

    @Test func onlyTheAPICallsOfAToolRunnerHaveHTTPAndURLAttributes() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])

        _ = try await toolSpanRun(try tracingClient(spans, router)).untilDone()

        var http: [String: [String]] = [:]
        for span in spans.finished {
            http["\(span.name) \(span.kind)"] = span.attributes.keys.filter { $0.hasPrefix("http.") || $0.hasPrefix("url.") || $0.hasPrefix("server.") }
                .sorted()
        }
        #expect(http == [
            "anthropic.messages.tool_runner \(SpanKind.internal)": [],
            "anthropic.custom_tool_use get_weather \(SpanKind.internal)": [],
            "anthropic.messages.create \(SpanKind.client)": [
                "http.request.method", "http.response.status_code", "http.route", "server.address", "server.port", "url.full", "url.path",
                "url.scheme",
            ],
        ])
    }

    // MARK: MCP tools and toolsets

    @Test(arguments: [false, true]) func aToolTheMCPHelperMadeRunsInAnMCPToolUseSpan(withDescription: Bool) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])
        let mcp = MCPTool(name: "get_weather", description: withDescription ? "The weather, from the MCP server." : nil,
                          inputSchema: ["type": "object", "properties": [:]])

        _ = try await toolSpanRun(try tracingClient(spans, router), tools: [mcpTool(mcp, client: FakeMCPSession())]).untilDone()

        let tool = try spans.one("anthropic.mcp_tool_use get_weather")
        #expect(tool.kind == .internal)
        #expect(tool.statusCode == .ok)
        #expect(toolSpanParent(tool) == (try spans.one("anthropic.messages.tool_runner")).spanID)
        var expected: SpanAttributes = [
            "gen_ai.operation.name": "execute_tool", "gen_ai.provider.name": "anthropic", "gen_ai.tool.name": "get_weather",
            "gen_ai.tool.call.id": "toolu_SF", "gen_ai.tool.type": "function",
        ]
        if withDescription { expected["gen_ai.tool.description"] = "The weather, from the MCP server." }
        #expect(tool.attributes == expected)
        #expect(spans.named("anthropic.custom_tool_use get_weather").isEmpty)
    }

    @Test(arguments: ToolSpanMode.allCases) func toolsetMemberThatTheRunnerRunsHasAToolSpan(mode: ToolSpanMode) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let client = try tracingClient(spans, router, openTelemetry: spans.option(conversationID: "conv_1"))

        let route = try await toolSpanRunWithABrowserToolset(
            router, toolSpanMemberCalls(("toolu_1", "navigate", "browser"), ("toolu_2", "screenshot", "browser")), client: client, mode: mode)

        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(span.statusCode == .ok)
        // Each member call that the toolset ran has one span, in the model's order.
        let tools = toolSpanToolSpans(spans)
        #expect(tools.map(\.name) == ["anthropic.custom_tool_use navigate", "anthropic.custom_tool_use screenshot"])
        for (tool, (name, id)) in zip(tools, [("navigate", "toolu_1"), ("screenshot", "toolu_2")]) {
            #expect(tool.kind == .internal)
            #expect(tool.statusCode == .ok)
            #expect(toolSpanParent(tool) == span.spanID)
            // A toolset has no description, and the call's input and result are content.
            #expect(tool.attributes == [
                "gen_ai.operation.name": "execute_tool", "gen_ai.provider.name": "anthropic", "gen_ai.tool.name": .string(name),
                "anthropic.toolset.name": "browser", "gen_ai.tool.call.id": .string(id), "gen_ai.conversation.id": "conv_1",
                "gen_ai.tool.type": "function",
            ])
        }
        // The spans are of the runs whose results the runner sent, and tracing made no request of its own.
        #expect(route.requests.count == 2)
        #expect(toolSpanSent(route).map { [$0["tool_use_id"] ?? nil, $0["content"] ?? nil] } == [
            ["toolu_1", #"navigate:{"step": 0}"#], ["toolu_2", #"screenshot:{"step": 1}"#],
        ])
    }

    @Test func toolsetMemberThatRunsWhileTheReplyStreamsHasItsSpan() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let client = try tracingClient(spans, router)
        let counts = ToolsBox<[Int]>([])

        _ = try await spans.provider.tracer("app", version: nil).withActiveSpan("app") { _ in
            try await toolSpanRunWithABrowserToolset(
                router, toolSpanMemberCalls(("toolu_1", "navigate", "browser"), ("toolu_2", "screenshot", "browser")), client: client,
                mode: .eager, atTheEndOfEachReply: { counts.mutate { $0.append(toolSpanToolSpans(spans).count) } })
        }

        // Both members ran, each in its span, before the application had read the whole reply that called them, and
        // the results that the runner kept from those runs did not start more spans when it sent them.
        #expect(counts.value == [2, 2])
        // The runner ran the members, so their spans are children of its span, not of the span that the application
        // read the reply from.
        let span = try spans.one("anthropic.messages.tool_runner")
        #expect(toolSpanToolSpans(spans).map(toolSpanParent) == [span.spanID, span.spanID])
        #expect(toolSpanToolSpans(spans).compactMap { $0["gen_ai.tool.call.id"]?.stringValue } == ["toolu_1", "toolu_2"])
    }

    @Test(arguments: ToolSpanMode.allCases)
    func toolsetMemberThatFailsHasAToolErrorAndTheMembersItStopsHaveNoSpan(mode: ToolSpanMode) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let client = try tracingClient(spans, router, openTelemetry: spans.option(traces: content))

        let route = try await toolSpanRunWithABrowserToolset(
            router, toolSpanMemberCalls(("toolu_1", "boom", "browser"), ("toolu_2", "navigate", "browser")), client: client, mode: mode)

        let tools = toolSpanToolSpans(spans)
        try #require(tools.count == 1)
        let tool = tools[0]
        #expect(tool.name == "anthropic.custom_tool_use boom")
        #expect(tool.statusCode == .error)
        #expect(tool["error.type"] == "tool_error")
        #expect(tool["gen_ai.tool.call.id"] == "toolu_1")
        #expect(tool.json("gen_ai.tool.call.arguments") == ["step": 0])
        // The content of the error result that the toolset made of the member's error.
        #expect(tool.json("anthropic.tool_result.content") == [["type": "text", "text": "member refused"]])
        #expect(try spans.one("anthropic.messages.tool_runner").statusCode == .ok)
        // The runner answered the later member without running it, so that call has no span.
        let sent = toolSpanSent(route)
        #expect(sent.map { [$0["tool_use_id"] ?? nil, $0["is_error"] ?? nil] } == [["toolu_1", true], ["toolu_2", true]])
        #expect(sent.count == 2 && sent[1]["content"] == "Not executed: an earlier action in this turn failed.")
    }

    @Test(arguments: ToolSpanMode.allCases) func toolsetCallThatNoToolsetOfTheRunnerRunsHasNoSpan(mode: ToolSpanMode) async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        let client = try tracingClient(spans, router)

        let (route, capture) = try await ToolDiagnostics.capture {
            // A member of a toolset that the runner doesn't have, and a call named like its toolset.
            try await toolSpanRunWithABrowserToolset(
                router, toolSpanMemberCalls(("toolu_1", "screenshot", "computer"), ("toolu_2", "browser", nil)), client: client, mode: mode)
        }

        #expect(capture.warnings.contains { $0.contains("Toolset 'computer'") && $0.contains("not found in tool runner") })
        #expect(toolSpanToolSpans(spans).isEmpty)
        #expect(try spans.one("anthropic.messages.tool_runner").statusCode == .ok)
        #expect(toolSpanSent(route).map { [$0["tool_use_id"] ?? nil, $0["is_error"] ?? nil] } == [["toolu_1", true], ["toolu_2", true]])
    }

    // MARK: Without tracing

    @Test(arguments: ["sampler", "on_start", "on_end"], [false, true])
    func tracingThatFailsLeavesTheToolRunnerAsItIs(failure: String, stream: Bool) async throws {
        let router = TracingRouter()
        let route = toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal], stream: stream)
        let client = try tracingClient(nil, router, openTelemetry: tracingFailingOption(failure))

        let message: BetaMessage = stream ? try await toolSpanStreamingRun(client).untilDone().message : try await toolSpanRun(client).untilDone()

        #expect(message.id == "msg_final")
        #expect(route.requests.count == 2)
        // The second request has the result of the tool, which ran.
        let sent = toolSpanSent(route)
        try #require(sent.count == 1)
        #expect(sent[0]["tool_use_id"] == "toolu_SF")
        #expect(try JSONValue.parse(sent[0]["content"]?.stringValue ?? "") == ["city": "SF", "weather": "sunny"])
    }

    @Test func noSpansWithoutATracer() async throws {
        let spans = TracingSpans()
        let router = TracingRouter()
        toolSpanMessages(router, [toolSpanToolUseMessage(), toolSpanFinal])

        #expect(try await toolSpanRun(try tracingClient(spans, router, openTelemetry: .disabled)).untilDone().id == "msg_final")
        #expect(spans.finished.isEmpty)
    }
}
