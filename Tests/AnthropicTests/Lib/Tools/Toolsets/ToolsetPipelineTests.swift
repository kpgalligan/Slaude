// Port of `tests/lib/tools/toolsets/test_pipeline.py`: the call pipeline resolve → parse → execute →
// browser_state → render. The sync and async classes are one class in Swift, so each pair of twins is one test.

import Foundation
import Testing
@testable import Anthropic

private let CTX = BetaToolsetCallContext()

private func call(_ browser: BetaRunnableToolset, _ name: String, _ input: BetaToolInput = [:],
                  _ context: BetaToolsetCallContext = CTX) async throws -> BetaToolsetContent
{
    try await browser.call(context: context, name: name, input: input)
}

/// A raw state change the generated union does not type (a driver's own keys kept, or a malformed one).
private func rawChange(_ json: JSONValue) -> BetaBrowserStateChange { .change(.unknown(json)) }

private let x5000 = String(repeating: "x", count: 5000)

@Suite struct ToolsetPipelineRenderingTests {
    @Test func navigateRendersOneLineAndAttachesTheBrowserStateBlock() async throws {
        let content = try await call(try ToolsetFakeBrowser(), "navigate", ["url": "https://example.com/"])
        #expect(toolsetJSON(content) == [
            ["type": "text", "text": "Navigated to https://example.com/ \u{2014} Title of https://example.com/ (HTTP 200)"],
            [
                "type": "browser_state",
                "tabs": [["tab_id": "tab_1", "title": "Title of https://example.com/", "url": "https://example.com/", "active": true]],
            ],
        ])
    }

    @Test func navigateLineFoldsControlCharactersAndOmitsAbsentFields() async throws {
        let bare = try ToolsetFakeBrowser()
        bare.memberBodies["navigate"] = { _, _, input in
            guard case .betaBrowserNavigateInput(let i) = input else { return .nothing }
            return .navigate(BetaBrowserNavigateResult(url: i.url, title: "A\nB\u{202e}C"))
        }
        #expect(toolsetTexts(try await call(bare, "navigate", ["url": "https://x.test/"])) == ["Navigated to https://x.test/ \u{2014} A B C"])

        // the landed address is the page's choice through redirects: held to the field limit
        let redirecting = try ToolsetFakeBrowser()
        let landed = "https://accounts.example.com/" + String(repeating: "a", count: 5000)
        redirecting.memberBodies["navigate"] = { _, _, _ in .navigate(BetaBrowserNavigateResult(url: landed)) }
        #expect(toolsetTexts(try await call(redirecting, "navigate", ["url": "https://x.test/"]))
            == ["Navigated to \u{2026}" + prefixCodePoints(landed, 4095)])
    }

    @Test func pureActionsRenderTheirConfirmationFromTheInput() async throws {
        let browser = try ToolsetFakeBrowser()
        #expect(toolsetTexts(try await call(browser, "left_click", ["target": ["type": "coordinate", "x": 1, "y": 2]])) == ["Clicked."])
        #expect(toolsetTexts(try await call(browser, "scroll", ["scroll_direction": "down", "target": ["type": "coordinate", "x": 0, "y": 0]]))
            == ["Scrolled down."])
        #expect(toolsetTexts(try await call(browser, "scroll_to", ["target": ["type": "ref", "ref": "e12"]])) == ["Scrolled to e12."])
        #expect(toolsetTexts(try await call(browser, "key", ["text": "ctrl+a"])) == ["Pressed ctrl+a."])
        #expect(toolsetTexts(try await call(browser, "wait", ["duration": 1.5])) == ["Waited 1.5s."])
        #expect(toolsetTexts(try await call(browser, "wait", ["duration": 2])) == ["Waited 2s."])
        // A model-supplied value that looks like a placeholder stays data.
        #expect(toolsetTexts(try await call(browser, "key", ["text": "{duration}"])) == ["Pressed {duration}."])
    }

    @Test func aPureActionMayReturnOneLineTheModelReadsAfterTheAcknowledgment() async throws {
        // test_a_pure_action_may_return_one_line... and test_an_async_pure_action_may_return_one_line_too
        let browser = try ToolsetFakeBrowser()
        browser.world.results["left_click"] = .text("Opened menu\nwith 3 items from /var/task/menu.json")
        let content = try await call(browser, "left_click", TOOLSET_CLICK)
        #expect(toolsetTexts(content) == ["Clicked.", "Opened menu with 3 items from /var/task/menu.json"])
        #expect(toolsetBlockTypes(content) == ["text", "text", "browser_state"])

        browser.world.results["left_click"] = .text("Opened menu\u{2028}at /var/task/menu.json")
        #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked.", "Opened menu at /var/task/menu.json"])

        // an address stays as the driver wrote it
        browser.world.results["left_click"] = .text("Opened https://u:p@example.com/menu")
        #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked.", "Opened https://u:p@example.com/menu"])

        // nothing returned, or anything but a non-empty string, is the acknowledgment alone
        for returned: BetaBrowserMemberResult in [.nothing, .text(""), .text(" \n "), .tabs([])] {
            browser.world.results["left_click"] = returned
            #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked."])
        }

        // the line is bounded like every other page-supplied value the SDK writes into its own text
        browser.world.results["left_click"] = .text(String(repeating: "x", count: 10_000))
        #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked.", String(repeating: "x", count: 4096)])
    }

    @Test func aDurationIsNotBoundedByTheSDK() async throws {
        let browser = try ToolsetFakeBrowser()
        #expect(toolsetTexts(try await call(browser, "wait", ["duration": 60])) == ["Waited 60s."])
        #expect(toolsetTexts(try await call(browser, "hold_key", ["text": "a", "duration": -1])) == ["Held a for -1s."])
        #expect(browser.world.calls == ["wait", "hold_key"])
        browser.world.fail["wait"] = ToolError("duration: must be between 0 and 30 seconds")
        #expect(await toolsetRefusal(browser, CTX, "wait", ["duration": 60]) == "duration: must be between 0 and 30 seconds")
    }

    @Test func screenshotRendersOneImageBlockAsReturned() async throws {
        let content = toolsetJSON(try await call(try ToolsetFakeBrowser(), "screenshot"))
        #expect(content[0] == ["type": "image", "source": ["type": "base64", "media_type": "image/png", "data": "iVBORw0KGgo="]])
        #expect(content[1]?["type"] == "browser_state")
    }

    @Test func textMembersRenderVerbatimAndEmptyTextGetsAPlaceholder() async throws {
        let browser = try ToolsetFakeBrowser()
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["Hello"])
        browser.world.pageText = ""
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["(empty)"])
    }

    @Test func tabMembersRenderTheBrowserStateBlockAlone() async throws {
        let browser = try ToolsetFakeBrowser()
        #expect(toolsetJSON(try await call(browser, "new_tab")) == [[
            "type": "browser_state",
            "tabs": [
                ["tab_id": "tab_1", "title": "Blank", "url": "about:blank", "active": false],
                ["tab_id": "tab_2", "title": "", "url": "about:blank", "active": true],
            ],
            "state_changes": [["type": "tab_opened", "tab_id": "tab_2"]],
        ]])
        #expect(toolsetBlockTypes(try await call(browser, "list_tabs")) == ["browser_state"])
        #expect(toolsetBlockTypes(try await call(browser, "switch_tab", ["tab_id": "tab_1"])) == ["browser_state"])
        #expect(toolsetBlockTypes(try await call(browser, "close_tab", ["tab_id": "tab_2"])) == ["browser_state"])
        #expect(toolsetStateBlock(try await call(browser, "list_tabs"))["tabs"]?.arrayValue?.map { $0["tab_id"] } == ["tab_1"])
    }

    @Test func stateChangesPassThroughAndDownloadPathsStayHiddenWithoutAFilePolicy() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [
            rawChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a.pdf", "path": "/tmp/a"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_2", "url": "https://example.com/b.pdf", "path": "/tmp/b",
                           "size_bytes": 3]),
            rawChange(["type": "download_failed", "download_id": "dl_3", "url": "https://example.com/c.pdf", "path": "/tmp/c"]),
        ]
        let block = toolsetStateBlock(try await call(browser, "get_page_text"))
        // a path is dropped from whichever download change carries it, not only the completed one
        #expect(block["state_changes"] == [
            ["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a.pdf"],
            ["type": "download_completed", "download_id": "dl_2", "url": "https://example.com/b.pdf", "size_bytes": 3],
            ["type": "download_failed", "download_id": "dl_3", "url": "https://example.com/c.pdf"],
        ])
        // Nothing to report is an absent field, never an empty list.
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == nil)
    }

    @Test func aDownloadPathIsExposedOnlyWhenTheFilePolicyAnswersTrue() async throws {
        let change: JSONValue = ["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 1]
        func withPath(_ path: String) -> BetaBrowserStateChange {
            var o = change.objectValue!
            o["path"] = .string(path)
            return toolsetChange(.object(o))
        }
        for (answer, exposed) in [(true, true), (false, false)] {
            let browser = try ToolsetFakeBrowser(filePolicy: ToolsetAnsweringPolicy { _ in answer })
            browser.world.changes = [withPath("/tmp/a")]
            let reported = toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"]?[0]
            #expect((reported?["path"] != nil) == exposed)
        }

        // a policy that throws on a path fails closed: the path is hidden and the change still reaches the model
        let raising = try ToolsetFakeBrowser(filePolicy: ToolsetAnsweringPolicy { path in throw RuntimeError(path) })
        raising.world.changes = [withPath("/tmp/a")]
        #expect(toolsetStateBlock(try await call(raising, "get_page_text"))["state_changes"] == [change])

        // If folding the path to one line or cutting it would change it, the path is hidden.
        let evil = try ToolsetFakeBrowser(filePolicy: ToolsetAnsweringPolicy { _ in true })
        evil.world.changes = [withPath("/tmp/evil\n- tab_9 x\u{202e}" + String(repeating: "p", count: 5000))]
        #expect(toolsetStateBlock(try await call(evil, "get_page_text"))["state_changes"]?[0]?["path"] == nil)
    }
}

