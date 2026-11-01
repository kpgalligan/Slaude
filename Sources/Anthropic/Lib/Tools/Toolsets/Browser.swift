// Port of `anthropic/lib/tools/_toolsets/_browser.py`, `_registry.py`, `_inputs.py` and `_pipeline.py`: the browser
// toolset (`browser_toolset_20260801`) a driver subclasses, its member registry, and the stages of a member call.
//
// A driver subclasses `BetaAbstractBrowserToolset20260801`, overrides the members its backend supports, lists them
// in `implementedMembers`, and implements `browserState(context:)`. A member it does not list is reported to the API
// as disabled and, if the model calls it anyway, answered with an `is_error` result. `execute` is the dispatch
// layer: override it (calling `super.execute`) for before/after hooks around every member. `call` runs the SDK's
// pipeline around it: resolve → parse → URL policy → file policy → confirm → execute → browser state → render.

import Foundation

let BROWSER_FAMILY = "browser"
let BROWSER_TOOLSET_TYPE = "browser_toolset_20260801"

/// Members whose calls wait for a person unless the application's `confirm` approves them unattended: page content
/// can steer what the model asks them to do, and what they do reaches outside the page.
let BROWSER_CONFIRM_REQUIRED: Set<String> = ["javascript_exec", "file_upload"]

/// The tab members, which render no content of their own, so their non-error result is exactly one `browser_state`
/// block, and a line meant for the model (a refused navigation) waits for the next result that can hold it.
let BROWSER_STATE_ONLY_MEMBERS: Set<String> = ["new_tab", "list_tabs", "switch_tab", "close_tab"]

/// Hand-kept: result kinds, confirmation templates and default-disabled flags. Everything else about a member is
/// generated.
let BROWSER_ROWS: [String: (ToolsetResultKind, String?, Bool)] = [
    "navigate": (.navigate, nil, true),
    "screenshot": (.screenshot, nil, true),
    "zoom": (.screenshot, nil, true),
    "left_click": (.none, "Clicked.", true),
    "right_click": (.none, "Right-clicked.", true),
    "middle_click": (.none, "Middle-clicked.", true),
    "double_click": (.none, "Double-clicked.", true),
    "triple_click": (.none, "Triple-clicked.", true),
    "hover": (.none, "Hovered.", true),
    "left_click_drag": (.none, "Dragged.", true),
    "left_mouse_down": (.none, "Mouse button pressed.", true),
    "left_mouse_up": (.none, "Mouse button released.", true),
    "mouse_move": (.none, "Moved the mouse.", true),
    "scroll": (.none, "Scrolled {scroll_direction}.", true),
    "scroll_to": (.none, "Scrolled to {ref}.", true),
    "type": (.none, "Typed.", true),
    "key": (.none, "Pressed {text}.", true),
    "hold_key": (.none, "Held {text} for {duration}s.", true),
    "form_input": (.none, "Set the value of {ref}.", true),
    "read_page": (.text, nil, true),
    "find": (.text, nil, true),
    "get_page_text": (.text, nil, true),
    "wait": (.none, "Waited {duration}s.", true),
    "file_upload": (.none, "Uploaded.", false),
    "read_console": (.text, nil, false),
    "read_network": (.text, nil, false),
    "javascript_exec": (.text, nil, false),
    "new_tab": (.tab, nil, true),
    "list_tabs": (.tabs, nil, true),
    "switch_tab": (.tab, nil, true),
    "close_tab": (.none, nil, true),
]

/// The members whose input does not declare `tab_id`: on them a `tab_id` key is an extra field and names no tab.
let BROWSER_MEMBERS_WITHOUT_TAB_ID: Set<String> = ["new_tab", "list_tabs"]

