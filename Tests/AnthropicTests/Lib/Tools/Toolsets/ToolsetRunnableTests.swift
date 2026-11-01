// Port of `tests/lib/tools/toolsets/test_runnable.py` and `test_refusals.py`.

import Foundation
import Testing
@testable import Anthropic

private func navigateTool() -> BetaFunctionTool {
    BetaFunctionTool(name: "navigate", description: "A custom tool that shares a browser member's name.",
                     inputSchema: ["type": "object", "properties": ["url": ["type": "string"]]]) { input in
        .string("custom:\(input["url"]?.stringValue ?? "")")
    }
}

@Suite struct ToolsetRunnableTests {
    struct TypeError: Error, CustomStringConvertible { let description: String }

    @Test func toolsAreIndexedByNameAndToolsetsByFamily() {
        let toolset = ToolsetEchoBrowser()
        let navigate = navigateTool()
        let (byName, byFamily) = indexRunnables([toolset, navigate])
        #expect(byName.keys == ["navigate"] && byName["navigate"] === navigate)
        #expect(byFamily.keys == ["browser"] && byFamily["browser"] === toolset)
        let (onlyTools, noToolsets) = indexRunnables([navigate])
        #expect(onlyTools.keys == ["navigate"] && noToolsets.isEmpty)
    }