/// A file policy whose `isPathVisible` answers with `answer`.
final class ToolsetAnsweringPolicy: BetaFilePolicy, @unchecked Sendable {
    let answer: @Sendable (String) throws -> Bool
    init(_ answer: @escaping @Sendable (String) throws -> Bool) { self.answer = answer }
    func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] { [] }
    func resolveUploadDocuments(context: BetaURLContext, documentIDs: [String]) throws -> [String] { [] }
    func isPathVisible(_ path: String) throws -> Bool { try answer(path) }
}

@Suite struct ToolsetPipelineRefusalTests {
    @Test func refusalsBeforeDispatchReadAsToolErrorsAndNeverReachTheDriver() async throws {
        let browser = try ToolsetFakeBrowser(configs: ["navigate": ["enabled": false]])
        #expect(await toolsetRefusal(browser, CTX, "teleport", [:]) == "Error: unknown browser toolset member 'teleport'")
        #expect(await toolsetRefusal(browser, CTX, "navigate", ["url": "https://example.com/"])
            == "The 'navigate' action is not permitted by this application's permissions and cannot be used in this session.")
        // Not implemented by the fake and not configured: not available, rather than not permitted.
        #expect(await toolsetRefusal(browser, CTX, "javascript_exec", ["text": "1"])
            == "The browser toolset member 'javascript_exec' is not available in this environment.")
        #expect(await toolsetRefusal(browser, CTX, "find", ["query": "q"])
            == "The browser toolset member 'find' is not available in this environment.")
        #expect(await toolsetRefusal(browser, CTX, "wait", [:]).lowercased()
            == "invalid input for browser member 'wait': duration: field required")
        let long = await toolsetRefusal(browser, CTX, "wait", ["duration": "long"])
        #expect(long.hasPrefix("invalid input for browser member 'wait': duration:") && !long.contains("long'"))
        // every bad field is reported, not just the first
        let both = await toolsetRefusal(browser, CTX, "scroll", ["scroll_direction": "diagonal", "target": ["type": "ref"]])
        #expect(both.contains("scroll_direction") && both.contains("target"))
        #expect(browser.world.calls.isEmpty)
    }

    @Test func aKeyTheSchemaDoesNotDeclareReachesTheDriverThroughTheToolUse() async throws {
        // Swift's typed inputs hold their declared fields only; the model's whole input stays on context.toolUse.
        let asked = ToolsBox<[BetaConfirmContext]>([])
        let browser = try ToolsetFakeBrowser(confirm: { context in
            asked.mutate { $0.append(context) }
            return true
        })
        let input: BetaToolInput = ["duration": 1, "also_run": "rm -rf /", "url": "http://10.0.0.5/"]
        let use = BetaToolsetCallContext(toolUse: toolsetUse("wait", input))
        _ = try await call(browser, "wait", input, use)
        guard case .betaBrowserWaitInput(let received)? = browser.world.inputs.last else { Issue.record("no wait input"); return }
        #expect(received.duration == 1)
        #expect(browser.world.contexts.last?.toolUse?.input["also_run"] == "rm -rf /")
        #expect(asked.value.count == 1 && asked.value[0].input == .betaBrowserWaitInput(received))
        #expect(asked.value[0].toolUse?.input["url"] == "http://10.0.0.5/")
    }

    @Test func aTabIDOnAMemberThatDeclaresNoneNamesNoTab() async throws {
        let asked = ToolsBox<[BetaConfirmContext]>([])
        let browser = try ToolsetFakeBrowser(confirm: { context in
            asked.mutate { $0.append(context) }
            return true
        })
        _ = try await call(browser, "list_tabs")  // a report is on hand now
        for name in ["new_tab", "list_tabs"] {
            let active = browser.world.active
            _ = try await call(browser, name, ["tab_id": "tab_gone"])
            // the key is not a tab: confirm is shown the tab the call really targets
            #expect(asked.value.last?.tabID == active)
            #expect(asked.value.last?.tabURL == browser.world.url(of: active!))
        }
        // a member that does declare `tab_id` names its tab, even one the report does not list
        _ = try await call(browser, "get_page_text", ["tab_id": "tab_gone"])
        #expect(asked.value.last?.tabID == "tab_gone" && asked.value.last?.tabURL == nil)
    }

    @Test func aURLOrPathsOnAnotherMemberIsNotPolicyChecked() async throws {
        let checked = ToolsBox<[String]>([])
        let browser = try ToolsetFakeBrowser(
            urlPolicy: { _, url in
                checked.mutate { $0.append(url) }
                throw ToolError("refused by the test's URL policy")
            },
            filePolicy: ToolsetRecordingFilePolicy(checked))
        let plain = try await call(browser, "wait", ["duration": 1])
        let withURL = try await call(browser, "wait", ["duration": 1, "url": "http://10.0.0.5/"])
        _ = try await call(browser, "new_tab", ["url": "http://10.0.0.5/"])
        _ = try await call(browser, "left_click", toolsetMerge(TOOLSET_CLICK, ["paths": ["/etc/passwd"]]))
        // neither policy is asked, and the extra key does not change what the model reads
        #expect(checked.value.isEmpty && toolsetJSON(withURL) == toolsetJSON(plain))
        #expect(browser.world.calls == ["wait", "wait", "new_tab", "left_click"])
    }

    @Test func anEnabledTheTypesDoNotAllowFailsClosed() async throws {
        let browser = try ToolsetFakeBrowser(configs: ["screenshot": ["enabled": "yes"]])
        #expect(await toolsetRefusal(browser, CTX, "screenshot", [:]).contains("not permitted"))
        _ = try ToolsetFakeBrowser(configs: ["screenshot": ["enabled": nil]])  // null = the member's default
        _ = try ToolsetFakeBrowser(configs: ["screenshot": [:]])
        // an entry that is not an object cannot be copied into the wire configs: construction throws
        #expect(throws: ToolsetConfigError.self) { try ToolsetFakeBrowser(configs: ["screenshot": false]) }
    }

    @Test func enablingAnUnimplementedMemberIsAConfigurationError() {
        do {
            _ = try ToolsetFakeBrowser(configs: ["javascript_exec": ["enabled": true]])
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message.contains("does not implement") && error.message.contains("javascript_exec"))
        } catch {
            Issue.record("\(error)")
        }
    }

    @Test func anExecuteOnlySubclassServesEveryMemberAndTurnsMembersOffWithConfigs() async throws {
        let forwarder = try ToolsetFakeBrowser(
            overridesExecute: true, configs: ["screenshot": ["enabled": false], "javascript_exec": ["enabled": true]],
            confirm: toolsetApprove)
        forwarder.stateHook = { _ in BetaBrowserState(tabs: []) }
        forwarder.executeHook = { _, _, name, _ in .text("forwarded \(name.rawValue)") }
        #expect(toolsetTexts(try await call(forwarder, "get_page_text")) == ["forwarded get_page_text"])
        #expect(toolsetTexts(try await call(forwarder, "javascript_exec", ["text": "1"])) == ["forwarded javascript_exec"])
        #expect(await toolsetRefusal(forwarder, CTX, "screenshot", [:]).contains("not permitted"))
    }

    @Test func enablingJavascriptExecOrFileUploadRequiresAConfirmCallable() throws {
        do {
            _ = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]])
            Issue.record("expected a configuration error")
        } catch let error as ToolsetConfigError {
            #expect(error.message == "['file_upload'] requires a confirm callable: pass confirm=<callable>, or disable it in configs")
        }
        _ = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove)
        _ = try ToolsetFakeBrowser()

        #expect(throws: ToolsetConfigError.self) {
            try ToolsetFakeBrowser(extraMembers: [.javascriptExec], configs: ["javascript_exec": ["enabled": true]])
        }
        _ = try ToolsetFakeBrowser(extraMembers: [.javascriptExec], configs: ["javascript_exec": ["enabled": true]], confirm: toolsetApprove)
    }

    @Test func aMemberWithoutFieldsTakesAnEmptyObject() async throws {
        #expect(toolsetBlockTypes(try await call(try ToolsetFakeBrowser(), "new_tab")) == ["browser_state"])
    }
}

