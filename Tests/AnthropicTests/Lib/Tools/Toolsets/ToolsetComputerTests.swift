// Port of `tests/lib/tools/toolsets/test_computer_pipeline.py`, `test_computer_interface.py`,
// `test_computer_registry.py` and `test_computer_surface.py`.

import Foundation
import Testing
@testable import Anthropic

private let CTX = BetaToolsetCallContext(toolUse: toolsetUse("left_click", id: "toolu_7", family: "computer"))

private func computerUse(_ name: String, _ input: BetaToolInput = [:], id: String = "toolu_1") -> BetaToolUseBlock {
    toolsetUse(name, input, id: id, family: "computer")
}

private func call(_ desktop: BetaRunnableToolset, _ name: String, _ input: BetaToolInput = [:],
                  _ context: BetaToolsetCallContext = CTX) async throws -> JSONValue
{
    toolsetJSON(try await desktop.call(context: context, name: name, input: input))
}

/// The text of the `ToolError` a call throws (`str(caught.value)`).
private func errorText(_ desktop: BetaRunnableToolset, _ name: String, _ input: BetaToolInput = [:]) async -> String {
    await toolsetCallError { try await desktop.call(context: CTX, name: name, input: input) }?.message ?? ""
}

private func text(_ s: String) -> JSONValue { [["type": "text", "text": .string(s)]] }

