// Port of `anthropic/lib/tools/_toolsets/_computer.py`, `_computer_registry.py` and `_computer_inputs.py`: the
// computer toolset (`computer_toolset_20260801`) a driver subclasses, and its member registry.
//
// A driver subclasses `BetaAbstractComputerToolset20260801`, overrides the members its desktop supports and lists
// them in `implementedMembers`; a member it does not list is reported to the API as disabled and, if the model
// calls it anyway, answered with an `is_error` result. The SDK ships no desktop driver: the backend (a VNC client, a
// remote-desktop API) is the driver's own.

import Foundation

let COMPUTER_FAMILY = "computer"
let COMPUTER_TOOLSET_TYPE = "computer_toolset_20260801"

/// Members that need a `confirm` callable: keyboard input goes to whichever window has focus, and what the screen
/// shows can steer what the model types. The API data marks no computer member as needing `confirm`, so this list is
/// the SDK's own.
let COMPUTER_CONFIRM_REQUIRED: Set<String> = ["type", "key", "hold_key"]

let COMPUTER_ROWS: [String: (ToolsetResultKind, String?)] = [
    "key": (.none, "Pressed {text}."),
    "hold_key": (.none, "Held {text} for {duration}s."),
    "type": (.none, "Typed."),
    "cursor_position": (.point, nil),
    "mouse_move": (.none, "Moved the mouse."),
    "left_mouse_down": (.none, "Left mouse button pressed."),
    "left_mouse_up": (.none, "Left mouse button released."),
    "left_click": (.none, "Clicked."),
    "left_click_drag": (.none, "Dragged."),
    "right_click": (.none, "Right-clicked."),
    "middle_click": (.none, "Middle-clicked."),
    "double_click": (.none, "Double-clicked."),
    "triple_click": (.none, "Triple-clicked."),
    "scroll": (.none, "Scrolled {scroll_direction}."),
    "wait": (.none, "Waited {duration}s."),
    "screenshot": (.screenshot, nil),
    "zoom": (.screenshot, nil),
]

/// The computer family: its members in the generated union's order, every one on by default.
let COMPUTER_REGISTRY = ToolsetRegistry(
    family: COMPUTER_FAMILY, helperTag: "computer-toolset",
    members: BetaComputerMemberName.allCases.map { name in
        let (result, text) = COMPUTER_ROWS[name.rawValue]!
        return ToolsetMember(name: name.rawValue, result: result, text: text, enabledByDefault: true, declaresTabID: false)
    })

/// The list-valued input fields, the shape the model is told to send, and the length that shape has.
let COMPUTER_SHAPES: [(String, String, Int)] = [
    ("coordinate", "[x, y]", 2), ("start_coordinate", "[x, y]", 2), ("region", "[x0, y0, x1, y1]", 4),
]

// MARK: - Input parsing

/// Parse a computer member's raw `tool_use.input` into its generated input model.
func parseComputerInput(_ name: String, _ raw: [String: JSONValue]) throws -> BetaComputerMemberInput {
    let family = "computer"
    switch name {
    case "key": return .betaComputerKeyInput(try parseMemberInput(BetaComputerKeyInput.self, raw, member: name, family: family))
    case "hold_key": return .betaComputerHoldKeyInput(try parseMemberInput(BetaComputerHoldKeyInput.self, raw, member: name, family: family))
    case "type": return .betaComputerTypeInput(try parseMemberInput(BetaComputerTypeInput.self, raw, member: name, family: family))
    case "cursor_position": return .betaComputerCursorPositionInput(try parseMemberInput(BetaComputerCursorPositionInput.self, raw, member: name, family: family))
    case "mouse_move": return .betaComputerMouseMoveInput(try parseMemberInput(BetaComputerMouseMoveInput.self, raw, member: name, family: family))
    case "left_mouse_down": return .betaComputerLeftMouseDownInput(try parseMemberInput(BetaComputerLeftMouseDownInput.self, raw, member: name, family: family))
    case "left_mouse_up": return .betaComputerLeftMouseUpInput(try parseMemberInput(BetaComputerLeftMouseUpInput.self, raw, member: name, family: family))
    case "left_click": return .betaComputerLeftClickInput(try parseMemberInput(BetaComputerLeftClickInput.self, raw, member: name, family: family))
    case "left_click_drag": return .betaComputerLeftClickDragInput(try parseMemberInput(BetaComputerLeftClickDragInput.self, raw, member: name, family: family))
    case "right_click": return .betaComputerRightClickInput(try parseMemberInput(BetaComputerRightClickInput.self, raw, member: name, family: family))
    case "middle_click": return .betaComputerMiddleClickInput(try parseMemberInput(BetaComputerMiddleClickInput.self, raw, member: name, family: family))
    case "double_click": return .betaComputerDoubleClickInput(try parseMemberInput(BetaComputerDoubleClickInput.self, raw, member: name, family: family))
    case "triple_click": return .betaComputerTripleClickInput(try parseMemberInput(BetaComputerTripleClickInput.self, raw, member: name, family: family))
    case "scroll": return .betaComputerScrollInput(try parseMemberInput(BetaComputerScrollInput.self, raw, member: name, family: family))
    case "wait": return .betaComputerWaitInput(try parseMemberInput(BetaComputerWaitInput.self, raw, member: name, family: family))
    case "screenshot": return .betaComputerScreenshotInput(try parseMemberInput(BetaComputerScreenshotInput.self, raw, member: name, family: family))
    case "zoom": return .betaComputerZoomInput(try parseMemberInput(BetaComputerZoomInput.self, raw, member: name, family: family))
    default: throw UnknownMemberError(name, family: family)
    }
}

