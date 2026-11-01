// Port of `anthropic/lib/tools/_toolsets/_pipeline.py`: the stages of a browser member call. The stages every
// family runs (resolving, parsing, the confirm verdict) are in `Base.swift`.
//
// The driver's report is read as JSON, as Python reads the driver's dicts, so a report the SDK cannot read (a field
// missing from a raw `.unknown` change) is the driver's contract error rather than a crash.

import Foundation

/// The refusal for a `urlPolicy` that threw something other than a `ToolError`: its own message may contain the URL
/// it refused, so the model reads this instead and the error goes to the log.
let POLICY_REFUSED = "refused by the URL policy"
let NO_DOCUMENT_POLICY = "file_upload has no configured document allowlist"
let UPLOAD_REFUSED = "the file policy could not vet the upload"
let NEW_TAB_NOT_ACTIVE =
    "new_tab opened a tab, but the browser does not report it as the only active tab. Call list_tabs to see the tabs."
let HISTORY_NAVIGATION: Set<String> = ["back", "forward", "reload"]

/// One member call in flight: what each stage produced, for the stages after it (`CallRecord`).
struct BrowserCallRecord {
    let context: BetaToolsetCallContext
    let name: String
    var member: ToolsetMember?
    var input: BetaBrowserMemberInput?
    var result: ToolsetMemberResult = .nothing
    var error: ToolError?

    init(context: BetaToolsetCallContext, name: String) {
        self.context = context
        self.name = name
    }

    /// The input as JSON, as the templates and the tab lookup read it.
    var inputJSON: JSONValue { input.flatMap { try? JSONValue.from($0) } ?? .object([:]) }

    /// The tab the call names, or `nil` when it names none (an absent or empty `tab_id` both mean the active tab).
    /// Only a member whose input declares `tab_id` names a tab.
    var tabID: String? {
        guard let member, member.declaresTabID, let id = inputJSON["tab_id"]?.stringValue, !id.isEmpty else { return nil }
        return id
    }

    var toolUseID: String? { context.toolUse?.id }

    /// The `tab_id` of the tab a `new_tab` call opened, from the tab entry it returned, or `nil` for any other call or
    /// result.
    var openedTabID: String? {
        guard member?.name == "new_tab", case .tab(let tab) = result else { return nil }
        return tab.tabID
    }

    var urlContext: BetaURLContext {
        BetaURLContext(member: member.map { BetaBrowserMemberName(rawValue: $0.name) }, tabID: tabID, toolUseID: toolUseID)
    }

    /// The `url` of a `navigate` call exactly as the model wrote it, for the URL policy (`navigate_url`). `nil` for
    /// the history words `back` / `forward` / `reload` (the driver receives the canonical lower-case word) and for
    /// other members.
    mutating func navigateURL() -> String? {
        guard case .betaBrowserNavigateInput(var navigate)? = input else { return nil }
        let word = pythonStrip(navigate.url).lowercased()
        if HISTORY_NAVIGATION.contains(word) {
            if word != navigate.url {
                navigate.url = word
                input = .betaBrowserNavigateInput(navigate)
            }
            return nil
        }
        return navigate.url
    }

    /// For `file_upload`: run `input.paths` and `input.documentIDs` through the file policy before dispatch, so the
    /// driver receives what the policy returned and a refused path or document never reaches it. Without a file
    /// policy, an upload that names either is refused (`resolve_upload_paths`).
    mutating func resolveUploadPaths(_ filePolicy: (any BetaFilePolicy)?) throws {
        guard case .betaBrowserFileUploadInput(var upload)? = input else { return }
        let paths = upload.paths ?? []
        let documents = upload.documentIDs ?? []
        guard let filePolicy else {
            if !paths.isEmpty { throw UploadNoRootsError() }
            if !documents.isEmpty { throw UploadRefusedError(NO_DOCUMENT_POLICY) }
            return
        }
        let context = urlContext
        if !paths.isEmpty {
            upload.paths = try vettedUploadEntries { try filePolicy.resolveUploadPaths(context: context, paths: paths) }
        }
        if !documents.isEmpty {
            upload.documentIDs = try vettedUploadEntries {
                try filePolicy.resolveUploadDocuments(context: context, documentIDs: documents)
            }
        }
        input = .betaBrowserFileUploadInput(upload)
    }

