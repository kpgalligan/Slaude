// Port of `anthropic/lib/tools/_toolsets/_render.py`: turns what a member returned into `tool_result` content, and
// a `BetaBrowserState` into the `browser_state` block.
//
// The registry row records what kind of result a member returns; the renderer reads the fields it needs off that
// result. The tab-management members render no content of their own: the API accepts the `browser_state` block as
// their whole result and produces the text the model reads from it. Blocks are built as JSON, as Python builds dicts.

import Foundation

/// What any member of either family may return (`MemberResult`).
enum ToolsetMemberResult: Sendable {
    case navigate(BetaBrowserNavigateResult)
    case screenshot(BetaScreenshotResult)
    case point(BetaComputerCursorPositionResult)
    case tab(BetaBrowserStateTabEntryParam)
    case tabs([BetaBrowserStateTabEntryParam])
    case text(String)
    case nothing

    init(_ result: BetaBrowserMemberResult) {
        switch result {
        case .navigate(let v): self = .navigate(v)
        case .screenshot(let v): self = .screenshot(v)
        case .tab(let v): self = .tab(v)
        case .tabs(let v): self = .tabs(v)
        case .text(let v): self = .text(v)
        case .nothing: self = .nothing
        }
    }

    init(_ result: BetaComputerMemberResult) {
        switch result {
        case .screenshot(let v): self = .screenshot(v)
        case .cursorPosition(let v): self = .point(v)
        case .text(let v): self = .text(v)
        case .nothing: self = .nothing
        }
    }

    var pythonTypeName: String {
        switch self {
        case .navigate: return "BetaBrowserNavigateResult"
        case .screenshot: return "BetaScreenshotResult"
        case .point: return "BetaComputerCursorPositionResult"
        case .tab: return "dict"
        case .tabs: return "list"
        case .text: return "str"
        case .nothing: return "NoneType"
        }
    }

    /// Python's `str(result)`.
    var pythonString: String {
        switch self {
        case .text(let s): return s
        case .nothing: return "None"
        case .navigate(let v): return String(describing: v)
        case .screenshot(let v): return String(describing: v)
        case .point(let v): return String(describing: v)
        case .tab(let v): return String(describing: v)
        case .tabs(let v): return String(describing: v)
        }
    }
}

/// The single line the model reads for any number of `BetaNavigationRefused` entries in a report.
let NAVIGATION_REFUSED_LINE = "A navigation was refused."

/// The confirmation placeholders and the input field each reads.
let TEMPLATE_FIELDS: [String: String] = [
    "scroll_direction": "scroll_direction",
    "text": "text",
    "duration": "duration",
    "ref": "target.ref",
]

private func inputField(_ input: JSONValue, _ path: String) -> String {
    var value: JSONValue? = input
    for part in path.split(separator: ".") {
        guard let current = value, !current.isNull else { return "" }
        value = current[String(part)]
    }
    guard let value, !value.isNull else { return "" }
    let text: String
    switch value {
    case .string(let s): text = s
    case .int(let i): text = String(i)
    case .double(let d):
        // a whole number as JSON spells it, so the model reads `Waited 2s.`
        text = d.rounded() == d && abs(d) < 1e16 ? String(Int(d)) : pythonFloatString(d)
    case .bool(let b): text = b ? "True" : "False"
    default: text = value.description
    }
    return oneLine(text)
}

/// Fill a pure action's template from its input in a single pass, so a model-supplied value such as `"{ref}"` stays
/// data and is never re-read as a placeholder (`confirmation_text`).
func confirmationText(_ template: String, _ input: JSONValue) -> String {
    var out = ""
    var rest = Substring(template)
    while let open = rest.firstIndex(of: "{") {
        out += rest[..<open]
        let afterOpen = rest.index(after: open)
        if let close = rest[afterOpen...].firstIndex(of: "}"), let field = TEMPLATE_FIELDS[String(rest[afterOpen..<close])] {
            out += inputField(input, field)
            rest = rest[rest.index(after: close)...]
        } else {
            out += "{"
            rest = rest[afterOpen...]
        }
    }
    return out + rest
}

/// One image block around the base64 `data` a screenshot or zoom member returned.
func imageBlock(_ data: String, _ mediaType: BetaBase64ImageSourceParam.MediaType) -> JSONValue {
    ["type": "image", "source": ["type": "base64", "media_type": .string(mediaType.rawValue), "data": .string(data)]]
}