/// `parseComputerInput` plus the shape of each coordinate list: the generated models type them as lists of integers
/// of any length, and a driver indexes them (`parse_computer_input`).
func parseComputerMemberInput(_ name: String, _ raw: [String: JSONValue]) throws -> BetaComputerMemberInput {
    let parsed = try parseComputerInput(name, raw)
    let json = (try? JSONValue.from(parsed)) ?? .null
    let problems = COMPUTER_SHAPES.compactMap { field, shape, length -> String? in
        guard case .array(let value)? = json[field], value.count != length else { return nil }
        return "\(field): expected \(shape)"
    }
    if !problems.isEmpty {
        throw InvalidMemberInputError(name, problems.joined(separator: "; "), family: COMPUTER_FAMILY)
    }
    return parsed
}

extension BetaComputerMemberInput {
    /// The member this input belongs to.
    var memberName: String {
        switch self {
        case .betaComputerKeyInput: return "key"
        case .betaComputerHoldKeyInput: return "hold_key"
        case .betaComputerTypeInput: return "type"
        case .betaComputerCursorPositionInput: return "cursor_position"
        case .betaComputerMouseMoveInput: return "mouse_move"
        case .betaComputerLeftMouseDownInput: return "left_mouse_down"
        case .betaComputerLeftMouseUpInput: return "left_mouse_up"
        case .betaComputerLeftClickInput: return "left_click"
        case .betaComputerLeftClickDragInput: return "left_click_drag"
        case .betaComputerRightClickInput: return "right_click"
        case .betaComputerMiddleClickInput: return "middle_click"
        case .betaComputerDoubleClickInput: return "double_click"
        case .betaComputerTripleClickInput: return "triple_click"
        case .betaComputerScrollInput: return "scroll"
        case .betaComputerWaitInput: return "wait"
        case .betaComputerScreenshotInput: return "screenshot"
        case .betaComputerZoomInput: return "zoom"
        case .unknown: return "unknown"
        }
    }
}

/// The content `call()` throws for a refusal or failure (`raised_content`): a string becomes one text block; a list
/// of blocks is kept as raised, images included. `toolResult()` later keeps only the text blocks.
func raisedContent(_ error: ToolError) -> BetaToolsetContent {
    if case .string(let s) = error.content { return toolsetContent([textBlock(s)]) }
    return error.content
}

// MARK: - The toolset

/// The computer toolset for `computer_toolset_20260801` (`BetaAsyncAbstractComputerToolset20260801`).
///
/// Subclass it, override the members your desktop supports and list them in `implementedMembers`. Each takes
/// `(context:input:)` and returns the result type in its signature:
///
/// - A pure action (a click, typing, scrolling) returns `nil`, or one line of text. The SDK folds that text to one
///   line and bounds its length. The model reads it in a text block of its own, after the SDK's fixed acknowledgment
///   (`Clicked.`).
/// - `screenshot` and `zoom` return an image that already fits the model's image limits.
/// - `cursorPosition` returns the cursor in screenshot pixels.
///
/// Read "Running a computer toolset safely" in the SDK guide (`computer-toolset.md`) before deploying one.
open class BetaAbstractComputerToolset20260801: BetaRunnableToolset, @unchecked Sendable {
    private var options: ToolsetOptions!
    private let confirm: BetaComputerConfirmCallable?
    private let gate = ToolsetCallGate()