@Suite struct ToolsetComputerPipelineTests {
    @Test func aScreenshotRendersAsOneImageBlock() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await call(desktop, "screenshot") == [["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": .string(TOOLSET_PNG)]]])
        // zoom is rendered the same way, with the media type the driver reported
        #expect(try await call(desktop, "zoom", ["region": [0, 0, 10, 10]])
            == [["type": "image", "source": ["type": "base64", "media_type": "image/jpeg", "data": .string(TOOLSET_PNG)]]])
        #expect(desktop.desktop.inputs.last == .betaComputerZoomInput(BetaComputerZoomInput(region: [0, 0, 10, 10])))
        // anything but the result model is the driver's bug: a ValueError, which reaches the model as an error result
        desktop.desktop.results["screenshot"] = .text("BBBB")
        await #expect(throws: ValueError("screenshot returned str, not its result model")) { _ = try await call(desktop, "screenshot") }
    }

    @Test func cursorPositionRendersAsATextLine() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await call(desktop, "cursor_position") == text("X=0,Y=0"))
        _ = try await call(desktop, "mouse_move", ["coordinate": [120, 45]])
        #expect(try await call(desktop, "cursor_position") == text("X=120,Y=45"))
        desktop.desktop.results["cursor_position"] = .text("1,2")  // not the result model: the driver's bug, named
        await #expect(throws: ValueError("cursor_position returned str, not its result model")) { _ = try await call(desktop, "cursor_position") }
    }

    @Test func aPureActionRendersItsAcknowledgmentThenTheLineItReturned() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await call(desktop, "left_click", ["coordinate": [1, 2]]) == text("Clicked."))
        #expect(try await call(desktop, "mouse_move", ["coordinate": [1, 2]]) == text("Moved the mouse."))
        #expect(try await call(desktop, "key", ["text": "ctrl+s"]) == text("Pressed ctrl+s."))
        #expect(try await call(desktop, "hold_key", ["text": "shift", "duration": 2]) == text("Held shift for 2s."))
        #expect(try await call(desktop, "type", ["text": "hello"]) == text("Typed."))
        #expect(try await call(desktop, "scroll", ["scroll_direction": "down", "scroll_amount": 3]) == text("Scrolled down."))
        #expect(try await call(desktop, "wait", ["duration": 3]) == text("Waited 3s."))

        let buttons = try ToolsetFakeDesktop(overridesExecute: true)
        buttons.executeHook = { _, _, _, _ in .nothing }
        #expect(try await call(buttons, "left_mouse_down") == text("Left mouse button pressed."))
        #expect(try await call(buttons, "left_mouse_up") == text("Left mouse button released."))
        #expect(try await call(buttons, "left_click_drag", ["start_coordinate": [1, 1], "coordinate": [2, 2]]) == text("Dragged."))

        // a line the action returned follows the acknowledgment, folded to one line and bounded
        desktop.desktop.results["left_click"] = .text("Window\n\u{202e}focused" + String(repeating: "x", count: 5000))
        let blocks = try await call(desktop, "left_click")
        #expect(blocks[0] == ["type": "text", "text": "Clicked."])
        let line = blocks[1]?["text"]?.stringValue ?? ""
        #expect(line.hasPrefix("Window focusedx") && line.unicodeScalars.count == 4096)
        desktop.desktop.results["left_click"] = .text("")  // blank: the acknowledgment only
        #expect(try await call(desktop, "left_click") == text("Clicked."))
    }

    @Test func aLineThatFoldsToNothingRendersAsTheAcknowledgmentAlone() async throws {
        // and its async twin
        let desktop = try ToolsetFakeDesktop()
        desktop.desktop.results["left_click"] = .text("\n \t\u{0}")
        #expect(try await call(desktop, "left_click") == text("Clicked."))
        let block = try await desktop.toolResultJSON(computerUse("left_click"))
        #expect(block["content"] == text("Clicked.") && block["is_error"] == nil)
        desktop.desktop.results["left_click"] = .text(" \u{2028} ")
        #expect(try await call(desktop, "left_click") == text("Clicked."))
    }

    @Test func aTemplateValueTheModelWroteStaysData() async throws {
        #expect(try await call(try ToolsetFakeDesktop(), "key", ["text": "{duration}\n{text}"]) == text("Pressed {duration} {text}."))
    }

    @Test func inputsAreParsedIntoTheGeneratedModels() async throws {
        // test_inputs_are_parsed_into_the_generated_models_and_undeclared_keys_are_kept: the typed input holds its
        // declared fields; a key the schema lacks stays on the tool_use the member is given.
        let desktop = try ToolsetFakeDesktop()
        _ = try await call(desktop, "key", ["text": "a", "repeat": 3, "tab_id": "t1"],
                           BetaToolsetCallContext(toolUse: computerUse("key", ["text": "a", "repeat": 3, "tab_id": "t1"])))
        guard case .betaComputerKeyInput(let parsed)? = desktop.desktop.inputs.last else { Issue.record("not a key input"); return }
        #expect(parsed.repeat == 3)
        #expect(desktop.desktop.contexts.last?.toolUse?.input["tab_id"] == "t1")
    }

    @Test func aBadFieldIsRefusedWithoutEchoingTheValue() async throws {
        let desktop = try ToolsetFakeDesktop()
        let wait = await errorText(desktop, "wait", ["duration": "long"])
        #expect(wait.hasPrefix("invalid input for computer member 'wait': duration: ") && !wait.contains("long"))
        #expect(await errorText(desktop, "mouse_move").lowercased()
            .hasPrefix("invalid input for computer member 'mouse_move': coordinate: field required"))
        #expect(await errorText(desktop, "scroll", ["scroll_direction": "sideways", "scroll_amount": 1])
            .hasPrefix("invalid input for computer member 'scroll': scroll_direction: "))
        #expect(desktop.desktop.calls.isEmpty)
    }

    @Test func coordinateListsMustHaveTheShapeTheModelWasTold() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(await errorText(desktop, "mouse_move", ["coordinate": [1]]) == "invalid input for computer member 'mouse_move': coordinate: expected [x, y]")
        #expect(await errorText(desktop, "zoom", ["region": [0, 0, 1]]) == "invalid input for computer member 'zoom': region: expected [x0, y0, x1, y1]")
        #expect(await errorText(desktop, "left_click_drag", ["start_coordinate": [1], "coordinate": [1, 2, 3]])
            == "invalid input for computer member 'left_click_drag': coordinate: expected [x, y]; start_coordinate: expected [x, y]")
        #expect(await errorText(desktop, "mouse_move", ["coordinate": [1, "b"]]).hasPrefix("invalid input for computer member 'mouse_move': coordinate.1: "))
        // an omitted optional coordinate means "at the cursor" and is not checked
        _ = try await call(desktop, "left_click")
        #expect(desktop.desktop.inputs.last == .betaComputerLeftClickInput(BetaComputerLeftClickInput()))
        #expect(desktop.desktop.calls == ["left_click"])
    }

    @Test func noNumericBoundIsAppliedBeyondTheGeneratedTypes() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await call(desktop, "wait", ["duration": 1000]) == text("Waited 1000s."))
        #expect(try await call(desktop, "key", ["text": "a", "repeat": 500]) == text("Pressed a."))
        #expect(desktop.desktop.inputs.last == .betaComputerKeyInput(BetaComputerKeyInput(text: "a", repeat: 500)))
    }

    @Test func memberResolutionRefusals() async throws {
        let desktop = try ToolsetFakeDesktop(configs: ["zoom": ["enabled": false]])
        #expect(await errorText(desktop, "teleport") == "Error: unknown computer toolset member 'teleport'")
        #expect(await errorText(desktop, "zoom", ["region": [0, 0, 1, 1]])
            == "The 'zoom' action is not permitted by this application's permissions and cannot be used in this session.")
        #expect(await errorText(desktop, "double_click") == "The computer toolset member 'double_click' is not available in this environment.")
        let unavailable = await toolsetCallError { try await desktop.call(context: CTX, name: "double_click", input: [:]) }
        #expect(unavailable?.cause is UnavailableMemberError)
        let invalid = await toolsetCallError { try await desktop.call(context: CTX, name: "wait", input: [:]) }
        #expect(invalid?.cause is InvalidMemberInputError)
        #expect(desktop.desktop.calls.isEmpty)
    }

    @Test func aDriverErrorReachesTheModelAsTextAndARefusalIsRelayed() async throws {
        let desktop = try ToolsetFakeDesktop()
        desktop.desktop.fail["left_click"] = RuntimeError("the display went away")
        let caught = await toolsetCallError { try await desktop.call(context: CTX, name: "left_click", input: [:]) }
        #expect(caught.map { toolsetJSON($0.content) } == text("RuntimeError: the display went away"))
        #expect(caught?.cause is ToolError && (caught?.cause as? ToolError)?.cause is RuntimeError)
        desktop.desktop.fail["left_click"] = ToolError("Nothing to click here.")
        let relayed = await toolsetCallError { try await desktop.call(context: CTX, name: "left_click", input: [:]) }
        #expect(relayed.map { toolsetJSON($0.content) } == text("Nothing to click here."))
        // a driver's text can carry a screen-sized payload: cut to the field limit, whether raised as ToolError or not
        desktop.desktop.fail["left_click"] = RuntimeError(String(repeating: "x", count: 5000))
        #expect(await errorText(desktop, "left_click").unicodeScalars.count == 4096)
        desktop.desktop.fail["left_click"] = ToolError(String(repeating: "y", count: 5000))
        #expect(await errorText(desktop, "left_click") == String(repeating: "y", count: 4096))
        #expect(try await desktop.toolResultJSON(computerUse("left_click"))["content"]?[0]?["text"]?.stringValue?.unicodeScalars.count == 4096)
        // a usage error is the driver's bug and propagates
        desktop.desktop.fail["left_click"] = ToolsetContractError("misused")
        await #expect(throws: ToolsetContractError.self) { _ = try await call(desktop, "left_click") }
    }

    @Test func callRaisesAToolErrorsBlocksAsTheyAreAndToolResultKeepsOnlyTheText() async throws {
        // and its async twin
        let image: JSONValue = ["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": .string(TOOLSET_PNG)]]
        let raised: [JSONValue] = [["type": "text", "text": "No button here."], image, ["type": "text", "text": ""]]
        let desktop = try ToolsetFakeDesktop()
        desktop.desktop.fail["left_click"] = ToolError(toolsetContent(raised))
        let caught = await toolsetCallError { try await desktop.call(context: CTX, name: "left_click", input: [:]) }
        #expect(caught.map { toolsetJSON($0.content) } == .array(raised))
        #expect(try await desktop.toolResultJSON(computerUse("left_click"))["content"] == text("No button here."))
    }

    struct OSError: Error, CustomStringConvertible { var description: String { "display :3 is gone" } }
    struct TimeoutError: Error, CustomStringConvertible { var description: String { "" } }

    @Test func aDriverErrorReadsAsItsTypeAndMessage() async throws {
        for (raised, expected) in [(OSError() as Error, "OSError: display :3 is gone"), (TimeoutError(), "TimeoutError")] {
            let desktop = try ToolsetFakeDesktop()
            desktop.desktop.fail["left_click"] = raised
            #expect(try await desktop.toolResultJSON(computerUse("left_click"))["content"] == text(expected))
        }
    }

    @Test func toolResultBuildsTheBlockAndNeverThrowsAToolError() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await desktop.toolResultJSON(computerUse("cursor_position")) == [
            "type": "tool_result", "tool_use_id": "toolu_1", "toolset_name": "computer", "content": text("X=0,Y=0"),
        ])
        #expect(try await desktop.toolResultJSON(computerUse("teleport", id: "toolu_2")) == [
            "type": "tool_result", "tool_use_id": "toolu_2", "toolset_name": "computer",
            "content": text("Error: unknown computer toolset member 'teleport'"), "is_error": true,
        ])
        // a browser block is not a computer member call, whatever its name
        do {
            _ = try await desktop.toolResultJSON(toolsetUse("screenshot", id: "x"))
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.contains("not a member call of the 'computer' toolset"))
        }
    }

    @Test func confirmSeesEveryCallWithTheMemberAndItsParsedInput() async throws {
        let seen = ToolsBox<[BetaComputerConfirmContext]>([])
        let desktop = try ToolsetFakeDesktop(confirm: { context in
            seen.mutate { $0.append(context) }
            return context.member != .type
        })
        _ = try await call(desktop, "key", ["text": "a"])
        #expect(await errorText(desktop, "type", ["text": "secret"])
            == "The user did not grant permission to run 'type'. Do not retry it unless the user asks you to.")
        #expect(seen.value.map(\.member) == [.key, .type])
        #expect(toolsetComputerInputJSON(seen.value[1].input) == ["text": "secret"] && seen.value[1].toolUse == CTX.toolUse)
        #expect(desktop.desktop.calls == ["key"])  // the declined call never reached the driver
        // a refused call is never shown: nothing to approve
        _ = await errorText(desktop, "teleport")
        #expect(seen.value.count == 2)
    }

    @Test func aConfirmThatThrowsRefusesTheCallAndFalseDeclines() async throws {
        let failing = try ToolsetFakeDesktop(confirm: { _ in throw RuntimeError("no terminal") })
        let caught = await toolsetCallError { try await failing.call(context: CTX, name: "key", input: ["text": "a"]) }
        #expect(caught?.cause is ConfirmFailedError)
        #expect(caught?.message.hasPrefix("Permission to run 'key' could not be obtained") == true)
        #expect(await errorText(try ToolsetFakeDesktop(confirm: { _ in throw ToolError("Ask again later.") }), "key", ["text": "a"]) == "Ask again later.")
        // A refusal raised before the call is held to the field limit, and so is a parse error on a long input.
        #expect(await errorText(try ToolsetFakeDesktop(confirm: { _ in throw ToolError(String(repeating: "r", count: 5000)) }), "key", ["text": "a"])
            == String(repeating: "r", count: 4096))
        #expect(await errorText(try ToolsetFakeDesktop(), "mouse_move", ["coordinate": .array(Array(repeating: "x", count: 5000))])
            .unicodeScalars.count <= 4096)
        let declined = await toolsetCallError { try await ToolsetFakeDesktop(confirm: { _ in false }).call(context: CTX, name: "key", input: ["text": "a"]) }
        #expect(declined?.cause is ConfirmDeclinedError)
    }

    @Test func theGateRunsBeforeAnExecuteOverride() async throws {
        let desktop = try ToolsetFakeDesktop(confirm: { _ in false })
        desktop.executeHook = { desktop, context, name, input in
            desktop.desktop.calls.append("execute:\(name.rawValue)")
            return try await desktop.baseExecute(context, name, input)
        }
        _ = await errorText(desktop, "key", ["text": "a"])
        #expect(desktop.desktop.calls.isEmpty)
    }

    @Test func confirmMayBeAsync() async throws {
        let desktop = try ToolsetFakeDesktop(confirm: { context in
            await Task.yield()
            return context.member == .key
        })
        #expect(try await call(desktop, "key", ["text": "a"]) == text("Pressed a."))
        let caught = await toolsetCallError { try await desktop.call(context: CTX, name: "type", input: ["text": "b"]) }
        #expect(caught?.cause is ConfirmDeclinedError)
        #expect(try await call(try ToolsetFakeDesktop(confirm: toolsetApproveComputer), "type", ["text": "b"]) == text("Typed."))
    }

    @Test func aToolsetWithTheKeyboardOffRunsItsCallsWithNoConfirm() async throws {
        // and its async twin
        let desktop = try ToolsetFakeDesktop(configs: ["type": ["enabled": false], "key": ["enabled": false], "hold_key": ["enabled": false]],
                                             confirm: nil)
        #expect(try await call(desktop, "left_click", ["coordinate": [1, 2]]) == text("Clicked."))
        #expect(try await call(desktop, "cursor_position") == text("X=0,Y=0"))
        #expect(desktop.desktop.calls == ["left_click", "cursor_position"])
    }

    @Test func theAsyncClassRendersAndRefusesTheSameWay() async throws {
        let desktop = try ToolsetFakeDesktop()
        #expect(try await call(desktop, "screenshot") == [["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": .string(TOOLSET_PNG)]]])
        #expect(try await call(desktop, "scroll", ["scroll_direction": "up", "scroll_amount": 2]) == text("Scrolled up."))
        #expect(await errorText(desktop, "mouse_move", ["coordinate": [1, 2, 3]]).contains("expected [x, y]"))
        desktop.desktop.fail["key"] = RuntimeError("boom")
        #expect(await errorText(desktop, "key", ["text": "a"]) == "RuntimeError: boom")
        desktop.desktop.fail["key"] = ToolError("Nothing to press.")
        #expect(await errorText(desktop, "key", ["text": "a"]) == "Nothing to press.")
        let result = try await desktop.toolResultJSON(computerUse("triple_click"))
        #expect(result["is_error"] == true && result["content"]?.description.contains("not available") == true)
    }

    @Test func aClosedToolsetRefusesCallsAndAMemberCannotNestCall() async throws {
        let desktop = try ToolsetFakeDesktop()
        try await desktop.use { _ = try await call(desktop, "key", ["text": "a"]) }
        await #expect(throws: ToolsetClosedError.self) { _ = try await call(desktop, "key", ["text": "a"]) }
        await #expect(throws: ToolsetClosedError.self) { try await desktop.use {} }

        let nesting = try ToolsetFakeDesktop()
        nesting.memberBodies["key"] = { desktop, context, input in
            guard case .betaComputerKeyInput(let key) = input else { return .nothing }
            _ = try await desktop.call(context: context, name: "type", input: ["text": .string(key.text)])
            return .nothing
        }
        do {
            _ = try await call(nesting, "key", ["text": "a"])
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.contains("call() was invoked from inside a member"))
        }
    }

    @Test func callsRunOneAtATimeAndCloseWaits() async throws {
        // test_close_waits_for_the_call_in_flight and test_async_calls_run_one_at_a_time_and_close_waits
        let order = ToolsBox<[String]>([])
        let desktop = try ToolsetFakeDesktop()
        desktop.memberBodies["key"] = { _, _, input in
            guard case .betaComputerKeyInput(let key) = input else { return .nothing }
            order.mutate { $0.append("start \(key.text)") }
            try await Task.sleep(nanoseconds: 50_000_000)
            order.mutate { $0.append("end \(key.text)") }
            return .nothing
        }
        let a = Task { _ = try await call(desktop, "key", ["text": "a"]) }
        let b = Task { _ = try await call(desktop, "key", ["text": "b"]) }
        while !order.value.contains(where: { $0.hasPrefix("start") }) { try await Task.sleep(nanoseconds: 1_000_000) }
        try await Task.sleep(nanoseconds: 20_000_000)  // the other call is queued behind the first by now
        try await desktop.close()
        order.mutate { $0.append("closed") }
        try await a.value
        try await b.value
        let log = order.value
        #expect(log.last == "closed")
        #expect(Array(log.prefix(4)) == ["start a", "end a", "start b", "end b"] || Array(log.prefix(4)) == ["start b", "end b", "start a", "end a"])
        await #expect(throws: ToolsetClosedError.self) { _ = try await call(desktop, "key", ["text": "c"]) }
    }
}