    @Test func toolResultEchoesToolsetNameAndPassesTheToolUseAsContext() async throws {
        let toolset = ToolsetEchoBrowser()
        let use = toolsetUse("navigate", ["url": "https://example.com"], id: "toolu_navigate")
        let result = try await toolset.toolResultJSON(use)
        #expect(result == [
            "type": "tool_result", "tool_use_id": "toolu_navigate", "toolset_name": "browser",
            "content": #"navigate:{"url": "https://example.com"}"#,
        ])
        #expect(toolset.calls.map(\.0) == ["navigate"] && toolset.calls[0].1 == ["url": "https://example.com"])
        // The member learns which model call it is answering through the context, not instance state.
        #expect(toolset.contexts[0].toolUse == use)
        // the typed block decodes from the same JSON
        #expect(try await toolset.toolResult(use).toolsetName == "browser")
    }

    @Test func anUnexpectedErrorIsLoggedWithFoldedNamesAndAnsweredWithBoundedText() async throws {
        // test_an_unexpected_exception_is_logged_... and its async twin
        let toolset = ToolsetEchoBrowser()
        toolset.failure = { _ in RuntimeError(String(repeating: "x", count: 10_000)) }
        let use = toolsetUse("scr\neenshot\u{1b}[2J", id: "toolu_f")
        let (result, capture) = try await ToolDiagnostics.capture { try await toolset.toolResultJSON(use) }
        #expect(result["is_error"] == true)
        let text = result["content"]?.stringValue ?? result["content"]?[0]?["text"]?.stringValue ?? ""
        #expect(text.unicodeScalars.count == TOOLSET_FIELD_MAX && text.hasPrefix("RuntimeError('xxx"))
        let records = capture.records.filter { $0.message.contains("toolset member") }
        #expect(records.count == 1)
        #expect(!records[0].message.contains("\n") && !records[0].message.contains("\u{1b}"))
    }

    @Test func toolResultMapsToolErrorToIsErrorTextContent() async throws {
        // The API rejects anything but text on an is_error result, so the image the member attached is dropped.
        let result = try await ToolsetEchoBrowser().toolResultJSON(toolsetUse("boom", id: "toolu_boom"))
        #expect(result == [
            "type": "tool_result", "tool_use_id": "toolu_boom", "toolset_name": "browser",
            "content": [["type": "text", "text": "member refused"]], "is_error": true,
        ])
    }

    @Test func anEmptyTextBlockIsDroppedFromErrorContentSoThePlaceholderApplies() async throws {
        let result = try await ToolsetEchoBrowser().toolResultJSON(toolsetUse("blank"))
        #expect(result["is_error"] == true)
        #expect(result["content"] == "The tool call failed with an empty error message.")
    }

    @Test(arguments: [
        (0, "TypeError('boom')"), (1, "RuntimeError('two\\nlines')"), (2, "ValueError()"),
    ])
    func aRaisedErrorReadsTheSameOnTheFunctionToolAndToolsetPaths(_ index: Int, _ text: String) {
        let errors: [Error] = [ArgumentTypeError("boom"), RuntimeError("two\nlines"), ValueError("")]
        #expect(toolErrorContent(errors[index]) == .string(text))
        #expect(errorText(errors[index]) == text)
    }

    @Test func theToolsetPathCutsToTheFieldLimit() {
        #expect(errorText(RuntimeError(String(repeating: "x", count: 10_000)))
            == prefixCodePoints("RuntimeError('" + String(repeating: "x", count: 10_000), TOOLSET_FIELD_MAX))
    }

    @Test func toolResultReportsAnyOtherErrorToTheModel() async throws {
        let result = try await ToolsetEchoBrowser().toolResultJSON(toolsetUse("crash"))
        #expect(result["is_error"] == true)
        #expect(result["content"] == "RuntimeError('backend exploded')")
    }

    @Test func toolResultPropagatesTheDeveloperErrorClassOnly() async throws {
        let toolset = ToolsetEchoBrowser()
        await #expect(throws: ToolsetContractError.self) { try await toolset.toolResultJSON(toolsetUse("misuse")) }

        let typeErrors = ToolsetEchoBrowser()
        typeErrors.failure = { _ in ArgumentTypeError("driver bug") }
        let result = try await typeErrors.toolResultJSON(toolsetUse("navigate"))
        #expect(result["is_error"] == true && result["content"] == "TypeError('driver bug')")
    }

    @Test(arguments: [nil, "computer"] as [String?])
    func toolResultRejectsABlockOfAnotherFamily(_ family: String?) async throws {
        let toolset = ToolsetEchoBrowser()
        do {
            _ = try await toolset.toolResultJSON(toolsetUse("navigate", family: family))
            Issue.record("expected a contract error")
        } catch let error as ToolsetContractError {
            #expect(error.message.contains("is not a member call of the 'browser' toolset"))
        }
        #expect(toolset.calls.isEmpty)
    }

    @Test func useClosesTheToolset() async throws {
        let toolset = ToolsetEchoBrowser()
        let entered = try await toolset.use { toolset.isClosed }
        #expect(entered == false)
        #expect(toolset.closed == 1)
    }

    @Test func asyncToolResultParity() async throws {
        let toolset = ToolsetEchoBrowser()
        let use = toolsetUse("navigate", ["url": "u"], id: "toolu_navigate")
        #expect(try await toolset.toolResultJSON(use) == [
            "type": "tool_result", "tool_use_id": "toolu_navigate", "toolset_name": "browser", "content": #"navigate:{"url": "u"}"#,
        ])
        #expect(toolset.contexts[0].toolUse == use)

        let failed = try await toolset.toolResultJSON(toolsetUse("boom"))
        #expect(failed["is_error"] == true && failed["toolset_name"] == "browser")
        #expect(failed["content"] == [["type": "text", "text": "member refused"]])
        #expect(try await toolset.toolResultJSON(toolsetUse("crash"))["content"] == "RuntimeError('backend exploded')")
        await #expect(throws: ToolsetContractError.self) { try await toolset.toolResultJSON(toolsetUse("misuse")) }
        await #expect(throws: ToolsetContractError.self) { try await toolset.toolResultJSON(toolsetUse("navigate", family: nil)) }

        try await toolset.use {}
        #expect(toolset.closed == 1)
    }
}

// MARK: - test_refusals.py

/// The refusal behind the `ToolError` a call throws: its cause, whose own text is what the model reads.
private func refusalCause(_ toolset: BetaRunnableToolset, _ name: String, _ input: BetaToolInput) async -> ToolError? {
    guard let error = await toolsetCallError({ try await toolset.call(context: BetaToolsetCallContext(), name: name, input: input) })
    else { return nil }
    guard let cause = error.cause as? ToolError else {
        Issue.record("the cause of \(error) is not a ToolError")
        return nil
    }
    #expect(toolsetTexts(error.content).first == cause.message)
    return cause
}

