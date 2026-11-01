// Port of `tests/lib/tools/toolsets/test_confirm.py` (the confirm approval gate) and
// `tests/lib/tools/toolsets/test_enforcement.py` (URL policy and file policy enforcement in the call pipeline).

import Foundation
import Testing
@testable import Anthropic

private let CONFIRM_CTX = BetaToolsetCallContext(toolUse: toolsetUse("left_click", id: "toolu_7"))
private let DECLINED = "The user did not grant permission to run 'left_click'. Do not retry it unless the user asks you to."
private let FAILED = "Permission to run 'left_click' could not be obtained (the confirmation prompt failed). "
    + "Do not retry it unless the user asks you to."

private func call(_ browser: BetaRunnableToolset, _ name: String, _ input: BetaToolInput = [:],
                  _ context: BetaToolsetCallContext = CONFIRM_CTX) async throws -> BetaToolsetContent
{
    try await browser.call(context: context, name: name, input: input)
}

/// A file policy that lets every upload path through.
final class ToolsetAnyPathPolicy: BetaLocalFilePolicy, @unchecked Sendable {
    init() throws { try super.init() }
    override func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] { paths }
}

@Suite struct ToolsetConfirmTests {
    @Test func confirmSeesEveryCallAndADeclineNeverReachesTheDriver() async throws {
        let asked = ToolsBox<[String]>([])
        let confirm: BetaConfirmCallable = { context in
            asked.mutate { $0.append(context.member.rawValue) }
            return context.member != .leftClick || asked.value.count > 2
        }
        let browser = try ToolsetFakeBrowser(confirm: confirm)
        #expect(toolsetTexts(try await call(browser, "get_page_text")) == ["Hello"])
        #expect(await toolsetRefusal(browser, CONFIRM_CTX, "left_click", TOOLSET_CLICK) == DECLINED)
        #expect(browser.world.calls == ["get_page_text"])
        #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked."])
        #expect(browser.world.calls == ["get_page_text", "left_click"] && asked.value == ["get_page_text", "left_click", "left_click"])

        // a call refused before dispatch (unknown member, disabled member) is never asked about
        _ = await toolsetCallError { try await call(browser, "teleport") }
        #expect(asked.value.count == 3)
        let gated = try ToolsetFakeBrowser(configs: ["left_click": ["enabled": false]], confirm: confirm)
        _ = await toolsetCallError { try await call(gated, "left_click", TOOLSET_CLICK) }
        #expect(asked.value.count == 3 && gated.world.calls.isEmpty)
    }