/// The browser family: its members in the generated union's order, and what it is called on the wire.
let BROWSER_REGISTRY = ToolsetRegistry(
    family: BROWSER_FAMILY, helperTag: "browser-toolset",
    members: BetaBrowserMemberName.allCases.map { name in
        let (result, text, enabled) = BROWSER_ROWS[name.rawValue]!
        return ToolsetMember(
            name: name.rawValue, result: result, text: text, enabledByDefault: enabled,
            declaresTabID: !BROWSER_MEMBERS_WITHOUT_TAB_ID.contains(name.rawValue))
    })

/// Members the API withholds unless `configs` enables them.
let BROWSER_DEFAULT_DISABLED_MEMBERS = BROWSER_REGISTRY.defaultDisabled

/// `browserState(context:)` threw, or the report could not be read: the driver's bug, not the model's.
public final class BrowserStateError: ToolsetContractError, @unchecked Sendable {
    public init(_ error: Error) {
        super.init(
            "browserState(context:) raised \(pythonExceptionRepr(error)) or returned no BetaBrowserState; return one, and "
                + "catch failures inside the hook")
    }
}

// MARK: - Input parsing

/// Parse a browser member's raw `tool_use.input` into its generated input model.
func parseBrowserInput(_ name: String, _ raw: [String: JSONValue]) throws -> BetaBrowserMemberInput {
    let family = "browser"
    switch name {
    case "navigate": return .betaBrowserNavigateInput(try parseMemberInput(BetaBrowserNavigateInput.self, raw, member: name, family: family))
    case "list_tabs": return .betaBrowserListTabsInput(try parseMemberInput(BetaBrowserListTabsInput.self, raw, member: name, family: family))
    case "new_tab": return .betaBrowserNewTabInput(try parseMemberInput(BetaBrowserNewTabInput.self, raw, member: name, family: family))
    case "switch_tab": return .betaBrowserSwitchTabInput(try parseMemberInput(BetaBrowserSwitchTabInput.self, raw, member: name, family: family))
    case "close_tab": return .betaBrowserCloseTabInput(try parseMemberInput(BetaBrowserCloseTabInput.self, raw, member: name, family: family))
    case "read_page": return .betaBrowserReadPageInput(try parseMemberInput(BetaBrowserReadPageInput.self, raw, member: name, family: family))
    case "get_page_text": return .betaBrowserGetPageTextInput(try parseMemberInput(BetaBrowserGetPageTextInput.self, raw, member: name, family: family))
    case "read_console": return .betaBrowserReadConsoleInput(try parseMemberInput(BetaBrowserReadConsoleInput.self, raw, member: name, family: family))
    case "read_network": return .betaBrowserReadNetworkInput(try parseMemberInput(BetaBrowserReadNetworkInput.self, raw, member: name, family: family))
    case "find": return .betaBrowserFindInput(try parseMemberInput(BetaBrowserFindInput.self, raw, member: name, family: family))
    case "form_input": return .betaBrowserFormInputInput(try parseMemberInput(BetaBrowserFormInputInput.self, raw, member: name, family: family))
    case "file_upload": return .betaBrowserFileUploadInput(try parseMemberInput(BetaBrowserFileUploadInput.self, raw, member: name, family: family))
    case "scroll_to": return .betaBrowserScrollToInput(try parseMemberInput(BetaBrowserScrollToInput.self, raw, member: name, family: family))
    case "screenshot": return .betaBrowserScreenshotInput(try parseMemberInput(BetaBrowserScreenshotInput.self, raw, member: name, family: family))
    case "zoom": return .betaBrowserZoomInput(try parseMemberInput(BetaBrowserZoomInput.self, raw, member: name, family: family))
    case "left_click": return .betaBrowserLeftClickInput(try parseMemberInput(BetaBrowserLeftClickInput.self, raw, member: name, family: family))
    case "right_click": return .betaBrowserRightClickInput(try parseMemberInput(BetaBrowserRightClickInput.self, raw, member: name, family: family))
    case "middle_click": return .betaBrowserMiddleClickInput(try parseMemberInput(BetaBrowserMiddleClickInput.self, raw, member: name, family: family))
    case "double_click": return .betaBrowserDoubleClickInput(try parseMemberInput(BetaBrowserDoubleClickInput.self, raw, member: name, family: family))
    case "triple_click": return .betaBrowserTripleClickInput(try parseMemberInput(BetaBrowserTripleClickInput.self, raw, member: name, family: family))
    case "hover": return .betaBrowserHoverInput(try parseMemberInput(BetaBrowserHoverInput.self, raw, member: name, family: family))
    case "left_click_drag": return .betaBrowserLeftClickDragInput(try parseMemberInput(BetaBrowserLeftClickDragInput.self, raw, member: name, family: family))
    case "left_mouse_down": return .betaBrowserLeftMouseDownInput(try parseMemberInput(BetaBrowserLeftMouseDownInput.self, raw, member: name, family: family))
    case "left_mouse_up": return .betaBrowserLeftMouseUpInput(try parseMemberInput(BetaBrowserLeftMouseUpInput.self, raw, member: name, family: family))
    case "mouse_move": return .betaBrowserMouseMoveInput(try parseMemberInput(BetaBrowserMouseMoveInput.self, raw, member: name, family: family))
    case "scroll": return .betaBrowserScrollInput(try parseMemberInput(BetaBrowserScrollInput.self, raw, member: name, family: family))
    case "type": return .betaBrowserTypeInput(try parseMemberInput(BetaBrowserTypeInput.self, raw, member: name, family: family))
    case "key": return .betaBrowserKeyInput(try parseMemberInput(BetaBrowserKeyInput.self, raw, member: name, family: family))
    case "hold_key": return .betaBrowserHoldKeyInput(try parseMemberInput(BetaBrowserHoldKeyInput.self, raw, member: name, family: family))
    case "wait": return .betaBrowserWaitInput(try parseMemberInput(BetaBrowserWaitInput.self, raw, member: name, family: family))
    case "javascript_exec": return .betaBrowserJavascriptExecInput(try parseMemberInput(BetaBrowserJavascriptExecInput.self, raw, member: name, family: family))
    default: throw UnknownMemberError(name, family: family)
    }
}

