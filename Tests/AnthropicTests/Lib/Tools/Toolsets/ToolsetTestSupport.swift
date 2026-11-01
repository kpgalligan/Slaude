// Port of `tests/lib/tools/toolsets/_fakes.py`, `_computer_fakes.py` and `_stubs.py`: in-memory toolsets for the
// toolset tests. Python's fakes subclass the abstract classes per test; Swift's local classes cannot close over a
// test's variables, so the fakes take the per-test behaviour as closures (`memberBodies`, `executeHook`, ...).

import Foundation
import Testing
@testable import Anthropic

// MARK: - Shared readers

/// The content as JSON.
func toolsetJSON(_ content: BetaToolsetContent) -> JSONValue { (try? JSONValue.from(content)) ?? .null }

/// The texts of the content's text blocks (`texts`).
func toolsetTexts(_ content: BetaToolsetContent) -> [String] { toolsetTexts(toolsetJSON(content)) }

func toolsetTexts(_ content: JSONValue) -> [String] {
    (content.arrayValue ?? []).compactMap { $0["type"] == "text" ? $0["text"]?.stringValue : nil }
}

/// The content's one `browser_state` block (`state_block`).
func toolsetStateBlock(_ content: BetaToolsetContent) -> JSONValue {
    let blocks = (toolsetJSON(content).arrayValue ?? []).filter { $0["type"] == "browser_state" }
    #expect(blocks.count == 1)
    return blocks.first ?? .null
}

/// The block types of the content.
func toolsetBlockTypes(_ content: BetaToolsetContent) -> [String] {
    (toolsetJSON(content).arrayValue ?? []).compactMap { $0["type"]?.stringValue }
}

/// The `ToolError` a call throws.
func toolsetCallError(_ body: () async throws -> BetaToolsetContent) async -> ToolError? {
    do {
        let content = try await body()
        Issue.record("expected a ToolError, got \(toolsetJSON(content))")
        return nil
    } catch let error as ToolError {
        return error
    } catch {
        Issue.record("expected a ToolError, got \(error)")
        return nil
    }
}

/// The one text the model reads for a refused call (`refusal`).
func toolsetRefusal(_ toolset: BetaRunnableToolset, _ context: BetaToolsetCallContext = BetaToolsetCallContext(), _ name: String,
                    _ input: BetaToolInput) async -> String
{
    guard let error = await toolsetCallError({ try await toolset.call(context: context, name: name, input: input) }) else {
        return ""
    }
    let texts = toolsetTexts(error.content)
    #expect(texts.count == 1, "\(texts)")
    return texts.first ?? ""
}

/// A member `tool_use` block of `family`.
func toolsetUse(_ name: String, _ input: BetaToolInput = [:], id: String = "toolu_1", family: String? = "browser") -> BetaToolUseBlock {
    BetaToolUseBlock(id: id, input: input, name: name, toolsetName: family)
}

let TOOLSET_CLICK: BetaToolInput = ["target": ["type": "coordinate", "x": 1, "y": 1]]
let TOOLSET_UPLOAD: BetaToolInput = ["target": ["type": "ref", "ref": "e1"]]

func toolsetMerge(_ a: BetaToolInput, _ b: BetaToolInput) -> BetaToolInput { a.merging(b) { _, new in new } }

let toolsetApprove: BetaConfirmCallable = { _ in true }
let toolsetApproveComputer: BetaComputerConfirmCallable = { _ in true }

/// A state change written as JSON.
func toolsetChange(_ json: JSONValue) -> BetaBrowserStateChange { try! json.decode() }

func toolsetTab(_ id: String, _ title: String, _ url: String, active: Bool? = nil) -> BetaBrowserStateTabEntryParam {
    BetaBrowserStateTabEntryParam(tabID: id, title: title, url: url, active: active)
}

/// A Python-style error type for drivers to throw, named after the Python class.
struct ToolsetPyError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String = "") { self.message = message }
    var description: String { message }
}

/// The disabled members of a `tools[]` entry (`_disabled`).
func toolsetDisabled(_ entry: JSONValue) -> [String] {
    (entry["configs"]?.objectValue ?? [:]).filter { $0.value["enabled"] == .bool(false) }.map(\.key).sorted()
}

// MARK: - The browser fake

/// One tab of the fake's world.
struct ToolsetWorldTab: Sendable {
    var id: String
    var title: String
    var url: String
}

