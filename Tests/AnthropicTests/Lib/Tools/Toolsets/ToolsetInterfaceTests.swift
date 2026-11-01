// Port of `tests/lib/tools/toolsets/test_interface.py`, `test_registry.py` and `test_surface.py`: construction rules
// and the dispatch surface of the abstract browser toolset, and the member registry against the published toolset.

import Foundation
import Testing
@testable import Anthropic

private let CTX = BetaToolsetCallContext()

/// A browser that serves `navigate` and `screenshot` (`TwoMembers` / `AsyncTwoMembers`).
class ToolsetTwoMembers: BetaAbstractBrowserToolset20260801, @unchecked Sendable {
    override var implementedMembers: Set<BetaBrowserMemberName> { [.navigate, .screenshot] }
    override func browserState(context: BetaToolsetCallContext) async throws -> BetaBrowserState { BetaBrowserState(tabs: []) }
    override func navigate(context: BetaToolsetCallContext, input: BetaBrowserNavigateInput) async throws -> BetaBrowserNavigateResult {
        BetaBrowserNavigateResult(url: input.url, status: 200, title: "T")
    }
    override func screenshot(context: BetaToolsetCallContext, input: BetaBrowserScreenshotInput) async throws -> BetaScreenshotResult {
        BetaScreenshotResult(data: "AAAA")
    }
}

/// A `ToolsetTwoMembers` that adds hooks around `super.execute`, and so serves every member.
final class ToolsetHookedTwoMembers: ToolsetTwoMembers, @unchecked Sendable {
    override var overridesExecute: Bool { true }
    override func execute(context: BetaToolsetCallContext, name: BetaBrowserMemberName, input: BetaBrowserMemberInput) async throws
        -> BetaBrowserMemberResult
    {
        try await super.execute(context: context, name: name, input: input)
    }
}

/// A browser that forwards every call through `execute` alone.
final class ToolsetForwardingBrowser: BetaAbstractBrowserToolset20260801, @unchecked Sendable {
    override var overridesExecute: Bool { true }
    override func browserState(context: BetaToolsetCallContext) async throws -> BetaBrowserState { BetaBrowserState(tabs: []) }
    override func execute(context: BetaToolsetCallContext, name: BetaBrowserMemberName, input: BetaBrowserMemberInput) async throws
        -> BetaBrowserMemberResult
    {
        .text("forwarded \(name.rawValue)")
    }
}

class ToolsetMiddleBrowser: ToolsetTwoMembers, @unchecked Sendable {}

final class ToolsetLeafBrowser: ToolsetMiddleBrowser, @unchecked Sendable {
    override var implementedMembers: Set<BetaBrowserMemberName> { super.implementedMembers.union([.getPageText]) }
    override func getPageText(context: BetaToolsetCallContext, input: BetaBrowserGetPageTextInput) async throws -> String { "t" }
}

@Suite struct ToolsetInterfaceTests {
    @Test func unimplementedMembersAreSentAsDisabledAndImplementedOnesLeftToTheAPI() throws {
        // and its async twin
        let entry = try ToolsetTwoMembers().toDict()
        #expect(entry["type"] == "browser_toolset_20260801")
        let disabled = toolsetDisabled(entry)
        #expect(!disabled.contains("navigate") && !disabled.contains("screenshot"))
        // Everything the subclass did not override is withheld, default-disabled members included.
        #expect(disabled.count == 29 && disabled.contains("left_click") && disabled.contains("javascript_exec"))
        // Nothing SDK-side leaks into the entry.
        #expect(Set(entry.objectValue!.keys) == ["type", "configs"])
        #expect(entry["configs"]!.objectValue!.values.allSatisfy { Set($0.objectValue!.keys) == ["enabled"] })
    }