    @Test func enablingFileUploadOrJavascriptExecRequiresConfirm() async throws {
        let upload: BetaToolInput = ["target": ["type": "ref", "ref": "e1"], "paths": ["/f"]]
        #expect(throws: ToolsetConfigError.self) {
            try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], filePolicy: ToolsetAnyPathPolicy())
        }
        let asked = ToolsBox<[String]>([])
        let browser = try ToolsetFakeBrowser(
            configs: ["file_upload": ["enabled": true]],
            confirm: { context in
                asked.mutate { $0.append(context.member.rawValue) }
                return context.member != .fileUpload
            }, filePolicy: ToolsetAnyPathPolicy())
        #expect(await toolsetRefusal(browser, CONFIRM_CTX, "file_upload", upload)
            == DECLINED.replacingOccurrences(of: "left_click", with: "file_upload"))
        #expect(asked.value == ["file_upload"] && browser.world.calls.isEmpty)
        // approving everything is the opt-out
        _ = try await call(try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove,
                                                  filePolicy: ToolsetAnyPathPolicy()), "file_upload", upload)
    }

    @Test func confirmContextDescribesTheTargetTabAsOfTheLastBlockAndCostsNothingUnread() async throws {
        let seen = ToolsBox<[BetaConfirmContext]>([])
        let record: BetaConfirmCallable = { context in
            seen.mutate { $0.append(context) }
            return true
        }
        let browser = try ToolsetFakeBrowser(confirm: record)
        let use = BetaToolsetCallContext(toolUse: toolsetUse("left_click", TOOLSET_CLICK, id: "toolu_c"))
        _ = try await call(browser, "left_click", TOOLSET_CLICK, use)
        // the context carries the tool_use block and the parsed input the driver received
        #expect(seen.value.last?.member == .leftClick && seen.value.last?.toolUse == use.toolUse)
        #expect(seen.value.last?.input == browser.world.inputs.last)
        guard case .betaBrowserLeftClickInput? = seen.value.last?.input else { Issue.record("not a left_click input"); return }
        // the prompt costs no state read: one per call, as without confirm
        #expect(browser.world.stateContexts.count == 1)

        let tabs = try ToolsetFakeBrowser(confirm: record)
        func lastTab() -> (String?, String?) { (seen.value.last?.tabURL, seen.value.last?.tabID) }
        _ = try await call(tabs, "left_click", TOOLSET_CLICK)  // before any report there is no tab to describe
        #expect(lastTab() == (nil, nil))
        _ = try await call(tabs, "navigate", ["url": "https://shop.example.com/cart?x=1"])
        _ = try await call(tabs, "left_click", TOOLSET_CLICK)
        #expect(lastTab() == ("https://shop.example.com/cart?x=1", "tab_1"))
        // reading the tab costs nothing either: it is described from the last report, with no page read
        #expect(tabs.world.stateContexts.count == 3)

        // A call that names a tab is described by that tab, not the active one.
        tabs.world.setTab("tab_2", title: "docs", url: "https://docs.example.com/")
        _ = try await call(tabs, "list_tabs")
        _ = try await call(tabs, "left_click", toolsetMerge(TOOLSET_CLICK, ["tab_id": "tab_2"]))
        #expect(lastTab() == ("https://docs.example.com/", "tab_2"))

        // tabURL is the URL as the driver reported it and the model read it, folded and held to 4,096 characters
        _ = try await call(tabs, "navigate", ["url": "HTTPS://trusted.example@Example.COM:443/cart"])
        _ = try await call(tabs, "left_click", TOOLSET_CLICK)
        #expect(lastTab().0 == "HTTPS://trusted.example@Example.COM:443/cart")

        tabs.world.setTab("tab_1", title: "t", url: "https://example.com/a\u{202e})b \u{2028}" + String(repeating: "c", count: 5000))
        _ = try await call(tabs, "list_tabs")
        _ = try await call(tabs, "left_click", TOOLSET_CLICK)
        let tabURL = lastTab().0 ?? ""
        #expect(tabURL.hasPrefix("\u{2026}https://example.com/a )b  c") && tabURL.unicodeScalars.count == 4096 && !tabURL.contains("\u{202e}"))

        // A page can pad its URL so that its first 4,096 characters alone parse to another host. The leading `…`
        // leaves no host to parse.
        tabs.world.setTab("tab_1", title: "t", url: "https://trusted.bank.com:" + String(repeating: "0", count: 4100) + "@evil.example/")
        _ = try await call(tabs, "list_tabs")
        _ = try await call(tabs, "left_click", TOOLSET_CLICK)
        let cut = lastTab().0 ?? ""
        #expect(cut.hasPrefix("\u{2026}") && URLComponents(string: cut)?.host == nil)
    }

    @Test func anApprovalCoversTheLastReportAndThePageIsNotReadAgain() async throws {
        let world = ToolsetWorld()
        let looked = ToolsBox<[String?]>([])
        let browser = try ToolsetFakeBrowser(world, confirm: { context in
            looked.mutate { $0.append(context.tabURL) }
            return true
        })
        _ = try await call(browser, "navigate", ["url": "https://shop.example.com/cart"])
        world.tabs[0].url = "https://elsewhere.example.net/next"
        #expect(toolsetTexts(try await call(browser, "left_click", TOOLSET_CLICK)) == ["Clicked."])
        #expect(looked.value.last == "https://shop.example.com/cart" && world.calls == ["navigate", "left_click"])
        #expect(world.stateContexts.count == 2)  // one report per call, none for the prompt
        // The block that click produced showed the new page, so the next prompt describes it.
        _ = try await call(browser, "left_click", TOOLSET_CLICK)
        #expect(looked.value.last == "https://elsewhere.example.net/next")
    }

    @Test func aConfirmThatThrowsRefusesTheCallAndAToolErrorIsRelayed() async throws {
        // and test_an_async_confirm_that_raises_refuses_the_call_and_a_tool_error_is_relayed
        #expect(await toolsetRefusal(try ToolsetFakeBrowser(confirm: { _ in throw RuntimeError("tty closed") }), CONFIRM_CTX,
                                     "left_click", TOOLSET_CLICK) == FAILED)
        #expect(await toolsetRefusal(try ToolsetFakeBrowser(confirm: { _ in throw ToolError("clicks are disabled after 5pm") }),
                                     CONFIRM_CTX, "left_click", TOOLSET_CLICK) == "clicks are disabled after 5pm")
    }

    @Test func aDeclinedCallNeverReachesTheDriver() async throws {
        // test_a_confirm_answer_other_than_true_declines_the_call: in Swift the answer is a `Bool`, so `false` is it
        let browser = try ToolsetFakeBrowser(confirm: { _ in false })
        #expect(await toolsetRefusal(browser, CONFIRM_CTX, "left_click", TOOLSET_CLICK) == DECLINED && browser.world.calls.isEmpty)
        let allow = try ToolsetFakeBrowser(confirm: toolsetApprove)
        #expect(toolsetTexts(try await call(allow, "left_click", TOOLSET_CLICK)) == ["Clicked."])
    }

    @Test func theGateRunsBeforeAnExecuteOverride() async throws {
        let reached = ToolsBox<[String]>([])
        let browser = try ToolsetFakeBrowser(confirm: { _ in false })
        browser.executeHook = { browser, context, name, input in
            reached.mutate { $0.append(name.rawValue) }
            return try await browser.baseExecute(context, name, input)
        }
        _ = await toolsetCallError { try await call(browser, "left_click", TOOLSET_CLICK) }
        #expect(reached.value.isEmpty)
    }

    @Test func theURLPolicyRunsBeforeConfirm() async throws {
        let asked = ToolsBox<[String]>([])
        let browser = try ToolsetFakeBrowser(
            confirm: { context in
                asked.mutate { $0.append(context.member.rawValue) }
                return true
            },
            urlPolicy: { _, url in if url.contains("internal") { throw ToolError("blocked: internal") } })
        #expect(await toolsetRefusal(browser, CONFIRM_CTX, "navigate", ["url": "https://wiki.internal/"]).contains("blocked"))
        #expect(asked.value.isEmpty)
    }
}