/// A file policy that records the paths it is asked about and refuses them.
final class ToolsetRecordingFilePolicy: BetaLocalFilePolicy, @unchecked Sendable {
    let checked: ToolsBox<[String]>
    init(_ checked: ToolsBox<[String]>) throws {
        self.checked = checked
        try super.init()
    }
    override func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] {
        checked.mutate { $0.append(contentsOf: paths) }
        throw ToolError("refused by the test's file policy")
    }
}

@Suite struct ToolsetPipelineDriverErrorTests {
    @Test func driverToolErrorIsTheErrorTextAndAnyOtherErrorIsReportedToo() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.fail["left_click"] = ToolError("element is covered")
        #expect(await toolsetRefusal(browser, CTX, "left_click", ["target": ["type": "ref", "ref": "e1"]]) == "element is covered")
        browser.world.fail["left_click"] = ArgumentTypeError("driver bug")
        #expect(await toolsetRefusal(browser, CTX, "left_click", ["target": ["type": "ref", "ref": "e1"]]) == "TypeError: driver bug")
    }

    @Test func theDeveloperErrorClassPropagatesOutOfCall() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.fail["left_click"] = ToolsetContractError("misuse")
        await #expect(throws: ToolsetContractError.self) { try await call(browser, "left_click", ["target": ["type": "ref", "ref": "e1"]]) }
    }

    @Test func aBrowserStateHookThatThrowsIsADeveloperError() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.stateError = RuntimeError("page crashed")
        do {
            _ = try await call(browser, "get_page_text")
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.hasPrefix("browserState(context:) raised RuntimeError('page crashed')"))
        }
        // a driver that does not implement browserState(context:) is the same developer error
        let unimplemented = try ToolsetStatelessBrowser()
        await #expect(throws: ToolsetContractError.self) { try await unimplemented.toolResultJSON(toolsetUse("navigate", ["url": "u"])) }
    }

    @Test(arguments: [1, 2])
    func aReportMissingAFieldTheSDKReadsIsTheDriversContractErrorNotTheModels(_ index: Int) async throws {
        // test_a_report_missing_a_field_... and its async twin. The first upstream case (a `None` title) cannot be
        // built: the generated tab entry types its title.
        let malformed: [BetaBrowserState] = [
            BetaBrowserState(tabs: []),
            BetaBrowserState(tabs: [], stateChanges: [rawChange("download_started")]),
            BetaBrowserState(tabs: [], stateChanges: [rawChange(["type": "tab_opened"])]),
        ]
        let browser = try ToolsetFakeBrowser()
        browser.world.stateOverride = malformed[index]
        do {
            _ = try await call(browser, "left_click", TOOLSET_CLICK)
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.contains("browser_state"))
        }
        await #expect(throws: ToolsetContractError.self) { try await browser.toolResultJSON(toolsetUse("left_click", TOOLSET_CLICK)) }
        // a failed call holds the state changes back for the next block, so it reads them too
        browser.world.fail["left_click"] = ToolError("element gone")
        await #expect(throws: ToolsetContractError.self) { try await call(browser, "left_click", TOOLSET_CLICK) }
    }

    @Test func aNewTabResultThatIsNotATabEntryStillRendersTheBlock() async throws {
        for returned: BetaBrowserMemberResult in [.nothing, .text("tab_2")] {
            let browser = try ToolsetFakeBrowser()
            browser.world.results["new_tab"] = returned
            browser.world.setTab("tab_2", title: "", url: "about:blank")
            browser.world.changes = [.tabOpened("tab_2")]
            let content = toolsetJSON(try await call(browser, "new_tab"))
            #expect(content.arrayValue?.count == 1 && content[0]?["type"] == "browser_state")
            #expect(content[0]?["state_changes"]?.arrayValue?.map { $0["tab_id"] } == ["tab_2"])
        }
    }

    @Test func toolResultMapsThePipelineOntoAResultBlockAndPassesTheToolUseAlong() async throws {
        let browser = try ToolsetFakeBrowser()
        let use = toolsetUse("get_page_text")
        let result = try await browser.toolResultJSON(use)
        #expect(result["content"]?[0] == ["type": "text", "text": "Hello"])
        #expect(result["is_error"] == nil)
        #expect(browser.world.contexts.last?.toolUse == use && browser.world.stateContexts.last?.toolUse == use)

        let failed = try await browser.toolResultJSON(toolsetUse("teleport"))
        #expect(failed["is_error"] == true)
        #expect(failed["content"] == [["type": "text", "text": "Error: unknown browser toolset member 'teleport'"]])
    }
}

