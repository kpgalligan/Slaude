// Port of `tests/lib/tools/toolsets/test_runner.py`, `test_browser_runner.py` and `test_computer_runner.py`:
// toolset member routing through `client.beta.messages.toolRunner`, with the Messages responses mocked so the runner
// sees `tool_use` blocks carrying `toolset_name` exactly as the API stamps them.

import Foundation
import Testing
@testable import Anthropic

private func use(_ name: String, _ id: String, _ input: JSONValue = [:], family: String? = nil) -> JSONValue {
    var block: [String: JSONValue] = ["type": "tool_use", "id": .string(id), "name": .string(name), "input": input]
    if let family { block["toolset_name"] = .string(family) }
    return .object(block)
}

private func turn(_ blocks: JSONValue...) -> JSONValue { messageResponse(id: "msg_tool_use", content: blocks, stopReason: "tool_use") }

private let DONE = endTurnResponse()
private let HALT = "Not executed: an earlier computer action in this turn failed."

private func runner(_ mock: MessagesMock, _ tools: [any BetaToolLike], messages: [BetaMessageParam] = [toolsUserMessage("Open example.com")],
                    thread: Bool? = false) throws -> BetaToolRunner
{
    try mock.client().beta.messages.toolRunner(maxTokens: 1024, messages: messages, model: "claude-haiku-4-5", tools: tools, thread: thread)
}

/// A function tool called `name` that echoes its `url` (`navigate` sharing a browser member's name).
private func customTool(_ name: String = "navigate") -> BetaFunctionTool {
    BetaFunctionTool(name: name, description: "Custom tool that shares a browser member's name.",
                     inputSchema: ["type": "object", "properties": ["url": ["type": "string"]]]) { input in
        .string("custom:\(input["url"]?.stringValue ?? "")")
    }
}

private func noopTool(_ name: String) -> BetaFunctionTool { recordingTool(name, ToolsBox([])) }

/// The `content` of the last message of request `index`.
private func lastResults(_ mock: MessagesMock, _ index: Int = 1) -> [JSONValue] {
    mock.bodies[index]["messages"]?.arrayValue?.last?["content"]?.arrayValue ?? []
}

private func helperTags(_ mock: MessagesMock, _ index: Int) -> [String] {
    (mock.requests[index].headers["x-stainless-helper"] ?? "").split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
}