extension BetaBrowserMemberInput {
    /// The member this input belongs to.
    var memberName: String {
        switch self {
        case .betaBrowserNavigateInput: return "navigate"
        case .betaBrowserListTabsInput: return "list_tabs"
        case .betaBrowserNewTabInput: return "new_tab"
        case .betaBrowserSwitchTabInput: return "switch_tab"
        case .betaBrowserCloseTabInput: return "close_tab"
        case .betaBrowserReadPageInput: return "read_page"
        case .betaBrowserGetPageTextInput: return "get_page_text"
        case .betaBrowserReadConsoleInput: return "read_console"
        case .betaBrowserReadNetworkInput: return "read_network"
        case .betaBrowserFindInput: return "find"
        case .betaBrowserFormInputInput: return "form_input"
        case .betaBrowserFileUploadInput: return "file_upload"
        case .betaBrowserScrollToInput: return "scroll_to"
        case .betaBrowserScreenshotInput: return "screenshot"
        case .betaBrowserZoomInput: return "zoom"
        case .betaBrowserLeftClickInput: return "left_click"
        case .betaBrowserRightClickInput: return "right_click"
        case .betaBrowserMiddleClickInput: return "middle_click"
        case .betaBrowserDoubleClickInput: return "double_click"
        case .betaBrowserTripleClickInput: return "triple_click"
        case .betaBrowserHoverInput: return "hover"
        case .betaBrowserLeftClickDragInput: return "left_click_drag"
        case .betaBrowserLeftMouseDownInput: return "left_mouse_down"
        case .betaBrowserLeftMouseUpInput: return "left_mouse_up"
        case .betaBrowserMouseMoveInput: return "mouse_move"
        case .betaBrowserScrollInput: return "scroll"
        case .betaBrowserTypeInput: return "type"
        case .betaBrowserKeyInput: return "key"
        case .betaBrowserHoldKeyInput: return "hold_key"
        case .betaBrowserWaitInput: return "wait"
        case .betaBrowserJavascriptExecInput: return "javascript_exec"
        case .unknown: return "unknown"
        }
    }
}

