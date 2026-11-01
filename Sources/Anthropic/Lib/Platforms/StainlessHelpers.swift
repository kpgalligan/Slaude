import Foundation

/// Port of `lib/_stainless_helpers.py`: tracking of SDK helper usage via the `x-stainless-helper` header.

/// Telemetry header naming the SDK helper(s) a request came from. Always this lowercase form.
public let STAINLESS_HELPER_HEADER = "x-stainless-helper"
/// Telemetry header naming the SDK method (e.g. `stream`) in use.
public let STAINLESS_HELPER_METHOD_HEADER = "x-stainless-helper-method"
/// Telemetry header naming the streaming surface (e.g. `beta.messages`).
public let STAINLESS_STREAM_HELPER_HEADER = "x-stainless-stream-helper"
public let HELPER_METHOD_STREAM = "stream"

/// The closed set of helper telemetry tags, shared verbatim across SDKs (`StainlessHelperHeaderValue`).
public enum StainlessHelper: String, Sendable, CaseIterable {
    case betaMessagesParse = "beta.messages.parse"
    case betaToolRunner = "BetaToolRunner"
    case browserToolset = "browser-toolset"
    case compaction = "compaction"
    case computerToolset = "computer-toolset"
    case environmentsWorkPoller = "environments-work-poller"
    case environmentsWorker = "environments-worker"
    case fallbackRefusalMiddleware = "fallback-refusal-middleware"
    case mcpContent = "mcp_content"
    case mcpMessage = "mcp_message"
    case mcpResourceToContent = "mcp_resource_to_content"
    case mcpResourceToFile = "mcp_resource_to_file"
    case mcpTool = "mcp_tool"
    case messageThread = "message-thread"
    case messagesParse = "messages.parse"
    case sessionToolRunner = "session-tool-runner"
}

/// The `x-stainless-helper: <value>` header layer, for `mergeHeaders` or `extraHeaders:`.
public func helperHeader(_ value: StainlessHelper) -> Headers {
    [STAINLESS_HELPER_HEADER: .value(value.rawValue)]
}

/// A value created by a named SDK helper (Python's `tag_helper` attribute; Swift values carry the
/// tag explicitly).
public protocol StainlessHelperTagged {
    var stainlessHelper: StainlessHelper? { get }
}

/// A value paired with the helper that created it.
public struct HelperTagged<Value>: StainlessHelperTagged {
    public var value: Value
    public var stainlessHelper: StainlessHelper?
    public init(_ value: Value, helper: StainlessHelper?) {
        self.value = value
        self.stainlessHelper = helper
    }
}

extension HelperTagged: Sendable where Value: Sendable {}

/// Deduplicated helper names from tagged tools and messages, in first-seen order (`collect_helpers`).
public func collectHelpers(_ items: [Any]) -> [String] {
    var helpers: [String] = []
    for item in items {
        if let tag = (item as? StainlessHelperTagged)?.stainlessHelper?.rawValue, !helpers.contains(tag) { helpers.append(tag) }
    }
    return helpers
}

/// The `x-stainless-helper` header for tagged items, or an empty layer (`stainless_helper_header`).
public func stainlessHelperHeader(_ items: [Any]) -> Headers {
    let helpers = collectHelpers(items)
    if helpers.isEmpty { return [:] }
    return [STAINLESS_HELPER_HEADER: .value(helpers.joined(separator: ", "))]
}

/// The headers whose values accumulate (`", "`-joined) across layers instead of being replaced.
public var appendHeaderNames: Set<String> { appendHeaders }