@Suite struct ToolsetRunnerRoutingTests {
    @Test func memberCallRoutesByFamilyNotName() async throws {
        let mock = MessagesMock([
            turn(use("navigate", "toolu_member", ["url": "https://example.com"], family: "browser"),
                 use("navigate", "toolu_custom", ["url": "https://custom.test"])),
            DONE,
        ])
        let toolset = ToolsetEchoBrowser()
        let results = try await collectToolResults(try runner(mock, [toolset, customTool()]))
        #expect(toolset.calls.map(\.0) == ["navigate"] && toolset.calls[0].1 == ["url": "https://example.com"])
        #expect(results == [[
            "role": "user",
            "content": [
                ["type": "tool_result", "tool_use_id": "toolu_member", "toolset_name": "browser", "content": #"navigate:{"url": "https://example.com"}"#],
                ["type": "tool_result", "tool_use_id": "toolu_custom", "content": "custom:https://custom.test"],
            ],
        ]])
        // Wire golden: the toolset goes out as its nameless entry, nothing SDK-side leaks.
        let sent = mock.bodies[0]["tools"]?.arrayValue ?? []
        #expect(sent.count == 2 && sent[0] == TOOLSET_BROWSER_ENTRY && sent[1]["name"] == "navigate")
    }

    @Test func anUnregisteredFamilyIsAnErrorResultWithToolsetName() async throws {
        // and its async twin
        let mock = MessagesMock([turn(use("screenshot", "toolu_cu", family: "computer")), DONE])
        let toolset = ToolsetEchoBrowser()
        let screenshot = ToolsBox<[String]>([])
        let (results, capture) = try await ToolDiagnostics.capture {
            try await collectToolResults(try runner(mock, [toolset, recordingTool("screenshot", screenshot)]))
        }
        #expect(capture.warnings.contains { $0.contains("Toolset 'computer' (member 'screenshot') not found in tool runner") })
        #expect(toolset.calls.isEmpty && screenshot.value.isEmpty)
        #expect(results == [[
            "role": "user",
            "content": [[
                "type": "tool_result", "tool_use_id": "toolu_cu", "toolset_name": "computer",
                "content": "Error: Toolset 'computer' member 'screenshot' not found", "is_error": true,
            ]],
        ]])
    }

    @Test func unregisteredFamilyNamesAreFoldedBeforeTheyReachALogOrTheResult() async throws {
        let weirdFamily = "comp\nuter\u{1b}[2J" + String(repeating: "x", count: 500)
        let mock = MessagesMock([turn(use("scr\u{202e}een", "toolu_cu", family: weirdFamily)), DONE])
        let (results, capture) = try await ToolDiagnostics.capture { try await collectToolResults(try runner(mock, [ToolsetEchoBrowser()])) }
        let warned = capture.warnings.first { $0.contains("not found in tool runner") } ?? ""
        let content = results[0]["content"]?[0]?["content"]?.stringValue ?? ""
        for text in [String(warned.components(separatedBy: ". Registered")[0]), content] {
            #expect(!text.contains("\n") && !text.contains("\u{1b}") && !text.contains("\u{202e}") && text.count < 500)
        }
        #expect(content.hasPrefix("Error: Toolset 'comp uter [2J" + String(repeating: "x", count: 20)))
    }

    @Test func aFamilyOrTypeNamedBlockWithoutToolsetNameIsNotAMemberCall() async throws {
        let mock = MessagesMock([turn(use("browser", "toolu_family"), use("browser_toolset_20260801", "toolu_type"), use("computer", "toolu_other")), DONE])
        let toolset = ToolsetEchoBrowser()
        let (results, capture) = try await ToolDiagnostics.capture { try await collectToolResults(try runner(mock, [toolset])) }
        #expect(capture.warnings.map { String($0.split(separator: ".")[0]) } == [
            "Tool 'browser_toolset_20260801' not found in tool runner", "Tool 'computer' not found in tool runner",
        ])
        #expect(toolset.calls.isEmpty)
        #expect(results == [[
            "role": "user",
            "content": [
                ["type": "tool_result", "tool_use_id": "toolu_family",
                 "content": "Error: the 'browser' toolset could not run this call: the call has no 'actions' list; nothing in the batch was executed",
                 "is_error": true],
                ["type": "tool_result", "tool_use_id": "toolu_type", "content": "Error: Tool 'browser_toolset_20260801' not found", "is_error": true],
                ["type": "tool_result", "tool_use_id": "toolu_other", "content": "Error: Tool 'computer' not found", "is_error": true],
            ],
        ]])
    }

    @Test func memberErrorsCarryToolsetName() async throws {
        let mock = MessagesMock([turn(use("boom", "toolu_boom", family: "browser")), turn(use("crash", "toolu_crash", family: "browser")), DONE])
        let results = try await collectToolResults(try runner(mock, [ToolsetEchoBrowser()]))
        #expect(results.map { $0["content"] } == [
            [["type": "tool_result", "tool_use_id": "toolu_boom", "toolset_name": "browser",
              "content": [["type": "text", "text": "member refused"]], "is_error": true]],
            [["type": "tool_result", "tool_use_id": "toolu_crash", "toolset_name": "browser",
              "content": "RuntimeError('backend exploded')", "is_error": true]],
        ])
    }

    @Test func aFailedMemberStopsTheRestOfTheTurnsMembersButNotFunctionTools() async throws {
        // the sync and async twins
        let mock = MessagesMock([
            turn(use("navigate", "toolu_1", ["url": "a"], family: "browser"), use("navigate", "toolu_fn1", ["url": "f1"]),
                 use("boom", "toolu_2", family: "browser"), use("navigate", "toolu_3", ["url": "c"], family: "browser"),
                 use("navigate", "toolu_fn2", ["url": "f2"])),
            turn(use("nope", "toolu_fn3"), use("navigate", "toolu_4", ["url": "d"], family: "browser")),
            DONE,
        ])
        let toolset = ToolsetEchoBrowser()
        let (results, capture) = try await ToolDiagnostics.capture { try await collectToolResults(try runner(mock, [toolset, customTool()])) }
        #expect(capture.warnings.contains { $0.contains("not found") })
        var first: [String: (Bool, JSONValue)] = [:]
        for r in results[0]["content"]?.arrayValue ?? [] { first[r["tool_use_id"]!.stringValue!] = (r["is_error"] == true, r["content"]!) }
        #expect(first["toolu_1"]! == (false, #"navigate:{"url": "a"}"#))
        #expect(first["toolu_2"]! == (true, [["type": "text", "text": "member refused"]]))
        #expect(first["toolu_3"]! == (true, "Not executed: an earlier action in this turn failed."))
        #expect(first["toolu_fn1"]! == (false, "custom:f1") && first["toolu_fn2"]! == (false, "custom:f2"))
        #expect(toolset.calls.map(\.1) == [["url": "a"], [:], ["url": "d"]])  // toolu_3 never reached the toolset
        var second: [String: Bool] = [:]
        for r in results[1]["content"]?.arrayValue ?? [] { second[r["tool_use_id"]!.stringValue!] = r["is_error"] == true }
        #expect(second == ["toolu_fn3": true, "toolu_4": false])
    }

    @Test func aToolRemovalOfAMemberNameDoesNotWithdrawTheToolset() async throws {
        let mock = MessagesMock([turn(use("navigate", "toolu_member", ["url": "u"], family: "browser"), use("navigate", "toolu_custom", ["url": "u"])), DONE])
        let toolset = ToolsetEchoBrowser()
        let messages = [toolsUserMessage("Open example.com"), try param(toolChangesMessage(toolReferenceBlock("tool_removal", "navigate")))]
        let (results, capture) = try await ToolDiagnostics.capture {
            try await collectToolResults(try runner(mock, [toolset, customTool()], messages: messages))
        }
        #expect(capture.warnings.contains { $0.contains("Tool 'navigate' not found in tool runner") })
        #expect(toolset.calls.map(\.0) == ["navigate"])
        #expect(results == [[
            "role": "user",
            "content": [
                ["type": "tool_result", "tool_use_id": "toolu_member", "toolset_name": "browser", "content": #"navigate:{"url": "u"}"#],
                ["type": "tool_result", "tool_use_id": "toolu_custom", "content": "Error: Tool 'navigate' not found", "is_error": true],
            ],
        ]])
    }

    @Test func memberCallRoundtrip() async throws {
        let mock = MessagesMock([
            turn(use("navigate", "toolu_member", ["url": "https://example.com"], family: "browser"),
                 use("navigate", "toolu_custom", ["url": "https://custom.test"]), use("boom", "toolu_boom", family: "browser")),
            DONE,
        ])
        let toolset = ToolsetEchoBrowser()
        let results = try await collectToolResults(try runner(mock, [toolset, customTool()]))
        #expect(toolset.calls.map(\.0) == ["navigate", "boom"])
        #expect(results[0]["content"]?[2] == [
            "type": "tool_result", "tool_use_id": "toolu_boom", "toolset_name": "browser",
            "content": [["type": "text", "text": "member refused"]], "is_error": true,
        ])
        #expect(mock.bodies[0]["tools"]?[0] == TOOLSET_BROWSER_ENTRY)
    }

    @Test func everyCallToAnUnregisteredFamilyInATurnSaysNotFound() async throws {
        let mock = MessagesMock([turn(use("screenshot", "toolu_screenshot", family: "computer"), use("left_click", "toolu_left_click", family: "computer")), DONE])
        let (results, capture) = try await ToolDiagnostics.capture { try await collectToolResults(try runner(mock, [ToolsetEchoBrowser()])) }
        #expect(capture.warnings.contains { $0.contains("not found in tool runner") })
        #expect(results[0]["content"]?.arrayValue?.map { $0["content"] } == [
            "Error: Toolset 'computer' member 'screenshot' not found", "Error: Toolset 'computer' member 'left_click' not found",
        ])
    }

    @Test func theRunnerPassesTheToolUseAsContextAndLeavesTheToolsetOpen() async throws {
        // the sync and async twins
        let mock = MessagesMock([
            turn(use("navigate", "toolu_member", ["url": "u"], family: "browser")), DONE,
            turn(use("misuse", "toolu_misuse", family: "browser")),
            turn(use("navigate", "toolu_again", ["url": "v"], family: "browser")), DONE,
        ])
        let toolset = ToolsetEchoBrowser()
        _ = try await collectToolResults(try runner(mock, [toolset]))
        #expect(toolset.contexts[0].toolUse?.id == "toolu_member" && toolset.closed == 0)

        await #expect(throws: ToolsetContractError.self) { _ = try await runner(mock, [toolset]).untilDone() }
        #expect(toolset.contexts[1].toolUse?.id == "toolu_misuse" && toolset.closed == 0)

        _ = try await collectToolResults(try runner(mock, [toolset]))  // the same instance serves another run
        #expect(toolset.calls.filter { $0.0 == "navigate" }.map(\.1) == [["url": "u"], ["url": "v"]] && toolset.closed == 0)
    }

    @Test func closeAndUseMarkTheToolsetClosed() async throws {
        let late = toolsetUse("navigate", ["url": "u"], id: "toolu_late")
        let toolset = ToolsetEchoBrowser()
        try await toolset.use { _ = try await toolset.toolResultJSON(late) }
        #expect(toolset.closed == 1)
        do {
            _ = try await toolset.toolResultJSON(late)
            Issue.record("expected the toolset to be closed")
        } catch let error as ToolsetClosedError {
            #expect(error.message.contains("is closed"))
        }
        await #expect(throws: ToolsetClosedError.self) { try await toolset.use {} }

        let twice = ToolsetEchoBrowser()
        try await twice.use { try await twice.close() }
        #expect(twice.closed == 1)  // closed inside the block: the block does not close again
    }

    @Test func theHelperHeaderNamesTheToolsetTheRunnerWasCreatedWith() async throws {
        let mock = MessagesMock([DONE, DONE])
        _ = try await collectToolResults(try runner(mock, [try ToolsetFakeBrowser()]))
        _ = try await collectToolResults(try runner(mock, [customTool()]))
        #expect(helperTags(mock, 0).contains("browser-toolset") && helperTags(mock, 0).contains("BetaToolRunner"))
        #expect(!helperTags(mock, 1).contains("browser-toolset"))
    }
}