// MARK: - The toolset

/// The browser toolset for `browser_toolset_20260801` (`BetaAsyncAbstractBrowserToolset20260801`).
///
/// Subclass it, override the members your backend supports and list them in `implementedMembers`. Each takes
/// `(context:input:)` and returns the result type in its signature. A pure action (a click, typing, scrolling)
/// returns `nil`, or a string the model reads in a text block of its own after the SDK's fixed acknowledgment (such
/// as `Clicked.`), folded to one line. Every driver implements `browserState(context:)`. Read "Running a browser
/// toolset safely" in the SDK guide (`browser-toolset.md`) before deploying one.
///
/// ```swift
/// final class MyBrowser: BetaAbstractBrowserToolset20260801, @unchecked Sendable {
///     override var implementedMembers: Set<BetaBrowserMemberName> { [.navigate, .screenshot] }
///     override func browserState(context: BetaToolsetCallContext) async throws -> BetaBrowserState { ... }
///     override func navigate(context: BetaToolsetCallContext, input: BetaBrowserNavigateInput) async throws
///         -> BetaBrowserNavigateResult { ... }
///     override func screenshot(context: BetaToolsetCallContext, input: BetaBrowserScreenshotInput) async throws
///         -> BetaScreenshotResult { ... }
/// }
/// ```
open class BetaAbstractBrowserToolset20260801: BetaRunnableToolset, @unchecked Sendable {
    private var options: ToolsetOptions!
    private let confirm: BetaConfirmCallable?
    private let urlPolicy: BetaURLPolicy?
    private let filePolicy: (any BetaFilePolicy)?
    private let gate = ToolsetCallGate()
    private var pipeline = BrowserPipelineState()

    /// A browser toolset with the given options. A mistake in them throws `ToolsetConfigError`.
    ///
    /// - Parameters:
    ///   - configs: The `configs` object of the `tools[]` entry, sent as given:
    ///     `["<member>": ["enabled": bool, "defer_loading": bool]]`. This is how a member is switched on or off. The
    ///     SDK adds `enabled: false` for every member the subclass does not implement and never dispatches a
    ///     disabled member. A subclass that overrides `execute` (and sets `overridesExecute`) serves every member, so
    ///     turn off the ones it does not serve here.
    ///   - confirm: Called before every member call the SDK is about to run (after the URL policy and the file
    ///     policy, never for a call already refused). Return `true` to run it or `false` to answer the model with a
    ///     refusal. Required when `javascript_exec` or `file_upload` is enabled.
    ///   - urlPolicy: Called once for each `navigate` that has a URL, with the URL exactly as the model wrote it,
    ///     before the driver receives it (`back`, `forward` and `reload` are not checked); throw `ToolError` to refuse.
    ///     Left unset, `navigate` is not checked. This is a hook for your own policy, not a security boundary.
    ///   - filePolicy: Which local paths and Files API document ids `file_upload` may use, and whether a download's
    ///     local path is shown to the model (the SDK ships `BetaLocalFilePolicy`). Without one, an upload with a path
    ///     or document id is refused and download paths stay hidden.
    ///   - toolConfigs: Fields set on the `tools[]` entry itself rather than on a member:
    ///     `["cache_control": ["type": "ephemeral"]]`.
    public init(configs: [String: JSONValue]? = nil, confirm: BetaConfirmCallable? = nil, urlPolicy: BetaURLPolicy? = nil,
                filePolicy: (any BetaFilePolicy)? = nil, toolConfigs: BetaToolConfigs? = nil) throws
    {
        self.confirm = confirm
        self.urlPolicy = urlPolicy
        self.filePolicy = filePolicy
        super.init()
        options = try ToolsetOptions(
            registry: BROWSER_REGISTRY, implemented: Set(implementedMembers.map(\.rawValue)), overridesExecute: overridesExecute,
            configs: configs, toolConfigs: toolConfigs)
        let required = options.confirmRequired(BROWSER_CONFIRM_REQUIRED)
        if !required.isEmpty && confirm == nil {
            // these members act on page-supplied intent (a script to run, files to send), so they are always gated
            throw ToolsetConfigError(
                "\(pythonList(required)) requires a confirm callable: pass confirm=<callable>, or disable it in configs")
        }
    }