// MARK: - test_computer_interface.py

/// A desktop that serves `screenshot` and `cursor_position` (`TwoMembers`).
class ToolsetTwoMemberDesktop: BetaAbstractComputerToolset20260801, @unchecked Sendable {
    override var implementedMembers: Set<BetaComputerMemberName> { [.screenshot, .cursorPosition] }
    override func screenshot(context: BetaToolsetCallContext, input: BetaComputerScreenshotInput) async throws -> BetaScreenshotResult {
        BetaScreenshotResult(data: "AAAA")
    }
    override func cursorPosition(context: BetaToolsetCallContext, input: BetaComputerCursorPositionInput) async throws
        -> BetaComputerCursorPositionResult
    {
        BetaComputerCursorPositionResult(x: 3, y: 4)
    }
}

final class ToolsetHookedDesktop: ToolsetTwoMemberDesktop, @unchecked Sendable {
    override var overridesExecute: Bool { true }
    override func execute(context: BetaToolsetCallContext, name: BetaComputerMemberName, input: BetaComputerMemberInput) async throws
        -> BetaComputerMemberResult
    {
        try await super.execute(context: context, name: name, input: input)
    }
}

final class ToolsetForwardingDesktop: BetaAbstractComputerToolset20260801, @unchecked Sendable {
    override var overridesExecute: Bool { true }
    override func execute(context: BetaToolsetCallContext, name: BetaComputerMemberName, input: BetaComputerMemberInput) async throws
        -> BetaComputerMemberResult
    {
        .text("forwarded \(name.rawValue)")
    }
}