@Suite struct ToolsetRefusalTests {
    @Test func memberResolutionAndInputRefusals() async throws {
        let browser = try ToolsetFakeBrowser(configs: ["scroll": ["enabled": false]])

        let unknown = await refusalCause(browser, "teleport", [:])
        #expect(unknown is UnknownMemberError)
        #expect(unknown?.message == "Error: unknown browser toolset member 'teleport'")

        let disabled = await refusalCause(browser, "scroll", toolsetMerge(["scroll_direction": "down"], TOOLSET_CLICK))
        #expect(disabled is DisabledMemberError)
        #expect(disabled?.message
            == "The 'scroll' action is not permitted by this application's permissions and cannot be used in this session.")

        let unavailable = await refusalCause(browser, "hover", TOOLSET_CLICK)  // the fake does not implement hover
        #expect(unavailable is UnavailableMemberError)
        #expect(unavailable?.message == "The browser toolset member 'hover' is not available in this environment.")

        let invalid = await refusalCause(browser, "left_click", [:])
        #expect(invalid is InvalidMemberInputError)
        #expect(invalid?.message.hasPrefix("invalid input for browser member 'left_click': target: ") == true)
        #expect(InvalidMemberInputError("wait", "duration: too long", family: "browser").message
            == "invalid input for browser member 'wait': duration: too long")
        #expect(browser.world.calls.isEmpty)
    }

    @Test func urlRefusals() async throws {
        let browser = try ToolsetFakeBrowser(urlPolicy: { _, url in
            if url.contains("logout") { throw ToolError("blocked: logout") }
        })
        let own = await refusalCause(browser, "navigate", ["url": "https://example.com/logout"])
        #expect(own.map { Swift.type(of: $0) == ToolError.self } == true && own?.message == "blocked: logout")

        // a policy that threw something other than a ToolError refused too, with the SDK's text
        let fallback = await refusalCause(try ToolsetFakeBrowser(urlPolicy: { _, url in throw RuntimeError(url) }), "navigate",
                                          ["url": "https://example.com/"])
        #expect(fallback is URLRefusedError && fallback?.message == "refused by the URL policy")

        // the reason is one bounded line
        #expect(URLRefusedError("blocked: " + String(repeating: "x", count: 500)).message
            == String(("blocked: " + String(repeating: "x", count: 500)).prefix(200)))
        #expect(browser.world.calls.isEmpty)
    }

    @Test func confirmRefusals() async throws {
        let declined = await refusalCause(try ToolsetFakeBrowser(confirm: { _ in false }), "left_click", TOOLSET_CLICK)
        #expect(declined is ConfirmDeclinedError)
        #expect(declined?.message
            == "The user did not grant permission to run 'left_click'. Do not retry it unless the user asks you to.")

        let failed = await refusalCause(try ToolsetFakeBrowser(confirm: { _ in throw RuntimeError("tty closed") }), "left_click",
                                        TOOLSET_CLICK)
        #expect(failed is ConfirmFailedError)
        #expect(failed?.message == "Permission to run 'left_click' could not be obtained (the confirmation prompt failed). "
            + "Do not retry it unless the user asks you to.")
    }

    @Test func aHookRefusalIsCutToTheFieldLimitAndStaysTheCause() async throws {
        let url = "https://example.com/" + String(repeating: "a", count: 5000)
        let cases: [(ToolsetFakeBrowser, String, BetaToolInput, String)] = [
            (try ToolsetFakeBrowser(urlPolicy: { _, url in throw ToolError("blocked: \(url)") }), "navigate", ["url": .string(url)],
             "blocked: \(url)"),
            (try ToolsetFakeBrowser(confirm: { _ in throw ToolError("declined: " + String(repeating: "c", count: 5000)) }),
             "left_click", TOOLSET_CLICK, "declined: " + String(repeating: "c", count: 5000)),
        ]
        for (browser, name, input, text) in cases {
            let error = await toolsetCallError { try await browser.call(context: BetaToolsetCallContext(), name: name, input: input) }
            #expect(toolsetTexts(error?.content ?? "").first == prefixCodePoints(text, 4096))
            #expect((error?.cause as? ToolError)?.message == text)  // the refusal as raised, uncut
        }
    }

    @Test func uploadRefusals() async throws {
        let tmp = try ToolsetTempDir()
        let root = tmp.path("uploads")
        try FileManager.default.createDirectory(atPath: root, withIntermediateDirectories: true)
        try "x".write(toFile: root + "/form.pdf", atomically: true, encoding: .utf8)
        let bare = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove)

        let noRoots = await refusalCause(bare, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(root + "/form.pdf")]]))
        #expect(noRoots is UploadRefusedError && noRoots?.message == "file_upload has no configured upload roots")
        let noDocuments = await refusalCause(bare, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["document_ids": ["doc_1"]]))
        #expect(noDocuments is UploadRefusedError)

        let policy = try BetaLocalFilePolicy(uploadRoots: [root], uploadDocumentIDs: ["doc_1"])
        let browser = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove, filePolicy: policy)
        let outside = await refusalCause(browser, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": [.string(tmp.path("secret"))]]))
        #expect(outside is UploadRefusedError && outside?.message == "file_upload path is outside the configured upload roots")
        let unlisted = await refusalCause(browser, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["document_ids": ["doc_2"]]))
        #expect(unlisted is UploadRefusedError && unlisted?.message == "document not in the upload allowlist")

        let crashing = try ToolsetFakeBrowser(configs: ["file_upload": ["enabled": true]], confirm: toolsetApprove,
                                              filePolicy: ToolsetCrashingFilePolicy())
        let crashed = await refusalCause(crashing, "file_upload", toolsetMerge(TOOLSET_UPLOAD, ["paths": ["/f"]]))
        #expect(crashed is UploadRefusedError && crashed?.message == "the file policy could not vet the upload")

        #expect(throws: UploadRefusedError.self) { try betaCheckUploadPath(tmp.path("secret"), [root]) }
        #expect(bare.world.calls.isEmpty && browser.world.calls.isEmpty)
    }

    @Test func theRefusalsAreToolErrorsAndTheUsageErrorsOneHierarchy() {
        // test_surface.py: test_the_error_family_is_one_hierarchy, test_the_refusals_are_exported_tool_errors
        let usage: [AnthropicError] = [ToolsetClosedError("x"), ToolsetConfigError("x"), ToolsetContractError("x")]
        #expect(usage.allSatisfy { $0 is ToolsetUsageError })
        let refusals: [ToolError] = [
            UnknownMemberError("x", family: "browser"), DisabledMemberError("x"), UnavailableMemberError("x", family: "browser"),
            InvalidMemberInputError("x", "y", family: "browser"), URLRefusedError("x"), TabMissingError(), ConfirmDeclinedError("x"),
            ConfirmFailedError("x"), UploadRefusedError("x"),
        ]
        #expect(refusals.allSatisfy { Swift.type(of: $0) != ToolError.self })
    }
}