    /// What the `confirm` callable receives: the member and its parsed input, and the tab the call targets (named,
    /// else active) with its URL, as of the last report and with no page read (`confirm_context`).
    func confirmContext(_ pipeline: BrowserPipelineState) -> BetaConfirmContext {
        let tab = targetTab(pipeline.lastTabs, tabID)
        return BetaConfirmContext(
            toolUse: context.toolUse, member: BetaBrowserMemberName(rawValue: member?.name ?? name), input: input ?? .unknown(.null),
            tabURL: tab?["url"]?.stringValue, tabID: tab == nil ? tabID : tab?["tab_id"]?.stringValue)
    }
}

/// One `file_upload` field run through the file policy: the entries the driver receives (`vetted_upload_entries`).
private func vettedUploadEntries(_ hook: () throws -> [String]) throws -> [String] {
    do {
        return try hook()
    } catch {
        // hookRefusal logs it, and the upload never reaches the driver
        throw try hookRefusal(error, fallback: UploadRefusedError(UPLOAD_REFUSED))
    }
}

/// Which tab a call targets: the tab it names by `tab_id`, else the active tab. `nil` when the named tab is not in
/// the report (or nothing is active) (`target_tab`).
func targetTab(_ tabs: [JSONValue], _ tabID: String?) -> JSONValue? {
    for tab in tabs {
        if let tabID {
            if tab["tab_id"]?.stringValue == tabID { return tab }
        } else if tab["active"] == .bool(true) {
            return tab
        }
    }
    return nil
}

/// The driver's report as the pipeline reads it, built once (`Report`): the tabs and the wire changes with each
/// page-supplied URL bounded (`with_bounded_tab_urls`), and the SDK's own change kinds set apart, since they reach the
/// model as text.
struct BrowserReport {
    var tabs: [JSONValue]
    var changes: [JSONValue]
    var navigationRefused = false
    var dialogs: [BetaDialogDismissed] = []

    init(_ state: BetaBrowserState) throws {
        tabs = []
        for tab in state.tabs {
            var bounded = tab
            bounded.url = boundedTabURL(tab.url)
            tabs.append(try JSONValue.from(bounded))
        }
        changes = []
        for change in state.stateChanges {
            switch change {
            case .navigationRefused: navigationRefused = true
            case .dialogDismissed(let dialog): dialogs.append(dialog)
            case .change(let param):
                var json = try JSONValue.from(param)
                if isDownloadChange(json), case .object(var o) = json {
                    o["url"] = .string(boundedTabURL(try reportString(json, "url")))
                    json = .object(o)
                }
                changes.append(json)
            }
        }
    }
}

/// Per-toolset bookkeeping that outlives a single call (`PipelineState`).
struct BrowserPipelineState {
    /// State changes not sent yet: those drained by a failed call, and a popup's `tab_opened` held back from a
    /// successful `new_tab`. They go out with the next `browser_state` block.
    var pendingChanges: [JSONValue] = []
    /// A refused-navigation line that could not be attached yet (the result was state-only).
    var refusalPending = false
    /// Dismissed dialogs whose lines could not be attached yet, for the same reason.
    var dialogsPending: [BetaDialogDismissed] = []
    /// The tab inventory of the most recent report: what `BetaConfirmContext` is filled from.
    var lastTabs: [JSONValue] = []

    /// Render the call's outcome with the browser state the driver just reported (`finish`). Returns
    /// `(content, isError)`; a report the SDK cannot read throws `ToolsetContractError` instead.
    mutating func finish(_ call: inout BrowserCallRecord, _ report: BrowserReport, _ filePolicy: (any BetaFilePolicy)?) throws
        -> ([JSONValue], Bool)
    {
        do {
            return try render(&call, report, filePolicy)
        } catch let error as ReportReadError {
            throw ToolsetContractError(
                "browser_state returned a report the SDK cannot read (\(error.kind): \(error.detail)); "
                    + "report each tab and state change with its documented fields")
        }
    }