/// A browser that implements no member and no `browserState(context:)`.
final class ToolsetStatelessBrowser: BetaAbstractBrowserToolset20260801, @unchecked Sendable {
    init() throws { try super.init() }
}

@Suite struct ToolsetPipelineStateChangeTests {
    @Test func changesDrainedByAFailedCallRideTheNextBlockThatReachesTheModel() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [
            .tabOpened("tab_9"),  // its tab is not in the inventory by the next call
            toolsetChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"]),
            toolsetChange(["type": "download_started", "download_id": "dl_2", "url": "https://example.com/b"]),
        ]
        browser.world.fail["left_click"] = ToolError("nope")
        _ = await toolsetCallError { try await call(browser, "left_click", ["target": ["type": "ref", "ref": "e1"]]) }
        // The failed call still consulted browserState, so the driver's queue was drained.
        #expect(browser.world.changes.isEmpty)

        browser.world.changes = [
            toolsetChange(["type": "download_completed", "download_id": "dl_2", "url": "https://example.com/b", "size_bytes": 1]),
        ]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [
            ["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"],
            // dl_2's held-back "started" is superseded by this report's "completed"; tab_9 is gone.
            ["type": "download_completed", "download_id": "dl_2", "url": "https://example.com/b", "size_bytes": 1],
        ])
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == nil)
    }

    @Test func ofTheChangesHeldForOneDownloadTheNewestIsTheOneCarriedForward() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [
            toolsetChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7]),
        ]
        browser.world.fail["left_click"] = ToolError("nope")
        for _ in 0..<2 { _ = await toolsetCallError { try await call(browser, "left_click", ["target": ["type": "ref", "ref": "e1"]]) } }
        browser.world.fail = [:]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [
            ["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7],
        ])
    }

    @Test func ofOneReportsChangesForADownloadOnlyTheLatestReachesTheModel() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [
            toolsetChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"]),
            toolsetChange(["type": "download_started", "download_id": "dl_2", "url": "https://example.com/b"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7]),
        ]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [
            ["type": "download_started", "download_id": "dl_2", "url": "https://example.com/b"],
            ["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7],
        ])
    }

    @Test func aTabOpenedForATabTheReportDoesNotListIsDroppedAndARepeatedOneSentOnce() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.setTab("tab_2", title: "popup", url: "https://example.com/popup")
        browser.world.changes = [.tabOpened("tab_9"), .tabOpened("tab_2"), .tabOpened("tab_2")]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_2"]])
        browser.world.changes = [.tabOpened("tab_8")]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == nil)
    }

    @Test func aHeldChangeAndAReplayedOneGiveWayToTheNewestForThatDownload() async throws {
        let browser = try ToolsetFakeBrowser()
        _ = try await call(browser, "list_tabs")
        browser.world.changes = [toolsetChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"])]
        browser.world.fail["get_page_text"] = ToolError("page gone")
        _ = await toolsetCallError { try await call(browser, "get_page_text") }
        browser.world.fail["get_page_text"] = nil
        browser.world.changes = [
            toolsetChange(["type": "download_started", "download_id": "dl_1", "url": "https://example.com/a"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7]),
        ]
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [
            ["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "size_bytes": 7],
        ])
    }

    @Test func aNewTabResultCarriesOnlyItsOwnTabOpenedAndHoldsAPopupsForTheNextBlock() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.setTab("tab_2", title: "popup", url: "https://example.com/popup")
        browser.world.changes = [.tabOpened("tab_2")]
        browser.world.nextTab = 3
        #expect(toolsetStateBlock(try await call(browser, "new_tab"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_3"]])
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_2"]])

        // The same when the popup's tab_opened was held back from a failed call and merged into the new_tab block.
        browser.world.setTab("tab_4", title: "popup 2", url: "https://example.com/p2")
        browser.world.changes = [.tabOpened("tab_4")]
        browser.world.fail["left_click"] = ToolError("nope")
        _ = await toolsetCallError { try await call(browser, "left_click", ["target": ["type": "ref", "ref": "e1"]]) }
        browser.world.fail = [:]
        browser.world.nextTab = 5
        #expect(toolsetStateBlock(try await call(browser, "new_tab"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_5"]])
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_4"]])
    }

    @Test func aNewTabResultGetsATabOpenedWhenTheDriverReportedNone() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.results["new_tab"] = .tab(toolsetTab("tab_2", "", "about:blank", active: true))
        browser.world.setTab("tab_2", title: "", url: "about:blank", active: true)
        #expect(toolsetStateBlock(try await call(browser, "new_tab"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_2"]])
    }

    @Test func aNewTabWhoseTabIsNotTheActiveOneFailsAndItsTabOpenedWaitsForTheNextBlock() async throws {
        // test_a_new_tab_whose_tab_is_not_the_active_one_fails_... and test_an_async_new_tab_whose_tab_...
        let browser = try ToolsetFakeBrowser()
        browser.world.results["new_tab"] = .tab(toolsetTab("tab_2", "", "about:blank", active: false))
        browser.world.setTab("tab_2", title: "", url: "about:blank")
        browser.world.changes = [.tabOpened("tab_2")]
        #expect(await toolsetRefusal(browser, CTX, "new_tab", [:]) == NEW_TAB_NOT_ACTIVE)
        #expect(toolsetStateBlock(try await call(browser, "get_page_text"))["state_changes"] == [["type": "tab_opened", "tab_id": "tab_2"]])
    }

    @Test func navigateAndScreenshotResultsRenderFromTheirModels() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.results["navigate"] = .navigate(BetaBrowserNavigateResult(url: "https://example.com/a", status: 200, title: "A"))
        #expect(toolsetTexts(try await call(browser, "navigate", ["url": "https://example.com"])).first
            == "Navigated to https://example.com/a \u{2014} A (HTTP 200)")
        browser.world.results["screenshot"] = .screenshot(BetaScreenshotResult(data: "QUJD"))
        let image = toolsetJSON(try await call(browser, "screenshot"))[0]
        #expect(image?["type"] == "image" && image?["source"] == ["type": "base64", "media_type": "image/png", "data": "QUJD"])
    }

    @Test(arguments: [("navigate", ["url": "https://example.com"] as BetaToolInput), ("screenshot", [:])])
    func aBareStringFromNavigateOrScreenshotReachesTheModelAsAnErrorNamingItsType(_ tool: String, _ given: BetaToolInput) async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.results[tool] = .text(tool == "navigate" ? "https://example.com/c" : "QUJD")
        let failed = try await browser.toolResultJSON(toolsetUse(tool, given))
        #expect(failed["is_error"] == true)
        #expect(failed["content"] == .string("ValueError('\(tool) returned str, not its result model')"))
    }

    @Test func aDismissedDialogIsALineOfTextWithItsMessageCapped() async throws {
        // and test_a_dismissed_dialog_is_a_line_of_text_on_the_async_class
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [.dialogDismissed(BetaDialogDismissed(kind: "confirm", message: "Delete\neverything?"))]
        let content = try await call(browser, "left_click", TOOLSET_CLICK)
        #expect(toolsetTexts(content) == ["Clicked.", #"A confirm dialog "Delete everything?" was dismissed."#])
        #expect(toolsetStateBlock(content)["state_changes"] == nil)

        browser.world.changes = [
            .dialogDismissed(BetaDialogDismissed(kind: "alert", message: String(repeating: "x", count: 500))),
            .dialogDismissed(BetaDialogDismissed(kind: "prompt")),
        ]
        browser.world.fail["left_click"] = ToolError("element gone")
        let failed = await toolsetCallError { try await call(browser, "left_click", TOOLSET_CLICK) }
        #expect(toolsetTexts(failed?.content ?? "") == [
            "element gone", "An alert dialog \"\(String(repeating: "x", count: 200))\u{2026}\" was dismissed.", "A prompt dialog was dismissed.",
        ])
        browser.world.fail = [:]

        // a blank or control-only kind reads as none; a long one is capped at a word's length
        browser.world.changes = [
            .dialogDismissed(BetaDialogDismissed(kind: "\n")), .dialogDismissed(BetaDialogDismissed(kind: String(repeating: "y", count: 50))),
        ]
        #expect(Array(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)).dropFirst())
            == ["A dialog was dismissed.", "A \(String(repeating: "y", count: 20)) dialog was dismissed."])

        // A tab member cannot carry text, so the dialogs are held; the cap applies when the lines are finally written.
        browser.world.changes = (0..<2).map { .dialogDismissed(BetaDialogDismissed(kind: "confirm", message: String($0))) }
        #expect(toolsetBlockTypes(try await call(browser, "list_tabs")) == ["browser_state"])
        browser.world.changes = (2..<5).map { .dialogDismissed(BetaDialogDismissed(kind: "confirm", message: String($0))) }
        #expect(Array(toolsetTexts(try await call(browser, "get_page_text")).dropFirst()) == [
            #"A confirm dialog "0" was dismissed."#, #"A confirm dialog "1" was dismissed."#, #"A confirm dialog "2" was dismissed."#,
            "2 more dialogs were dismissed.",
        ])

        browser.world.changes = [.dialogDismissed(BetaDialogDismissed(kind: "confirm", message: "Löschen?"))]
        #expect(Array(toolsetTexts(try await call(browser, "get_page_text")).dropFirst()) == [#"A confirm dialog "Löschen?" was dismissed."#])
    }

    @Test func aReportedURLIsFoldedToOneLineAndCutToTheFieldLimitAndNothingElse() async throws {
        let longURL = "https://evil.test/" + String(repeating: "(", count: 5000)
        #expect(boundedTabURL(longURL) == "\u{2026}" + prefixCodePoints(longURL, 4095))
        let fits = "https://x.test/" + String(repeating: "a", count: 4096 - "https://x.test/".count)
        #expect(boundedTabURL(fits) == fits)  // exactly at the limit: untouched
        #expect(boundedTabURL(fits + "b") == "\u{2026}" + prefixCodePoints(fits, 4095))
        #expect(boundedTabURL("https://exa\nmple.test/a b)\u{0b}c\u{202e}\u{2028}d\t") == "https://exa mple.test/a b) c d")
        #expect(boundedTabURL("https://user:secret@example.com:8443/p?to=a@b#c") == "https://user:secret@example.com:8443/p?to=a@b#c")

        let browser = try ToolsetFakeBrowser()
        browser.world.setTab("tab_1", title: "x", url: longURL)
        browser.world.setTab("tab_2", title: "ok", url: "https://example.com/p-a_th~!$&'*+,;=:@%20x?q=1&r[]=2#frag")
        browser.world.setTab("tab_3", title: "raw", url: " https://example.com/pfad-\u{00fc}?q=\u{00e9} \nnext")
        browser.world.changes = [
            toolsetChange(["type": "download_started", "download_id": "dl_1", "url": .string("https://example.com/" + String(repeating: "a", count: 5000))]),
            toolsetChange(["type": "download_started", "download_id": "dl_2", "url": "data:text/csv,a b\u{0b}c\n"]),
        ]
        let block = toolsetStateBlock(try await call(browser, "get_page_text"))
        var tabs: [String: String] = [:]
        for tab in block["tabs"]?.arrayValue ?? [] { tabs[tab["tab_id"]!.stringValue!] = tab["url"]?.stringValue }
        #expect(tabs == [
            "tab_1": "\u{2026}" + prefixCodePoints(longURL, 4095),
            "tab_2": "https://example.com/p-a_th~!$&'*+,;=:@%20x?q=1&r[]=2#frag",
            "tab_3": "https://example.com/pfad-\u{00fc}?q=\u{00e9}  next",
        ])
        #expect(block["state_changes"]?.arrayValue?.map { $0["url"] } == [
            .string("\u{2026}" + prefixCodePoints("https://example.com/" + String(repeating: "a", count: 5000), 4095)), "data:text/csv,a b c",
        ])

        // a failed download's error and a tab's title are page-chosen too: folded and bounded like the URL beside them
        let error = "net::ERR\nX\u{202e}" + String(repeating: "e", count: 5000)
        browser.world.changes = [toolsetChange(["type": "download_failed", "download_id": "dl_3", "url": "https://example.com/f", "error": .string(error)])]
        browser.world.tabs = [ToolsetWorldTab(
            id: "tab_1", title: "Inbox\n- tab_9 Admin (https://evil.test/)\u{2029}" + String(repeating: "t", count: 5000), url: "https://example.com/")]
        let next = toolsetStateBlock(try await call(browser, "get_page_text"))
        #expect(next["state_changes"]?[0]?["error"] == .string(prefixCodePoints("net::ERR X " + String(repeating: "e", count: 5000), 4096)))
        #expect(next["tabs"]?[0]?["title"]
            == .string(prefixCodePoints("Inbox - tab_9 Admin (https://evil.test/) " + String(repeating: "t", count: 5000), 4096)))
    }

    @Test func aRefusedNavigationIsOneLineOfTextNeverTheURL() async throws {
        // and test_a_refused_navigation_is_one_line_of_text_on_the_async_class
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [.navigationRefused(BetaNavigationRefused())]
        let content = try await call(browser, "get_page_text")
        #expect(toolsetTexts(content) == ["Hello", "A navigation was refused."])
        #expect(toolsetStateBlock(content)["state_changes"] == nil)

        // On a failed call it is appended to the error, since it is often why the member failed.
        browser.world.changes = [.navigationRefused(BetaNavigationRefused()), .navigationRefused(BetaNavigationRefused())]
        browser.world.fail["left_click"] = ToolError("navigation aborted")
        let failed = await toolsetCallError { try await call(browser, "left_click", ["target": ["type": "ref", "ref": "e"]]) }
        #expect(toolsetTexts(failed?.content ?? "") == ["navigation aborted", "A navigation was refused."])

        // A tab member cannot carry text, so the line waits for the next result that can.
        browser.world.fail = [:]
        browser.world.changes = [.navigationRefused(BetaNavigationRefused())]
        #expect(toolsetBlockTypes(try await call(browser, "list_tabs")) == ["browser_state"])
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["Hello", "A navigation was refused."])
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["Hello"])
    }

    @Test func driverValuesAreForwardedAsBuilt() async throws {
        // test_driver_values_are_validated_where_the_driver_builds_them_and_forwarded_as_built, and its async twin.
        // The typed tab entry and the typed change kinds hold their declared fields only; a change of a kind the SDK
        // does not know reaches the block as the driver built it, keys and all.
        let browser = try ToolsetFakeBrowser()
        let tab = toolsetTab("tab_1", "T", "https://example.com/", active: true)
        let change: JSONValue = ["type": "download_paused", "download_id": "d1", "url": "https://example.com/f", "filename": "f", "sha256": "abc"]
        browser.world.stateOverride = BetaBrowserState(tabs: [tab], stateChanges: [rawChange(change)])
        let block = toolsetStateBlock(try await call(browser, "get_page_text"))
        #expect(block["tabs"] == [try JSONValue.from(tab)] && block["state_changes"] == [change])
    }
}

