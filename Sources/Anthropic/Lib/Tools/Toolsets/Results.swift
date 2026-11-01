// Port of `anthropic/lib/tools/_toolsets/_results.py`, `_computer_results.py` and `_hooks.py`: what a member
// returns, the browser's state report, and the types of the constructor hooks.
//
// Tabs and state changes are the generated wire types (`BetaBrowserStateTabEntryParam`,
// `BetaBrowserStateChangeParam`) returned as they are. Only the shapes with no wire twin are declared here.

import Foundation

// MARK: - Browser results

/// Where a navigation ended up. Rendered as `Navigated to {url} — {title} (HTTP {status})`, each value made safe for
/// one line of text (control, line-separator and bidi characters replaced, length bounded).
public struct BetaBrowserNavigateResult: Sendable, Hashable, Codable {
    /// The final URL after redirects.
    public var url: String
    public var status: Int?
    public var title: String?

    public init(url: String, status: Int? = nil, title: String? = nil) {
        self.url = url
        self.status = status
        self.title = title
    }
}

/// A navigation the driver refused, for example a page-started navigation its request interception stopped.
///
/// Its `type` is the SDK's own and is never sent: the SDK reports it to the model as one fixed line of text rather
/// than in the `browser_state` block.
public struct BetaNavigationRefused: Sendable, Hashable, Codable {
    public var type: String = "navigation_refused"
    public init() {}
}

/// A native dialog (`alert`, `confirm`, `prompt`) the page opened and the driver dismissed.
///
/// Its `type` is the SDK's own and is never sent: the SDK reports it to the model as a line of text with the next
/// block (`A confirm dialog "Delete everything?" was dismissed.`). `message` is page-supplied text, capped when
/// rendered.
public struct BetaDialogDismissed: Sendable, Hashable, Codable {
    public var type: String = "dialog_dismissed"
    /// `"alert"`, `"confirm"`, `"prompt"` (or whatever the browser called it).
    public var kind: String
    public var message: String

    public init(kind: String, message: String = "") {
        self.kind = kind
        self.message = message
    }

    enum CodingKeys: String, CodingKey { case type, kind, message }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        kind = try c.decode(String.self, forKey: .kind)
        message = try c.decodeIfPresent(String.self, forKey: .message) ?? ""
    }
}

/// One `state_changes` entry, told apart by `type` (`StateChange`): a generated `BetaBrowserStateChangeParam`, or one
/// of the SDK's own kinds (`BetaNavigationRefused`, `BetaDialogDismissed`) that reach the model as text.
///
/// Decoding one from JSON requires its `type` and refuses a `type` none of them has.
public enum BetaBrowserStateChange: Sendable, Hashable, Codable {
    case change(BetaBrowserStateChangeParam)
    case navigationRefused(BetaNavigationRefused)
    case dialogDismissed(BetaDialogDismissed)

    static let tags = [
        "tab_opened", "download_started", "download_completed", "download_failed", "navigation_refused",
        "dialog_dismissed",
    ]

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyCodingKey.self)
        guard let type = try c.decodeIfPresent(String.self, forKey: AnyCodingKey("type")) else {
            throw DecodingError.keyNotFound(
                AnyCodingKey("type"),
                .init(codingPath: decoder.codingPath, debugDescription: "Unable to extract tag using discriminator 'type'"))
        }
        switch type {
        case "navigation_refused": self = .navigationRefused(BetaNavigationRefused())
        case "dialog_dismissed": self = .dialogDismissed(try BetaDialogDismissed(from: decoder))
        case _ where Self.tags.contains(type): self = .change(try BetaBrowserStateChangeParam(from: decoder))
        default:
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath + [AnyCodingKey("type")],
                debugDescription: "Input tag \(pythonStringRepr(type)) found using 'type' does not match any of the "
                    + "expected tags: \(Self.tags.map(pythonStringRepr).joined(separator: ", "))"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .change(let v): try v.encode(to: encoder)
        case .navigationRefused(let v): try v.encode(to: encoder)
        case .dialogDismissed(let v): try v.encode(to: encoder)
        }
    }

    /// A `tab_opened` change.
    public static func tabOpened(_ tabID: String) -> BetaBrowserStateChange {
        .change(.tabOpened(BetaBrowserStateChangeTabOpenedParam(tabID: tabID)))
    }
}

/// The browser after a call: what `browserState(context:)` returns (`BetaBrowserState`). Forwarded to the API with
/// download paths the file policy does not expose removed and each reported URL, title and error folded to one
/// bounded line.
///
/// `tabs` is the full inventory, with the active tab marked by its own `active` flag; `stateChanges` is what changed
/// since the last report. The API's rules apply unchanged: `tab_id` values are unique, exactly one tab is `active`
/// when any tab is open, and there are at most 100 tabs. Of the state changes, the SDK keeps the latest per
/// `download_id` and one `tab_opened` per tab still open, so the list need not be deduplicated.
public struct BetaBrowserState: Sendable, Hashable, Codable {
    public var tabs: [BetaBrowserStateTabEntryParam]
    public var stateChanges: [BetaBrowserStateChange]

    public init(tabs: [BetaBrowserStateTabEntryParam], stateChanges: [BetaBrowserStateChange] = []) {
        self.tabs = tabs
        self.stateChanges = stateChanges
    }

    enum CodingKeys: String, CodingKey {
        case tabs
        case stateChanges = "state_changes"
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        tabs = try c.decode([BetaBrowserStateTabEntryParam].self, forKey: .tabs)
        stateChanges = try c.decodeIfPresent([BetaBrowserStateChange].self, forKey: .stateChanges) ?? []
    }
}