/// The browser the fake drives: tabs, the active tab, queued state changes and a call log (`World`).
final class ToolsetWorld: @unchecked Sendable {
    var tabs: [ToolsetWorldTab] = [ToolsetWorldTab(id: "tab_1", title: "Blank", url: "about:blank")]
    var active: String? = "tab_1"
    var changes: [BetaBrowserStateChange] = []
    var calls: [String] = []
    var inputs: [BetaBrowserMemberInput] = []
    var contexts: [BetaToolsetCallContext] = []
    var stateContexts: [BetaToolsetCallContext] = []
    var pageText = "Hello"
    var fail: [String: Error] = [:]
    var stateError: Error?
    var stateOverride: BetaBrowserState?
    /// A member name -> the result to hand back instead of the usual one (tests stash off-type values on purpose).
    var results: [String: BetaBrowserMemberResult] = [:]
    var nextTab = 2

    func setTab(_ id: String, title: String, url: String, active makeActive: Bool = false) {
        if let i = tabs.firstIndex(where: { $0.id == id }) {
            tabs[i] = ToolsetWorldTab(id: id, title: title, url: url)
        } else {
            tabs.append(ToolsetWorldTab(id: id, title: title, url: url))
        }
        if makeActive { active = id }
    }

    func url(of id: String) -> String? { tabs.first { $0.id == id }?.url }

    func state(_ context: BetaToolsetCallContext) throws -> BetaBrowserState {
        stateContexts.append(context)
        if let stateError { throw stateError }
        if let stateOverride { return stateOverride }
        let drained = changes
        changes = []
        return BetaBrowserState(tabs: tabs.map { toolsetTab($0.id, $0.title, $0.url, active: $0.id == active) }, stateChanges: drained)
    }

    func record(_ name: String, _ context: BetaToolsetCallContext, _ input: BetaBrowserMemberInput) throws {
        calls.append(name)
        inputs.append(input)
        contexts.append(context)
        if let error = fail[name] { throw error }
    }

    func tab(_ tabID: String?) throws -> String {
        let key = tabID ?? active
        guard let key, tabs.contains(where: { $0.id == key }) else {
            throw ToolError("No open tab with tab_id \(tabID.map(pythonStringRepr) ?? "None").")
        }
        return key
    }

    var tabEntries: [BetaBrowserStateTabEntryParam] { tabs.map { toolsetTab($0.id, $0.title, $0.url, active: $0.id == active) } }
}

typealias ToolsetBrowserBody = @Sendable (ToolsetFakeBrowser, BetaToolsetCallContext, BetaBrowserMemberInput) async throws
    -> BetaBrowserMemberResult
typealias ToolsetBrowserExecuteHook = @Sendable (ToolsetFakeBrowser, BetaToolsetCallContext, BetaBrowserMemberName,
    BetaBrowserMemberInput) async throws -> BetaBrowserMemberResult

/// The fake browser (`FakeBrowser` / `AsyncFakeBrowser`): a handful of members over the scripted `ToolsetWorld`.
class ToolsetFakeBrowser: BetaAbstractBrowserToolset20260801, @unchecked Sendable {
    static let members: Set<BetaBrowserMemberName> = [
        .navigate, .screenshot, .leftClick, .scroll, .scrollTo, .key, .holdKey, .wait, .fileUpload, .getPageText, .newTab,
        .listTabs, .switchTab, .closeTab,
    ]

    let world: ToolsetWorld
    private let served: Set<BetaBrowserMemberName>
    private let forwards: Bool
    /// Member name -> a body that replaces the fake's (or the default) one.
    var memberBodies: [String: ToolsetBrowserBody] = [:]
    /// Replaces `execute`; call `baseExecute` from it for `super.execute`.
    var executeHook: ToolsetBrowserExecuteHook?
    /// Replaces `browserState`.
    var stateHook: (@Sendable (BetaToolsetCallContext) async throws -> BetaBrowserState)?

    init(_ world: ToolsetWorld = ToolsetWorld(), extraMembers: Set<BetaBrowserMemberName> = [], overridesExecute: Bool = false,
         configs: [String: JSONValue]? = nil, confirm: BetaConfirmCallable? = nil, urlPolicy: BetaURLPolicy? = nil,
         filePolicy: (any BetaFilePolicy)? = nil, toolConfigs: BetaToolConfigs? = nil) throws
    {
        self.world = world
        served = Self.members.union(extraMembers)
        forwards = overridesExecute
        try super.init(configs: configs, confirm: confirm, urlPolicy: urlPolicy, filePolicy: filePolicy, toolConfigs: toolConfigs)
    }