    private mutating func render(_ call: inout BrowserCallRecord, _ report: BrowserReport, _ filePolicy: (any BetaFilePolicy)?)
        throws -> ([JSONValue], Bool)
    {
        lastTabs = report.tabs
        let refused = report.navigationRefused || refusalPending
        let dialogs = dialogsPending + report.dialogs
        var changes = try mergePendingChanges(pendingChanges, report)

        // Held first: should rendering stop the run, the drained changes are still on hand.
        pendingChanges = changes
        let opened = call.error == nil ? call.openedTabID : nil
        if let opened {
            let active = try report.tabs.filter { $0["active"] == .bool(true) }.map { try reportField($0, "tab_id") }
            if active != [.string(opened)] {
                // The API rejects a new_tab result unless the opened tab is the only active one.
                call.error = ToolError(NEW_TAB_NOT_ACTIVE)
            }
        }

        if call.error == nil, let member = call.member {
            let content = try renderResult(member, call.inputJSON, call.result)
            let held: [JSONValue]
            (changes, held) = try newTabChanges(call.error == nil ? call.openedTabID : nil, changes)
            let block = try renderBrowserState(report.tabs, changes, filePolicy)
            pendingChanges = held
            if BROWSER_STATE_ONLY_MEMBERS.contains(member.name) {
                // A block-only result has no text, so the lines wait for the next result that can include them.
                refusalPending = refused
                dialogsPending = dialogs
                return ([block], false)
            }
            return (content + takeNotices(refused, dialogs) + [block], false)
        }
        let error = call.error ?? ToolError("")
        return (errorContent(boundedError(error)) + takeNotices(refused, dialogs), true)
    }

    /// The refused-navigation line and the dialog lines as text blocks, now that a result can include them.
    private mutating func takeNotices(_ refused: Bool, _ dialogs: [BetaDialogDismissed]) -> [JSONValue] {
        refusalPending = false
        dialogsPending = []
        let lines = (refused ? [NAVIGATION_REFUSED_LINE] : []) + dialogLines(dialogs)
        return lines.map(textBlock)
    }
}

/// State changes held back from earlier calls, followed by this report's own, coalesced into what one block may
/// contain (`merge_pending_changes`): of the changes for one `download_id` only the latest, where it stands; of the
/// `tab_opened` entries for one tab only the first, and only while that tab is in the report's `tabs`.
func mergePendingChanges(_ pending: [JSONValue], _ report: BrowserReport) throws -> [JSONValue] {
    let changes = pending + report.changes
    var liveTabs = Set<JSONValue>()
    for tab in report.tabs { liveTabs.insert(try reportField(tab, "tab_id")) }

    var latest: [JSONValue: Int] = [:]
    for (index, change) in changes.enumerated() where isDownloadChange(change) {
        latest[change["download_id"] ?? .null] = index
    }

    var kept: [JSONValue] = []
    var opened = Set<JSONValue>()
    for (index, change) in changes.enumerated() {
        let type = try reportField(change, "type")
        if type == "tab_opened" {
            let tabID = try reportField(change, "tab_id")
            if !liveTabs.contains(tabID) || opened.contains(tabID) { continue }
            opened.insert(tabID)
        } else if isDownloadChange(change) && latest[change["download_id"] ?? .null] != index {
            continue
        }
        kept.append(change)
    }
    return kept
}

/// The changes for this block and the changes to hold, as `(keep, held)` (`new_tab_changes`). On a `new_tab` result
/// the block carries exactly one `tab_opened`, for the tab it opened, added when the driver reported none; a
/// `tab_opened` for any other tab waits for the next block. For any other call the changes pass through.
func newTabChanges(_ opened: String?, _ changes: [JSONValue]) throws -> ([JSONValue], [JSONValue]) {
    guard let opened else { return (changes, []) }
    var keep: [JSONValue] = []
    var held: [JSONValue] = []
    for change in changes {
        if try reportField(change, "type") == "tab_opened", try reportField(change, "tab_id") != .string(opened) {
            held.append(change)
        } else {
            keep.append(change)
        }
    }
    if !keep.contains(where: { $0["type"] == "tab_opened" }) {
        keep.append(["type": "tab_opened", "tab_id": .string(opened)])
    }
    return (keep, held)
}