    /// A computer toolset with the given options; a mistake in them throws `ToolsetConfigError`.
    ///
    /// - Parameters:
    ///   - configs: The `configs` object of the `tools[]` entry, sent as given:
    ///     `["<member>": ["enabled": bool, "defer_loading": bool]]`. The SDK adds `enabled: false` for every member the
    ///     subclass does not implement and never dispatches a disabled member. Every member is on by default.
    ///   - confirm: Called before every member call the SDK is about to run (never for a call already refused).
    ///     Required while `type`, `key` or `hold_key` is enabled, and optional otherwise. Return `true` to run the
    ///     call, `false` to answer the model with a refusal.
    ///   - toolConfigs: Fields set on the `tools[]` entry itself rather than on a member:
    ///     `["cache_control": ["type": "ephemeral"]]`.
    public init(configs: [String: JSONValue]? = nil, confirm: BetaComputerConfirmCallable? = nil,
                toolConfigs: BetaToolConfigs? = nil) throws
    {
        self.confirm = confirm
        super.init()
        options = try ToolsetOptions(
            registry: COMPUTER_REGISTRY, implemented: Set(implementedMembers.map(\.rawValue)),
            overridesExecute: overridesExecute, configs: configs, toolConfigs: toolConfigs)
        let required = options.confirmRequired(COMPUTER_CONFIRM_REQUIRED)
        if !required.isEmpty && confirm == nil {
            // a toolset that serves `type`, `key` or `hold_key` needs a `confirm`, unless `configs` turns them off
            throw ToolsetConfigError(
                "\(pythonList(required)) requires a confirm callable: pass confirm=<callable>, or disable it in configs")
        }
    }

    /// The member methods this class overrides. A member not listed is sent to the API as `enabled: false`.
    open var implementedMembers: Set<BetaComputerMemberName> { [] }

    /// Whether this class overrides `execute`, which makes it serve every member (turn off the ones it does not serve
    /// in `configs`).
    open var overridesExecute: Bool { false }

    public final override var toolsetName: String { COMPUTER_FAMILY }

    public final override var helperTag: String? { COMPUTER_REGISTRY.helperTag }

    /// The `tools[]` entry: the tool configs, `type`, and the wire `configs`. A fresh value each call.
    public final override func toDict() -> JSONValue { options.entry(type: COMPUTER_TOOLSET_TYPE) }

    /// The wire `configs`: yours, plus `enabled: false` for every member this class does not serve.
    public var configs: [String: JSONValue]? { toDict()["configs"]?.objectValue }

    /// The entry point the tool runner and `toolResult` use: runs one member call and returns its `tool_result`
    /// content. A refusal or failure is thrown as a `ToolError` carrying the content, its `cause` the specific
    /// refusal. Calls run one at a time; not for use from inside a member.
    public final override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws
        -> BetaToolsetContent
    {
        try refuseIfClosed()
        return try await gate.run(for: self) { try await runPipeline(context, name, input) }
    }

    /// Marks the toolset closed, then waits for the calls already accepted to settle. An override awaits
    /// `super.close()` first. Called from inside a member it returns without waiting.
    open override func close() async throws {
        try await super.close()
        if ToolsetCallGate.isInsideCall(of: self) { return }
        await gate.waitSettled()
    }