    override var implementedMembers: Set<BetaBrowserMemberName> { served }
    override var overridesExecute: Bool { forwards }

    override func browserState(context: BetaToolsetCallContext) async throws -> BetaBrowserState {
        if let stateHook { return try await stateHook(context) }
        return try world.state(context)
    }

    override func execute(context: BetaToolsetCallContext, name: BetaBrowserMemberName, input: BetaBrowserMemberInput)
        async throws -> BetaBrowserMemberResult
    {
        if let executeHook { return try await executeHook(self, context, name, input) }
        return try await baseExecute(context, name, input)
    }

    /// `super.execute`, with the world's stashed results and the per-test member bodies.
    func baseExecute(_ context: BetaToolsetCallContext, _ name: BetaBrowserMemberName, _ input: BetaBrowserMemberInput)
        async throws -> BetaBrowserMemberResult
    {
        if let body = memberBodies[name.rawValue] { return try await body(self, context, input) }
        let result = try await super.execute(context: context, name: name, input: input)
        return world.results[name.rawValue] ?? result
    }

    override func navigate(context: BetaToolsetCallContext, input: BetaBrowserNavigateInput) async throws -> BetaBrowserNavigateResult {
        try world.record("navigate", context, .betaBrowserNavigateInput(input))
        let key = try world.tab(input.tabID)
        // a history word moves within the tab's history; like a real browser the fake then reports the page it is on
        let url = ["back", "forward"].contains(input.url) ? (world.url(of: key) ?? "about:blank") : input.url
        world.setTab(key, title: "Title of \(url)", url: url)
        return BetaBrowserNavigateResult(url: url, status: 200, title: "Title of \(url)")
    }

    override func screenshot(context: BetaToolsetCallContext, input: BetaBrowserScreenshotInput) async throws -> BetaScreenshotResult {
        try world.record("screenshot", context, .betaBrowserScreenshotInput(input))
        return BetaScreenshotResult(data: "iVBORw0KGgo=")
    }

    private func action(_ name: String, _ context: BetaToolsetCallContext, _ input: BetaBrowserMemberInput) throws -> String? {
        try world.record(name, context, input)
        return nil  // a stashed line comes back through `baseExecute`
    }

    override func leftClick(context: BetaToolsetCallContext, input: BetaBrowserLeftClickInput) async throws -> String? {
        try action("left_click", context, .betaBrowserLeftClickInput(input))
    }
    override func scroll(context: BetaToolsetCallContext, input: BetaBrowserScrollInput) async throws -> String? {
        try action("scroll", context, .betaBrowserScrollInput(input))
    }
    override func scrollTo(context: BetaToolsetCallContext, input: BetaBrowserScrollToInput) async throws -> String? {
        try action("scroll_to", context, .betaBrowserScrollToInput(input))
    }
    override func key(context: BetaToolsetCallContext, input: BetaBrowserKeyInput) async throws -> String? {
        try action("key", context, .betaBrowserKeyInput(input))
    }
    override func holdKey(context: BetaToolsetCallContext, input: BetaBrowserHoldKeyInput) async throws -> String? {
        try action("hold_key", context, .betaBrowserHoldKeyInput(input))
    }
    override func wait(context: BetaToolsetCallContext, input: BetaBrowserWaitInput) async throws -> String? {
        try action("wait", context, .betaBrowserWaitInput(input))
    }
    override func fileUpload(context: BetaToolsetCallContext, input: BetaBrowserFileUploadInput) async throws -> String? {
        try action("file_upload", context, .betaBrowserFileUploadInput(input))
    }

    override func getPageText(context: BetaToolsetCallContext, input: BetaBrowserGetPageTextInput) async throws -> String {
        try world.record("get_page_text", context, .betaBrowserGetPageTextInput(input))
        return world.pageText
    }

    override func newTab(context: BetaToolsetCallContext, input: BetaBrowserNewTabInput) async throws -> BetaBrowserStateTabEntryParam {
        try world.record("new_tab", context, .betaBrowserNewTabInput(input))
        if world.results["new_tab"] != nil { return toolsetTab("unused", "", "about:blank") }
        let id = "tab_\(world.nextTab)"
        world.nextTab += 1
        world.setTab(id, title: "", url: "about:blank", active: true)
        world.changes.append(.tabOpened(id))
        return toolsetTab(id, "", "about:blank", active: true)
    }