final class ToolsetEmptyDesktop: BetaAbstractComputerToolset20260801, @unchecked Sendable {}

final class ToolsetLeafDesktop: ToolsetTwoMemberDesktop, @unchecked Sendable {
    override var implementedMembers: Set<BetaComputerMemberName> { super.implementedMembers.union([.key]) }
    override func key(context: BetaToolsetCallContext, input: BetaComputerKeyInput) async throws -> String? { nil }
}

private let KEYBOARD: [BetaComputerMemberName] = [.type, .key, .holdKey]

@Suite struct ToolsetComputerInterfaceTests {
    private static let CTX = BetaToolsetCallContext()

    @Test func aToolsetWithNoMemberEnabledSendsEveryMemberDisabled() throws {
        #expect(toolsetDisabled(try ToolsetEmptyDesktop().toDict()).count == 17)
        let off = try ToolsetTwoMemberDesktop(configs: ["screenshot": ["enabled": false], "cursor_position": ["enabled": false]])
        #expect(toolsetDisabled(off.toDict()).count == 17)
    }

    @Test func unimplementedMembersAreSentAsDisabledAndImplementedOnesLeftToTheAPI() throws {
        let entry = try ToolsetTwoMemberDesktop().toDict()
        #expect(entry["type"] == "computer_toolset_20260801")
        let disabled = toolsetDisabled(entry)
        #expect(!disabled.contains("screenshot") && !disabled.contains("cursor_position"))
        #expect(disabled.count == 15 && disabled.contains("left_click") && disabled.contains("zoom"))
        #expect(Set(entry.objectValue!.keys) == ["type", "configs"])
        #expect(entry["configs"]!.objectValue!.values.allSatisfy { Set($0.objectValue!.keys) == ["enabled"] })
    }