    @Test func theCallersConfigsPassThroughUntouchedAndAreCopied() throws {
        var configs: [String: JSONValue] = ["navigate": ["defer_loading": true], "javascript_exec": ["enabled": false, "defer_loading": true]]
        let browser = try ToolsetTwoMembers(configs: configs)
        let entry = browser.toDict()
        #expect(entry["configs"]?["navigate"] == ["defer_loading": true])
        #expect(entry["configs"]?["javascript_exec"] == ["enabled": false, "defer_loading": true])
        // Enabling a member the subclass does not implement would offer the model something that can only answer
        // "not available": refused at construction.
        do {
            _ = try ToolsetTwoMembers(configs: ["javascript_exec": ["enabled": true]])
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message.contains("does not implement"))
        }
        configs["navigate"] = ["defer_loading": true, "enabled": false]
        #expect(browser.toDict()["configs"]?["navigate"] == ["defer_loading": true])
    }

    @Test func anExecuteOnlySubclassServesEveryMemberAndTurnsMembersOffWithConfigs() async throws {
        // and its async twin
        #expect(toolsetDisabled(try ToolsetForwardingBrowser().toDict()) == [])
        let trimmed = try ToolsetForwardingBrowser(configs: ["screenshot": ["enabled": false], "zoom": ["enabled": false]]).toDict()
        #expect(toolsetDisabled(trimmed) == ["screenshot", "zoom"])
        // A subclass that only overrides member methods serves only those.
        #expect(toolsetDisabled(try ToolsetTwoMembers().toDict()).contains("zoom"))

        // One that adds hooks around super.execute also serves every member: a member it implements runs, one it does
        // not answers from its default body inside super.execute, and configs turns off the rest.
        let hooked = try ToolsetHookedTwoMembers()
        #expect(toolsetDisabled(hooked.toDict()) == [])
        let result = try await hooked.execute(context: CTX, name: .navigate, input: .betaBrowserNavigateInput(BetaBrowserNavigateInput(url: "https://example.com/")))
        #expect(result == .navigate(BetaBrowserNavigateResult(url: "https://example.com/", status: 200, title: "T")))
        do {
            _ = try await hooked.execute(context: CTX, name: .zoom, input: .betaBrowserZoomInput(BetaBrowserZoomInput(region: [0, 0, 1, 1])))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message.contains("not available"))
        }
        #expect(toolsetDisabled(try ToolsetHookedTwoMembers(configs: ["zoom": ["enabled": false]]).toDict()) == ["zoom"])
    }

    @Test func aNullConfigsEntryLeavesTheMemberAtItsDefaultsAndGoesToTheAPIAsGiven() async throws {
        let entry = try ToolsetTwoMembers(configs: ["navigate": nil, "screenshot": nil]).toDict()
        #expect(entry["configs"]?["navigate"] == .null && !toolsetDisabled(entry).contains("navigate"))
        _ = try await ToolsetTwoMembers(configs: ["navigate": nil]).call(context: CTX, name: "navigate", input: ["url": "https://example.com/"])
    }

    @Test func anEntryThatIsNotAnObjectFailsLoudly() {
        // test_configs_are_gated_on_the_copy_that_is_sent: an entry that is not a mapping fails rather than collapsing
        // to {} (member left on). The dict subclasses that answer differently when copied have no Swift counterpart.
        #expect(throws: ToolsetConfigError.self) { try ToolsetTwoMembers(configs: ["navigate": []]) }
    }

    @Test func urlPolicyIsAClosureOrUnset() throws {
        _ = try ToolsetTwoMembers(urlPolicy: { _, _ in })
        _ = try ToolsetTwoMembers()
    }

    @Test func toolConfigsGoOntoTheEntryAndTheHelperTagDoesNot() throws {
        let browser = try ToolsetTwoMembers(toolConfigs: ["cache_control": ["type": "ephemeral"]])
        #expect(browser.toDict()["cache_control"] == ["type": "ephemeral"])
        #expect(browser.helperTag == "browser-toolset")
        #expect(!browser.toDict().description.contains("browser-toolset"))
        do {
            _ = try ToolsetTwoMembers(toolConfigs: ["configs": ["navigate": ["enabled": false]]])
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message == "tool_configs cannot set 'configs'; pass configs= instead")
        }
        #expect(try ToolsetTwoMembers(toolConfigs: ["type": "browser_toolset_20990101"]).toDict()["type"] == "browser_toolset_20260801")
    }

    @Test func executeDispatchesToTheMemberMethodAndRefusesUnknownNames() async throws {
        // and its async twin
        let browser = try ToolsetTwoMembers()
        let result = try await browser.execute(context: CTX, name: .navigate, input: .betaBrowserNavigateInput(BetaBrowserNavigateInput(url: "https://example.com/")))
        #expect(result == .navigate(BetaBrowserNavigateResult(url: "https://example.com/", status: 200, title: "T")))
        do {
            _ = try await browser.execute(context: CTX, name: "__init__", input: .betaBrowserNavigateInput(BetaBrowserNavigateInput(url: "x")))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "Error: unknown browser toolset member '__init__'")
        }
        // A member the subclass did not implement answers the model rather than throwing into the runner.
        do {
            _ = try await browser.execute(context: CTX, name: .getPageText, input: .betaBrowserGetPageTextInput(BetaBrowserGetPageTextInput()))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "The browser toolset member 'get_page_text' is not available in this environment.")
        }
    }

    @Test func unknownMemberNameIsSanitisedInTheRefusal() async throws {
        // and its async twin
        do {
            _ = try await ToolsetTwoMembers().execute(
                context: CTX, name: BetaBrowserMemberName(rawValue: "x'\n\u{202e}evil"), input: .betaBrowserNavigateInput(BetaBrowserNavigateInput(url: "x")))
            Issue.record("expected a refusal")
        } catch let error as ToolError {
            #expect(error.message == "Error: unknown browser toolset member 'x evil'")  // one line, no quote, runs collapsed
        }
    }

    @Test func implementedMembersCarryThroughIntermediateClasses() throws {
        // test_override_detection_sees_dynamic_assignment_and_intermediate_classes: Swift has no dynamic assignment of
        // methods; a subclass extends its superclass's implementedMembers.
        let disabled = toolsetDisabled(try ToolsetLeafBrowser().toDict())
        #expect(Set(["navigate", "screenshot", "get_page_text"]).isDisjoint(with: disabled))
    }

    @Test func optionsDoNotLeakIntoTheEntry() throws {
        let entry = try ToolsetTwoMembers(confirm: toolsetApprove, urlPolicy: { _, _ in }).toDict()
        #expect(Set(entry.objectValue!.keys) == ["type", "configs"])
    }

    @Test func configsIsACopyOfWhatToDictSends() throws {
        for browser in [try ToolsetTwoMembers(configs: ["javascript_exec": ["enabled": false]]), try ToolsetTwoMembers()] {
            var configs = browser.configs
            #expect(configs != nil && configs.map { JSONValue.object($0) } == browser.toDict()["configs"])
            #expect(configs?["left_click"] == ["enabled": false])  // not implemented, so withheld from the model
            configs?["left_click"] = ["enabled": true]  // a copy: nothing the toolset holds changes
            #expect(browser.configs?["left_click"] == ["enabled": false])
        }
    }

    @Test func aToolsetInstanceIsAToolLike() throws {
        let tool: any BetaToolLike = try ToolsetTwoMembers()
        #expect(try tool.toToolParam()["type"] == "browser_toolset_20260801")
        #expect(tool.helperTag == "browser-toolset")
    }

    @Test func valueTypesConstruct() {
        #expect(BetaBrowserState(tabs: []).stateChanges.isEmpty)
        let context = BetaURLContext()
        #expect(context.member == nil && context.tabID == nil && context.toolUseID == nil)
        #expect(BetaScreenshotResult(data: "AAAA").mediaType == .imagePng)
    }

    @Test func stateChangesAreToldApartByTheirType() throws {
        // A wire change decodes into the generated union; the SDK's own kinds arrive as their own cases.
        let download: JSONValue = ["type": "download_completed", "download_id": "d1", "url": "https://a.test/f"]
        let opened: JSONValue = ["type": "tab_opened", "tab_id": "tab_2"]
        let dialog: JSONValue = ["type": "dialog_dismissed", "kind": "confirm", "message": "Sure?"]
        let state: BetaBrowserState = try JSONValue.object(["tabs": [], "state_changes": [download, opened, ["type": "navigation_refused"], dialog]]).decode()
        #expect(state.stateChanges.count == 4)
        if case .change(.downloadCompleted(let d)) = state.stateChanges[0] { #expect(d.downloadID == "d1") } else { Issue.record("not a download") }
        #expect(state.stateChanges[1] == .tabOpened("tab_2"))
        #expect(state.stateChanges[2] == .navigationRefused(BetaNavigationRefused()))
        #expect(state.stateChanges[3] == .dialogDismissed(BetaDialogDismissed(kind: "confirm", message: "Sure?")))

        func decodingError(_ change: JSONValue) -> String {
            do {
                _ = try change.decode(as: BetaBrowserStateChange.self)
                return ""
            } catch {
                return "\(error)"
            }
        }
        #expect(decodingError(["download_id": "d1", "url": "https://a.test/f"]).contains("'type'"))
        #expect(decodingError([:]).contains("'type'"))
        let unknown = decodingError(["type": "made_up", "url": "https://a.test/"])
        for tag in BetaBrowserStateChange.tags { #expect(unknown.contains(tag)) }
        #expect(decodingError(["type": "download_completed", "downlaod_id": "d1", "url": "https://a.test/f"]).contains("download_id"))
    }
}

// MARK: - test_registry.py

/// `anthropic/_data/browser_toolset_members.py`, the toolset's member table generated from the API's definition.
private func publishedBrowserMembers() throws -> [String: JSONValue] {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let source = try String(contentsOf: root.appendingPathComponent("upstream/anthropic-sdk-python/src/anthropic/_data/browser_toolset_members.py"),
                            encoding: .utf8)
    guard let start = source.range(of: "BROWSER_TOOLSET_MEMBERS: Dict[str, BrowserToolsetMembers] = ") else { return [:] }
    var literal = String(source[start.upperBound...])
    literal = literal.replacingOccurrences(of: "None", with: "null").replacingOccurrences(of: "True", with: "true")
        .replacingOccurrences(of: "False", with: "false")
        .replacingOccurrences(of: #",(\s*[}\]])"#, with: "$1", options: .regularExpression)
    return try JSONValue.parse(literal).objectValue ?? [:]
}

@Suite struct ToolsetRegistryTests {
    @Test func memberSetMatchesThePublishedToolset() throws {
        let published = try publishedBrowserMembers()
        #expect(Set(BROWSER_REGISTRY.names) == Set(published.keys))
        #expect(BROWSER_REGISTRY.names.count == Set(BROWSER_REGISTRY.names).count && BROWSER_REGISTRY.names.count == 31)
    }

    @Test func defaultDisabledMembersMatchThePublishedToolset() throws {
        let published = try publishedBrowserMembers()
        #expect(BROWSER_DEFAULT_DISABLED_MEMBERS == Set(published.filter { $0.value["enabled_by_default"] == false }.keys))
    }

    @Test func resultKindsConfirmationsAndDefaultFlagsMatchThePublishedToolset() throws {
        for (name, member) in try publishedBrowserMembers() {
            let row = BROWSER_ROWS[name]
            #expect(row?.0.rawValue == member["result"]?.stringValue, "\(name)")
            #expect(row?.1 == member["confirmation"]?.stringValue, "\(name)")
            #expect(row.map { JSONValue.bool($0.2) } == member["enabled_by_default"], "\(name)")
        }
    }

    @Test func membersThatNeedAConfirmMatchThePublishedToolset() throws {
        #expect(BROWSER_CONFIRM_REQUIRED == Set(try publishedBrowserMembers().filter { $0.value["confirm_required"] == true }.keys))
    }

    @Test func memberSetMatchesTheGeneratedConfigsParam() {
        // The wire configs object has one key per member.
        let fields = Mirror(reflecting: BetaBrowserToolsetConfigsParam()).children.compactMap { $0.label.map(wireFieldName) }
        #expect(Set(fields) == Set(BROWSER_REGISTRY.names))
    }

    @Test func staticAliasesAgreeWithTheDerivedTables() throws {
        #expect(BetaBrowserMemberName.allCases.map(\.rawValue) == BROWSER_REGISTRY.names)
        for name in BROWSER_REGISTRY.names {
            // every member parses into the input case of its own name; the two property-less members take {}
            if let input = try? parseBrowserInput(name, ["url": "u", "tab_id": "t", "text": "x", "query": "q", "duration": 1,
                                                       "region": [0, 0, 1, 1], "scroll_direction": "up",
                                                       "target": ["type": "ref", "ref": "e1"], "value": "v"]) {
                #expect(input.memberName == name)
            }
        }
        #expect(try parseBrowserInput("navigate", ["url": "u"]) == .betaBrowserNavigateInput(BetaBrowserNavigateInput(url: "u")))
        #expect(try parseBrowserInput("new_tab", [:]) == .betaBrowserNewTabInput(BetaBrowserNewTabInput()))
        #expect(try parseBrowserInput("list_tabs", [:]) == .betaBrowserListTabsInput(BetaBrowserListTabsInput()))
    }

    @Test func everyPureActionHasConfirmationTextAndTabMembersRenderStateOnly() {
        for name in BROWSER_REGISTRY.names {
            let member = BROWSER_REGISTRY.members[name]!
            if BROWSER_STATE_ONLY_MEMBERS.contains(name) {
                #expect(member.text == nil && [.tab, .tabs, .none].contains(member.result))
            } else if member.result == .none {
                #expect(member.text?.isEmpty == false, "\(name) is a pure action with nothing for the model to read")
            }
        }
    }

    @Test func derivedMemberSets() {
        #expect(BROWSER_STATE_ONLY_MEMBERS == ["new_tab", "list_tabs", "switch_tab", "close_tab"])
    }

    @Test func memberEnabledFailsClosed() {
        let enabled = BROWSER_REGISTRY.memberEnabled
        #expect(enabled("navigate", nil) == true)
        #expect(enabled("javascript_exec", nil) == false)
        #expect(enabled("javascript_exec", ["javascript_exec": ["enabled": true]]) == true)
        #expect(enabled("navigate", ["navigate": ["enabled": false]]) == false)
        // Anything but a real boolean turns the member off rather than on.
        #expect(enabled("javascript_exec", ["javascript_exec": ["enabled": "yes"]]) == false)
        #expect(enabled("navigate", ["navigate": ["enabled": 1]]) == false)
        #expect(enabled("navigate", ["navigate": ["defer_loading": true]]) == true)
        // An entry that is neither an object nor null reads as off too.
        #expect(enabled("navigate", ["navigate": false]) == false)
        #expect(enabled("navigate", ["navigate": "off"]) == false)
        #expect(enabled("navigate", ["navigate": nil]) == true)  // null is the wire type's "defaults"
    }

    @Test func everyConfirmationPlaceholderHasATemplateField() throws {
        let regex = try NSRegularExpression(pattern: #"\{(\w+)\}"#)
        var placeholders = Set<String>()
        for member in BROWSER_REGISTRY.members.values {
            guard let text = member.text else { continue }
            for match in regex.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                placeholders.insert(String(text[Range(match.range(at: 1), in: text)!]))
            }
        }
        #expect(placeholders == Set(TEMPLATE_FIELDS.keys))
    }

    @Test func everyStateChangeKindIsEitherTabOpenedOrADownloadKind() throws {
        let wire = BetaBrowserStateChange.tags.filter { !["navigation_refused", "dialog_dismissed"].contains($0) }
        #expect(Set(wire) == Set(["tab_opened"] + DOWNLOAD_TYPES))
        // each wire kind decodes into a case of the generated union
        for kind in wire {
            let change: BetaBrowserStateChangeParam = try JSONValue.object(["type": .string(kind), "tab_id": "t", "download_id": "d", "url": "u"]).decode()
            if case .unknown = change { Issue.record("\(kind) is not a generated change kind") }
        }
    }
}