    override func listTabs(context: BetaToolsetCallContext, input: BetaBrowserListTabsInput) async throws -> [BetaBrowserStateTabEntryParam] {
        try world.record("list_tabs", context, .betaBrowserListTabsInput(input))
        return world.tabEntries
    }

    override func switchTab(context: BetaToolsetCallContext, input: BetaBrowserSwitchTabInput) async throws -> BetaBrowserStateTabEntryParam {
        try world.record("switch_tab", context, .betaBrowserSwitchTabInput(input))
        let key = try world.tab(input.tabID)
        world.active = key
        let tab = world.tabs.first { $0.id == key }!
        return toolsetTab(key, tab.title, tab.url, active: true)
    }

    override func closeTab(context: BetaToolsetCallContext, input: BetaBrowserCloseTabInput) async throws {
        try world.record("close_tab", context, .betaBrowserCloseTabInput(input))
        let key = try world.tab(input.tabID)
        world.tabs.removeAll { $0.id == key }
        if world.active == key { world.active = world.tabs.first?.id }
    }
}

/// What a recorded input decodes to on the wire.
func toolsetInputJSON(_ input: BetaBrowserMemberInput?) -> JSONValue { input.flatMap { try? JSONValue.from($0) } ?? .null }

// MARK: - The computer fake

let TOOLSET_PNG = "iVBORw0KGgo="

/// The desktop the computer fake drives: the cursor, a call log, and what each member hands back (`Desktop`).
final class ToolsetDesktop: @unchecked Sendable {
    var cursor = (0, 0)
    var calls: [String] = []
    var inputs: [BetaComputerMemberInput] = []
    var contexts: [BetaToolsetCallContext] = []
    var fail: [String: Error] = [:]
    var results: [String: BetaComputerMemberResult] = [:]

    func record(_ name: String, _ context: BetaToolsetCallContext, _ input: BetaComputerMemberInput) throws {
        calls.append(name)
        inputs.append(input)
        contexts.append(context)
        if let error = fail[name] { throw error }
    }
}

typealias ToolsetComputerBody = @Sendable (ToolsetFakeDesktop, BetaToolsetCallContext, BetaComputerMemberInput) async throws
    -> BetaComputerMemberResult
typealias ToolsetComputerExecuteHook = @Sendable (ToolsetFakeDesktop, BetaToolsetCallContext, BetaComputerMemberName,
    BetaComputerMemberInput) async throws -> BetaComputerMemberResult

/// The fake desktop (`FakeDesktop` / `AsyncFakeDesktop`). It serves `type`, `key` and `hold_key`, so it needs a
/// `confirm`: it approves everything unless a test passes another (or `nil`, turning the keyboard off).
class ToolsetFakeDesktop: BetaAbstractComputerToolset20260801, @unchecked Sendable {
    static let members: Set<BetaComputerMemberName> = [
        .screenshot, .zoom, .cursorPosition, .mouseMove, .leftClick, .leftClickDrag, .type, .key, .holdKey, .scroll, .wait,
    ]

    let desktop: ToolsetDesktop
    private let served: Set<BetaComputerMemberName>
    private let forwards: Bool
    var memberBodies: [String: ToolsetComputerBody] = [:]
    var executeHook: ToolsetComputerExecuteHook?

    init(_ desktop: ToolsetDesktop = ToolsetDesktop(), members: Set<BetaComputerMemberName>? = nil, overridesExecute: Bool = false,
         configs: [String: JSONValue]? = nil, confirm: BetaComputerConfirmCallable? = toolsetApproveComputer,
         toolConfigs: BetaToolConfigs? = nil) throws
    {
        self.desktop = desktop
        served = members ?? Self.members
        forwards = overridesExecute
        try super.init(configs: configs, confirm: confirm, toolConfigs: toolConfigs)
    }

    override var implementedMembers: Set<BetaComputerMemberName> { served }
    override var overridesExecute: Bool { forwards }

    override func execute(context: BetaToolsetCallContext, name: BetaComputerMemberName, input: BetaComputerMemberInput)
        async throws -> BetaComputerMemberResult
    {
        if let executeHook { return try await executeHook(self, context, name, input) }
        return try await baseExecute(context, name, input)
    }

    func baseExecute(_ context: BetaToolsetCallContext, _ name: BetaComputerMemberName, _ input: BetaComputerMemberInput)
        async throws -> BetaComputerMemberResult
    {
        if let body = memberBodies[name.rawValue] { return try await body(self, context, input) }
        let result = try await super.execute(context: context, name: name, input: input)
        return desktop.results[name.rawValue] ?? result
    }