/// The line of text a pure action returned, as written (`action_line`); `nil` when it returned nothing, or anything
/// but a non-empty string, and for every other member.
func actionLine(_ member: ToolsetMember, _ result: ToolsetMemberResult) -> String? {
    guard member.result == .none, member.text != nil, case .text(let line) = result else { return nil }
    return line.isEmpty ? nil : line
}

/// `result` as it is rendered: the line a pure action returned is folded to one line and cut (`bounded_result`).
func boundedResult(_ member: ToolsetMember, _ result: ToolsetMemberResult) -> ToolsetMemberResult {
    guard let line = actionLine(member, result) else { return result }
    return .text(prefixCodePoints(folded(line), TOOLSET_FIELD_MAX))
}

/// The content blocks for a member's result, by the registry's result kind (`render_result`). A pure action renders
/// as its fixed acknowledgment, then, in a text block of its own, the line it returned, if any.
func renderResult(_ member: ToolsetMember, _ input: JSONValue, _ result: ToolsetMemberResult) throws -> [JSONValue] {
    switch member.result {
    case .none:
        guard let template = member.text, !template.isEmpty else { return [] }
        var lines = [confirmationText(template, input)]
        if let line = actionLine(member, result) { lines.append(oneLine(line)) }
        return lines.map(textBlock)
    case .tab, .tabs:
        // new_tab / switch_tab / list_tabs: the browser_state block is the whole result.
        return []
    case .navigate:
        guard case .navigate(let nav) = result else {
            // Not a contract error: a ValueError reaches the model as an error result.
            throw ValueError("navigate returned \(result.pythonTypeName), not its result model")
        }
        // the final address is page-chosen through redirects: folded to one line and held to the bound
        var line = "Navigated to \(boundedTabURL(nav.url))"
        if let title = nav.title { line += " \u{2014} \(oneLine(title))" }
        if let status = nav.status { line += " (HTTP \(status))" }
        return [textBlock(line)]
    case .screenshot:
        guard case .screenshot(let shot) = result else {
            throw ValueError("screenshot returned \(result.pythonTypeName), not its result model")
        }
        return [imageBlock(shot.data, shot.mediaType)]
    case .point:
        guard case .point(let point) = result else {
            throw ValueError("cursor_position returned \(result.pythonTypeName), not its result model")
        }
        return [textBlock("X=\(point.x),Y=\(point.y)")]
    case .text:
        let text = wellFormed(result.pythonString)
        return [textBlock(text.isEmpty ? "(empty)" : text)]
    }
}

// MARK: - Dialogs

let DIALOG_MESSAGE_MAX = 200
let DIALOG_KIND_MAX = 20  // `kind` is driver-supplied and goes into the line unquoted
let DIALOG_LINES_MAX = 3

/// One line per dismissed dialog the driver reported (`A confirm dialog "…" was dismissed.`), the message capped and
/// at most a few lines, then a count of the rest, because a page can open dialogs in a loop (`dialog_lines`).
func dialogLines(_ dialogs: [BetaDialogDismissed]) -> [String] {
    var lines: [String] = []
    for dialog in dialogs.prefix(DIALOG_LINES_MAX) {
        var kind = prefixCodePoints(oneLine(dialog.kind), DIALOG_KIND_MAX)
        if kind.isEmpty { kind = "dialog" }
        let article = "aeiou".contains(kind.prefix(1).lowercased()) ? "An" : "A"
        let noun = kind == "dialog" ? kind : "\(kind) dialog"
        var message = oneLine(dialog.message)
        if message.unicodeScalars.count > DIALOG_MESSAGE_MAX {
            message = prefixCodePoints(message, DIALOG_MESSAGE_MAX) + "\u{2026}"
        }
        let quoted = message.isEmpty ? "" : " \(jsonQuoted(message))"
        lines.append("\(article) \(noun)\(quoted) was dismissed.")
    }
    if dialogs.count > DIALOG_LINES_MAX {
        lines.append("\(dialogs.count - DIALOG_LINES_MAX) more dialogs were dismissed.")
    }
    return lines
}