@Suite struct ToolsetBrowserRunnerTests {
    @Test func memberCallsRoundTripThroughTheRunner() async throws {
        let mock = MessagesMock([turn(use("navigate", "toolu_nav", ["url": "https://example.com/"], family: "browser"),
                                      use("teleport", "toolu_bad", family: "browser")), DONE])
        let browser = try ToolsetFakeBrowser()
        _ = try await runner(mock, [browser], thread: nil).untilDone()
        // The entry on the wire is exactly toDict(): the type plus enabled:false for unimplemented members.
        #expect(mock.bodies[0]["tools"] == [browser.toDict()])
        #expect(helperTags(mock, 0).contains("browser-toolset"))
        let results = lastResults(mock)
        #expect(results[0]["tool_use_id"] == "toolu_nav" && results[0]["toolset_name"] == "browser")
        #expect(results[0]["content"]?.arrayValue?.map { $0["type"] } == ["text", "browser_state"] && results[0]["is_error"] == nil)
        #expect(results[1] == [
            "type": "tool_result", "tool_use_id": "toolu_bad", "toolset_name": "browser",
            "content": [["type": "text", "text": "Error: unknown browser toolset member 'teleport'"]], "is_error": true,
        ])
        // The member and the state hook both saw the tool_use they were answering.
        #expect(browser.world.contexts[0].toolUse?.id == "toolu_nav" && browser.world.stateContexts[0].toolUse?.id == "toolu_nav")
    }

    @Test func memberCallsRoundTripThroughTheAsyncRunner() async throws {
        let mock = MessagesMock([turn(use("get_page_text", "toolu_txt", family: "browser")), DONE])
        _ = try await runner(mock, [try ToolsetFakeBrowser()]).untilDone()
        let results = lastResults(mock)
        #expect(results[0]["content"]?[0] == ["type": "text", "text": "Hello"] && results[0]["content"]?[1]?["type"] == "browser_state")
    }

    @Test(arguments: [true, false])
    func aToolsetRunsOnlyWhileSetMessagesParamsLeavesItsDefinitionInTools(_ kept: Bool) async throws {
        // and test_a_toolset_in_set_messages_params_is_sent_as_its_wire_entry
        let mock = MessagesMock([turn(use("navigate", "toolu_nav", ["url": "https://example.com/"], family: "browser")), DONE])
        let mine = try ToolsetFakeBrowser()
        let raw: JSONValue = ["type": "custom", "name": "raw", "input_schema": ["type": "object"]]
        let run = try runner(mock, [mine], messages: [toolsUserMessage("hi")])
        let tools: JSONValue = kept ? [mine.toDict(), raw] : [raw]
        try await run.setMessagesParams { params in
            var params = params
            params["tools"] = tools
            return params
        }
        let (_, capture) = try await ToolDiagnostics.capture { _ = try await run.untilDone() }
        #expect(mock.bodies[0]["tools"] == tools)
        #expect(lastResults(mock).first?["is_error"].map { $0 == true } ?? false == !kept)
        #expect(!mine.world.contexts.isEmpty == kept)
        if !kept { #expect(capture.warnings.contains { $0.contains("Toolset 'browser'") && $0.contains("not found in tool runner") }) }
    }

    @Test func addToolsRefusesAToolsetAndQueuesNothing() async throws {
        let mock = MessagesMock([DONE])
        let run = try runner(mock, [], messages: [toolsUserMessage("hi")])
        do {
            try await run.addTools(noopTool("get_time"), try ToolsetFakeBrowser())
            Issue.record("expected the toolset to be refused")
        } catch let error as ToolsetContractError {
            #expect(error.message.hasPrefix("add_tools() can't add the 'browser' toolset: a tool runner's toolsets are fixed"))
        }
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"] == [["role": "user", "content": "hi"]])
    }

    @Test(arguments: ["toolset", "its_name", "a_function_tool_named_like_it"])
    func removeToolsRefusesAToolsetAndQueuesNothing(_ removed: String) async throws {
        let mock = MessagesMock([DONE])
        let browser = try ToolsetFakeBrowser()
        let getTime = noopTool("get_time")
        let run = try runner(mock, [browser, getTime], messages: [toolsUserMessage("hi")])
        let expected = "remove_tools() can't remove the 'browser' toolset: a tool runner's toolsets are fixed when it is created; "
            + "build a new runner without it"
        do {
            switch removed {
            case "toolset": try await run.removeTools(getTime, browser)
            case "its_name": try await run.removeTools("get_time", "browser")
            default: try await run.removeTools(getTime, noopTool("browser"))
            }
            Issue.record("expected the toolset to be refused")
        } catch let error as ToolsetContractError {
            #expect(error.message == expected)
        }
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"] == [["role": "user", "content": "hi"]])
    }

    @Test(arguments: ["browser_toolset_20260801", "browser_toolset_20270101"])
    func addToolsRefusesARawDefinitionOfTheRunnersToolsetAndQueuesNothing(_ definitionType: String) async throws {
        let mock = MessagesMock([DONE])
        let run = try runner(mock, [try ToolsetFakeBrowser()], messages: [toolsUserMessage("hi")])
        do {
            try await run.addTools(noopTool("get_time"), JSONValue.object(["type": .string(definitionType)]))
            Issue.record("expected the definition to be refused")
        } catch let error as ToolsetContractError {
            #expect(error.message.hasPrefix("add_tools() can't replace the 'browser' toolset: "))
        }
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"] == [["role": "user", "content": "hi"]])
    }

    @Test(arguments: ["function_tool", "raw_definition"])
    func addToolsRefusesAToolNamedLikeTheRunnersToolsetAndQueuesNothing(_ added: String) async throws {
        let mock = MessagesMock([DONE])
        let run = try runner(mock, [try ToolsetFakeBrowser()], messages: [toolsUserMessage("hi")])
        let named: any BetaToolLike = added == "function_tool"
            ? noopTool("browser") : JSONValue.object(["name": "browser", "description": "A tool.", "input_schema": ["type": "object"]])
        do {
            try await run.addTools(noopTool("get_time"), named)
            Issue.record("expected the tool to be refused")
        } catch let error as ToolsetContractError {
            #expect(error.message
                == "add_tools() can't add a tool named 'browser': the runner's browser toolset has that name; give the tool another name")
        }
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"] == [["role": "user", "content": "hi"]])
    }

    @Test func addToolsSendsARawToolsetDefinitionOfAnotherFamily() async throws {
        let mock = MessagesMock([DONE])
        let run = try runner(mock, [try ToolsetFakeBrowser()], messages: [toolsUserMessage("hi")])
        let computer: JSONValue = ["type": "computer_toolset_20260801"]
        try await run.addTools(computer)
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"]?.arrayValue?.last == [
            "role": "system", "content": [["type": "tool_addition", "tool": ["type": "tool_definition", "definition": computer]]],
        ])
    }

    @Test func removeToolsRemovesAFunctionToolNamedLikeAMember() async throws {
        let mock = MessagesMock([DONE])
        let run = try runner(mock, [try ToolsetFakeBrowser(), noopTool("navigate")], messages: [toolsUserMessage("hi")])
        try await run.removeTools("navigate")
        _ = try await run.untilDone()
        #expect(mock.bodies[0]["messages"]?.arrayValue?.last == toolChangesMessage(toolReferenceBlock("tool_removal", "navigate")))
    }

    @Test func removeToolsWithAMemberNameRemovesOnlyTheFunctionToolOfThatName() async throws {
        let mock = MessagesMock([turn(use("navigate", "toolu_1", ["url": "https://a.test/"], family: "browser"), use("navigate", "toolu_fn")), DONE])
        let browser = try ToolsetFakeBrowser()
        let run = try runner(mock, [browser, noopTool("navigate")], messages: [toolsUserMessage("hi")])
        try await run.removeTools("navigate")
        let (_, capture) = try await ToolDiagnostics.capture { _ = try await run.untilDone() }
        #expect(capture.warnings.contains { $0.contains("Tool 'navigate' not found in tool runner") })
        #expect(browser.world.calls == ["navigate"])
        #expect(mock.bodies[0]["messages"]?.arrayValue?.last == toolChangesMessage(toolReferenceBlock("tool_removal", "navigate")))
        let results = lastResults(mock)
        #expect(results[0]["tool_use_id"] == "toolu_1" && results[0]["is_error"] == nil)
        #expect(results[1] == ["type": "tool_result", "tool_use_id": "toolu_fn", "content": "Error: Tool 'navigate' not found", "is_error": true])
    }

    @Test func aToolsetStandsInToolsForCreateAndCountTokens() async throws {
        // and the computer twin: Swift's create and countTokens take the generated tool params, so the toolset hands
        // over its entry as one
        let mock = MessagesMock([DONE, ["input_tokens": 3]])
        let browser = try ToolsetFakeBrowser()
        let desktop = try ToolsetFakeDesktop()
        let raw: JSONValue = ["type": "custom", "name": "raw", "input_schema": ["type": "object"]]
        let client = try mock.client()
        _ = try await client.beta.messages.create(maxTokens: 8, messages: [toolsUserMessage("hi")], model: "m",
                                                  tools: [try browser.toToolUnionParam(), try raw.decode()])
        _ = try await client.beta.messages.countTokens(messages: [toolsUserMessage("hi")], model: "m", tools: [try desktop.toToolUnionParam()])
        #expect(mock.bodies.map { $0["tools"] } == [[browser.toDict(), raw], [desktop.toDict()]])
    }
}