    @Test func theCallersConfigsPassThroughUntouchedAndAreCopied() throws {
        let desktop = try ToolsetTwoMemberDesktop(configs: ["screenshot": ["defer_loading": true], "zoom": ["enabled": false, "defer_loading": true]])
        #expect(desktop.toDict()["configs"]?["screenshot"] == ["defer_loading": true])
        #expect(desktop.toDict()["configs"]?["zoom"] == ["enabled": false, "defer_loading": true])
        do {
            _ = try ToolsetTwoMemberDesktop(configs: ["zoom": ["enabled": true]])
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message.contains("does not implement"))
        }
    }

    @Test func anExecuteOnlySubclassServesEveryMemberAndTurnsMembersOffWithConfigs() async throws {
        #expect(try ToolsetForwardingDesktop(confirm: toolsetApproveComputer).toDict() == ["type": "computer_toolset_20260801"])
        let trimmed = try ToolsetForwardingDesktop(configs: ["screenshot": ["enabled": false], "zoom": ["enabled": false]],
                                                   confirm: toolsetApproveComputer).toDict()
        #expect(toolsetDisabled(trimmed) == ["screenshot", "zoom"])

        let hooked = try ToolsetHookedDesktop(confirm: toolsetApproveComputer)
        #expect(toolsetDisabled(hooked.toDict()) == [])
        #expect(try await hooked.execute(context: Self.CTX, name: .cursorPosition, input: .betaComputerCursorPositionInput(BetaComputerCursorPositionInput()))
            == .cursorPosition(BetaComputerCursorPositionResult(x: 3, y: 4)))
        do {
            _ = try await hooked.execute(context: Self.CTX, name: .zoom, input: .betaComputerZoomInput(BetaComputerZoomInput(region: [0, 0, 1, 1])))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "The computer toolset member 'zoom' is not available in this environment.")
        }
        #expect(toolsetDisabled(try ToolsetHookedDesktop(configs: ["zoom": ["enabled": false]], confirm: toolsetApproveComputer).toDict()) == ["zoom"])
    }

    @Test func aNullConfigsEntryLeavesTheMemberAtItsDefaultsAndGoesToTheAPIAsGiven() async throws {
        let entry = try ToolsetTwoMemberDesktop(configs: ["screenshot": nil]).toDict()
        #expect(entry["configs"]?["screenshot"] == .null && !toolsetDisabled(entry).contains("screenshot"))
        _ = try await ToolsetTwoMemberDesktop(configs: ["screenshot": nil]).call(context: Self.CTX, name: "screenshot", input: [:])
    }

    @Test func toolConfigsGoOntoTheEntryAndTheHelperTagDoesNot() throws {
        let desktop = try ToolsetTwoMemberDesktop(toolConfigs: ["cache_control": ["type": "ephemeral"]])
        #expect(desktop.toDict()["cache_control"] == ["type": "ephemeral"])
        #expect(desktop.helperTag == "computer-toolset" && !desktop.toDict().description.contains("computer-toolset"))
    }

    @Test func executeDispatchesToTheMemberMethodAndRefusesUnknownNames() async throws {
        let desktop = try ToolsetTwoMemberDesktop()
        #expect(try await desktop.execute(context: Self.CTX, name: .screenshot, input: .betaComputerScreenshotInput(BetaComputerScreenshotInput()))
            == .screenshot(BetaScreenshotResult(data: "AAAA")))
        do {
            _ = try await desktop.execute(context: Self.CTX, name: "__init__", input: .betaComputerScreenshotInput(BetaComputerScreenshotInput()))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "Error: unknown computer toolset member '__init__'")
        }
        do {
            _ = try await desktop.execute(context: Self.CTX, name: .key, input: .betaComputerKeyInput(BetaComputerKeyInput(text: "a")))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "The computer toolset member 'key' is not available in this environment.")
        }
    }

    @Test func implementedMembersCarryThroughIntermediateClasses() throws {
        #expect(Set(["screenshot", "cursor_position", "key"]).isDisjoint(with: toolsetDisabled(try ToolsetLeafDesktop(confirm: toolsetApproveComputer).toDict())))
    }

    @Test func optionsDoNotLeakIntoTheEntry() throws {
        #expect(Set(try ToolsetTwoMemberDesktop(confirm: toolsetApproveComputer).toDict().objectValue!.keys) == ["type", "configs"])
    }

    @Test func configsIsACopyOfWhatToDictSends() throws {
        let desktop = try ToolsetTwoMemberDesktop(configs: ["zoom": ["enabled": false]])
        var configs = desktop.configs
        #expect(configs.map { JSONValue.object($0) } == desktop.toDict()["configs"])
        #expect(configs?["left_click"] == ["enabled": false])
        configs?["left_click"] = ["enabled": true]
        #expect(desktop.configs?["left_click"] == ["enabled": false])
    }

    @Test(arguments: KEYBOARD)
    func aToolsetThatServesKeyboardInputWillNotBuildWithoutAConfirm(_ member: BetaComputerMemberName) throws {
        // the sync and async twins are one class
        do {
            _ = try ToolsetFakeDesktop(members: [member], confirm: nil)
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message.contains("['\(member.rawValue)'] requires a confirm callable"))
        }
        #expect(try ToolsetFakeDesktop(members: [member], confirm: toolsetApproveComputer).toDict()["type"] == "computer_toolset_20260801")
    }

    @Test func theRefusalNamesTheKeyboardMembersStillEnabledAndSaysHowToGoOn() {
        func refused(_ configs: [String: JSONValue]? = nil) -> String {
            do {
                _ = try ToolsetForwardingDesktop(configs: configs)
                return ""
            } catch {
                return (error as? ToolsetConfigError)?.message ?? "\(error)"
            }
        }
        let how = "requires a confirm callable: pass confirm=<callable>, or disable it in configs"
        #expect(refused() == "['hold_key', 'key', 'type'] \(how)")
        #expect(refused(["type": ["enabled": false], "hold_key": ["enabled": false]]) == "['key'] \(how)")
    }

    @Test func aToolsetWithAllThreeKeyboardMembersDisabledNeedsNoConfirm() throws {
        let off: [String: JSONValue] = ["type": ["enabled": false], "key": ["enabled": false], "hold_key": ["enabled": false]]
        let desktop = try ToolsetFakeDesktop(configs: off, confirm: nil)
        #expect(KEYBOARD.allSatisfy { desktop.configs?[$0.rawValue] == ["enabled": false] })
        do {
            _ = try ToolsetFakeDesktop(confirm: nil)
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message.hasPrefix("['hold_key', 'key', 'type'] requires"))
        }
    }

    @Test func membersThatDoNotTypeNeedNoConfirm() throws {
        _ = try ToolsetFakeDesktop(members: [.screenshot, .zoom, .cursorPosition, .mouseMove, .leftClick, .leftClickDrag, .scroll, .wait], confirm: nil)
    }
}