@Suite struct ToolsetPipelineTextCaseTests {
    /// `text_cases.json`, the table both SDKs' tests read for the text folds: `{c*N}` stands for N copies of the
    /// character c, and where the SDKs differ on purpose a row gives `{"py", "ts"}`. A lone surrogate, which a Swift
    /// string cannot hold, is read as the U+FFFD it becomes.
    static func cases() throws -> [(String, String, String)] {
        let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        var text = try String(contentsOf: root.appendingPathComponent("upstream/anthropic-sdk-python/tests/lib/tools/toolsets/text_cases.json"), encoding: .utf8)
        text = text.replacingOccurrences(of: #"\\ud[89ab][0-9a-f]{2}(?!\\ud[c-f])"#, with: #"\\ufffd"#, options: .regularExpression)
        text = text.replacingOccurrences(of: #"(?<!\\ud[89ab][0-9a-f]{2})\\ud[c-f][0-9a-f]{2}"#, with: #"\\ufffd"#, options: .regularExpression)
        let rows = try JSONValue.parse(text).arrayValue ?? []
        func expand(_ s: String) -> String {
            var out = ""
            var scalars = Array(s.unicodeScalars)[...]
            while let first = scalars.first {
                if first == "{", scalars.count >= 4, scalars[scalars.startIndex + 2] == "*",
                   let close = scalars.firstIndex(of: "}"), let n = Int(String(String.UnicodeScalarView(scalars[(scalars.startIndex + 3)..<close])))
                {
                    out += String(repeating: String(scalars[scalars.startIndex + 1]), count: n)
                    scalars = scalars[(close + 1)...]
                } else {
                    out.unicodeScalars.append(first)
                    scalars = scalars.dropFirst()
                }
            }
            return out
        }
        return rows.map { row in
            let shown = row["shown"]?.stringValue ?? row["shown"]?["py"]?.stringValue ?? ""
            return (row["fn"]?.stringValue ?? "", expand(row["input"]?.stringValue ?? ""), expand(shown))
        }
    }

    @Test func pageAndModelTextIsFoldedTheSameInBothSDKs() throws {
        let cases = try Self.cases()
        #expect(cases.count >= 18)
        for (fn, raw, shown) in cases {
            let got = fn == "one_line" ? oneLine(raw) : quotedName(raw)
            #expect(got == shown, "\(fn)(\(raw.debugDescription.prefix(60)))")
        }
    }
}

@Suite struct ToolsetPipelineSerializationTests {
    @Test func anExecuteOverrideWrapsDispatchAndThePipelineWrapsTheOverride() async throws {
        // and test_an_execute_override_wraps_dispatch_on_the_async_class
        let seen = ToolsBox<[(String, String)]>([])
        let browser = try ToolsetFakeBrowser()
        browser.executeHook = { browser, context, name, input in
            seen.mutate { $0.append((name.rawValue, input.memberName)) }
            let result = try await browser.baseExecute(context, name, input)
            if name == .getPageText, case .text(let s) = result { return .text(s.uppercased()) }
            return result
        }
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["HELLO"])
        #expect(seen.value.count == 1 && seen.value[0] == ("get_page_text", "get_page_text"))
        // A call refused before dispatch never reaches the override.
        _ = await toolsetCallError { try await call(browser, "teleport") }
        #expect(seen.value.count == 1)
    }

    @Test func callsRunOneAtATime() async throws {
        // test_calls_run_one_at_a_time and test_async_calls_run_one_at_a_time
        let gauge = ToolsBox<(inside: Int, peak: Int)>((0, 0))
        let browser = try ToolsetFakeBrowser()
        browser.memberBodies["get_page_text"] = { _, _, _ in
            gauge.mutate { $0.inside += 1; $0.peak = max($0.peak, $0.inside) }
            try await Task.sleep(nanoseconds: 20_000_000)
            gauge.mutate { $0.inside -= 1 }
            return .text("t")
        }
        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<4 { group.addTask { _ = try await call(browser, "get_page_text") } }
            try await group.waitForAll()
        }
        #expect(gauge.value.peak == 1)
    }