    /// The member methods this class overrides. A member not listed is sent to the API as `enabled: false`.
    open var implementedMembers: Set<BetaBrowserMemberName> { [] }

    /// Whether this class overrides `execute`, which makes it serve every member (turn off the ones it does not serve
    /// in `configs`).
    open var overridesExecute: Bool { false }

    public final override var toolsetName: String { BROWSER_FAMILY }

    public final override var helperTag: String? { BROWSER_REGISTRY.helperTag }

    /// The `tools[]` entry: the tool configs, `type`, and the wire `configs`. A fresh value each call.
    public final override func toDict() -> JSONValue { options.entry(type: BROWSER_TOOLSET_TYPE) }

    /// The wire `configs` that `toDict()` sends: yours, plus `enabled: false` for every member this class does not
    /// serve.
    public var configs: [String: JSONValue]? { toDict()["configs"]?.objectValue }

    /// The entry point the tool runner and `toolResult` use: runs one member call through the pipeline and returns
    /// its `tool_result` content.
    ///
    /// A refusal or failure is thrown as a `ToolError` that carries the `tool_result` content; its `cause` is the
    /// specific refusal (`DisabledMemberError`, …) or, when a member threw something other than `ToolError`, the
    /// `ToolError` that wraps it. Calls run one at a time. Not an extension point (override `execute` or a member
    /// method) and not for use from inside a member: a member that composes others calls their methods directly.
    public final override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws
        -> BetaToolsetContent
    {
        try refuseIfClosed()
        return try await gate.run(for: self) { try await runPipeline(context, name, input) }
    }

    /// Release what the toolset holds when you are done. The tool runner never calls this. Marks the toolset closed
    /// (a call that arrives afterwards throws `ToolsetClosedError`), then waits for the calls already accepted to
    /// settle, so an override that calls `super.close()` first tears the backend down with nothing still using it.
    /// Called from inside a member it returns without waiting.
    open override func close() async throws {
        try await super.close()
        if ToolsetCallGate.isInsideCall(of: self) { return }
        await gate.waitSettled()
    }