// MARK: - test_computer_registry.py and test_computer_surface.py

/// `computer_toolset_20260801.json`, a checked-in copy of the toolset's member set as the API defines it.
private func computerSpec() throws -> JSONValue {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    return try JSONValue.parse(Data(contentsOf: root.appendingPathComponent(
        "upstream/anthropic-sdk-python/tests/lib/tools/toolsets/computer_toolset_20260801.json")))
}

@Suite struct ToolsetComputerRegistryTests {
    @Test func memberSetMatchesThePublishedToolsetInItsOrder() throws {
        let spec = try computerSpec()
        #expect(COMPUTER_REGISTRY.names.map { JSONValue.string($0) } == spec["members"]?.arrayValue)
        #expect(COMPUTER_REGISTRY.names.count == Set(COMPUTER_REGISTRY.names).count && COMPUTER_REGISTRY.names.count == 17)
    }

    @Test func everyMemberIsEnabledByDefault() throws {
        #expect(try computerSpec()["default_disabled"] == [])
        #expect(COMPUTER_REGISTRY.defaultDisabled.isEmpty && COMPUTER_REGISTRY.members.values.allSatisfy(\.enabledByDefault))
    }

    @Test func memberSetMatchesTheGeneratedConfigsParam() {
        let fields = Mirror(reflecting: BetaComputerToolsetConfigsParam()).children.compactMap { $0.label.map(wireFieldName) }
        #expect(Set(fields) == Set(COMPUTER_REGISTRY.names))
    }