    /// Dispatch one member call to its method. Override it, calling `super.execute(context:name:input:)`, for
    /// before/after hooks around every member; `confirm` has already run and the result is rendered from what the
    /// override returns.
    open func execute(context: BetaToolsetCallContext, name: BetaComputerMemberName, input: BetaComputerMemberInput)
        async throws -> BetaComputerMemberResult
    {
        guard COMPUTER_REGISTRY.members[name.rawValue] != nil else {
            throw UnknownMemberError(name.rawValue, family: COMPUTER_FAMILY)
        }
        switch (name, input) {
        case (.key, .betaComputerKeyInput(let i)):
            let r = try await key(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.holdKey, .betaComputerHoldKeyInput(let i)):
            let r = try await holdKey(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.type, .betaComputerTypeInput(let i)):
            let r = try await type(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.cursorPosition, .betaComputerCursorPositionInput(let i)):
            let r = try await cursorPosition(context: context, input: i)
            return .cursorPosition(r)
        case (.mouseMove, .betaComputerMouseMoveInput(let i)):
            let r = try await mouseMove(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftMouseDown, .betaComputerLeftMouseDownInput(let i)):
            let r = try await leftMouseDown(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftMouseUp, .betaComputerLeftMouseUpInput(let i)):
            let r = try await leftMouseUp(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftClick, .betaComputerLeftClickInput(let i)):
            let r = try await leftClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftClickDrag, .betaComputerLeftClickDragInput(let i)):
            let r = try await leftClickDrag(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.rightClick, .betaComputerRightClickInput(let i)):
            let r = try await rightClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.middleClick, .betaComputerMiddleClickInput(let i)):
            let r = try await middleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.doubleClick, .betaComputerDoubleClickInput(let i)):
            let r = try await doubleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.tripleClick, .betaComputerTripleClickInput(let i)):
            let r = try await tripleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.scroll, .betaComputerScrollInput(let i)):
            let r = try await scroll(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.wait, .betaComputerWaitInput(let i)):
            let r = try await wait(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.screenshot, .betaComputerScreenshotInput(let i)):
            let r = try await screenshot(context: context, input: i)
            return .screenshot(r)
        case (.zoom, .betaComputerZoomInput(let i)):
            let r = try await zoom(context: context, input: i)
            return .screenshot(r)
        default: break
        }
        throw ToolsetContractError(
            "execute() was given a \(pythonStringRepr(input.memberName)) input for the computer member \(pythonStringRepr(name.rawValue))")
    }

    open func key(context: BetaToolsetCallContext, input: BetaComputerKeyInput) async throws -> String? {
        throw UnavailableMemberError("key", family: "computer")
    }

    open func holdKey(context: BetaToolsetCallContext, input: BetaComputerHoldKeyInput) async throws -> String? {
        throw UnavailableMemberError("hold_key", family: "computer")
    }

    open func type(context: BetaToolsetCallContext, input: BetaComputerTypeInput) async throws -> String? {
        throw UnavailableMemberError("type", family: "computer")
    }

    open func cursorPosition(context: BetaToolsetCallContext, input: BetaComputerCursorPositionInput) async throws -> BetaComputerCursorPositionResult {
        throw UnavailableMemberError("cursor_position", family: "computer")
    }

    open func mouseMove(context: BetaToolsetCallContext, input: BetaComputerMouseMoveInput) async throws -> String? {
        throw UnavailableMemberError("mouse_move", family: "computer")
    }

    open func leftMouseDown(context: BetaToolsetCallContext, input: BetaComputerLeftMouseDownInput) async throws -> String? {
        throw UnavailableMemberError("left_mouse_down", family: "computer")
    }

    open func leftMouseUp(context: BetaToolsetCallContext, input: BetaComputerLeftMouseUpInput) async throws -> String? {
        throw UnavailableMemberError("left_mouse_up", family: "computer")
    }

    open func leftClick(context: BetaToolsetCallContext, input: BetaComputerLeftClickInput) async throws -> String? {
        throw UnavailableMemberError("left_click", family: "computer")
    }

    open func leftClickDrag(context: BetaToolsetCallContext, input: BetaComputerLeftClickDragInput) async throws -> String? {
        throw UnavailableMemberError("left_click_drag", family: "computer")
    }

    open func rightClick(context: BetaToolsetCallContext, input: BetaComputerRightClickInput) async throws -> String? {
        throw UnavailableMemberError("right_click", family: "computer")
    }

    open func middleClick(context: BetaToolsetCallContext, input: BetaComputerMiddleClickInput) async throws -> String? {
        throw UnavailableMemberError("middle_click", family: "computer")
    }

    open func doubleClick(context: BetaToolsetCallContext, input: BetaComputerDoubleClickInput) async throws -> String? {
        throw UnavailableMemberError("double_click", family: "computer")
    }

    open func tripleClick(context: BetaToolsetCallContext, input: BetaComputerTripleClickInput) async throws -> String? {
        throw UnavailableMemberError("triple_click", family: "computer")
    }

    open func scroll(context: BetaToolsetCallContext, input: BetaComputerScrollInput) async throws -> String? {
        throw UnavailableMemberError("scroll", family: "computer")
    }

    open func wait(context: BetaToolsetCallContext, input: BetaComputerWaitInput) async throws -> String? {
        throw UnavailableMemberError("wait", family: "computer")
    }

    open func screenshot(context: BetaToolsetCallContext, input: BetaComputerScreenshotInput) async throws -> BetaScreenshotResult {
        throw UnavailableMemberError("screenshot", family: "computer")
    }

    open func zoom(context: BetaToolsetCallContext, input: BetaComputerZoomInput) async throws -> BetaScreenshotResult {
        throw UnavailableMemberError("zoom", family: "computer")
    }
    private func runPipeline(_ context: BetaToolsetCallContext, _ name: String, _ raw: BetaToolInput) async throws
        -> BetaToolsetContent
    {
        do {
            let member = try options.resolve(name)
            let parsed = try parseComputerMemberInput(member.name, raw)
            try await runConfirm(
                member.name, confirm,
                BetaComputerConfirmContext(toolUse: context.toolUse, member: BetaComputerMemberName(rawValue: member.name), input: parsed))
            let result: BetaComputerMemberResult
            do {
                result = try await execute(context: context, name: BetaComputerMemberName(rawValue: member.name), input: parsed)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // The driver's own error text reaches the model, cut to the field limit.
                let refusal = boundedError(try classifyWithCause(error))
                if refusal === (error as? ToolError) { throw error }
                throw refusal
            }
            let blocks = try renderResult(member, (try? JSONValue.from(parsed)) ?? .null, boundedResult(member, ToolsetMemberResult(result)))
            return toolsetContent(blocks)
        } catch let refusal as ToolError {
            throw ToolError(raisedContent(boundedError(refusal)), cause: refusal)
        }
    }
}