/// A file policy whose upload check crashes.
final class ToolsetCrashingFilePolicy: BetaLocalFilePolicy, @unchecked Sendable {
    init() throws { try super.init() }
    override func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String] {
        throw RuntimeError(paths.joined(separator: ","))
    }
}

/// A temporary directory removed on deinit (`tmp_path`), with its symlinks resolved.
final class ToolsetTempDir: @unchecked Sendable {
    let root: String

    init() throws {
        let base = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("toolset-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        root = try posixRealpath(base.path)
    }

    func path(_ components: String...) -> String { ([root] + components).joined(separator: "/") }

    func mkdir(_ components: String...) throws -> String {
        let p = ([root] + components).joined(separator: "/")
        try FileManager.default.createDirectory(atPath: p, withIntermediateDirectories: true)
        return p
    }

    func write(_ text: String, _ components: String...) throws -> String {
        let p = ([root] + components).joined(separator: "/")
        try FileManager.default.createDirectory(atPath: (p as NSString).deletingLastPathComponent, withIntermediateDirectories: true)
        try text.write(toFile: p, atomically: false, encoding: .utf8)
        return p
    }

    func symlink(_ link: String, to target: String) throws {
        try FileManager.default.createSymbolicLink(atPath: link, withDestinationPath: target)
    }

    deinit { try? FileManager.default.removeItem(atPath: root) }
}