    @Test func staticAliasesAgreeWithTheDerivedTables() throws {
        #expect(BetaComputerMemberName.allCases.map(\.rawValue) == COMPUTER_REGISTRY.names)
        #expect(try parseComputerInput("key", ["text": "a"]) == .betaComputerKeyInput(BetaComputerKeyInput(text: "a")))
        #expect(try parseComputerInput("zoom", ["region": [0, 0, 1, 1]]) == .betaComputerZoomInput(BetaComputerZoomInput(region: [0, 0, 1, 1])))
        #expect(try parseComputerInput("screenshot", [:]) == .betaComputerScreenshotInput(BetaComputerScreenshotInput()))
        #expect(try parseComputerInput("cursor_position", [:]) == .betaComputerCursorPositionInput(BetaComputerCursorPositionInput()))
        #expect(try parseComputerInput("left_mouse_down", [:]) == .betaComputerLeftMouseDownInput(BetaComputerLeftMouseDownInput()))
        #expect(try parseComputerInput("left_mouse_up", [:]) == .betaComputerLeftMouseUpInput(BetaComputerLeftMouseUpInput()))
    }

    @Test func resultKindsAndConfirmationTexts() {
        for (name, member) in COMPUTER_REGISTRY.members {
            if ["screenshot", "zoom"].contains(name) {
                #expect(member.result == .screenshot && member.text == nil)
            } else if name == "cursor_position" {
                #expect(member.result == .point && member.text == nil)
            } else {
                #expect(member.result == .none && member.text?.isEmpty == false, "\(name)")
            }
        }
    }