    @Test func callFromInsideAMemberIsAContractErrorAndCancellationReleasesTheLock() async throws {
        // test_call_from_inside_a_member_is_a_contract_error_not_a_deadlock and its async twin
        let browser = try ToolsetFakeBrowser()
        browser.memberBodies["get_page_text"] = { browser, context, _ in
            _ = try await browser.call(context: context, name: "list_tabs", input: [:])
            return .text("unreachable")
        }
        browser.memberBodies["wait"] = { _, _, _ in
            try await Task.sleep(nanoseconds: 10_000_000_000)
            return .nothing
        }
        do {
            _ = try await call(browser, "get_page_text")
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.contains("from inside a member"))
        }

        let waiting = Task { try await call(browser, "wait", ["duration": 10]) }
        try await Task.sleep(nanoseconds: 50_000_000)
        waiting.cancel()
        await #expect(throws: CancellationError.self) { _ = try await waiting.value }
        // The lock was released by the cancelled call, so the next one runs.
        #expect(toolsetBlockTypes(try await call(browser, "list_tabs")) == ["browser_state"])
    }

    @Test func asyncPipelineParity() async throws {
        let browser = try ToolsetFakeBrowser()
        let content = try await call(browser, "navigate", ["url": "https://example.com/"])
        #expect(toolsetTexts(content) == ["Navigated to https://example.com/ \u{2014} Title of https://example.com/ (HTTP 200)"])
        #expect(toolsetStateBlock(content)["tabs"]?[0]?["url"] == "https://example.com/")

        browser.world.tabs[0].url = "https://u:p@example.com/\n" + String(repeating: "a", count: 5000)
        let bounded = toolsetStateBlock(try await call(browser, "get_page_text"))["tabs"]?[0]?["url"]
        #expect(bounded == .string("\u{2026}" + prefixCodePoints("https://u:p@example.com/ " + String(repeating: "a", count: 5000), 4095)))
        #expect(toolsetBlockTypes(try await call(browser, "new_tab")) == ["browser_state"])
        #expect(await toolsetRefusal(browser, CTX, "javascript_exec", ["text": "1"]).contains("not available"))

        browser.world.fail["left_click"] = ValueError("bad")
        let result = try await browser.toolResultJSON(toolsetUse("left_click", ["target": ["type": "ref", "ref": "e"]]))
        #expect(result["is_error"] == true && result["content"] == [["type": "text", "text": "ValueError: bad"]])

        browser.world.stateError = RuntimeError("gone")
        await #expect(throws: ToolsetContractError.self) { try await call(browser, "get_page_text") }
    }

    @Test func aClosedToolsetAnswersNoMemberCall() async throws {
        // test_a_closed_toolset_answers_no_member_call and its async twin
        let browser = try ToolsetFakeBrowser()
        _ = try await call(browser, "get_page_text")
        try await browser.close()
        await #expect(throws: ToolsetClosedError.self) { try await call(browser, "get_page_text") }
        #expect(browser.world.calls == ["get_page_text"])
    }

    @Test func closeWaitsForAcceptedCallsToSettle() async throws {
        // test_close_waits_for_accepted_calls_to_settle and its async twin
        let entered = ToolsetSignal()
        let release = ToolsetSignal()
        let events = ToolsBox<[String]>([])
        let browser = try ToolsetFakeBrowser()
        // Each call notes its end inside the member, before it settles: `close()` returning after both notes is what
        // waiting for the accepted calls means. (Noting it in the calling task instead races `close()`'s own task.)
        browser.memberBodies["get_page_text"] = { _, _, _ in
            entered.fire()
            await release.wait()
            events.mutate { $0.append("call done") }
            return .text("text")
        }
        let first = Task { _ = try await call(browser, "get_page_text") }
        await entered.wait()
        let queued = Task { _ = try await call(browser, "get_page_text") }
        try await Task.sleep(nanoseconds: 200_000_000)
        let closer = Task {
            try await browser.close()
            events.mutate { $0.append("closed") }
        }
        // `close()` marks the toolset closed before it waits; wait for that rather than for a fixed time.
        let start = Date()
        while !browser.isClosed && Date().timeIntervalSince(start) < 20 { try await Task.sleep(nanoseconds: 1_000_000) }
        #expect(!events.value.contains("closed"))  // still waiting: a call is in flight and another is queued
        // arrives after close(): refused, never queued
        await #expect(throws: ToolsetClosedError.self) { try await call(browser, "get_page_text") }
        release.fire()
        try await first.value
        try await queued.value
        try await closer.value
        #expect(events.value == ["call done", "call done", "closed"])
    }

    @Test func closeFromInsideAMemberDoesNotWaitForItself() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.memberBodies["get_page_text"] = { browser, _, _ in
            try await browser.close()
            return .text("closing")
        }
        #expect(toolsetTexts(try await call(browser, "get_page_text")).first?.contains("closing") == true)
        await #expect(throws: ToolsetClosedError.self) { try await call(browser, "get_page_text") }
    }
}

/// A one-shot event a task can wait for (`anyio.Event`).
final class ToolsetSignal: @unchecked Sendable {
    private let lock = NSLock()
    private var fired = false
    private var waiters: [CheckedContinuation<Void, Never>] = []

    func fire() {
        let pending: [CheckedContinuation<Void, Never>] = lock.withLock {
            fired = true
            defer { waiters = [] }
            return waiters
        }
        for waiter in pending { waiter.resume() }
    }

    func wait() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let ready: Bool = lock.withLock {
                if fired { return true }
                waiters.append(continuation)
                return false
            }
            if ready { continuation.resume() }
        }
    }
}