@Suite struct ToolsetComputerRunnerTests {
    @Test func memberCallsRoundTripThroughTheRunner() async throws {
        let mock = MessagesMock([turn(use("mouse_move", "toolu_move", ["coordinate": [10, 20]], family: "computer"),
                                      use("cursor_position", "toolu_pos", family: "computer"), use("teleport", "toolu_bad", family: "computer")), DONE])
        let desktop = try ToolsetFakeDesktop()
        _ = try await runner(mock, [desktop], thread: nil).untilDone()
        #expect(mock.bodies[0]["tools"] == [desktop.toDict()])
        #expect(helperTags(mock, 0).contains("computer-toolset"))
        let results = lastResults(mock)
        #expect(results[0] == ["type": "tool_result", "tool_use_id": "toolu_move", "toolset_name": "computer",
                               "content": [["type": "text", "text": "Moved the mouse."]]])
        #expect(results[1]["content"] == [["type": "text", "text": "X=10,Y=20"]])
        #expect(results[2] == ["type": "tool_result", "tool_use_id": "toolu_bad", "toolset_name": "computer",
                               "content": [["type": "text", "text": "Error: unknown computer toolset member 'teleport'"]], "is_error": true])
        #expect(desktop.desktop.contexts[0].toolUse?.id == "toolu_move")
    }

    @Test func aFailureHaltsTheLaterComputerActionsOfTheTurnWithTheComputerWording() async throws {
        let mock = MessagesMock([turn(use("left_click", "toolu_1", ["coordinate": [1, 1]], family: "computer"),
                                      use("key", "toolu_2", ["text": "Return"], family: "computer"), use("screenshot", "toolu_3", family: "computer")), DONE])
        let desktop = try ToolsetFakeDesktop()
        desktop.desktop.fail["key"] = RuntimeError("keyboard unplugged")
        _ = try await runner(mock, [desktop]).untilDone()
        let results = lastResults(mock)
        #expect(results.map { $0["tool_use_id"] } == ["toolu_1", "toolu_2", "toolu_3"])
        #expect(results[0]["is_error"] == nil)
        #expect(results[1]["is_error"] == true && results[1]["content"] == [["type": "text", "text": "RuntimeError: keyboard unplugged"]])
        #expect(results[2] == ["type": "tool_result", "tool_use_id": "toolu_3", "toolset_name": "computer", "content": .string(HALT), "is_error": true])
        #expect(desktop.desktop.calls == ["left_click", "key"])  // the screenshot was never taken
    }

    @Test func aComputerAndABrowserToolsetServeOneRequestByFamily() async throws {
        let mock = MessagesMock([turn(
            use("screenshot", "toolu_c1", family: "computer"), use("screenshot", "toolu_b1", family: "browser"),
            use("key", "toolu_c2", ["text": "a"], family: "computer"), use("key", "toolu_c3", ["text": "b"], family: "computer"),
            use("navigate", "toolu_b2", ["url": "https://example.com/"], family: "browser"),
            use("navigate", "toolu_b3", ["url": "https://example.com/"], family: "browser")), DONE])
        let desktop = try ToolsetFakeDesktop()
        let browser = try ToolsetFakeBrowser()
        desktop.desktop.fail["key"] = RuntimeError("stuck")
        browser.world.fail["navigate"] = RuntimeError("offline")
        _ = try await runner(mock, [desktop, browser]).untilDone()
        #expect(mock.bodies[0]["tools"] == [desktop.toDict(), browser.toDict()])
        var results: [String: JSONValue] = [:]
        for r in lastResults(mock) { results[r["tool_use_id"]!.stringValue!] = r }
        #expect(results["toolu_c1"]?["content"]?[0]?["type"] == "image" && results["toolu_c1"]?["toolset_name"] == "computer")
        #expect(results["toolu_b1"]?["content"]?.arrayValue?.map { $0["type"] } == ["image", "browser_state"])
        #expect(results["toolu_c3"]?["content"] == .string(HALT))
        #expect(results["toolu_b3"]?["content"] == "Not executed: an earlier action in this turn failed.")
        #expect(desktop.desktop.calls == ["screenshot", "key"] && browser.world.calls == ["screenshot", "navigate"])
    }

    @Test func aCallNamedAfterTheToolsetWithoutToolsetNameGetsAnErrorThatSaysWhatIsWrong() async throws {
        let calls: [(String, JSONValue)] = [
            ("text", ["actions": #"[{"action": "key",}]"#]), ("object", ["actions": ["action": "key"]]), ("empty", ["actions": []]),
            ("no_action", ["actions": [["action": "screenshot"], ["text": "a"]]]), ("not_text", ["actions": [["action": 5]]]),
            ("not_object", ["actions": ["key"]]), ("flat_number", ["action": 5]), ("null", ["actions": nil]),
            ("odd_name", ["actions": [["action": "a'b\nc  d"]]]), ("well_formed", ["actions": [["action": "screenshot"], ["action": "x"]]]),
            ("many", ["actions": .array((0..<12).map { ["action": .string("a\($0)")] })]), ("flat", ["action": "screenshot"]), ("none", [:]),
        ]
        var blocks = calls.map { use("computer", $0.0, $0.1) }
        blocks.append(["type": "tool_use", "id": "null_toolset", "name": "computer", "input": ["actions": []], "toolset_name": nil])
        blocks.append(use("calculator", "calculator"))
        let mock = MessagesMock([messageResponse(id: "msg_tool_use", content: blocks, stopReason: "tool_use"), DONE])
        let desktop = try ToolsetFakeDesktop()
        let (_, capture) = try await ToolDiagnostics.capture { _ = try await runner(mock, [desktop]).untilDone() }
        var results: [String: JSONValue] = [:]
        for r in lastResults(mock) { results[r["tool_use_id"]!.stringValue!] = r }
        let prefix = "Error: the 'computer' toolset could not run this call"
        let suffix = "; nothing in the batch was executed"
        let many = (0..<10).map { "'a\($0)'" }.joined(separator: ", ")
        let expected: [String: String] = [
            "text": "\(prefix): 'actions' is text, not a list of actions\(suffix)",
            "object": "\(prefix): 'actions' is not a list of actions\(suffix)",
            "empty": "\(prefix): the 'actions' list is empty\(suffix)",
            "no_action": "\(prefix): action 1 must be an object with a string 'action' field\(suffix)",
            "not_text": "\(prefix): action 0 must be an object with a string 'action' field\(suffix)",
            "not_object": "\(prefix): action 0 must be an object with a string 'action' field\(suffix)",
            "flat_number": "\(prefix): the call has no 'actions' list\(suffix)",
            "null": "\(prefix): 'actions' is not a list of actions\(suffix)",
            "odd_name": "\(prefix): its actions could not be run as sent (actions: 'a b c d')\(suffix)",
            "well_formed": "\(prefix): its actions could not be run as sent (actions: 'screenshot', 'x')\(suffix)",
            "many": "\(prefix): its actions could not be run as sent (actions: \(many), and 2 more)\(suffix)",
            "flat": "\(prefix): the call has no 'actions' list (action: 'screenshot')\(suffix)",
            "none": "\(prefix): the call has no 'actions' list\(suffix)",
            "null_toolset": "\(prefix): the 'actions' list is empty\(suffix)",
            // A name that is neither a tool nor a toolset in the run gets the plain not-found reply.
            "calculator": "Error: Tool 'calculator' not found",
        ]
        #expect(results.mapValues { $0["content"]?.stringValue ?? "" } == expected)
        #expect(results.values.allSatisfy { $0["is_error"] == true && $0["toolset_name"] == nil })
        #expect(capture.warnings.map { String($0.split(separator: ".")[0]) } == ["Tool 'calculator' not found in tool runner"])
        #expect(desktop.desktop.calls.isEmpty)
    }

    @Test func aCallNamedAfterTheToolsetStopsTheToolsetsLaterCallsInTheReply() async throws {
        let mock = MessagesMock([turn(use("mouse_move", "toolu_before", ["coordinate": [10, 20]], family: "computer"),
                                      use("computer", "toolu_bad", ["actions": "["]), use("cursor_position", "toolu_after", family: "computer")), DONE])
        let desktop = try ToolsetFakeDesktop()
        _ = try await runner(mock, [desktop]).untilDone()
        let results = lastResults(mock)
        #expect(results.map { [$0["tool_use_id"]!, .bool($0["is_error"] == true)] } == [["toolu_before", false], ["toolu_bad", true], ["toolu_after", true]])
        #expect(results[2]["content"] == .string(HALT))
        #expect(desktop.desktop.calls == ["mouse_move"])
    }

    @Test func memberCallsRoundTripThroughTheAsyncRunner() async throws {
        let mock = MessagesMock([turn(use("zoom", "toolu_z", ["region": [0, 0, 4, 4]], family: "computer")), DONE])
        _ = try await runner(mock, [try ToolsetFakeDesktop()]).untilDone()
        #expect(lastResults(mock)[0]["content"]?[0]?["source"]?["media_type"] == "image/jpeg")
    }
}