/// Anything a browser member may return: `execute`'s result (`BetaBrowserMemberResult`).
public enum BetaBrowserMemberResult: Sendable, Hashable {
    case navigate(BetaBrowserNavigateResult)
    case screenshot(BetaScreenshotResult)
    case tab(BetaBrowserStateTabEntryParam)
    case tabs([BetaBrowserStateTabEntryParam])
    case text(String)
    /// A pure action that returned no line of text.
    case nothing

    /// The Python type name of the value, for the error that names an off-type result.
    var pythonTypeName: String {
        switch self {
        case .navigate: return "BetaBrowserNavigateResult"
        case .screenshot: return "BetaScreenshotResult"
        case .tab: return "dict"
        case .tabs: return "list"
        case .text: return "str"
        case .nothing: return "NoneType"
        }
    }
}

// MARK: - Computer results

/// Where the cursor is, in screenshot pixels; rendered as `X={x},Y={y}`.
public struct BetaComputerCursorPositionResult: Sendable, Hashable, Codable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

/// Anything a computer member may return: `execute`'s result (`BetaComputerMemberResult`).
public enum BetaComputerMemberResult: Sendable, Hashable {
    case screenshot(BetaScreenshotResult)
    case cursorPosition(BetaComputerCursorPositionResult)
    case text(String)
    /// A pure action that returned no line of text.
    case nothing

    var pythonTypeName: String {
        switch self {
        case .screenshot: return "BetaScreenshotResult"
        case .cursorPosition: return "BetaComputerCursorPositionResult"
        case .text: return "str"
        case .nothing: return "NoneType"
        }
    }
}

// MARK: - Hooks

/// What a hook receives about the call it serves: the first argument of `urlPolicy(context, url)` and of the file
/// policy's `resolveUploadPaths(context:paths:)` / `resolveUploadDocuments(context:documentIDs:)`.
public struct BetaURLContext: Sendable, Hashable {
    /// The member being called: `navigate` for the URL policy, `file_upload` for the file policy.
    public var member: BetaBrowserMemberName?
    /// The tab the call named, if any.
    public var tabID: String?
    /// The model call being served, or `nil` when a hook is invoked outside one.
    public var toolUseID: String?

    public init(member: BetaBrowserMemberName? = nil, tabID: String? = nil, toolUseID: String? = nil) {
        self.member = member
        self.tabID = tabID
        self.toolUseID = toolUseID
    }
}

/// The URL policy (`BetaAsyncURLPolicy`): `(context, url)`, called once for each `navigate` that has a URL, with
/// `url` exactly as the model wrote it, before the driver receives it (`back`, `forward` and `reload` are not
/// checked). Return to allow, throw `ToolError` to refuse.
public typealias BetaURLPolicy = @Sendable (BetaURLContext, String) async throws -> Void

/// Controls which upload paths and document ids a `file_upload` may use and which download paths the model may see
/// (`BetaFilePolicy`).
///
/// With no file policy configured, an upload input that has a path or a document id is refused and download paths
/// are never shown to the model.
public protocol BetaFilePolicy: Sendable {
    /// Resolve each path the model asked to upload, or throw `ToolError` to refuse. The driver receives the returned
    /// paths in `input.paths`.
    func resolveUploadPaths(context: BetaURLContext, paths: [String]) throws -> [String]
    /// Vet each document id (a file staged with the Files API) the model asked to upload, or throw `ToolError` to
    /// refuse. The driver receives the returned ids in `input.documentIDs`.
    func resolveUploadDocuments(context: BetaURLContext, documentIDs: [String]) throws -> [String]
    /// Whether a `download_completed` path may reach the model. Only `true` shows it.
    func isPathVisible(_ path: String) throws -> Bool
}

/// What `confirm` receives about the browser call awaiting approval (`BetaConfirmContext`): the member, its parsed
/// input, the `tool_use` block being answered, and, through `tabID` and `tabURL`, the tab the call targets (the
/// active tab when it names none) as of the last `browser_state` report the SDK collected, with no page read. Both
/// are `nil` when that report has no such tab (anything before the first). `tabURL` is the URL as the model read it:
/// the driver's string, folded to one line and held to 4,096 characters. `input` holds a `file_upload`'s paths and
/// document ids as the file policy returned them, and a `navigate` history word in lower case.
public struct BetaConfirmContext: Sendable, Hashable {
    public var toolUse: BetaToolUseBlock?
    public var member: BetaBrowserMemberName
    public var input: BetaBrowserMemberInput
    public var tabURL: String?
    public var tabID: String?

    public init(toolUse: BetaToolUseBlock? = nil, member: BetaBrowserMemberName, input: BetaBrowserMemberInput,
                tabURL: String? = nil, tabID: String? = nil)
    {
        self.toolUse = toolUse
        self.member = member
        self.input = input
        self.tabURL = tabURL
        self.tabID = tabID
    }
}

/// The browser toolset's `confirm` callable: return `true` to run the call; `false`, or a thrown error, refuses it.
public typealias BetaConfirmCallable = @Sendable (BetaConfirmContext) async throws -> Bool

/// What the computer toolset's `confirm` callable is told about the call awaiting approval: the member, its parsed
/// input, and the `tool_use` block being answered (`BetaComputerConfirmContext`).
public struct BetaComputerConfirmContext: Sendable, Hashable {
    public var toolUse: BetaToolUseBlock?
    public var member: BetaComputerMemberName
    public var input: BetaComputerMemberInput

    public init(toolUse: BetaToolUseBlock? = nil, member: BetaComputerMemberName, input: BetaComputerMemberInput) {
        self.toolUse = toolUse
        self.member = member
        self.input = input
    }
}

/// The computer toolset's `confirm` callable.
public typealias BetaComputerConfirmCallable = @Sendable (BetaComputerConfirmContext) async throws -> Bool