// MARK: - test_enforcement.py

private let ENFORCE_CTX = BetaToolsetCallContext(toolUse: toolsetUse("navigate", id: "toolu_9"))

private func enforce(_ browser: BetaRunnableToolset, _ name: String, _ input: BetaToolInput = [:]) async throws -> BetaToolsetContent {
    try await browser.call(context: ENFORCE_CTX, name: name, input: input)
}

private func navigatedURLs(_ world: ToolsetWorld) -> [String] {
    world.inputs.compactMap { if case .betaBrowserNavigateInput(let i) = $0 { return i.url } else { return nil } }
}

@Suite struct ToolsetEnforcementTests {
    @Test func thePolicyIsCalledOncePerNavigateWithTheURLAsWrittenBeforeTheDriverRuns() async throws {
        let world = ToolsetWorld()
        let seen = ToolsBox<[(BetaURLContext, String, Int)]>([])
        let browser = try ToolsetFakeBrowser(world, urlPolicy: { context, url in
            seen.mutate { $0.append((context, url, world.calls.count)) }
            if url.contains("logout") { throw ToolError("blocked: logout") }
        })
        let written = ["https://example.com/", "example.com/path", " Http://Exa\tmple.COM./x ", "javascript:alert(1)", "backwards"]
        for url in written { _ = try await enforce(browser, "navigate", ["url": .string(url), "tab_id": "tab_1"]) }
        // once per call, with the string exactly as the model wrote it, and before the driver heard of it
        #expect(seen.value.map(\.1) == written)
        #expect(seen.value.map(\.2) == [0, 1, 2, 3, 4])
        #expect(navigatedURLs(world) == written)
        #expect(seen.value.allSatisfy { $0.0 == BetaURLContext(member: .navigate, tabID: "tab_1", toolUseID: "toolu_9") })

        // the history words are navigate's own vocabulary: the policy is not asked, and the driver receives the
        // canonical lower-case word
        for url in ["back", " Forward ", "RELOAD"] { _ = try await enforce(browser, "navigate", ["url": .string(url)]) }
        #expect(seen.value.count == 5 && Array(navigatedURLs(world).suffix(3)) == ["back", "forward", "reload"])

        // a ToolError it throws is the refusal the model reads, and the driver is not called
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "navigate", ["url": "https://example.com/logout"]) == "blocked: logout")
        #expect(seen.value.count == 6 && world.calls.filter { $0 == "navigate" }.count == 8)

        // no other member consults it, and nothing a result or a report carries does
        world.setTab("tab_2", title: "title of https://example.com/logout", url: "https://example.com/logout")
        world.results["navigate"] = .navigate(BetaBrowserNavigateResult(url: "https://example.com/logout", title: "bye"))
        let others: [(String, BetaToolInput)] = [
            ("get_page_text", [:]), ("left_click", TOOLSET_CLICK), ("list_tabs", [:]), ("new_tab", [:]), ("switch_tab", ["tab_id": "tab_2"]),
        ]
        for (name, given) in others { _ = try await enforce(browser, name, given) }
        #expect(toolsetTexts(try await enforce(browser, "navigate", ["url": "https://example.com/in"])).first
            == "Navigated to https://example.com/logout \u{2014} bye")
        #expect(seen.value.count == 7)

        // a call without a tab_id says so
        _ = try await enforce(browser, "navigate", ["url": "https://example.com/"])
        #expect(seen.value.last?.0.tabID == nil)
    }

    @Test func aPolicyThatThrowsSomethingElseRefusesWithTheSDKsTextAndLogs() async throws {
        // and its async twin
        let browser = try ToolsetFakeBrowser(urlPolicy: { _, url in throw ArgumentTypeError("could not parse \(url)") })
        let (text, capture) = await ToolDiagnostics.capture {
            await toolsetRefusal(browser, ENFORCE_CTX, "navigate", ["url": "https://example.com/oops"])
        }
        // its own message (which names the URL) goes to the log, not the model
        #expect(text == "refused by the URL policy")
        #expect(capture.records.contains { $0.error?.contains("could not parse https://example.com/oops") == true })
        #expect(browser.world.calls.isEmpty)

        // a ToolsetUsageError out of the policy is the developer's and stops the run
        let misuse = try ToolsetFakeBrowser(urlPolicy: { _, _ in throw ToolsetContractError("wired wrong") })
        await #expect(throws: ToolsetContractError.self) { try await enforce(misuse, "navigate", ["url": "https://example.com/"]) }
    }

    @Test func unsetChecksNothing() async throws {
        let browser = try ToolsetFakeBrowser()
        let urls = ["javascript:alert(1)", "file:///etc/passwd", "http://10.0.0.5/", "chrome://settings", "not a url", ""]
        for url in urls { _ = try await enforce(browser, "navigate", ["url": .string(url)]) }
        #expect(navigatedURLs(browser.world) == urls)
        // a URL that is not a string is the model's input error and never reaches the driver
        _ = await toolsetRefusal(browser, ENFORCE_CTX, "navigate", ["url": ["x"]])
        #expect(browser.world.calls.count == 6)
        // and a reported address reaches the model as the driver reported it
        for reported in ["file:///etc/passwd", "blob:null/1", "view-source:http://10.0.0.5/", "about:blank", ""] {
            browser.world.setTab("tab_1", title: "title of \(reported)", url: reported, active: true)
            let content = try await enforce(browser, "get_page_text")
            #expect(toolsetTexts(content) == ["Hello"] && toolsetStateBlock(content)["tabs"]?[0]?["url"] == .string(reported))
        }
        // the async test_the_async_class_takes_a_plain_or_a_coroutine_policy... checks the same with a policy
        let plain = try ToolsetFakeBrowser(urlPolicy: { _, url in if url.contains("internal") { throw ToolError("blocked: internal") } })
        #expect(await toolsetRefusal(plain, ENFORCE_CTX, "navigate", ["url": "https://wiki.internal/", "tab_id": "tab_1"]) == "blocked: internal")
        _ = try await enforce(plain, "navigate", ["url": " Example.COM/x "])
        #expect(navigatedURLs(plain.world) == [" Example.COM/x "])
    }

    @Test func aCallNamingATabTheLastReportDidNotListGoesToTheDriver() async throws {
        let asked = ToolsBox<[BetaConfirmContext]>([])
        let browser = try ToolsetFakeBrowser(confirm: { context in
            asked.mutate { $0.append(context) }
            return true
        })
        browser.world.setTab("tab_1", title: "t", url: "https://example.com/", active: true)
        _ = try await enforce(browser, "list_tabs")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "navigate", ["url": "x", "tab_id": "tab_nope"]) == "No open tab with tab_id 'tab_nope'.")
        #expect(browser.world.calls.last == "navigate")
        #expect(asked.value.last?.tabID == "tab_nope" && asked.value.last?.tabURL == nil)
    }

    @Test func aDownloadChangeWithoutAURLIsTheDriversBug() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.changes = [.change(.unknown(["type": "download_started", "download_id": "dl_1"]))]
        do {
            _ = try await enforce(browser, "get_page_text")
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.hasPrefix("browserState(context:) raised"))
        }
    }

    @Test func aLongReportedTabURLIsCutToTheFieldLimitAndItsControlsFolded() async throws {
        let browser = try ToolsetFakeBrowser()
        let longURL = "https://" + String(repeating: "u", count: 4090) + "@example.com/admin\n\u{0b}next\u{202e}"
        browser.world.setTab("tab_1", title: "t", url: "https://example.com/", active: true)
        browser.world.setTab("tab_2", title: "t", url: longURL)
        func urls(_ content: BetaToolsetContent) -> [String: String] {
            var out: [String: String] = [:]
            for tab in toolsetStateBlock(content)["tabs"]?.arrayValue ?? [] { out[tab["tab_id"]!.stringValue!] = tab["url"]?.stringValue }
            return out
        }
        let tab2 = urls(try await enforce(browser, "list_tabs"))["tab_2"] ?? ""
        #expect(tab2 == "\u{2026}" + prefixCodePoints(longURL, 4095) && tab2.unicodeScalars.count == 4096)
        browser.world.setTab("tab_2", title: "t", url: "https://exa\nmple.com/a b\u{0b})\u{202e}\u{2028}c")
        #expect(urls(try await enforce(browser, "get_page_text"))["tab_2"] == "https://exa mple.com/a b ) c")
    }

    @Test func uploadsAreRefusedWithoutAFilePolicyAndResolvedWithOne() async throws {
        let tmp = try ToolsetTempDir()
        let root = try tmp.mkdir("uploads")
        _ = try tmp.write("x", "uploads", "form.pdf")
        let bare = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove)
        #expect(await toolsetRefusal(bare, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(root + "/form.pdf")]]))
            == "file_upload has no configured upload roots")
        // A staged document is contained the same way: no policy, no upload; a policy lists the ids it allows.
        #expect(await toolsetRefusal(bare, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["document_ids": ["doc_1"]]))
            == "file_upload has no configured document allowlist")

        let policy = try BetaLocalFilePolicy(uploadRoots: [root], uploadDocumentIDs: ["doc_1"])
        let browser = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove, filePolicy: policy)
        func lastUpload() -> BetaBrowserFileUploadInput? {
            if case .betaBrowserFileUploadInput(let i)? = browser.world.inputs.last { return i }
            return nil
        }
        #expect(toolsetTexts(try await enforce(browser, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(root + "/form.pdf")]])))
            == ["Uploaded."])
        #expect(lastUpload()?.paths == [try posixRealpath(root + "/form.pdf")])
        #expect(toolsetTexts(try await enforce(browser, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["document_ids": ["doc_1"]]))) == ["Uploaded."])
        #expect(lastUpload()?.documentIDs == ["doc_1"])
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["document_ids": ["doc_1", "doc_2"]]))
            == "document not in the upload allowlist")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(tmp.path("secret"))]]))
            == "file_upload path is outside the configured upload roots")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(root + "/../secret")]]))
            == "file_upload path must not contain a '..' component")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": "form.pdf"]))
            .hasPrefix("invalid input"))
        // Only the two accepted uploads reached the driver.
        #expect(browser.world.calls.filter { $0 == "file_upload" }.count == 2)

        // an upload with no paths and no document ids names nothing to vet, so it is the driver's to answer
        #expect(toolsetTexts(try await enforce(browser, "file_upload", TOOLSET_UPLOAD)) == ["Uploaded."])
        #expect(toolsetTexts(try await enforce(bare, "file_upload", TOOLSET_UPLOAD)) == ["Uploaded."])

        // the async class enforces the roots too
        let uploads = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove,
                                             filePolicy: try BetaLocalFilePolicy(uploadRoots: [tmp.root]))
        #expect(await toolsetRefusal(uploads, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": ["/etc/passwd"]]))
            == "file_upload path is outside the configured upload roots")
        #expect(uploads.world.calls.isEmpty)
    }

    @Test func downloadPathsReachTheModelOnlyThroughAnExposingFilePolicy() async throws {
        // and its async twin
        func paths(_ browser: ToolsetFakeBrowser) async throws -> [String?] {
            browser.world.changes = [
                toolsetChange(["type": "download_completed", "download_id": "dl_1", "url": "https://example.com/a", "path": "/dl/x/a.bin"]),
                toolsetChange(["type": "download_completed", "download_id": "dl_2", "url": "https://example.com/b", "path": "/elsewhere/b.bin"]),
            ]
            return (toolsetStateBlock(try await enforce(browser, "get_page_text"))["state_changes"]?.arrayValue ?? []).map { $0["path"]?.stringValue }
        }
        #expect(try await paths(try ToolsetFakeBrowser()) == [nil, nil])
        #expect(try await paths(try ToolsetFakeBrowser(filePolicy: try BetaLocalFilePolicy(downloadDir: "/dl"))) == [nil, nil])
        #expect(try await paths(try ToolsetFakeBrowser(filePolicy: try BetaLocalFilePolicy(downloadDir: "/dl", exposeDownloadPaths: true)))
            == ["/dl/x/a.bin", nil])
        // A custom predicate that fails hides the path and the report still reaches the model.
        #expect(try await paths(try ToolsetFakeBrowser(filePolicy: try ToolsetFlakyPolicy(downloadDir: "/dl", exposeDownloadPaths: true)))
            == [nil, nil])

        // An exposed path reaches the block exactly as the driver reported it. A path with a line break stays hidden,
        // and so does one too long for the policy to resolve.
        let exposing = try ToolsetFakeBrowser(filePolicy: try BetaLocalFilePolicy(downloadDir: "/dl", exposeDownloadPaths: true))
        exposing.world.changes = [
            toolsetChange(["type": "download_completed", "download_id": "dl_3", "url": "https://example.com/c", "path": "/dl/x/c\n.bin"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_4", "url": "https://example.com/d",
                           "path": .string("/dl/x/" + String(repeating: "d", count: 5000))]),
            toolsetChange(["type": "download_completed", "download_id": "dl_5", "url": "https://example.com/e", "path": "/dl/x/e.bin"]),
            toolsetChange(["type": "download_completed", "download_id": "dl_6", "url": "https://example.com/f", "path": "/dl/my file (1).pdf"]),
        ]
        let changes = toolsetStateBlock(try await enforce(exposing, "get_page_text"))["state_changes"]?.arrayValue ?? []
        #expect(changes.map { $0["download_id"]?.stringValue ?? "" } == ["dl_3", "dl_4", "dl_5", "dl_6"])
        #expect(changes.map { $0["path"]?.stringValue } == [nil, nil, "/dl/x/e.bin", "/dl/my file (1).pdf"])
    }

    @Test func aFilePolicyThatFailsRefusesTheUploadAndTheCallIsStillObserved() async throws {
        // and test_a_file_policy_that_fails_refuses_the_upload_on_the_async_class
        let tmp = try ToolsetTempDir()
        let browser = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove,
                                             filePolicy: try ToolsetBrokenUploadPolicy(uploadRoots: [tmp.root]))
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(tmp.path("a.pdf"))]]))
            == "the file policy could not vet the upload")
        #expect(browser.world.calls.isEmpty && browser.world.stateContexts.count == 1)

        // a ToolsetUsageError out of the policy is the developer's and stops the run
        let misused = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove,
                                             filePolicy: try ToolsetBrokenUploadPolicy(uploadRoots: [tmp.root], misuse: true))
        await #expect(throws: ToolsetContractError.self) {
            try await enforce(misused, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(tmp.path("a.pdf"))]]))
        }
        #expect(misused.world.calls.isEmpty)
    }

    struct AuthFailed: Error, CustomStringConvertible {
        let token: String
        var description: String { "authentication failed" }
    }
    struct TimeoutError: Error, CustomStringConvertible { var description: String { "" } }

    @Test func aDriversErrorTextReachesTheModelAsWrittenAndCutToTheFieldLimit() async throws {
        let browser = try ToolsetFakeBrowser()
        browser.world.setTab("tab_1", title: "t", url: "https://example.com/", active: true)
        browser.world.fail["left_click"] = ToolError("saved to /var/task/dl/f8a1.bin")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "left_click", TOOLSET_CLICK) == "saved to /var/task/dl/f8a1.bin")
        browser.world.fail["left_click"] = ToolError(String(repeating: "x", count: 5000))
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "left_click", TOOLSET_CLICK) == String(repeating: "x", count: 4096))

        // a dialog's message and a failed download's error reach the model as written too, folded to one line
        browser.world.fail = [:]
        browser.world.changes = [
            toolsetChange(["type": "download_failed", "download_id": "dl_1", "url": "https://example.com/f", "error": "at /var/dl/x"]),
            .dialogDismissed(BetaDialogDismissed(kind: "alert", message: "see /var/task/secret")),
        ]
        let content = try await enforce(browser, "left_click", TOOLSET_CLICK)
        #expect(toolsetTexts(content)[1] == #"An alert dialog "see /var/task/secret" was dismissed."#)
        #expect(toolsetStateBlock(content)["state_changes"]?[0]?["error"] == "at /var/dl/x")
    }

    @Test func aRaisedErrorReadsAsItsTypeAndMessageOnly() async throws {
        let browser = try ToolsetFakeBrowser()
        // a constructor argument the message leaves out, such as a token, does not reach the model
        browser.world.fail["left_click"] = AuthFailed(token: "token-123")
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "left_click", TOOLSET_CLICK) == "AuthFailed: authentication failed")
        // with no message the model gets the type
        browser.world.fail["left_click"] = TimeoutError()
        #expect(await toolsetRefusal(browser, ENFORCE_CTX, "left_click", TOOLSET_CLICK) == "TimeoutError")
    }
}

final class ToolsetFlakyPolicy: BetaLocalFilePolicy, @unchecked Sendable {
    override func isPathVisible(_ path: String) throws -> Bool { throw RuntimeError("disk on fire") }
}

final class ToolsetBrokenUploadPolicy: BetaLocalFilePolicy, @unchecked Sendable {
    let misuse: Bool
    init(uploadRoots: [String], misuse: Bool = false) throws {
        self.misuse = misuse
        try super.init(uploadRoots: uploadRoots)
    }
    override func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] {
        if misuse { throw ToolsetContractError("wired wrong") }
        throw RuntimeError("disk on fire")
    }
}