    @Test func memberEnabledFailsClosed() {
        let enabled = COMPUTER_REGISTRY.memberEnabled
        #expect(enabled("zoom", nil) == true)
        #expect(enabled("zoom", ["zoom": ["enabled": false]]) == false)
        #expect(enabled("zoom", ["zoom": ["enabled": true]]) == true)
        #expect(enabled("zoom", ["zoom": ["enabled": "yes"]]) == false)
        #expect(enabled("zoom", ["zoom": ["defer_loading": true]]) == true)
        #expect(enabled("zoom", ["zoom": false]) == false)
        #expect(enabled("zoom", ["zoom": nil]) == true)
    }

    @Test func everyConfirmationPlaceholderHasATemplateField() throws {
        let regex = try NSRegularExpression(pattern: #"\{(\w+)\}"#)
        var placeholders = Set<String>()
        for member in COMPUTER_REGISTRY.members.values {
            guard let text = member.text else { continue }
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                placeholders.insert(String(text[Range(match.range(at: 1), in: text)!]))
            }
        }
        #expect(placeholders.isSubset(of: Set(TEMPLATE_FIELDS.keys)) && placeholders == ["text", "duration", "scroll_direction"])
    }

    @Test func valueTypesConstructAndAToolsetIsAToolLike() throws {
        #expect(BetaScreenshotResult(data: "AAAA").mediaType == .imagePng)
        #expect(try JSONValue.from(BetaComputerCursorPositionResult(x: 1, y: 2)) == ["x": 1, "y": 2])
        let tool: any BetaToolLike = try ToolsetTwoMemberDesktop()
        #expect(try tool.toToolParam()["type"] == "computer_toolset_20260801")
    }

    @Test func imageMediaTypesTrackTheGeneratedImageSource() {
        // BetaScreenshotResult takes the generated media type itself, so the two cannot drift
        #expect(BetaBase64ImageSourceParam.MediaType.allCases.map { imageBlock("x", $0)["source"]?["media_type"]?.stringValue }
            == ["image/jpeg", "image/png", "image/gif", "image/webp"])
    }
}