/// `json.dumps(text, ensure_ascii=False)`.
func jsonQuoted(_ text: String) -> String {
    var out = "\""
    for scalar in text.unicodeScalars {
        switch scalar {
        case "\"": out += "\\\""
        case "\\": out += "\\\\"
        case "\n": out += "\\n"
        case "\r": out += "\\r"
        case "\t": out += "\\t"
        default:
            if scalar.value < 0x20 {
                out += String(format: "\\u%04x", scalar.value)
            } else {
                out.unicodeScalars.append(scalar)
            }
        }
    }
    return out + "\""
}

// MARK: - The browser_state block

/// The wire change kinds that have a page-supplied `url` (and possibly a local `path` or an `error`).
let DOWNLOAD_TYPES = ["download_started", "download_completed", "download_failed"]

/// A report value the SDK could not read: Python's `KeyError` / `TypeError` while it reads the driver's report.
struct ReportReadError: Error {
    let kind: String
    let detail: String
}

/// `object[key]`, as Python's `dict[key]` reads it.
func reportField(_ object: JSONValue, _ key: String) throws -> JSONValue {
    guard case .object(let o) = object else {
        throw ReportReadError(kind: "TypeError", detail: "\(pythonTypeName(object)) indices must be integers or slices, not str")
    }
    guard let value = o[key] else { throw ReportReadError(kind: "KeyError", detail: pythonStringRepr(key)) }
    return value
}

/// `object[key]` where the SDK reads the value as text.
func reportString(_ object: JSONValue, _ key: String) throws -> String {
    let value = try reportField(object, key)
    guard case .string(let s) = value else {
        throw ReportReadError(kind: "TypeError", detail: "expected str for \(pythonStringRepr(key)), got \(pythonTypeName(value))")
    }
    return s
}

func isDownloadChange(_ change: JSONValue) -> Bool {
    guard case .object(let o) = change, let type = o["type"]?.stringValue else { return false }
    return DOWNLOAD_TYPES.contains(type)
}

/// The file policy's verdict on one download path, hidden without a policy (`path_visible`). Only `true` shows it.
/// A `ToolsetUsageError` propagates; any other error from the predicate fails closed: the path stays hidden.
func pathVisible(_ filePolicy: (any BetaFilePolicy)?, _ path: String) throws -> Bool {
    guard let filePolicy else { return false }
    do {
        return try filePolicy.isPathVisible(path)
    } catch {
        _ = try hookRefusal(error, fallback: ToolError("path hidden"))
        return false
    }
}

private func boundedTab(_ tab: JSONValue) throws -> JSONValue {
    guard case .object(var o) = tab else { _ = try reportField(tab, "url"); return tab }
    o["url"] = .string(boundedTabURL(try reportString(tab, "url")))
    o["title"] = .string(oneLine(try reportString(tab, "title")))
    return .object(o)
}

/// The `browser_state` block (`render_browser_state`): the driver's tabs as reported with each URL and title folded
/// to one line and held to the API's length limit, and `changes` with a download's `url` and a failed download's
/// `error` bounded the same way, and its `path` removed from every download change, kept only on a
/// `download_completed` whose path the file policy exposes.
func renderBrowserState(_ tabs: [JSONValue], _ changes: [JSONValue], _ filePolicy: (any BetaFilePolicy)?) throws -> JSONValue {
    var wireChanges: [JSONValue] = []
    for change in changes {
        guard isDownloadChange(change), case .object(var o) = change else {
            wireChanges.append(change)
            continue
        }
        o["url"] = .string(boundedTabURL(try reportString(change, "url")))
        // taken off whichever kind has it, declared or not: a local path never goes out unchecked
        let path = o.removeValue(forKey: "path")
        let type = o["type"]?.stringValue
        if type == "download_completed", case .string(let p)? = path, try pathVisible(filePolicy, p) {
            // a page-chosen name that folding or cutting would change could name another file
            if oneLine(p) == p { o["path"] = .string(p) }
        }
        if type == "download_failed", case .string(let error)? = o["error"] {
            o["error"] = .string(oneLine(error))
        }
        wireChanges.append(.object(o))
    }
    var block: [String: JSONValue] = ["type": "browser_state", "tabs": .array(try tabs.map(boundedTab))]
    if !wireChanges.isEmpty { block["state_changes"] = .array(wireChanges) }  // "nothing to report" is an absent field
    return .object(block)
}