    /// Dispatch one member call to its method.
    ///
    /// Override it, calling `super.execute(context:name:input:)`, for before/after hooks around every member. The
    /// pipeline still wraps the override, so the URL policy, the file policy and `confirm` run before it. A subclass
    /// that forwards every member elsewhere implements this method and `browserState(context:)`, and sets
    /// `overridesExecute`. A call the SDK refused before dispatch never reaches it.
    open func execute(context: BetaToolsetCallContext, name: BetaBrowserMemberName, input: BetaBrowserMemberInput)
        async throws -> BetaBrowserMemberResult
    {
        // Resolved through the registry: a name the model made up never reaches a method.
        guard BROWSER_REGISTRY.members[name.rawValue] != nil else {
            throw UnknownMemberError(name.rawValue, family: BROWSER_FAMILY)
        }
        switch (name, input) {
        case (.navigate, .betaBrowserNavigateInput(let i)):
            let r = try await navigate(context: context, input: i)
            return .navigate(r)
        case (.listTabs, .betaBrowserListTabsInput(let i)):
            let r = try await listTabs(context: context, input: i)
            return .tabs(r)
        case (.newTab, .betaBrowserNewTabInput(let i)):
            let r = try await newTab(context: context, input: i)
            return .tab(r)
        case (.switchTab, .betaBrowserSwitchTabInput(let i)):
            let r = try await switchTab(context: context, input: i)
            return .tab(r)
        case (.closeTab, .betaBrowserCloseTabInput(let i)): try await closeTab(context: context, input: i); return .nothing
        case (.readPage, .betaBrowserReadPageInput(let i)):
            let r = try await readPage(context: context, input: i)
            return .text(r)
        case (.getPageText, .betaBrowserGetPageTextInput(let i)):
            let r = try await getPageText(context: context, input: i)
            return .text(r)
        case (.readConsole, .betaBrowserReadConsoleInput(let i)):
            let r = try await readConsole(context: context, input: i)
            return .text(r)
        case (.readNetwork, .betaBrowserReadNetworkInput(let i)):
            let r = try await readNetwork(context: context, input: i)
            return .text(r)
        case (.find, .betaBrowserFindInput(let i)):
            let r = try await find(context: context, input: i)
            return .text(r)
        case (.formInput, .betaBrowserFormInputInput(let i)):
            let r = try await formInput(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.fileUpload, .betaBrowserFileUploadInput(let i)):
            let r = try await fileUpload(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.scrollTo, .betaBrowserScrollToInput(let i)):
            let r = try await scrollTo(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.screenshot, .betaBrowserScreenshotInput(let i)):
            let r = try await screenshot(context: context, input: i)
            return .screenshot(r)
        case (.zoom, .betaBrowserZoomInput(let i)):
            let r = try await zoom(context: context, input: i)
            return .screenshot(r)
        case (.leftClick, .betaBrowserLeftClickInput(let i)):
            let r = try await leftClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.rightClick, .betaBrowserRightClickInput(let i)):
            let r = try await rightClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.middleClick, .betaBrowserMiddleClickInput(let i)):
            let r = try await middleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.doubleClick, .betaBrowserDoubleClickInput(let i)):
            let r = try await doubleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.tripleClick, .betaBrowserTripleClickInput(let i)):
            let r = try await tripleClick(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.hover, .betaBrowserHoverInput(let i)):
            let r = try await hover(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftClickDrag, .betaBrowserLeftClickDragInput(let i)):
            let r = try await leftClickDrag(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftMouseDown, .betaBrowserLeftMouseDownInput(let i)):
            let r = try await leftMouseDown(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.leftMouseUp, .betaBrowserLeftMouseUpInput(let i)):
            let r = try await leftMouseUp(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.mouseMove, .betaBrowserMouseMoveInput(let i)):
            let r = try await mouseMove(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.scroll, .betaBrowserScrollInput(let i)):
            let r = try await scroll(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.type, .betaBrowserTypeInput(let i)):
            let r = try await type(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.key, .betaBrowserKeyInput(let i)):
            let r = try await key(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.holdKey, .betaBrowserHoldKeyInput(let i)):
            let r = try await holdKey(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.wait, .betaBrowserWaitInput(let i)):
            let r = try await wait(context: context, input: i)
            return r.map { .text($0) } ?? .nothing
        case (.javascriptExec, .betaBrowserJavascriptExecInput(let i)):
            let r = try await javascriptExec(context: context, input: i)
            return .text(r)
        default: break
        }
        throw ToolsetContractError(
            "execute() was given a \(pythonStringRepr(input.memberName)) input for the browser member \(pythonStringRepr(name.rawValue))")
    }

    /// The browser after a call: the open tabs (one marked active) and the state changes since the previous report.
    /// Every driver implements it. The SDK calls it once after every member call, refused and failed ones included
    /// (not one that threw `ToolsetUsageError` or was cancelled), and attaches the result as the `browser_state`
    /// block, less the download paths the file policy hides.
    open func browserState(context: BetaToolsetCallContext) async throws -> BetaBrowserState {
        throw ToolsetContractError("\(Swift.type(of: self)) must override browserState(context:)")
    }

    open func navigate(context: BetaToolsetCallContext, input: BetaBrowserNavigateInput) async throws -> BetaBrowserNavigateResult {
        throw UnavailableMemberError("navigate", family: "browser")
    }

    open func listTabs(context: BetaToolsetCallContext, input: BetaBrowserListTabsInput) async throws -> [BetaBrowserStateTabEntryParam] {
        throw UnavailableMemberError("list_tabs", family: "browser")
    }

    open func newTab(context: BetaToolsetCallContext, input: BetaBrowserNewTabInput) async throws -> BetaBrowserStateTabEntryParam {
        throw UnavailableMemberError("new_tab", family: "browser")
    }

    open func switchTab(context: BetaToolsetCallContext, input: BetaBrowserSwitchTabInput) async throws -> BetaBrowserStateTabEntryParam {
        throw UnavailableMemberError("switch_tab", family: "browser")
    }

    open func closeTab(context: BetaToolsetCallContext, input: BetaBrowserCloseTabInput) async throws {
        throw UnavailableMemberError("close_tab", family: "browser")
    }

    open func readPage(context: BetaToolsetCallContext, input: BetaBrowserReadPageInput) async throws -> String {
        throw UnavailableMemberError("read_page", family: "browser")
    }

    open func getPageText(context: BetaToolsetCallContext, input: BetaBrowserGetPageTextInput) async throws -> String {
        throw UnavailableMemberError("get_page_text", family: "browser")
    }

    open func readConsole(context: BetaToolsetCallContext, input: BetaBrowserReadConsoleInput) async throws -> String {
        throw UnavailableMemberError("read_console", family: "browser")
    }

    open func readNetwork(context: BetaToolsetCallContext, input: BetaBrowserReadNetworkInput) async throws -> String {
        throw UnavailableMemberError("read_network", family: "browser")
    }

    open func find(context: BetaToolsetCallContext, input: BetaBrowserFindInput) async throws -> String {
        throw UnavailableMemberError("find", family: "browser")
    }

    open func formInput(context: BetaToolsetCallContext, input: BetaBrowserFormInputInput) async throws -> String? {
        throw UnavailableMemberError("form_input", family: "browser")
    }

    open func fileUpload(context: BetaToolsetCallContext, input: BetaBrowserFileUploadInput) async throws -> String? {
        throw UnavailableMemberError("file_upload", family: "browser")
    }

    open func scrollTo(context: BetaToolsetCallContext, input: BetaBrowserScrollToInput) async throws -> String? {
        throw UnavailableMemberError("scroll_to", family: "browser")
    }

    open func screenshot(context: BetaToolsetCallContext, input: BetaBrowserScreenshotInput) async throws -> BetaScreenshotResult {
        throw UnavailableMemberError("screenshot", family: "browser")
    }

    open func zoom(context: BetaToolsetCallContext, input: BetaBrowserZoomInput) async throws -> BetaScreenshotResult {
        throw UnavailableMemberError("zoom", family: "browser")
    }

    open func leftClick(context: BetaToolsetCallContext, input: BetaBrowserLeftClickInput) async throws -> String? {
        throw UnavailableMemberError("left_click", family: "browser")
    }

    open func rightClick(context: BetaToolsetCallContext, input: BetaBrowserRightClickInput) async throws -> String? {
        throw UnavailableMemberError("right_click", family: "browser")
    }

    open func middleClick(context: BetaToolsetCallContext, input: BetaBrowserMiddleClickInput) async throws -> String? {
        throw UnavailableMemberError("middle_click", family: "browser")
    }

    open func doubleClick(context: BetaToolsetCallContext, input: BetaBrowserDoubleClickInput) async throws -> String? {
        throw UnavailableMemberError("double_click", family: "browser")
    }

    open func tripleClick(context: BetaToolsetCallContext, input: BetaBrowserTripleClickInput) async throws -> String? {
        throw UnavailableMemberError("triple_click", family: "browser")
    }

    open func hover(context: BetaToolsetCallContext, input: BetaBrowserHoverInput) async throws -> String? {
        throw UnavailableMemberError("hover", family: "browser")
    }

    open func leftClickDrag(context: BetaToolsetCallContext, input: BetaBrowserLeftClickDragInput) async throws -> String? {
        throw UnavailableMemberError("left_click_drag", family: "browser")
    }

    open func leftMouseDown(context: BetaToolsetCallContext, input: BetaBrowserLeftMouseDownInput) async throws -> String? {
        throw UnavailableMemberError("left_mouse_down", family: "browser")
    }

    open func leftMouseUp(context: BetaToolsetCallContext, input: BetaBrowserLeftMouseUpInput) async throws -> String? {
        throw UnavailableMemberError("left_mouse_up", family: "browser")
    }

    open func mouseMove(context: BetaToolsetCallContext, input: BetaBrowserMouseMoveInput) async throws -> String? {
        throw UnavailableMemberError("mouse_move", family: "browser")
    }

    open func scroll(context: BetaToolsetCallContext, input: BetaBrowserScrollInput) async throws -> String? {
        throw UnavailableMemberError("scroll", family: "browser")
    }

    open func type(context: BetaToolsetCallContext, input: BetaBrowserTypeInput) async throws -> String? {
        throw UnavailableMemberError("type", family: "browser")
    }

    open func key(context: BetaToolsetCallContext, input: BetaBrowserKeyInput) async throws -> String? {
        throw UnavailableMemberError("key", family: "browser")
    }

    open func holdKey(context: BetaToolsetCallContext, input: BetaBrowserHoldKeyInput) async throws -> String? {
        throw UnavailableMemberError("hold_key", family: "browser")
    }

    open func wait(context: BetaToolsetCallContext, input: BetaBrowserWaitInput) async throws -> String? {
        throw UnavailableMemberError("wait", family: "browser")
    }

    open func javascriptExec(context: BetaToolsetCallContext, input: BetaBrowserJavascriptExecInput) async throws -> String {
        throw UnavailableMemberError("javascript_exec", family: "browser")
    }
    // MARK: The pipeline

    private func runPipeline(_ context: BetaToolsetCallContext, _ name: String, _ raw: BetaToolInput) async throws
        -> BetaToolsetContent
    {
        var record = BrowserCallRecord(context: context, name: name)
        do {
            let member = try options.resolve(name)
            record.member = member
            record.input = try parseBrowserInput(member.name, raw)

            if let url = record.navigateURL() { try await applyURLPolicy(url, record.urlContext) }
            if member.name == "file_upload" { try record.resolveUploadPaths(filePolicy) }
            try await runConfirm(member.name, confirm, record.confirmContext(pipeline))

            do {
                let result = try await execute(
                    context: context, name: BetaBrowserMemberName(rawValue: member.name), input: record.input!)
                record.result = boundedResult(member, ToolsetMemberResult(result))
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // The driver's own error text reaches the model, cut to the field limit.
                record.error = boundedError(try classifyWithCause(error))
            }
        } catch let refusal as ToolError {
            record.error = refusal
        }

        let report = try await collectBrowserState(context)
        let (content, isError) = try pipeline.finish(&record, report, filePolicy)
        if isError { throw pipelineError(content, cause: record.error) }
        return toolsetContent(content)
    }

    /// Called after every call, failed and refused ones included, so the driver can report what changed meanwhile.
    private func collectBrowserState(_ context: BetaToolsetCallContext) async throws -> BrowserReport {
        do {
            return try BrowserReport(try await browserState(context: context))
        } catch let error as ToolsetUsageError {
            throw error
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw BrowserStateError(error)
        }
    }

    /// Run the URL policy on one address, throwing the refusal unless it passes or there is no policy.
    private func applyURLPolicy(_ url: String, _ context: BetaURLContext) async throws {
        guard let urlPolicy else { return }
        do {
            try await urlPolicy(context, url)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw try hookRefusal(error, fallback: URLRefusedError(POLICY_REFUSED))
        }
    }
}

/// `classify`, with the error it wrapped as the refusal's cause.
func classifyWithCause(_ error: Error) throws -> ToolError {
    let refusal = try classify(error)
    if refusal === (error as? ToolError) { return refusal }
    return ToolError(refusal.content, cause: error)
}