    override func screenshot(context: BetaToolsetCallContext, input: BetaComputerScreenshotInput) async throws -> BetaScreenshotResult {
        try desktop.record("screenshot", context, .betaComputerScreenshotInput(input))
        return BetaScreenshotResult(data: TOOLSET_PNG)
    }
    override func zoom(context: BetaToolsetCallContext, input: BetaComputerZoomInput) async throws -> BetaScreenshotResult {
        try desktop.record("zoom", context, .betaComputerZoomInput(input))
        return BetaScreenshotResult(data: TOOLSET_PNG, mediaType: .imageJpeg)
    }
    override func cursorPosition(context: BetaToolsetCallContext, input: BetaComputerCursorPositionInput) async throws
        -> BetaComputerCursorPositionResult
    {
        let (x, y) = desktop.cursor
        try desktop.record("cursor_position", context, .betaComputerCursorPositionInput(input))
        return BetaComputerCursorPositionResult(x: x, y: y)
    }
    override func mouseMove(context: BetaToolsetCallContext, input: BetaComputerMouseMoveInput) async throws -> String? {
        desktop.cursor = (input.coordinate[0], input.coordinate[1])
        try desktop.record("mouse_move", context, .betaComputerMouseMoveInput(input))
        return nil
    }
    override func leftClick(context: BetaToolsetCallContext, input: BetaComputerLeftClickInput) async throws -> String? {
        try desktop.record("left_click", context, .betaComputerLeftClickInput(input))
        return nil
    }
    override func leftClickDrag(context: BetaToolsetCallContext, input: BetaComputerLeftClickDragInput) async throws -> String? {
        try desktop.record("left_click_drag", context, .betaComputerLeftClickDragInput(input))
        return nil
    }
    override func type(context: BetaToolsetCallContext, input: BetaComputerTypeInput) async throws -> String? {
        try desktop.record("type", context, .betaComputerTypeInput(input))
        return nil
    }
    override func key(context: BetaToolsetCallContext, input: BetaComputerKeyInput) async throws -> String? {
        try desktop.record("key", context, .betaComputerKeyInput(input))
        return nil
    }
    override func holdKey(context: BetaToolsetCallContext, input: BetaComputerHoldKeyInput) async throws -> String? {
        try desktop.record("hold_key", context, .betaComputerHoldKeyInput(input))
        return nil
    }
    override func scroll(context: BetaToolsetCallContext, input: BetaComputerScrollInput) async throws -> String? {
        try desktop.record("scroll", context, .betaComputerScrollInput(input))
        return nil
    }
    override func wait(context: BetaToolsetCallContext, input: BetaComputerWaitInput) async throws -> String? {
        try desktop.record("wait", context, .betaComputerWaitInput(input))
        return nil
    }
}

func toolsetComputerInputJSON(_ input: BetaComputerMemberInput?) -> JSONValue { input.flatMap { try? JSONValue.from($0) } ?? .null }

// MARK: - The echo stubs

let TOOLSET_BROWSER_ENTRY: JSONValue = ["type": "browser_toolset_20260801", "configs": ["javascript_exec": ["enabled": true]]]

/// A toolset that records calls and echoes the member name plus input, and throws on the `boom` / `blank` /
/// `crash` / `misuse` members (`AsyncEchoBrowserToolset`).
class ToolsetEchoBrowser: BetaRunnableToolset, @unchecked Sendable {
    var calls: [(String, JSONValue)] = []
    var contexts: [BetaToolsetCallContext] = []
    var closed = 0
    var failure: (@Sendable (String) -> Error)?

    override var toolsetName: String { "browser" }
    override func toDict() throws -> JSONValue { TOOLSET_BROWSER_ENTRY }

    override func call(context: BetaToolsetCallContext, name: String, input: BetaToolInput) async throws -> BetaToolsetContent {
        calls.append((name, .object(input)))
        contexts.append(context)
        if let failure { throw failure(name) }
        switch name {
        case "boom":
            throw ToolError(toolsetContent([
                textBlock("member refused"),
                ["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": "AAAA"]],
            ]))
        case "blank": throw ToolError(toolsetContent([textBlock("")]))
        case "crash": throw RuntimeError("backend exploded")
        case "misuse": throw ToolsetContractError("the driver misused the SDK surface")
        default: return .string("\(name):\(pythonJSONDumps(.object(input)))")
        }
    }

    override func close() async throws {
        closed += 1
        try await super.close()
    }
}
